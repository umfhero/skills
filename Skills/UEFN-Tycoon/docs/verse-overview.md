# SimpleLowPolyTycoon — Verse Scripting System Overview

Scope: the 22 `.verse` files in
`C:\Users\umfhe\Documents\Fortnite Projects\MCSkyblockTycoon\Plugins\SimpleLowPolyTycoon\Content\`
(the `MCSkyblockTycoon` / `Skyblock` experience).

This document is a companion to `verse-dependencies.md` (the dependency and
device-reference map). It is written to let another agent extend or rework the
scripting without re-reading every file.

---

## 1. Architecture summary

The plugin implements a **Skyblock-style incremental tycoon**. A player claims a
floating plot, then works through a linear (or branching) chain of purchasable
upgrades ("Tycoon Nodes"). Each upgrade costs gold, adds to the player's gold
per second (GPS), reveals props, and unlocks the next upgrade. Gold accrues in a
pool and is granted to the player's inventory by standing at a claim point.
Players can periodically **rebirth** (prestige): reset all purchases while
keeping a multiplicative earning bonus that permanently persists.

All Verse execution in UEFN runs **server-side**; clients receive UI, props,
devices and NPCs through normal Fortnite replication. Nearly every device keeps
per-player state in `[player]...` or `[agent]...` maps and exposes it through
per-player UI widgets.

### 1.1 The three layers

| Layer | Files | Role |
|---|---|---|
| **Core tycoon loop** | `tycoon_currency_manager.verse`, `pressure_plate_with_generator.verse`, `plot_claim_device.verse`, `UI_Trackers.verse` | currency, purchases, plot ownership, persistence, HUD |
| **Event / gameplay layer** | `event_manager.verse`, `color_switch.verse`, `king_of_the_hill.verse` | timed minigame events awarded in gold |
| **Side features** | `pets_device.verse`, `giftbox_device.verse`, `gun_store.verse`, `SpaceStage.verse`, `playtimerewards.verse`, `playtime_award_manager.verse`, `chicken_animations.verse`, `subtle_chicken_animations.verse`, `generic_animation_device.verse`, `GiantBehavior.verse`, `Skeletons.verse`, `BehaviorHelper.verse`, `intro.verse`, `respawn_backup.verse`, `GoldTracker.verse` | cosmetics, monetisation, ambient life, AI mobs, safety nets |

### 1.2 The core loop (data flow)

```
plot_claim_device          pressure_plate_with_generator        tycoon_currency_manager
────────────────          ───────────────────────────────        ───────────────────────
Player stands near        OwningPlayers registered,             holds GoldPerSecond,
ClaimProp → claimed        activity: inactive/purchased/active   StoredGold, UsableMultiplier,
→ AddPlayerToPlot()        on plate press with enough gold:      RebirthCount
   │                        purchase → SavePurchase()            grants via GrantGold()
   │                        → AddToGoldPerSecond() ──────────►   (item granter, 10^0..10^9)
   │                        → ShowAndHide() props                CheckClaim() pays out
   │                        → activate next node(s)              StoredGold at claim props
   ▼                                                            AddToStoredResources()
player_save_data (persistable, weak_map by player)  ◄─────────  every tick
   Rebirths, Multiplier, ActivityMap[int]int (0/1/2),           rebirth: ClearOldNumbers,
   SecondsActive, NodeSaveSchemaVersion                         BackToStart → first node
                                                                 UI_Trackers HUD + map
```

### 1.3 Key design decisions and conventions

- **Tag-based discovery.** Devices that must find each other without an explicit
  reference use `FindCreativeObjectsWithTag`. Tags defined in Verse: `gold_currency_manager`,
  `purchase_audio`, `tycoon_node`, `creature_spawner_tag`, `gold_remover_tag`,
  `rebirth_count_tracker`, `earning_multiplier_tracker`, `stage_saving_tracker`,
  `ui_system_tag`, `gold_counter_tag`. See `verse-dependencies.md` for the tag map.
- **Persistence** is a single global `weak_map(player, player_save_data)` named
  `PlayerProfileDataMap` declared at file scope in `pressure_plate_with_generator.verse`.
  `player_save_data` is `persistable`; it stores rebirths, multiplier, an activity
  map keyed by a node "persistence key", and seconds active. Every device that
  needs save data reads/writes this one map.
- **Two ways to chain nodes.** (a) explicit `CommonlyUsed.NextManagers` device
  references, or (b) automatic spatial chaining: a node tagged `tycoon_node`
  finds the nearest untagged-to-it node further along the map's `+Y` axis.
  This lets MCP duplicate a tagged node without wiring device references.
- **Node identity / save keys.** Legacy nodes use a dynamic `PlateIndex` (assigned
  by graph traversal via `GetAndIncrementIndex`). Newer nodes can opt into a stable
  `StableNodeId` so saved state survives graph edits. `GetPersistenceKey()` chooses
  between them. `MigrateLegacyNodeStates` repairs impossible v0 save states once per player.
- **Gold as inventory items.** The currency manager grants gold through an
  `item_granter_device` configured with 10 gold-denomination items (1, 10, 100, 1k,
  10k, 100k, 1M, 10M, 100M, 1B). Cost is deducted via a shared `conditional_button_device`.
  `GetItemCount` is used to read current gold for the HUD and the map indicator.
- **Co-op support.** Plots have `OwningPlayers` arrays; `MaxPlayersPerPlot` (1 on
  plates) is not enforced at the currency-manager level. `GrantGold` deliberately
  grants the pool to the first claiming player rather than duplicating for every
  co-owner (see comment in `CheckClaim`).
- **Multiplayer UI.** Every persistent widget is created per `agent`/`player` and
  stored in a per-agent map (`...PerAgent`, `...Map`). Refresh loops `Sleep` and
  update text blocks; overlays are added/removed from `GetPlayerUI[Player]`.

---

## 2. File-by-file reference

Files are listed alphabetically. For each: purpose, exported types, key members,
device references, in-set dependencies, and multiplayer notes.

---

### 2.1 `BehaviorHelper.verse`

**Purpose.** A tiny shared helper for NPC behaviours. Exposes a utility that
finds the nearest living player to a given Fort character — used so NPCs aggro
the closest human rather than a fixed target.

**Exported types / functions**
- `BehaviorHelper : class(creative_device)`
  - `FindNearestTarget(FC : fort_character)<decides><transacts> : fort_character` — scans all playspace players and returns the closest one to `FC` (default search radius 1000), excluding `FC` itself.

**Key member variables.** `(none — stateless helper, only local var CheckRange/MaybeTarget)`

**UEFN devices referenced.** None.

**Dependencies on other files.** None (in-set).

**Multiplayer logic.** Directly iterates `GetPlayspace().GetPlayers()`; returns a
character reference so callers can navigate/focus/damage.

---

### 2.2 `chicken_animations.verse`

**Purpose.** Ambient animation device that makes decorative chicken props wander
randomly inside a bounded rectangle defined by corner props. Chickens pick a
random target, rotate towards it, move, and avoid crowding each other. Includes a
"uniform heading" mode where all chickens face one yaw and walk forward.

**Exported types / functions**
- `chicken_animations : class(creative_device)`
  - `OnBegin<override>()<suspends>` → `Activate()` → spawns a `MoveAround` loop per chicken.
  - `MoveAround(Index : int, Chicken : creative_prop)<suspends>` — main wander loop using `keyframe_delta` frames and the prop's animation controller.

**Key member variables.** `Chickens : []creative_prop`, `CornerProps : []creative_prop` (bounding box), `MaxTime`/`MinTime` (move duration), `RotateSpeedDegPerSec`, `WalkSpeed`, `MoveToRotateTimeRatio`, `MinDistanceBetweenChickens`, `ForceUniformHeading : logic`, `UniformYawDegrees`, `RespectBounds`, `MoveChance : int`, `TimeBetweenChances`.

**UEFN devices referenced.** `creative_prop` props + their animation controllers (`/Fortnite.com/Devices/CreativeAnimation`).

**Dependencies.** None in-set.

**Multiplayer logic.** None — purely cosmetic, server-driven, no player interaction.

---

### 2.3 `color_switch.verse`

**Purpose.** A `game` minigame: players must stand on the tile colour announced
on billboards. Non-selected colours' tiles are hidden each round; the last player
standing wins. Rounds get shorter and randomisation faster as play proceeds.

**Exported types / functions**
- `color_info : class<concrete>` — editable colour definition (`ColorName`, `AllTilesOfThisColor`, `RepresentativeImages`).
- `color_switch : class(game)` (base class `game` is defined in `event_manager.verse`)
  - `StartGame<override>()<suspends>`, `EndGame<override>()<suspends>`, `EndGameWin<override>(Player)<suspends>`, `OnBegin`.
  - `RandomColor()`, `SetColor(Color)`, `ResetTiles()`, `Format(Num : float)`.

**Key member variables.** `PlayAreaMutatorZone : mutator_zone_device`, `ColorBillboards / MessageBillboards / TimeBillboards : []billboard_device`, `AllColors : []color_info`, `TriggerDevices : []trigger_device` (commented out), `CountdownToStartGame`, `StartingPrepTime`, `TimeDecreasePerRound`, `RandomizeRate`, `EndGameWhenThisManyPlayersRemain`, `var RemainingPlayers`, `var Participants` (from base `game`).

**UEFN devices referenced.** `mutator_zone_device` (removes players who leave the area), `billboard_device`, `trigger_device`, `creative_prop` tiles (Show/Hide).

**Dependencies.** `event_manager.verse` (base `game` class). Indirectly uses `RemainingPlayers`/`Participants` inherited from `game`.

**Multiplayer logic.** `Participants` are seeded from the base class when `StartGame` runs; `RemainingPlayers` shrinks via the mutator zone; winner is `RemainingPlayers[0]`.

---

### 2.4 `event_manager.verse`

**Purpose.** The event subsystem core. Defines the abstract `game` base class
that every minigame subclasses, and the `event_manager` device that runs a
repeating, randomised schedule of events (first event after a short delay, then
every few minutes), teleports participants into the event via portal mutator
zones, and pays out gold based on each player's tycoon earning rate.

**Exported types / functions**
- `player_info : class` — `Player : player`, `CurrencyManager : tycoon_currency_manager`, `ReturnLocation : vector3`, `ReturnRotation : rotation` (used to send players back to their plot).
- `game : class(creative_device)` — **the minigame base class.**
  - Members: `EventName`, `GameTeleportLocation`, `GameTeleportRotation`, `Participants : []player`, `RemainingPlayers : []player`, `OnlyEventManager : []event_manager`.
  - `StartGame()<suspends>`, `EndGame()<suspends>`, `EndGameWin(Player)<suspends>`, `AddPlayerToGame(Player)`, `AdditionalAddBehavior(Player)`, `GetPlayerManager(Player)<decides><transacts>:tycoon_currency_manager`.
  - `EndGame`/`EndGameWin` call back into `OnlyEventManager[0]` → `AwardParticipation` / `AwardWin` / `AllowNextGame`.
- `event_manager : class(creative_device)`
  - `OnBegin` subscribes portal zones, wires `AllEvents[*].OnlyEventManager = {Self}`, spawns `ActivateEvents()`.
  - `StartGameLoop()<suspends>` — countdowns, HUD announcements, then `CurrentEvent.StartGame()`, with a force-end watchdog (`MaxEventTimeBeforeForceEnd`).
  - `OnEnteredPortal(Agent)` — finds the plot the player owns (via `plot_claim_device` and pressure-plate `OwningPlayers`), records `player_info`, teleports them to the current event.
  - `AwardWin(Winner, Players)`, `AwardParticipation(Players)` — round `GoldPerSecond × ParticipationAward (× AwardMultiple for winner)` and `GrantGold`; teleport back to plot.

**Key member variables.** `PlayerInfoMap : [player]player_info`, `OnlyPlotClaimDevice : []plot_claim_device`, `PortalMutatorZones : []mutator_zone_device`, `HudMessager : hud_message_device`, `AllEvents : []game`, `AwardMultiple : float`, `ParticipationAward : float`, `TimeBeforeFirstEvent / TimeBetweenEvents / TimeToShowStartingMessage`, `MaxEventTimeBeforeForceEnd`, `CurrentEvent : game`, `EventsThisSession`, `GameEndedEvent : event()`.

**UEFN devices referenced.** `mutator_zone_device` (portals), `hud_message_device`, plus everything routed through `plot_claim_device` and `tycoon_currency_manager`.

**Dependencies.** `tycoon_currency_manager.verse` (type + `GrantGold`/`GoldPerSecond`), `plot_claim_device.verse` (`ClaimedPlots`, `SpawnReturnLocation/Rotation`, `FirstPressurePlateDeviceOnly`), `pressure_plate_with_generator.verse` (`OwningPlayers`, `MainTycoonManager`). **Defines `game`, which `color_switch` and `king_of_the_hill` subclass.**

**Multiplayer logic.** Per-player `player_info` capture, per-player teleport in/out, participant arrays, `PlayerAddedEvent`-driven HUD announcements. All event state is server-side.

---

### 2.5 `generic_animation_device.verse`

**Purpose.** A reusable prop-animation driver. Reads start/end transforms from
key prop pairs (`KeyLocationInfo`) and plays looping or one-shot keyframe
animations on the target props, with per-keyframe easing/curves. Used by the
tycoon nodes to play showpiece animations (windmills, harvesters, etc.). Also
supports "manual" move/return animations and a session-wide speed multiplier.

**Exported types / functions**
- `animation_curve : class<concrete>` — editable cubic-bezier bounce curve (`X0,Y0,BounceTime,BounceScale`, `Curve():cubic_bezier_parameters`).
- `keyframe_info : class<concrete>` — `Prop`, `Time`, `MovementType`, `CustomCurve`.
- `movement_type : enum{Linear_Movement, Ease_Movement, EaseIn_Movement, EaseOut_Movement, EaseInOut_Movement, UseCustomCurve}`.
- `manual_animation_settings : class<concrete>`.
- `generic_animation_device : class(creative_device)`
  - Public API consumed by other files: `StartAnimating(TriggeringDeviceInfo)`, `StopAnimating()`, `ToggleAnimation(MaybeAgent, Info)`, `UpdateSpeed(Speed)`.
  - `ActivationSequence`, `StartAnimation`, `ManualAnimation`, `ReverseManualAnimation`, `CarefullyHide`/`ActualHide` internals.

**Key member variables.** `AnimationName`, `StartByDefault`, `UseManualMovement`, `PropsToMove : []creative_prop`, `KeyLocationInfo : []keyframe_info`, `DelayBetweenStarts`, `TimeBeforeFirstStart`, `HideHeightChange`, `StartingPosMap : [int]transform`, `KeepAnimating`, `SessionSpeedMultipleMap` (file-scope `weak_map(session,[int]float)` shared by all instances).

**UEFN devices referenced.** `creative_prop` + animation controllers; `animation_mode.OneShot` keyframe playback.

**Dependencies.** None in-set (standalone library). **Consumed by** `pressure_plate_with_generator.verse` (`AnimationsToPlay/Stop`, `animation_curve`).

**Multiplayer logic.** None directly; prop movement is server-authoritative. Speed map is keyed by session, shared across all devices.

---

### 2.6 `GiantBehavior.verse`

**Purpose.** NPC behaviour for a "Giant" mob: finds the nearest player, focuses,
navigates (running), plays an attack animation, and deals melee damage in range.

**Exported types / functions**
- `GiantBehavior<public> : class(npc_behavior)` — `OnBegin<override>()<suspends>`, `OnEnd<override>()`.

**Key member variables.** `BehaviorHelp : BehaviorHelper`, `Attack1 : animation_sequence` (from `MobZombie` assets), `HealthMultiplier : float = 5.0`, `MaxShieldAmount : float = 100.0`.

**UEFN devices referenced.** `MobZombie` animation asset; NPC character interfaces (`GetNavigatable`, `GetFocusInterface`, `GetPlayAnimationController`).

**Dependencies.** `BehaviorHelper.verse` (`FindNearestTarget`).

**Multiplayer logic.** Targets the nearest real player; damage applied to their Fort character.

---

### 2.7 `giftbox_device.verse`

**Purpose.** Daily-gift style boxes on each plot. Interacting with the gift-box
button opens a full-screen canvas listing timed gifts (12 reward tiles). Counts
down each gift's timer; when a timer reaches zero the device grants the matching
item and marks it claimed. Only the player who owns the closest plot can claim.

**Exported types / functions**
- `giftbox_device : class(creative_device)`
  - `OnBegin` builds the 4-stage box animation keyframes (wait → up → slam down → settle) and subscribes spawn/button events.
  - `OnGiftBoxButtonInteracted(Agent)` → `PlayerIsValid` → shows canvas, grants immediately-ready gifts.
  - `AsyncTickPerSecond()` — per-second countdown; at 0 sets text to ✔ and grants via `GiftGranter.SetNextItem(I).GrantItem(Player)`.
  - `GetClosestPlotManager():?tycoon_currency_manager` — spatial search over `FindCreativeObjectsWithTag(gold_currency_manager{})`.
  - `PlayerIsValid(Agent)` — checks the closest manager's `OwningPlayers`.
  - `CreateGiftBoxCanvas():canvas` — builds the whole 800×800 reward grid (textures `Textures.GiftBoxBackground`, `Textures.Chest1..5`, `Textures.Wait`, `Textures.Claimed`).

**Key member variables.** `PlayerSpawners : []player_spawner_device`, `GiftBoxProp : creative_prop`, `GiftBoxButton : button_device`, `GiftGranter : item_granter_device`, `GiftBoxDurations : []int`, `GiftBoxCanvasPerAgent : [agent]canvas`, `GiftBoxDurationsPerAgent : [agent][]int`, slot index bookkeeping (`GiftTextStart/EndIndex`, `GiftImageStart/EndIndex`), `ClosestPlotManager : ?tycoon_currency_manager` (cached).

**UEFN devices referenced.** `player_spawner_device`, `button_device`, `item_granter_device`, `creative_prop`, UMG widgets (`canvas`, `text_block`, `texture_block`, `button_quiet`).

**Dependencies.** `tycoon_currency_manager.verse` (type + `OwningPlayers`), `pressure_plate_with_generator.verse` (the `gold_currency_manager` tag class), `playtimerewards.verse` (the shared `Textures` module namespace populated by the Giftbox asset digest).

**Multiplayer logic.** Fully per-agent: canvas and duration maps keyed by `agent`; grant only fires for the plot owner; uses `player_spawner_device.SpawnedEvent`.

---

### 2.8 `GoldTracker.verse`

**Purpose.** Legacy / minimal gold HUD. Reads the player's gold count from a
conditional button and shows "Gold: $X" in a text block, refreshed on a timer.

**Exported types / functions**
- `gold_counter_tag : class(tag){}`
- `GoldTracker : class(creative_device)` — `GetGold(Agent):int`, `RefreshUI(Agent)`, `MakeCanvas(Agent):canvas`, `AssignUI`.

**Key member variables.** `PlayerSpawners : []player_spawner_device`, `RefreshRate : float = 0.1`, `ConditButton : conditional_button_device`, `ResourceTextBlockPerAgent : [agent]?text_block`.

**UEFN devices referenced.** `player_spawner_device`, `conditional_button_device`.

**Dependencies.** None in-set (self-contained legacy HUD; superseded by `UI_Trackers`).

**Multiplayer logic.** Per-agent UI assignment on spawn event.

---

### 2.9 `gun_store.verse`

**Purpose.** Two-tier weapon store. (1) **V-Bucks guns**: Machine Gun (50 VB) and
Rocket Launcher (100 VB) sold as permanent Marketplace entitlements; the device
grants the weapon whenever the player owns the entitlement (on join and on
purchase/refund). (2) **Coin guns**: Pistol, Assault Rifle and SCAR bought with
in-game gold through `conditional_button_device` (configured in UEFN to require
gold counts 500 / 1500 / 3000), each tied to an `item_granter_device`.

**Exported types / functions**
- `GunInfo<public> : module` — localised gun names/descriptions.
- `GunEntitlements<public> : module` — `gun_entitlement<public> : class<abstract><castable>(entitlement)`, `machine_gun_access`, `rocket_launcher_access` (concrete subclasses).
- `GunOffers<public> : module` — `entitlement_offer` subclasses with `MakePriceVBucks(50.0 / 100.0)`.
- `gun_store : class(creative_device)` — `OnPlayerJoin`/`OnPlayerLeft` subscribe entitlement-change events; `GrantOwnedGunsOnJoin` walks owned entitlements and grants; `ShowGunStoreDialog` calls `ShowOffersDialog`; coin purchases handled by `OnPistolPurchased`/`OnAssaultRiflePurchased`/`OnScarPurchased`.

**Key member variables.** `VBucksStoreButton : button_device`, `MachineGunGranter / RocketLauncherGranter : item_granter_device`, `PistolButton / AssaultRifleButton / ScarButton : conditional_button_device`, matching `...Granter : item_granter_device`, `EntitlementChangeSubscription : [player]?cancelable`, join/left subscriptions.

**UEFN devices referenced.** `button_device`, `item_granter_device`, `conditional_button_device`, Marketplace API (`GetEntitlementsChangedEvent`, `GetPurchasedEntitlements`, `ShowOffersDialog`, `entitlement`/`entitlement_offer`).

**Dependencies.** `SpaceStage.verse` — uses the `A_MCSkyblock.market.moonpass` texture via the `<public>` module declared there (icon placeholder).

**Multiplayer logic.** Subscribes `PlayerAddedEvent`/`PlayerRemovedEvent` and per-player entitlement change events; catches up players who joined before `OnBegin` (same pattern as `SpaceStage`).

---

### 2.10 `intro.verse`

**Purpose.** Shows a full-screen intro texture for a few seconds after a player
spawns on the configured spawn pad.

**Exported types / functions**
- `intro_system : class(creative_device)` — `OnBegin` subscribes to `SpawnPad.SpawnedEvent`; `ShowIntroTexture(Agent)` builds an `overlay` with `UI.intro` at maximum `ZOrder`, sleeps, then removes it.

**Key member variables.** `SpawnPad : player_spawner_device`, `IntroDisplayTime : float = 5.0`, `PlayerIntroMap : [agent]?player_ui`.

**UEFN devices referenced.** `player_spawner_device`, UMG overlay/texture; asset `UI.intro` (from `/majid@fortnite.com/MCSkyblockTycoon`).

**Dependencies.** External module `/majid@fortnite.com/MCSkyblockTycoon` (same module `UI_Trackers` uses). No in-set Verse dependency. Contains a copyright header.

**Multiplayer logic.** Per-agent; spawn-driven.

---

### 2.11 `king_of_the_hill.verse`

**Purpose.** A `game` minigame: players fight over a capture area. The last
player to capture it when the timer ends wins. Eliminated players respawn on
cycling spawn props. Players earn gold based on their tycoon GPS for each capture
(`AreaIsScoredEvent`).

**Exported types / functions**
- `king_of_the_hill : class(game)` (base from `event_manager.verse`)
  - `StartGame<override>()<suspends>` → `CaptureArea.AllowCapture()` + `EventTimer()`.
  - `EndGame<override>()<suspends>` → neutralize/disallow capture, cancel subscriptions, `EndGameWin(LastToCapture[0])`.
  - `GrantDuringGame(Agent)` — `Round[Manager.EffectiveGoldPerSecond() * EarningsAmountDuringGame]` → `Manager.GrantGold`.
  - `RespawnPlayer(Result)` / `CheckPlayerSpawn` / `TryAgainCheckPlayerSpawn` — respawn/teleport cycling `SpawnLocationProps`.
  - `AdditionalAddBehavior<override>(Player)` — subscribes `Char.EliminatedEvent()` for respawns.

**Key member variables.** `CaptureArea : capture_area_device`, `EventTimeMins`, `EarningsAmountDuringGame`, `SpawnLocationProps : []creative_prop`, `RespawnHeightAddition`, `LastToCapture : []player`, `ThingsToCancel : []cancelable`.

**UEFN devices referenced.** `capture_area_device`, `creative_prop` spawn points; character `EliminatedEvent`.

**Dependencies.** `event_manager.verse` (base `game`, `GetPlayerManager`), `tycoon_currency_manager.verse` (`EffectiveGoldPerSecond()`, `GrantGold`).

**Multiplayer logic.** Participants tracked in the base class; per-player spawn cycling and respawn handling; gold grants keyed to the capturing player.

---

### 2.12 `pets_device.verse`

**Purpose.** Cosmetic companion pets bought with **rebirth levels** (not gold).
Each pet purchase slot has a required rebirth level and a set of pet props; a pet
follows its owner, idles with a hover animation when close, and teleports back to
the owner when far away. One active pet per player; props are freed back to the
pool when a player leaves.

**Exported types / functions**
- `agent_data : class` — per-player pet state (`OwnedPets : []tuple(creative_prop, int)`, `ActivePetIndex`, `bPetPlayingAnim`, `bPetContinuousHover`).
- `pet_purchase_data : class<concrete>` — `ButtonForPurchase : button_device`, `RequiredRebirthLevel : int`, `PetProps : []creative_prop`, internal `Index`, `MaybeMainDevice`, `AvailablePetProps : []logic`; `OnPurchase(Agent)` forwards to the main device.
- `pets_device : class(creative_device)`
  - `OnPetPurchase(Agent, Data)` — checks rebirth level via `GetPlayerRebirthLevel` (reads `PlayerProfileDataMap[Player].Rebirths`), switches active pet, starts hover animation.
  - `AsyncPetFollow()` — global loop; moves pets that fall behind (≥200 units) and resumes hover.
  - `StartContinuousHover`, `MovePetAndRestartHover`, `OnPlayerLeft` (frees props).

**Key member variables.** `TycoonCurrencyManager : tycoon_currency_manager` (editable, unused for currency here), `NotEnoughRebirthsHudMessage / PetPurchaseConfirmedHudMessage : hud_message_device`, `PlayerSpawners : []player_spawner_device`, `PetPurchasesData : []pet_purchase_data`, `AgentMap : [agent]agent_data`, idle/hover keyframe arrays.

**UEFN devices referenced.** `button_device`, `hud_message_device`, `player_spawner_device`, `creative_prop` + animation controllers.

**Dependencies.** `pressure_plate_with_generator.verse` (file-scope `PlayerProfileDataMap`, `player_save_data`), `tycoon_currency_manager.verse` (type in editable field).

**Multiplayer logic.** Fully per-agent maps; pet props are hidden/shown per owner; `PlayerRemovedEvent` frees pool slots.

---

### 2.13 `playtimerewards.verse`

**Purpose.** "Playtime rewards" gift panel: a button opens a full UMG shop of
reward tiles, each with its own playtime cooldown. A compact HUD alert shows the
number of gifts waiting and the nearest cooldown. Claiming fires the reward's
`trigger_device` and shows a "YOU RECEIVED" overlay.

**Exported types / functions**
- `Textures<public> : module` — empty module declaration that seeds the `Textures` namespace (shared with `giftbox_device.verse`; populated by the Giftbox asset digest).
- `playtime_hud_component` / `playtime_component` — per-player UI/state classes.
- `playtime_reward_unlock : class<concrete>` — `ClaimTrigger : trigger_device`, `PlaytimeSeconds`, `RewardReceivedText`, `RewardReceivedTextColor`.
- `custom_playtime_margin : struct<concrete>`.
- `playtime_reward_device : class(creative_device)`
  - `StartRewardsCountdown(Agent)` — per-second loop computing remaining times (`RewardTimes`), signals `UpdateTimes`, updates HUD.
  - `CreateHUD` / `CreateUI` / `AwaitClaimNow` — UMG construction and claim flow (`PlayReward.ClaimTrigger.Trigger(Agent)`).
  - `playtime_reward_button : class` — reusable textured button widget (background, icon, text, clickable).
- File-scope `Format` is **not** here; `playtimerewards` uses its own inline time formatting.

**Key member variables.** `PlaytimeRewardsList : []playtime_reward_unlock`, `ShowPlaytimeRewardsButton/2 : button_device`, colour tunables (HeaderColor, BackgroundColor, ClaimNowButtonColor, …), `ShowGiftAlertHud`, `GiftAlertHudAnchors/Offset`, `PlaytimeHudPerAgent`, `PlaytimePerAgent`.

**UEFN devices referenced.** `button_device`, `trigger_device`, UMG widgets (canvas, overlay, stack_box, texture_block, text_block, button_quiet); textures from the `Giftbox` asset folder.

**Dependencies.** In-set: none directly, but its `Textures<public>` module namespace is consumed by `giftbox_device.verse`. Uses `Giftbox.*` asset textures only.

**Multiplayer logic.** Fully per-agent UI maps; joins/removals handled via `PlayerAddedEvent`/`PlayerRemovedEvent` with cleanup loops that rebuild maps (`ConcatenateMaps`).

---

### 2.14 `playtime_award_manager.verse`

**Purpose.** Awards a duo of **accolades** at fixed playtime milestones (default
20 and 30 minutes). Renders two progress-bar textures (green/blue on grey) that
fill with playtime on a custom-positioned canvas.

**Exported types / functions**
- `playtime_award_manager : class(creative_device)`
  - `CountPlaytime()<suspends>` — 1 Hz loop; increments `PlaytimeMap[Player]`; awards `Accolade1` when `Mod[Time, 60*FirstMins] = 0`, `Accolade2` likewise.
  - `GenerateWidget(Player)` / `UpdateUI(Player)` — builds and resizes the two bars.

**Key member variables.** `PlaytimeMap : [player]int`, `UiMap : [player]tuple(texture_block, texture_block)`, `Accolade1/2 : ?accolades_device`, `PositionFromTopLeft : vector2`, `FirstMins/SecondMins`, `XMultiple/YMultiple`, `MinSizeX/MaxSizeX/SizeY`.

**UEFN devices referenced.** `accolades_device`, textures from the `XP_UI` asset folder (`GreenLoadingBar`, `GreyLoadingBar`, `BlueLoadingBar`, `PlaytimeUIBackground`).

**Dependencies.** None in-set (standalone; it maintains its own `PlaytimeMap` independent of `player_save_data.SecondsActive`).

**Multiplayer logic.** Iterates all playspace players each tick; per-player widget map.

---

### 2.15 `plot_claim_device.verse`

**Purpose.** Plot ownership. A player who stands close to a plot's claim prop
is assigned that plot; they are teleported onto it, the first pressure plate in
the chain is registered as theirs, and claim/show props are swapped. If the owner
leaves the game the plot is unclaimed after a 15 s grace period. Also provides
dev-debug toggles for the `TryPrint`/`ChecklistPrint` global helpers.

**Exported types / functions**
- File-scope: `var AllowPrint/AllowChecklist : weak_map(session, logic)`, `TryPrint(String, ?Duration)`, `ChecklistPrint(String, ?Duration)`.
- `first_pressure_plate_assignment : class<concrete>` — the claim-to-plot mapping: `ClaimProp`, `HideProp`, `ShowProp`, `TimeToSwap`, `FirstPressurePlateDeviceOnly : []pressure_plate_with_generator`, `OptionalTeleportLocationOverride : []transform`, `Value : int` (plot number); `SwapOnClaim()`, `SwapOnUnclaim()`, `Unclaim()<suspends>` (calls `Plate.ResetEverythingForAll()`).
- `unclaim_helper : class` — subscribes `PlayerRemovedEvent`; after 15 s confirms the player is gone before calling `PCD.UnclaimPlot(PlotInfo)`.
- `plot_claim_device : class(creative_device)`
  - `OnBegin` — sets debug flags, subscribes player add/remove, portal zones, debug buttons, seeds `UnclaimedPlots` with `Value`s, spawns `CheckPlotClaim()`.
  - `CheckPlotClaim()<suspends>` — 0.2 s loop; assigns players to plots, moves them `UnassignedPlayers → AssignedPlayers`, calls `OnClaim`.
  - `UnclaimPlot(PlotInfo)`, `ReturnPlayerToPlot(Agent)`, `TeleportToPlot(Player, Plate, PlotInfo)`.

**Key member variables.** `ClaimToPlotAssignments : []first_pressure_plate_assignment`, `DistToClaim : float`, `PlotGroundHeight`, `OptionalPortalMutatorZone : []mutator_zone_device`, `SpawnReturnLocation/Rotation`, `TogglePrintingButton/ToggleCheckListButton : button_device`, `UnclaimedPlots/ClaimedPlots/UnassignedPlayers/AssignedPlayers`.

**UEFN devices referenced.** `mutator_zone_device`, `button_device`, `creative_prop` (claim/show/hide props), pressure plates via `pressure_plate_with_generator`.

**Dependencies.** `pressure_plate_with_generator.verse` (`AddPlayerToPlot`, `ResetEverythingForAll`, `OwningPlayers`, `MainTycoonManager`, `CommonlyUsed.PressurePlate`). **Consumed by** `event_manager.verse`.

**Multiplayer logic.** Central claim registry; per-player plot assignment; ownership checked against `Plate.OwningPlayers`; unclaim only when a player is verifiably gone.

---

### 2.16 `pressure_plate_with_generator.verse`

**Purpose.** The **Tycoon Node** — the heart of progression. Each instance is
one purchasable upgrade: a (hidden until active) pressure plate with a cost, a
gold-per-second value, props to reveal/hide, price billboards, optional
cinematics and animations. A persistent, per-player `ActivityMap` records each
node's state (0 = inactive, 1 = purchased, 2 = active). Standing on an active
plate with sufficient gold triggers a purchase via the shared conditional button,
which banks the GPS with the currency manager, plays effects, and activates the
next node(s) in the chain.

**Exported types / functions (the largest file; also the persistence hub)**
- File-scope persistence: `var PlayerProfileDataMap : weak_map(player, player_save_data)`.
- `player_save_data : class<persistable><final>` — `Rebirths:int`, `Multiplier:float`, `ActivityMap:[int]int`, `SecondsActive:int`, `NodeSaveSchemaVersion:int`; functional update methods (`UpdateRebirths`, `UpdateMultiplier`, `UpdateActivityMap`, `AddToSecondsActive`, `UpdateNodeSaveSchemaVersion`).
- Tags: `gold_currency_manager`, `purchase_audio`, `tycoon_node`.
- Settings classes: `special_settings_classic` (`Name`, `StableNodeId`, `AccoladeIndexOverride`, `CutsceneToPlay/CinematicsToPlay/CinematicsToStop`, `ExtraCinematicChanges`, `StartAsActive`, `DistanceToPress`, `BillboardTextSettings`, `TimeToWaitAfterFailedPurchaseAttempt`), `commonly_used_settings` (`PressurePlate`, `PriceBillboards`, `GoldCost`, `GoldPerSecond`, `PropsToShow/PropsToHide`, `NextManagers`), `assets_and_animation_settings`, `sound_settings`, `animation_curves_settings`, `extra_cinematic_settings`, `billboard_text_settings`.
- Enums: `activity_type_classic : enum{purchased, active, inactive}`, `current_move_direction : enum{up, down, none}`.
- `pressure_plate_with_generator : class(creative_device)`
  - Lifecycle: `OnBegin` → `Activate()` → `InitPropPosMap()` → `InitBillboards()` → `Setup()` (tag discovery) → `StartingVisibilityAndActivitySettings()` → continuous plate-check loop (`CheckLocation`).
  - Purchase: `OnPlatePressed` → conditional-button `sync`/`race` on `ActivatedEvent`/`NotEnoughItemsEvent` → `MainTycoonManager.AwardNormalPurchase(...)` → `SuccessfulPurchase` → `SavePurchase()`, `AddToGoldPerSecond`, hide plate, `ShowAndHide()`, activate next managers.
  - State/save: `CheckSaveData`, `RecoverVisibilitySettings`, `RestoreSavedActivity`, `SavePurchase`, `SaveActive`, `GetPersistenceKey`, `MigrateLegacyNodeStates` (called by the manager).
  - Chaining: `GetAllManagers(Base)` (BFS traversal assigning `PlateIndex`), `GetNextManagers()` (explicit `NextManagers` else `GetAutomaticNextManagers()` — nearest `tycoon_node`-tagged node ahead on `+Y`), `SendPreviousMangers()`.
  - Prop animation: `(Prop).AnimateUp/Animatedown` + `AnimateUpProp/AnimateDownProp` keyframe helpers, `ShowAndHide`, `DefaultHidden/DefaultShown`, `ResetAnimations`, `FacePlayer` (billboards rotate to face the owner), `AttemptPurchaseAudio`.
  - Player management: `AddPlayerToPlot`, `ResetPlayers`, `ResetEverything/ForAll`, `BackToDefaultAll`, `DoubleCheckOwningPlayers`.

**Key member variables.** `CommonlyUsed`, `AssetsAndAnimation`, `Sound`, `AnimationCurves`, `SpecialSettings`, `MainTycoonManager : tycoon_currency_manager`, `ConditionalButton : conditional_button_device`, `GoldGranter : item_granter_device`, `OwningPlayers : []player`, `Activity : activity_type_classic`, `PlateIndex : int`, `PressurePlateIndex = 2000` (map key for the plate itself), `HideStartIndex/ShowStartIndex`, `PropPosMap : [int]vector3`, `MoveDirectionMap : [int]current_move_direction`, `PreviousManagers`, `StartupVisibilityReady`, `DelayToStartAutoAnimationsAfterRebirth`.

**UEFN devices referenced.** `creative_prop` (plate + show/hide props), `billboard_device`, `cinematic_sequence_device`, `audio_player_device`, `conditional_button_device`, `item_granter_device`, `generic_animation_device`, animation controllers; tag discovery for `gold_currency_manager`, `purchase_audio`, `tycoon_node`.

**Dependencies.** `tycoon_currency_manager.verse` (type; `SetOwningPlayers`, `AwardNormalPurchase`, `AddToGoldPerSecond`, `ShowNotEnoughGold`, `ConditionalButton`, `GoldGranter`, `GetAndIncrementIndex`), `generic_animation_device.verse` (`animation_curve`, `generic_animation_device.StartAnimating/StopAnimating`).

**Multiplayer logic.** Per-player persistence (`PlayerProfileDataMap`), `OwningPlayers` array (co-op plots), per-player purchase flow through the shared conditional button, per-owner audio/slam, save-state restore racing against early plot claims (`RecoverVisibilitySettings` waits on `StartupVisibilityReady`).

---

### 2.17 `respawn_backup.verse`

**Purpose.** Safety net: any player whose Z position exceeds a configured
ceiling (default 25000) is force-respawned to the configured location. Guards
against players falling out of the floating islands.

**Exported types / functions**
- `respawn_backup : class(creative_device)` — `RespawnPlayersThatAreTooHigh()<suspends>` (1 Hz loop).

**Key member variables.** `MaxReasonablePlayerHeight : float = 25000.0`, `RespawnLocation : ?vector3`, `RespawnRotation : ?rotation`.

**UEFN devices referenced.** None (uses `Player.Respawn`).

**Dependencies.** None in-set.

**Multiplayer logic.** Iterates all playspace players every second.

---

### 2.18 `Skeletons.verse`

**Purpose.** NPC behaviour for a "Skeleton" mob: identical loop to the Giant but
leaner (2.5× health, 5 shield, no damage-reduction hook).

**Exported types / functions**
- `Skeletons<public> : class(npc_behavior)` — `OnBegin<override>()<suspends>`.

**Key member variables.** `BehaviorHelp : BehaviorHelper`, `Attack1 : animation_sequence` (`MobZombie` assets).

**UEFN devices referenced.** `MobZombie` animation asset; NPC character interfaces.

**Dependencies.** `BehaviorHelper.verse`.

**Multiplayer logic.** Targets nearest player (see `BehaviorHelper`).

---

### 2.19 `SpaceStage.verse`

**Purpose.** Paid-area monetisation: the "Moon Pass" (500 V-Bucks) permanently
unlocks the moon area. Uses Marketplace entitlements/offers; unlocking disables a
global `barrier_device`. Declares `A_MCSkyblock<public>` with `market<public>`
so texture assets (e.g. `moonpass`) are reachable by other files.

**Exported types / functions**
- `A_MCSkyblock<public> : module` → `market<public> : module{}` — asset namespace declaration.
- `EntitlementInfo<public> : module` — Moon Pass text.
- `Entitlements<public> : module` — `feature_example_entitlement : class<abstract><castable>(entitlement)`, `space_area_access` (concrete, `PaidArea := true`).
- `ExampleOffers<public> : module` — `space_area_access` offer at `MakePriceVBucks(500.0)`.
- `SpaceStage : class(creative_device)` — `OnPlayerJoin` subscribes entitlement changes; `HandlePurchaseButton` (buy or unlock-if-owned); `CheckAndUnlockIfOwned` (single source of truth: re-read owned entitlements); `UnlockMoonArea()` (`MoonAreaBarrier.Disable()`); `OnPlayerLeft` cleans subscriptions.

**Key member variables.** `PurchaseButton : button_device`, `MoonAreaBarrier : barrier_device`, `EntitlementChangeSubscription : [player]?cancelable`, join/left subscriptions.

**UEFN devices referenced.** `button_device`, `barrier_device`, Marketplace API (`GetEntitlementsChangedEvent`, `GetPurchasedEntitlements`, `BuyOffer`, `TryBuyOffer`).

**Dependencies.** None in-set (but **exports the `A_MCSkyblock.market` module consumed by `gun_store.verse`**). Note in comments: the auto-generated `Assets.digest.verse` must regenerate with these `<public>` specifiers.

**Multiplayer logic.** Per-player entitlement subscriptions; catch-up for players who joined before `OnBegin`. Barrier disable is global — the file itself notes to swap for `mutator_zone_device`/`class_selector_device` for per-player gating.

---

### 2.20 `subtle_chicken_animations.verse`

**Purpose.** Ambient chicken animation, gentler than `chicken_animations.verse`:
chickens rotate in place, occasionally jump, and otherwise idle; a safety clamp
returns a chicken to `HeightToReturnTo` if it drifts above `MaxHeight`.

**Exported types / functions**
- `subtle_chicken_animations : class(creative_device)` — `MoveAround(Index, Chicken)` loop using `animation_mode.PingPong` frames.

**Key member variables.** `Name : string`, `Chickens : []creative_prop`, `MaxTime/MinTime`, `MaxRotDegrees`, `RotChance : int`, `JumpChance : int`, `JumpHeight`, `MinJumpTime/MaxJumpTime`, `MaxHeight`, `HeightToReturnTo`, `TimeBetweenMoveChances`.

**UEFN devices referenced.** `creative_prop` + animation controllers.

**Dependencies.** None in-set.

**Multiplayer logic.** None (purely cosmetic).

---

### 2.21 `tycoon_currency_manager.verse`

**Purpose.** The **central economy hub**. Tracks `GoldPerSecond`, `StoredGold`,
the rebirth multiplier and rebirth count for the plot's owner(s); accrues gold
each tick; pays it out to players standing at claim locations; drives rebirths
(reset purchases, keep multiplier, save); awards XP accolades; runs the objective
map indicator; optionally simulates a full playthrough to estimate completion
time; and pays gold on creature eliminations.

**Exported types / functions**
- Tags: `rebirth_count_tracker`, `earning_multiplier_tracker`, `stage_saving_tracker`, `gold_remover_tag`, `creature_spawner_tag`.
- `claim_text_settings : class<concrete>` — billboard formatting.
- `tycoon_currency_manager : class(creative_device)`
  - `OnBegin` — spawns `CalculateMinimumTime()`, `branch{sync{ChecklistLoop(); RunTimer(); MapIndicatorDeviceLoop()}}`, finds `GoldRemover` via tag, subscribes `RebirthButton`, `InitDeviceArray()`, `CreatureStuff()`, and runs the earn/claim loop (1× `AddToStoredResources` + 5× `CheckClaim` per second).
  - Economy: `AddToStoredResources()`, `CheckClaim()<suspends>`, `GrantGold(Player, Amount)` (denomination loop 10⁹→1), `AddToGoldPerSecond(Amount)`, `EffectiveGoldPerSecond():float`, `UpdatePotentialMultiplier()`.
  - Rebirth: `VerifyRebirth(Agent)` (30 s cooldown), `Rebirth(Player)<suspends>` (persist multiplier, `ClearOldNumbers`, `BackToStart`), `ClearPlayerGold`.
  - Persistence: `SetOwningPlayers(Players)`, `MigrateLegacyNodeStates(Player)` (schema repair v0→v1).
  - Progression: `InitDeviceArray()` (BFS over `FirstPlateManager.GetAllManagers(Self)`), `GetAndIncrementIndex()`.
  - Map objective: `MapIndicatorDeviceLoop()` (pulses the cheapest affordable active node, else the rebirth button), `DeactivateObjective`, `RebirthObjective`.
  - Creatures: `CreatureStuff()`, `CreatureEliminated(AI_Result)` → gold + `CREATUREaccolades`.
  - Simulation: `CalculateMinimumTime()<suspends>` — greedily simulates purchases to estimate minimum completion time.
  - API used by other files: `AwardNormalPurchase(Agent, Cost, AccoladeIndex)`, `ShowNotEnoughGold(Agent)`, `GrantGold`, `EffectiveGoldPerSecond`, `SetOwningPlayers`, `SetTempMultiplier/ResetTempMultiplier`, `GetRebirthCooldownRemaining`.

**Key member variables.** `SimBySeconds`, `CountBySeconds`, `LengthOfSecond`, `FirstPlateManager : []pressure_plate_with_generator`, `ResourceClaimLocationProps : []creative_prop`, `ClaimTextSettings`, `GoldStorageBillboards : []billboard_device`, `RebirthButton : button_device`, `RebirthInfoBillboard : billboard_device`, `ClaimDistance : float`, `GoldGranter : item_granter_device`, `ConditionalButton : conditional_button_device`, `NotEnoughGold / RebirthCooldownMessage : hud_message_device`, `PurchaseAccoladeDevices / CREATUREaccolades : []accolades_device`, `CreatureElimMultiplier`, `MultiplierPerGoldPerSecond : float`, `GoldRemover : item_remover_device`, `MapIndicatorDevice : map_indicator_device`, `PlayerReference : player_reference_device`, state: `OwningPlayers`, `AllPlateManagers`, `GoldPerSecond`, `StoredGold`, `UsableMultiplier`, `PotentialMultiplier`, `RebirthCount`, `TempMultiplier`, `LastRebirthTime`, `RebirthCooldownSeconds = 30`, `TimeSincePlayerAdded`, `UISystem : UI_Trackers`.

**UEFN devices referenced.** `item_granter_device`, `conditional_button_device`, `billboard_device`, `button_device`, `hud_message_device`, `accolades_device`, `item_remover_device`, `map_indicator_device`, `player_reference_device`, `creature_spawner_device`, `audio_player_device`.

**Dependencies.** `pressure_plate_with_generator.verse` (`player_save_data`, `PlayerProfileDataMap`, `activity_type_classic`, node methods `GetPersistenceKey`/`GetNextManagers`/`SpecialSettings`/`CommonlyUsed`), `UI_Trackers.verse` (`ui_system_tag`, `UI_Trackers` type, `UpdatePlaytime/UpdateRebirths/UpdateGoldPerSecond/UpdateToDo/GetGold/ConfirmRebirth/ShowRebirthCooldown`).

**Multiplayer logic.** Single shared pool per plot; `OwningPlayers` array; grant-to-first-claimer behaviour; per-player save records; player-reference device registers the plot owner; creature eliminations matched to `OwningPlayers`.

---

### 2.22 `UI_Trackers.verse`

**Purpose.** The persistent HUD: gold, gold/second, rebirths, "To-Do", and
playtime, rendered as five stacked overlays on a left-side canvas. Also hosts the
rebirth confirmation and cooldown pop-ups, grants the rebirth token, and exposes
updater functions used by the currency manager. (Also contains the global
`Format` and `FormatTime` string helpers used across the codebase.)

**Exported types / functions**
- `ui_system_tag : class(tag){}`.
- File-scope helpers: `Format(Num:int):string` (K/M/B), `FormatTime(Sec:int):string`.
- `player_tycoon_ui_data : class` — `PlayerUI`, `MainStackBox`, `GoldTextBlock`, `GoldPerSecondTextBlock`, `RebirthsTextBlock`, `ToDoTextBlock`, `PlayTimeTextBlock`, `PlayerGold`, `GoldPerSecond`, `Rebirths`, `ToDo`, `SecondsActive`.
- `UI_Trackers : class(creative_device)`
  - `OnBegin` — subscribes `PlayerAddedEvent`, catches up existing players.
  - `RefreshUI(Agent)` — 0.1 s loop writing all five stats.
  - Updaters (called by `tycoon_currency_manager`): `UpdateGoldPerSecond(Agent, int)`, `UpdateRebirths(Agent, int)`, `UpdateToDo(Agent, string)`, `UpdatePlaytime(Agent, SecondsActive)`, `UpdateSecondsActive(Agent)`, `GetGold(Agent):int`.
  - Rebirth UI: `ShowRebirthCooldown(Player, RemainingSeconds)`, `ConfirmRebirth(CurrencyManager, Player)`, `RebirthConfirmed` (grants `RebirthToken` via `RebirthTokenGranter` then calls `CurrencyManager.Rebirth`), `RebirthCancelled`.
  - `MakeCanvas(Agent):canvas` — builds the full HUD.

**Key member variables.** `PlaytimeStartingText`, `RebirthToken : item_granter_device`, `GoldRemover : item_granter_device` (editable, legacy), `RefreshRate : float = 0.1`, `ConditButton : conditional_button_device`, `PlayerUIMap : [agent]?player_tycoon_ui_data`.

**UEFN devices referenced.** `item_granter_device`, `conditional_button_device`, UMG widgets; textures from the `UI` asset folder (`Orange`, `Green_Button`, `Rebirth_Button`, `Blue`, `GoldIcon`, `GoldSecondicon`, `RestartGraphic`, `Todo1`, `Rebirth_Warning`, `Rebirth_Timer`, `SD_Card_Save_Locker_Graphic`, `Island_code`) via `/majid@fortnite.com/MCSkyblockTycoon`.

**Dependencies.** `pressure_plate_with_generator.verse` (`PlayerProfileDataMap` in `UpdateSecondsActive`), `tycoon_currency_manager.verse` (type in `ConfirmRebirth` signature).

**Multiplayer logic.** Per-agent UI map; `PlayerAddedEvent`-driven; refresh loops per player.

---

## 3. Core vs side features — how it all interconnects

### 3.1 Core tycoon system (don't break these)
1. **`pressure_plate_with_generator`** — the node graph + persistence hub.
2. **`tycoon_currency_manager`** — economy, rebirths, objectives, accolades.
3. **`plot_claim_device`** — plot ownership that binds players to node chains.
4. **`UI_Trackers`** — the HUD surface for the economy.
5. **`player_save_data` + `PlayerProfileDataMap`** (in the pressure-plate file) — the single save schema shared by core and several side features.

**Interconnection:** `plot_claim_device` → `pressure_plate.AddPlayerToPlot()` →
`tycoon_currency_manager.SetOwningPlayers()` → node purchases call
`AddToGoldPerSecond()`/`AwardNormalPurchase()` → earning loop fills
`StoredGold` → `CheckClaim()`/`GrantGold()` → `UI_Trackers` reflects
gold/GPS/rebirths/playtime. Rebirths call `BackToDefaultAll` (reset through the
whole chain) and persist `Multiplier`. The map indicator and simulation both walk
`AllPlateManagers`.

### 3.2 Side features and their hooks into the core
| Side feature | Hooks into core |
|---|---|
| `pets_device` | Reads `PlayerProfileDataMap[Player].Rebirths` for gating; holds an (unused-for-currency) `tycoon_currency_manager` reference. |
| `giftbox_device` | Finds the nearest `gold_currency_manager`-tagged manager; validates ownership against its `OwningPlayers`. |
| `event_manager` + `color_switch` + `king_of_the_hill` | Uses `plot_claim_device` to find the owner's plot and `tycoon_currency_manager.GoldPerSecond`/`GrantGold` for payouts. |
| `gun_store` | Purchases deduct gold via a `conditional_button_device` (the same gold item tracked by the economy). No direct Verse link. |
| `SpaceStage` | V-Bucks only; unrelated to gold. Also hosts the shared `A_MCSkyblock.market` texture namespace used by `gun_store`. |
| `playtimerewards` | Standalone gold-agnostic gifts; shares the `Textures` module namespace with `giftbox_device`. |
| `playtime_award_manager` | Independent playtime counter + accolades (does not use `SecondsActive`). |
| `GiantBehavior` / `Skeletons` / `BehaviorHelper` | Mob AI; economy pays gold on eliminations via `creature_spawner_tag` devices. |
| `chicken_animations` / `subtle_chicken_animations` | Pure cosmetics. |
| `generic_animation_device` | Animation library used by the node system (`AnimationsToPlay/Stop`). |
| `intro` / `respawn_backup` / `GoldTracker` | One-shot/legacy helpers; `GoldTracker` is superseded by `UI_Trackers`. |

---

## 4. Conventions an extending agent should respect

- **British English** is used throughout this documentation; the code itself
  mixes US spellings (e.g. `Color`), which should be preserved when editing.
- File-scope globals in Verse are effectively singletons: `PlayerProfileDataMap`,
  `SessionSpeedMultipleMap`, `AllowPrint`, `AllowChecklist`. Reusing them is fine;
  redeclaring them is not.
- Persistence schema changes must bump `NodeSaveSchemaVersion` and be handled by
  `MigrateLegacyNodeStates`-style repair functions.
- The node chain is discovered via `GetAllManagers` (explicit `NextManagers`) or
  spatial `tycoon_node` tag auto-chaining (`GetAutomaticNextManagers`, +Y axis).
  When adding nodes, either wire `NextManagers` or tag + place further along +Y.
- The conditional button at `tycoon_currency_manager` is shared by every node;
  purchases use its `ActivatedEvent`/`NotEnoughItemsEvent` synchronised with a
  `race`/`sync`. Don't route money through the granter directly for purchases.
- All UMG is built programmatically in Verse (no widgets authored in UEFN).
- Most loops are un-throttled `Sleep(0.1)`-style server loops; they are safe but
  add CPU. New loops should sleep similarly and only run on owning/participating
  players to avoid waste.
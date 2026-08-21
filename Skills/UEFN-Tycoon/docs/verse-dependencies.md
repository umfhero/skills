# SimpleLowPolyTycoon — Verse Dependency Map & Device-Reference Graph

Companion to `verse-overview.md`. Every `.verse` file in the plugin's `Content\`
folder is listed with (a) what it depends on **within the set**, (b) what other
files depend on **it**, (c) the UEFN devices it references via `@editable`
fields or runtime discovery, and (d) any runtime tag / module-namespace links.

Legend for the dependency columns:
- **Depends on (in-set)** — files whose declared types, globals or tags this file needs at compile time.
- **Used by (in-set)** — files that reference this file's exports.
- **Tag discovery** — `FindCreativeObjectsWithTag(...)` / `GetCreativeObjectsWithTag(...)` at runtime (no compile-time link, but a real world link).
- **Namespace/module links** — shared `<public>` module declarations or asset-digest namespaces.

---

## 1. Dependency summary table

| File | Depends on (in-set) | Used by (in-set) |
|---|---|---|
| `BehaviorHelper.verse` | — | `GiantBehavior`, `Skeletons` |
| `chicken_animations.verse` | — | — |
| `color_switch.verse` | `event_manager` (base `game`) | `event_manager` (as an `AllEvents` entry) |
| `event_manager.verse` | `tycoon_currency_manager`, `plot_claim_device`, `pressure_plate_with_generator` | `color_switch`, `king_of_the_hill` (subclass `game`) |
| `generic_animation_device.verse` | — | `pressure_plate_with_generator` (`animation_curve`, `generic_animation_device`) |
| `GiantBehavior.verse` | `BehaviorHelper` | — |
| `giftbox_device.verse` | `tycoon_currency_manager`, `pressure_plate_with_generator` (tag `gold_currency_manager`), `playtimerewards` (`Textures` namespace) | — |
| `GoldTracker.verse` | — | — (legacy) |
| `gun_store.verse` | `SpaceStage` (`A_MCSkyblock.market` module) | — |
| `intro.verse` | — (external `/majid@fortnite.com/MCSkyblockTycoon`) | — |
| `king_of_the_hill.verse` | `event_manager` (base `game`), `tycoon_currency_manager` | `event_manager` (as an `AllEvents` entry) |
| `pets_device.verse` | `pressure_plate_with_generator` (`PlayerProfileDataMap`), `tycoon_currency_manager` | — |
| `playtime_award_manager.verse` | — | — |
| `playtimerewards.verse` | — | `giftbox_device` (`Textures` namespace) |
| `plot_claim_device.verse` | `pressure_plate_with_generator` | `event_manager`, `giftbox_device` (indirect via pressure plate) |
| `pressure_plate_with_generator.verse` | `generic_animation_device`, `tycoon_currency_manager` | `event_manager`, `giftbox_device`, `pets_device`, `plot_claim_device`, `tycoon_currency_manager`, `UI_Trackers` |
| `respawn_backup.verse` | — | — |
| `Skeletons.verse` | `BehaviorHelper` | — |
| `SpaceStage.verse` | — | `gun_store` (`A_MCSkyblock.market` module) |
| `subtle_chicken_animations.verse` | — | — |
| `tycoon_currency_manager.verse` | `pressure_plate_with_generator`, `UI_Trackers` | `event_manager`, `giftbox_device`, `king_of_the_hill`, `pets_device`, `pressure_plate_with_generator`, `UI_Trackers` |
| `UI_Trackers.verse` | `pressure_plate_with_generator` (`PlayerProfileDataMap`), `tycoon_currency_manager` | `tycoon_currency_manager` |

---

## 2. Directed dependency graph

```
                      ┌───────────────────────────┐
                      │ BehaviorHelper.verse      │
                      └─────────────┬─────────────┘
                                    │
                  ┌─────────────────┴─────────────────┐
                  ▼                                   ▼
        GiantBehavior.verse                   Skeletons.verse


             generic_animation_device.verse ────────────────┐
                                                            │
        SpaceStage.verse ───────────┐                       │
              │                     │                       │
              │  A_MCSkyblock.market│                       │
              ▼                     ▼                       ▼
        gun_store.verse      tycoon_currency_manager.verse ◄─────────────┐
              ┐                     │  ▲              │                   │
              │                     │  │  ui_system_tag│                   │
              │                     ▼  │              ▼                   │
              │              UI_Trackers.verse        │                   │
              │                     ▲                 │                   │
              │                     │                 │                   │
              │                     │                 ▼                   │
              │                     │    pressure_plate_with_generator.verse
              │                     │        (PlayerProfileDataMap, player_save_data,
              │                     │         gold_currency_manager / purchase_audio /
              │                     │         tycoon_node tags, activity_type_classic)
              │                     │                 │  ▲
              │                     │                 │  │
              │                     │                 │  │
              │        ┌────────────┘  ┌──────────────┘  └────────────┐
              │        │               │                  │           │
              │        ▼               ▼                  ▼           ▼
              │   plot_claim_device  giftbox_device   pets_device  event_manager.verse
              │        ▲                                    (game base) │
              │        │                                          ▲    │
              │        └──────────────────────────────────────────┤    │
              │                                                   │    │
              │                  ┌────────────────────────────────┘    │
              │                  ▼  (subclass game)                    ▼
              │        color_switch.verse                  king_of_the_hill.verse
              │                                                     │
              │              ┌──────────────────────────────────────┘
              │              │
              ▼              ▼
        playtimerewards.verse ──── Textures namespace ────► giftbox_device.verse


Standalone (no in-set edges):  chicken_animations.verse
                               subtle_chicken_animations.verse
                               GoldTracker.verse
                               playtime_award_manager.verse
                               respawn_backup.verse
                               intro.verse
```

### Cycle note
`tycoon_currency_manager ↔ pressure_plate_with_generator ↔ UI_Trackers` form a
compile-time cycle. This is legal in Verse (all files compile into one module
set); it means the three are conceptually one subsystem and must be reworked
together.

---

## 3. Runtime tag map

Verse tags used with `FindCreativeObjectsWithTag` / `GetCreativeObjectsWithTag`
(no device reference needed — UEFN objects are tagged in the editor):

| Tag class | Declared in | Discovered/consumed by | Discovered object type |
|---|---|---|---|
| `gold_currency_manager` | `pressure_plate_with_generator.verse` | `pressure_plate_with_generator.Setup()`, `giftbox_device.GetClosestPlotManager()` | `tycoon_currency_manager` |
| `purchase_audio` | `pressure_plate_with_generator.verse` | `pressure_plate_with_generator.Setup()` | `audio_player_device` |
| `tycoon_node` | `pressure_plate_with_generator.verse` | `pressure_plate_with_generator.GetAutomaticNextManagers()` (spatial +Y chaining) | `pressure_plate_with_generator` |
| `ui_system_tag` | `UI_Trackers.verse` | `tycoon_currency_manager.MapIndicatorDeviceLoop()` | `UI_Trackers` |
| `gold_remover_tag` | `tycoon_currency_manager.verse` | `tycoon_currency_manager.OnBegin()` | `item_remover_device` |
| `creature_spawner_tag` | `tycoon_currency_manager.verse` | `tycoon_currency_manager.CreatureStuff()` | `creature_spawner_device` |
| `rebirth_count_tracker` | `tycoon_currency_manager.verse` | (legacy trackers — replaced by save data) | tracker device |
| `earning_multiplier_tracker` | `tycoon_currency_manager.verse` | (legacy — replaced by save data) | tracker device |
| `stage_saving_tracker` | `tycoon_currency_manager.verse` | (legacy — replaced by save data) | tracker device |
| `gold_counter_tag` | `GoldTracker.verse` | (legacy HUD) | — |

---

## 4. Cross-file symbols (what is actually shared)

| Symbol | Declared in | Referenced in |
|---|---|---|
| `game` (base class) | `event_manager.verse` | `color_switch.verse`, `king_of_the_hill.verse` |
| `player_info` | `event_manager.verse` | — |
| `PlayerProfileDataMap` (global `weak_map(player, player_save_data)`) | `pressure_plate_with_generator.verse` | `pets_device.verse`, `tycoon_currency_manager.verse`, `UI_Trackers.verse` |
| `player_save_data` (persistable) | `pressure_plate_with_generator.verse` | `pets_device`, `tycoon_currency_manager` |
| `activity_type_classic` enum | `pressure_plate_with_generator.verse` | `tycoon_currency_manager`, `pressure_plate` (self) |
| `gold_currency_manager` tag | `pressure_plate_with_generator.verse` | `giftbox_device`, `pressure_plate` (self) |
| `animation_curve` | `generic_animation_device.verse` | `pressure_plate_with_generator` (`animation_curves_settings`) |
| `generic_animation_device` | `generic_animation_device.verse` | `pressure_plate_with_generator` (`AssetsAndAnimation.AnimationsToPlay/Stop`) |
| `UI_Trackers` + `ui_system_tag` | `UI_Trackers.verse` | `tycoon_currency_manager` (editable `UISystem` + tag) |
| `tycoon_currency_manager` | `tycoon_currency_manager.verse` | `event_manager` (`player_info`), `giftbox_device`, `king_of_the_hill`, `pets_device`, `pressure_plate_with_generator`, `UI_Trackers` (`ConfirmRebirth`) |
| `A_MCSkyblock.market` module | `SpaceStage.verse` | `gun_store.verse` (`A_MCSkyblock.market.moonpass`) |
| `Textures` module namespace | `playtimerewards.verse` (seed declaration) | `giftbox_device.verse` (`Textures.Chest1..5`, `Textures.Wait`, `Textures.Claimed`, `Textures.GiftBoxBackground`) |
| `TryPrint` / `ChecklistPrint` / `AllowPrint` / `AllowChecklist` | `plot_claim_device.verse` | `plot_claim_device` (self), `pressure_plate_with_generator` (`TryPrint`), `tycoon_currency_manager` (`TryPrint`, `ChecklistPrint`) |
| `Format(int)` / `FormatTime(int)` | `UI_Trackers.verse` | `tycoon_currency_manager` (`Format`, `FormatTime` in simulation), `UI_Trackers` (self) |

> Note on `Format`: `UI_Trackers.verse` defines the global `Format(Num:int)`
> (K/M/B abbreviation). `GoldTracker.verse` contains a commented-out duplicate.
> `tycoon_currency_manager` and `pressure_plate_with_generator` call the global
> `Format`; `event_manager` has its own local `Format` inside `color_switch`.

---

## 5. Device-reference graph (UEFN device objects wired in the editor)

`@editable` device references plus runtime-discovered device types, per file.
This is the graph an MCP tool would need to (re)wire in UEFN.

### 5.1 Core subsystem

**`tycoon_currency_manager.verse`** (the hub)
- `FirstPlateManager : []pressure_plate_with_generator` — entry node(s) of the chain (BFS from here builds `AllPlateManagers`).
- `GoldGranter : item_granter_device` — 10 gold denominations (index 0..9 = 1, 10, 100, 1k, 10k, 100k, 1M, 10M, 100M, 1B).
- `ConditionalButton : conditional_button_device` — shared payment button (item 0 = gold).
- `NotEnoughGold`, `RebirthCooldownMessage : hud_message_device`.
- `GoldStorageBillboards : []billboard_device`, `RebirthInfoBillboard : billboard_device`, `RebirthButton : button_device`.
- `ResourceClaimLocationProps : []creative_prop` — claim pads.
- `PurchaseAccoladeDevices / CREATUREaccolades : []accolades_device`.
- `PurchaseSounds : []audio_player_device`.
- `MapIndicatorDevice : map_indicator_device`, `MapIndicatorDeviceZOffset`, `PlayerReference : player_reference_device`.
- Tag-discovered: `GoldRemover : item_remover_device` (`gold_remover_tag`), `CreatureSpawners : []creature_spawner_device` (`creature_spawner_tag`), `UISystem : UI_Trackers` (`ui_system_tag`).

**`pressure_plate_with_generator.verse`** (one instance per upgrade node)
- `CommonlyUsed.PressurePlate : creative_prop` — the plate mesh.
- `CommonlyUsed.PriceBillboards : []billboard_device`.
- `CommonlyUsed.PropsToShow / PropsToHide : []creative_prop`.
- `CommonlyUsed.NextManagers : []pressure_plate_with_generator` — explicit chain edges.
- `SpecialSettings.CutsceneToPlay / CinematicsToPlay / CinematicsToStop : []cinematic_sequence_device`, `ExtraCinematicChanges : []extra_cinematic_settings`.
- `AssetsAndAnimation.AnimationsToPlay / AnimationsToStop : []generic_animation_device`.
- `Sound.SlamSound : audio_player_device`, `Sound.AdditionalPurchaseSounds : []audio_player_device`.
- `ConditionalButton` + `GoldGranter` — **copied at runtime** from the tag-found `MainTycoonManager`.
- Tag-discovered: `MainTycoonManager : tycoon_currency_manager` (`gold_currency_manager`), `PurchaseAudio : audio_player_device` (`purchase_audio`), next nodes via `tycoon_node`.

**`plot_claim_device.verse`**
- `ClaimToPlotAssignments : []first_pressure_plate_assignment`, each containing `ClaimProp`, `HideProp`, `ShowProp : creative_prop`, `FirstPressurePlateDeviceOnly : []pressure_plate_with_generator`, `OptionalTeleportLocationOverride : []transform`.
- `OptionalPortalMutatorZone : []mutator_zone_device`, `TogglePrintingButton / ToggleCheckListButton : button_device`.

**`UI_Trackers.verse`**
- `ConditButton : conditional_button_device` — gold readout (`GetItemCount(Agent, 0)`).
- `RebirthToken : item_granter_device`, `GoldRemover : item_granter_device` (editable; legacy).
- Textures from `/majid@fortnite.com/MCSkyblockTycoon` (`UI.Orange`, `UI.GoldIcon`, `UI.Rebirth_Button`, `UI.Rebirth_Warning`, `UI.Rebirth_Timer`, ...).

### 5.2 Event subsystem

**`event_manager.verse`**
- `OnlyPlotClaimDevice : []plot_claim_device`, `PortalMutatorZones : []mutator_zone_device`, `HudMessager / HudMessageDevice : hud_message_device`, `AllEvents : []game` (list of the minigame devices).

**`color_switch.verse`**
- `PlayAreaMutatorZone : mutator_zone_device`, `ColorBillboards / MessageBillboards / TimeBillboards : []billboard_device`, `AllColors : []color_info` (each with `AllTilesOfThisColor` / `RepresentativeImages : []creative_prop`), `TriggerDevices : []trigger_device` (commented out).

**`king_of_the_hill.verse`**
- `CaptureArea : capture_area_device`, `SpawnLocationProps : []creative_prop`.

### 5.3 Side features

**`giftbox_device.verse`**
- `PlayerSpawners : []player_spawner_device`, `GiftBoxProp : creative_prop`, `GiftBoxButton : button_device`, `GiftGranter : item_granter_device`, `GiftBoxDurations : []int`.
- Tag-discovered: closest `tycoon_currency_manager` (`gold_currency_manager`).
- Textures: `Textures.GiftBoxBackground`, `Textures.Chest1..5`, `Textures.Wait`, `Textures.Claimed`.

**`pets_device.verse`**
- `TycoonCurrencyManager : tycoon_currency_manager`, `NotEnoughRebirthsHudMessage / PetPurchaseConfirmedHudMessage : hud_message_device`, `PlayerSpawners : []player_spawner_device`, `PetPurchasesData : []pet_purchase_data` (each: `ButtonForPurchase : button_device`, `PetProps : []creative_prop`).

**`gun_store.verse`**
- `VBucksStoreButton : button_device`, `MachineGunGranter / RocketLauncherGranter : item_granter_device`, `PistolButton / AssaultRifleButton / ScarButton : conditional_button_device`, `PistolGranter / AssaultRifleGranter / ScarGranter : item_granter_device`.

**`SpaceStage.verse`**
- `PurchaseButton : button_device`, `MoonAreaBarrier : barrier_device`.

**`playtimerewards.verse`**
- `PlaytimeRewardsList : []playtime_reward_unlock` (each: `ClaimTrigger : trigger_device`), `ShowPlaytimeRewardsButton / ShowPlaytimeRewardsButton2 : button_device`. Textures from `Giftbox.*`.

**`playtime_award_manager.verse`**
- `Accolade1 / Accolade2 : ?accolades_device`. Textures from `XP_UI.*`.

**`generic_animation_device.verse`**
- `PropsToMove : []creative_prop`, `KeyLocationInfo : []keyframe_info` (each references a `Prop`).

**`chicken_animations.verse` / `subtle_chicken_animations.verse`**
- `Chickens : []creative_prop`, `CornerProps : []creative_prop` (chicken file only).

**`intro.verse`**
- `SpawnPad : player_spawner_device`; texture `UI.intro`.

**`respawn_backup.verse`**
- None (`Player.Respawn` API only).

**`GiantBehavior.verse` / `Skeletons.verse`**
- NPC spawner configuration in UEFN; `MobZombie` animation assets; `BehaviorHelper` device placed in level.

**`GoldTracker.verse`**
- `PlayerSpawners : []player_spawner_device`, `ConditButton : conditional_button_device`.

---

## 6. Multiplayer / replication notes

- **Server-authoritative design.** All economy, claim, save and event state lives
  on the server. Clients only receive replicated props/NPCs and their own UI.
- **Per-player state maps.** `[agent]`/`[player]` maps are the universal pattern:
  `PlayerProfileDataMap`, `PlayerInfoMap`, `GiftBoxCanvasPerAgent`,
  `GiftBoxDurationsPerAgent`, `AgentMap` (pets), `PlaytimePerAgent`,
  `PlaytimeHudPerAgent`, `UiMap`, `PlayerUIMap`, `ResourceTextBlockPerAgent`,
  `PlayerIntroMap`, `EntitlementChangeSubscription`.
- **Playspace events.** Join/leave handled via `PlayerAddedEvent` /
  `PlayerRemovedEvent` (and spawners' `SpawnedEvent`). Several devices
  explicitly "catch up" players who joined before their own `OnBegin` ran
  (`SpaceStage`, `gun_store`, `playtimerewards`, `UI_Trackers`).
- **Ownership model.** `OwningPlayers` on the currency manager and each node;
  plots claimed via `plot_claim_device`. Gold is granted to the first claiming
  player at a claim point (not duplicated for co-owners).
- **Persistence.** `player_save_data` is `persistable`; stored in
  `PlayerProfileDataMap`, survives session end, and is guarded by the
  `NodeSaveSchemaVersion` migration path (`MigrateLegacyNodeStates`).

---

## 7. Things to watch when reworking

1. **Do not split the `tycoon_currency_manager ↔ pressure_plate_with_generator ↔ UI_Trackers` cycle carelessly** — shared globals and mutual calls assume a single compilation unit.
2. **`PlayerProfileDataMap` is the de-facto save store.** Any new persistence feature should extend `player_save_data` and bump `NodeSaveSchemaVersion` rather than adding parallel maps.
3. **Node chaining has two mechanisms** (explicit `NextManagers` vs `tycoon_node` spatial auto-chain). New nodes should either wire `NextManagers` or be tagged and placed ahead on `+Y`; the MCP duplication flow depends on this.
4. **Gold routing:** purchases go through the shared `ConditionalButton` on the currency manager; `GrantGold` uses the 10-denomination granter. Both are assumed by `giftbox`/`gun_store`/events for their own payouts.
5. **Global helpers** (`TryPrint`, `ChecklistPrint`, `Format`, `FormatTime`, `AllowPrint`, `AllowChecklist`, `SessionSpeedMultipleMap`) live at file scope and are shared across files — keep them unique per module set.
6. **Asset/module namespaces** (`A_MCSkyblock.market`, `Textures`, `UI.*`, `Giftbox.*`, `XP_UI.*`) depend on the auto-generated `Assets.digest.verse`; `<public>` specifiers on seed module declarations (as in `SpaceStage.verse` and `playtimerewards.verse`) are what keep them reachable across files.
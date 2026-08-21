# SimpleLowPolyTycoon — Live Project Wiring (verified via MCP)

Scope: the **published 2-player tycoon** at
`C:\Users\umfhe\Documents\Fortnite Projects\SimpleLowPolyTycoon\Plugins\SimpleLowPolyTycoon\Content\`
(12 `.verse` files, single `SimpleLowPolyTycoon.umap`). This is the older
`NextManagers`-only lineage of the same plugin family as `MCSkyblockTycoon`
(see `verse-overview.md`); it does **not** use the newer `tycoon_node` spatial
auto-chaining, `StableNodeId`, or `MigrateLegacyNodeStates`.

All device references, class names and settings below were pulled live from the
level through UEFN MCP (session `5f1ac6314091a574cb81adb17c161cde`, tool-search
mode, serial calls).

---

## 1. Level layout (two mirrored plots)

Everything is duplicated for Player 1 and Player 2 along the X axis:

| Thing | Player 1 | Player 2 |
|---|---|---|
| tycoon currency manager | label `tycoon currency manager` (x≈-11,826) | label `tycoon currency manager2` (x≈-62,225) |
| pressure-plate node chain | ~85 plates (x≈-6k..-16k) | ~85 plates (x≈-55k..-66k) |
| item granter | `Item Granter` (x≈-12,400) | `Item Granter2` (x≈-62,800) |
| conditional button | `Conditional Button4` (x≈-12,011) | `Conditional Button5` (x≈-62,411) |
| rebirth button | `Button` (x≈-10,024) | `Button4` (x≈-60,424) |
| rebirth tracker | `RebirthCount` (x≈-8,930) | `RebirthCount2` (x≈-59,329) |
| claim props | `Claim` / `Claimed` (y≈-81,500..-81,800) | `Claim2` / `Claimed2` (y≈-82,000..-82,400) |

Shared, single instance: the **plot claim device** at x≈-4,480 y≈-82,000 and
small debug `Button2`/`Button3` next to it.

The plot claim device has **two** `first_pressure_plate_assignment` entries
(`claimToPlotAssignments[0]` and `[1]`), i.e. one assignment per plot. Each
assignment points at the *first pressure plate* of that plot's node chain.

---

## 2. tycoon_currency_manager — what it is

Class `tycoon_currency_manager : class(creative_device)` (one per plot). It is
the **central economy hub**. It does not do the purchasing itself; nodes do that.
The manager holds the pool and grants items:

- **Accrues** `GoldPerSecond` → `StoredGold` once per second
  (`AddToStoredResources`, `SimBySeconds=10` / `CountBySeconds=1` /
  `LengthOfSecond=1`).
- **Pays out** `StoredGold` to the owning player standing within `ClaimDistance`
  of a `ResourceClaimLocationProps` prop (`CheckClaim` → `GrantGold`).
- **Grants gold as inventory items** through `GoldGranter`
  (`item_granter_device`) using `SetNextItem(0..9)` → `GrantItem(Player)`,
  denominated 1, 10, 100, 1k, 10k, 100k, 1M, 10M, 100M, 1B.
- **Rebirth** via `RebirthButton` (`button_device`): keeps `Multiplier`,
  `ClearOldNumbers` → `BackToStart` (recurses through `FirstPlateManager`
  `BackToDefaultAll`), persists to `PlayerProfileDataMap`.
- **Objective** via `MapIndicatorDevice` (`map_indicator_device`): pulses the
  cheapest affordable active node, else points at the rebirth button.
- **Simulation**: `CalculateMinimumTime` (only when `RunTestTimeSimulation`
  enabled) greedily simulates purchases to print a minimum completion time.

### 2.1 Settings as placed (P1 currency manager)

- `simBySeconds = 10`, `lengthOfSecond = 1`, `countBySeconds = 1`
- `holdObjectiveAtGoldClaim = false`, `runTestTimeSimulation = false`
- `claimDistance = 150`
- `firstPlateManager = [ <first pressure plate of the chain> ]`
  (an array — "THERE SHOULD ONLY BE ONE OF THESE")
- `resourceClaimLocationProps = [ creative_prop inside the currency manager ]`
- `goldGranter` → `Item Granter`, `conditionalButton` → `Conditional Button4`,
  `rebirthButton` → `Button`, `rebirthInfoBillboard` → billboard,
  `goldStorageBillboards` → billboards, `mapIndicatorDevice` → map indicator,
  `playerReference` → player reference device (registers plot owner)
- `notEnoughGold` → hud message, `purchaseSounds` → audio players
- `purchaseAccoladeDevices` / `creatureAccolades` → accolades devices
- `creatureElimMultiplier`, `multiplierPerGoldPerSecond = 0.0001`
  (rebirth multiplier accrual: `Multiplier + GPS × 0.0001`)

### 2.2 Item Granter settings (P1, native `Device_ItemGranter_V2_C`)

- `itemToGrant = 1` (index of next item; driven at runtime by `SetNextItem`)
- `bGrantOnGameStart = false`, `bGrantOnTimer = false`, `grantOnCycle = true`
- `grantTime = 1`, `itemCount = 0`, `bEquipGrantedItem = false`
- Item list is **not** readable via MCP (`items`/`grantBehavior` rejected) but
  `GrantGold` in verse references indices 0–9 = 1,10,100,1k,10k,100k,1M,10M,100M,1B.

---

## 3. pressure_plate_with_generator — what a "pressure plate with generator" is

Class `pressure_plate_with_generator : class(creative_device)`, one **node** per
instance. A node = a purchasable upgrade. It consists of:

- `CommonlyUsed` (`commonly_used_settings`):
  - `PressurePlate : creative_prop` — the physical plate (hidden until active).
  - `PriceBillboards : []billboard_device` — show "$COST / +GPS per second".
  - `GoldCost : int` — purchase price.
  - `GoldPerSecond : int` — GPS added to the manager on purchase.
  - `PropsToShow : []creative_prop` — props animated up on purchase.
  - `PropsToHide : []creative_prop` — props animated down on purchase.
  - `NextManagers : []pressure_plate_with_generator` — **the node chain edges.**
- `SpecialSettings` (`special_settings_classic`): `Name`, `StartAsActive`,
  `DistanceToPress` (default 160), `AccoladeIndexOverride`, cutscenes/cinematics,
  `BillboardTextSettings` (text/format tokens).
- `AssetsAndAnimation` / `Sound` / `AnimationCurves`: hide/show animation times,
  curves, slam sound, extra purchase sounds, generic animation devices.

### 3.1 Purchase flow (verified from verse source)

1. Continuous loop `CheckLocation(Player)` checks each owning player's distance
   to `PressurePlateLoc` vs `DistanceToPress`.
2. If standing on an **active** plate: `OnPlatePressed`.
3. If `GoldCost > 0`: `sync { race { NotEnoughItemsEvent.Await() → ShowNotEnoughGold;
   ActivatedEvent.Await() → continue } ; loop { ConditionalButton.SetItemCountRequired(0, GoldCost);
   ConditionalButton.Activate(Player); break } }`. Gold is deducted **through the
   shared conditional button**, not the granter.
4. `AwardNormalPurchase` (XP accolades), purchase audio, `SuccessfulPurchase`:
   - `Activity = purchased`, `SavePurchase()` (ActivityMap[PlateIndex] = 1)
   - `MainTycoonManager.AddToGoldPerSecond(GoldPerSecond)` if GPS > 0
   - hide plate, `ShowAndHide()` (show `PropsToShow`, hide `PropsToHide`)
   - for each `NextManagers` still inactive → `SetActive()` (reveal next plate).

### 3.2 How the node system is set up (chaining)

- **Chain discovery (BFS):** manager `InitDeviceArray()` calls
  `FirstPlateManager[0].GetAllManagers(Self)`. `GetAllManagers` does a breadth
  first walk over `CommonlyUsed.NextManagers`, assigning each node a unique
  `PlateIndex` via `Base.GetAndIncrementIndex()`. Result cached as
  `AllPlateManagers`.
- **Activation order:** purchase of node N calls `SetActive()` on every node in
  `N.CommonlyUsed.NextManagers` that is still `inactive`. Branching/rejoining
  paths are supported (visited nodes skipped once `PlateIndex >= 0`).
- **Persistence key:** per-player `ActivityMap[PlateIndex]` where
  0 = inactive, 1 = purchased, 2 = active (this published lineage keys saves on
  the traversal-assigned `PlateIndex`, not a stable id).
- **Rebirth reset:** `BackToDefaultAll(Player)` recurses through all
  `NextManagers` then re-applies `StartingVisibilityAndActivitySettings` and
  `CheckSaveData`.
- **Tags:** `gold_currency_manager` on the manager, `purchase_audio` on an audio
  player, `gold_remover_tag` on an item remover — discovered via
  `GetCreativeObjectsWithTag`. The manager itself is found by each node in
  `Setup()` (nearest tagged manager wins).

### 3.3 MCP limitation (important for automation)

The per-node **values** (`GoldCost`, `GoldPerSecond`, `PropsToShow/Hide`,
`NextManagers`, `PriceBillboards`) live in Verse struct sub-objects
(`...pressure_plate_with_generator_0.__verse_0x273B4230_CommonlyUsed`). They are
**not readable through UEFN MCP**:
- `ObjectTools.get_properties` → "could not be read"
- `DeviceToolset.GetDeviceProperties` → "not valid ScriptDevice"
- `ObjectTools.list_properties` → returns the *schema* (types/ref paths), which
  is how the struct keys were confirmed.

So the graph shape and device connections ARE visible (ref paths resolve), but
individual node costs/GPS must be read from the UEFN editor UI, the save data,
or by parsing the level binaries.

---

## 4. plot_claim_device — how players get plots (2-player binding)

Class `plot_claim_device : class(creative_device)` (single shared instance).

- `ClaimToPlotAssignments : []first_pressure_plate_assignment` — one per plot.
- `first_pressure_plate_assignment` contains `ClaimProp`, `HideProp`,
  `ShowProp` (creative props swapped on claim), `TimeToSwap`,
  `FirstPressurePlateDeviceOnly : []pressure_plate_with_generator`,
  `OptionalTeleportLocationOverride : []transform`.
- `CheckPlotClaim()` loop (0.2 s): for each unassigned player and unclaimed plot,
  if the player stands within `DistToClaim` (150 as placed) of `ClaimProp` →
  assign, teleport onto the first plate, `SwapOnClaim()`, register the player on
  the whole node chain (`Plate.AddPlayerToPlot(Player)` recurses `NextManagers`)
  and on the manager (`SetOwningPlayers`).
- Player leaving: `unclaim_helper` waits 15 s, confirms the player is gone, then
  `UnclaimPlot` → `ResetEverythingForAll` + `SwapOnUnclaim`.
- `SpawnReturnLocation` as placed: (x≈-2,891, y=-81,000, z=2000). Portal mutator
  zones teleport players back to their plot. Debug buttons toggle `TryPrint` /
  `ChecklistPrint` output.

### 4.1 Settings as placed

- `claimToPlotAssignments = [ assignment_0, assignment_1 ]` (P1 + P2)
- `distToClaim = 150`, `plotGroundHeight = 5`
- `togglePrintingButton` → `Button3`, `toggleCheckListButton` → `Button2`
- `spawnReturnLocation`/`spawnReturnRotation` set (identity rotation)

---

## 5. Persistence (published lineage)

`player_save_data : class<persistable><final>` declared in
`pressure_plate_with_generator.verse`:
`Rebirths:int`, `Multiplier:float`, `ActivityMap:[int]int`, `SecondsActive:int`.
Single file-scope `var PlayerProfileDataMap : weak_map(player, player_save_data)`.
`tycoon_currency_manager.RunTimer()` tracks `SecondsActive` (playtime) and feeds
`UI_Trackers.UpdatePlaytime`.

---

## 6. Checklist to reproduce / extend this tycoon

Per plot you need:

1. One `tycoon_currency_manager` tagged `gold_currency_manager`, wired:
   `FirstPlateManager → first node`, `GoldGranter → Item Granter`,
   `ConditionalButton → Conditional Button`, `RebirthButton → Button`,
   `RebirthInfoBillboard`, `GoldStorageBillboards`,
   `ResourceClaimLocationProps → claim prop(s)`, `MapIndicatorDevice`,
   `PlayerReference`, `NotEnoughGold` HUD, accolade + audio devices.
2. An `item_granter_device` with 10 gold items (1..1B) for `GrantGold`.
3. A `conditional_button_device` shared by all nodes for purchase/cost checks.
4. N × `pressure_plate_with_generator` nodes, each with a `creative_prop` plate,
   price billboards, `GoldCost`/`GoldPerSecond`, props to show/hide, and
   `NextManagers` pointing at its successors. First node `StartAsActive = true`.
5. A `plot_claim_device` with one `first_pressure_plate_assignment` per plot,
   each referencing the plot's first node, claim/show/hide props.
6. An `item_remover_device` tagged `gold_remover_tag` (used by rebirth
   `ClearPlayerGold`), an `audio_player_device` tagged `purchase_audio`, and a
   `UI_Trackers` device tagged `ui_system_tag` for the HUD.
7. Mirror the whole group for player 2 (the published map duplicates everything
   at a second X position and adds a second claim assignment).

The hardest/most manual part (as with any such tycoon) is authoring the content:
the props, and wiring every node's `NextManagers` + `CommonlyUsed` refs in the
UEFN editor, doubled for co-op.
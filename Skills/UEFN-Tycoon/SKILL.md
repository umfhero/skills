---
name: uefn-tycoon
description: >-
  Extend, rework, or debug the user's Skyblock-style UEFN tycoon built on the
  SimpleLowPolyTycoon Verse system. Includes the Verse snapshot, architecture, dependency
  graph, persistence rules, multiplayer constraints, and verified live device wiring.
---

# UEFN-Tycoon

The user's multiplayer Skyblock-style incremental tycoon built on the Verse scripting
system in the plugin `SimpleLowPolyTycoon`. Source project:

`C:\Users\umfhe\Documents\Fortnite Projects\MCSkyblockTycoon`

Before editing, verify that this is the intended UEFN project rather than another MCP test or
tycoon project with a similar name.

## Read only what the task needs

- [`docs/verse-overview.md`](docs/verse-overview.md) — architecture summary and per-file
  reference. Read the section for the subsystem being changed.
- [`docs/live-project-wiring.md`](docs/live-project-wiring.md) — the published
  2-player tycoon (`SimpleLowPolyTycoon`): every device actually placed in the level, its
  live settings (currency manager, item granter, plot claim device), the `NextManagers`
  node-chain mechanics, the plot-claim binding, and a checklist to reproduce a plot.
  This is the older lineage — it has no `tycoon_node` spatial chaining, no
  `StableNodeId`; node values (goldCost/goldPerSecond) are NOT readable via MCP.
- [`docs/verse-dependencies.md`](docs/verse-dependencies.md) — dependency table, directed
  graph, runtime tag map, device-reference graph, and rework warnings. Read it for any change
  crossing subsystem boundaries.
- [`verse-files/`](verse-files/) — snapshot of all 22 `.verse` files. Read the relevant
  source files after the overview. Edit the source in `MCSkyblockTycoon`, not this snapshot,
  then refresh the snapshot or mark it stale.

## The game, start to finish

1. A player claims a floating plot via `plot_claim_device.verse`
   (`AddPlayerToPlot()` binds the player to a chain of "Tycoon Nodes").
2. Nodes are `pressure_plate_with_generator` devices. Standing on a plate with enough gold
   purchases the upgrade: cost deducted, `AddToGoldPerSecond()` raised, props revealed,
   next node(s) activated.
3. `tycoon_currency_manager.verse` is the economy brain: holds `GoldPerSecond`, `StoredGold`,
   `UsableMultiplier`, `RebirthCount`; grants gold as inventory items through an
   `item_granter_device` configured with 10 denominations (1 → 1B); pays out `StoredGold`
   at claim props (`CheckClaim()`).
4. **Rebirth** (prestige): resets all purchases, keeps a permanent multiplicative earning
   bonus, restarts at the first node.
5. `UI_Trackers.verse` renders the HUD and map indicator.
6. **Events**: `event_manager.verse` defines an abstract `game` class with timed events;
   `color_switch.verse` and `king_of_the_hill.verse` subclass it and pay out gold.
7. **Side features**: pets (rebirth-gated), giftboxes, gun store + SpaceStage (Marketplace
   V-Bucks entitlements), playtime rewards/accolades, NPC mobs (Giant/Skeletons over
   `BehaviorHelper`), ambient chickens, generic prop animations, intro, respawn backup.

## Hard-won architecture facts (do not violate blindly)

- **One global save map**: `PlayerProfileDataMap` = `weak_map(player, player_save_data)`,
  declared at file scope in `pressure_plate_with_generator.verse`. `player_save_data` is
  `persistable` (rebirths, multiplier, `ActivityMap[int]int` 0/1/2, seconds active,
  `NodeSaveSchemaVersion`). All persistence flows through this ONE map — adding a second
  save store will fragment state.
- **Tag-based discovery instead of device references**: devices find each other with
  `FindCreativeObjectsWithTag`. Tags: `gold_currency_manager`, `purchase_audio`,
  `tycoon_node`, `creature_spawner_tag`, `gold_remover_tag`, `ui_system_tag`,
  `gold_counter_tag` (legacy). New systems should follow the same tag pattern.
- **Two node-chaining modes**: explicit `CommonlyUsed.NextManagers` references, OR
  automatic spatial chaining — a node tagged `tycoon_node` finds the nearest node ahead
  along the map `+Y` axis (`GetAutomaticNextManagers`). The spatial mode is what lets
  MCP duplicate a tagged node without wiring device refs.
- **Compile-time cycle**: `tycoon_currency_manager ↔ pressure_plate_with_generator ↔
  UI_Trackers` all compile as one subsystem — rework them together.
- **Gold is inventory items**: read current gold via `GetItemCount`; deduct via a shared
  `conditional_button_device`; grant via the shared 10-denomination granter. Don't invent
  a parallel economy.
- **Node save keys**: legacy nodes use dynamic `PlateIndex` (graph traversal, `GetAndIncrementIndex`);
  newer nodes can opt into a stable `StableNodeId` so saved state survives graph edits.
  `GetPersistenceKey()` chooses between them; `MigrateLegacyNodeStates` repairs v0 saves
  once per player.
- **Multiplayer**: all Verse runs server-side; every persistent widget is created per
  player/agent and stored in a per-agent map, refreshed on `Sleep` loops, added to
  `GetPlayerUI[Player]`. Co-op plots use `OwningPlayers` arrays; `GrantGold` grants the
  pool to the first claiming player deliberately (not duplicated per co-owner).

## How to extend / rework safely

1. Start from `verse-overview.md` section for the file you touch, then read the actual
   verse source in the MCSkyblockTycoon project (snapshot may lag).
2. Trace the data flow through the tag map + dependency graph before editing — a change
   in `pressure_plate_with_generator` ripples to 6+ files.
3. Keep save-state schema changes versioned: bump `NodeSaveSchemaVersion` and add a
   migration, never mutate legacy states in place.
4. For new purchasable nodes: create a `pressure_plate_with_generator` (or subclass),
   tag it `tycoon_node`, position it +Y of the previous node for auto-chaining, and
   configure its generator + props.
5. Build/verify through the native UEFN MCP integration: discover the current Verse and
   Session toolsets, run `BuildAll`, start a PIC session, wait for it to connect, exercise
   the changed path, and query `GetClientLogEntries` with a relevant non-empty pattern.
   Inspect the actual returned errors/logs; a tool call completing is not itself a pass.
6. After any edit to the source, refresh the snapshot in `verse-files\` (recopy the 22
   files) so the knowledge base stays current.

## Known pain points (the user's words: "a pain to connect and link up")

- Device references must be wired in the editor; the tag + spatial-chaining system exists
  to reduce that burden — prefer it for anything new.
- The 3-file compile cycle makes isolated edits awkward.
- Migrations and stable node IDs are the guardrails when the graph changes.

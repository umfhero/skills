---
name: uefn-build
description: >-
  Build or place content in UEFN through Epic's MCP server, including materials, props,
  meshes, buildings, actors, imported assets, and larger level layouts. Use for requests
  such as "build a city", "place this prop", or "make a red material".
---

# UEFN-build

Daily-driver skill for building Fortnite levels through UEFN's official MCP server. It
combines the transport discipline of `uefn-mcp` with a build/place/material workflow.

## Before changing the level

1. Read [`../UEFN-MCP/SKILL.md`](../UEFN-MCP/SKILL.md); its transport, discovery, safety,
   and version-drift rules apply here.
2. Confirm the active UEFN project and current level match the user's target. Inspect existing
   actors/assets and preserve unrelated dirty editor work.
3. Prefer the agent's configured MCP connection. If raw HTTP is genuinely needed, initialise
   a session, retain its `Mcp-Session-Id`, and make every request serially.
4. For a multi-step build, state the intended objects, rough transforms, reused assets, and
   verification target before mutating the editor.

## Build loop (the "say it, I build it" flow)

For every build task, follow this loop and VERIFY at each stage:

```
1. DISCOVER   list_toolsets + describe_toolset (never guess tool names/args)
2. FIND       what exists: find_assets (materials/textures/meshes), find_actors, list_folders
3. SPAWN      add_to_scene_from_class (e.g. /Script/Engine.StaticMeshActor)
4. SHAPE      primitive.add_cube/sphere/cylinder/cone (OMIT dimensions — default 100cm)
              OR assign an existing StaticMesh via set_properties (StaticMeshComponent.StaticMesh)
5. MATERIAL   create/use material or MaterialInstance, apply via overrideMaterials
6. PLACE      set transform (get_actor_transform / set via set_properties, actor location/rotation/scale)
7. SAVE       save only the named assets/level changed by this task
8. VERIFY     matching read tools + FocusOnActors + CaptureViewport image and metadata
```

UEFN's current Python toolsets translate between XYZ and UEFN's LUF coordinate convention
imperfectly. Before repeating a transform across a large layout, make one reversible placement
and verify the actual direction, rotation, scale, and ground contact.

## Proven working request bodies

The complete, copy-ready set is in
[`../UEFN-MCP/tests/working-examples.md`](../UEFN-MCP/tests/working-examples.md). The most
useful examples are below.

### Spawn a cube building block
```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.scene.SceneTools","tool_name":"add_to_scene_from_class","arguments":{"actor_type":{"refPath":"/Script/Engine.StaticMeshActor"},"name":"Building_01","xform":{"location":{"x":0,"y":0,"z":100},"rotation":{"pitch":0,"yaw":0,"roll":0},"scale":{"x":1,"y":1,"z":1}}}}}}
```

### Add a cube primitive to that actor (default 100cm — omit dimensions!)
```json
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.primitive.PrimitiveTools","tool_name":"add_cube","arguments":{"actor":{"refPath":"<ACTOR_REF>"},"name":"Cube_01"}}}}
```

### Create a solid-colour material
```json
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.material.MaterialTools","tool_name":"create_material","arguments":{"folder_path":"/Game","asset_name":"M_Red"}}}}
```
Then add a `MaterialExpressionConstant3Vector`, set `constant` via `set_properties`, connect
to `MP_BaseColor`, recompile, save. (Full sequence documented in
[`../UEFN-MCP/first-run-findings/first-run-2026-08-20.md`](../UEFN-MCP/first-run-findings/first-run-2026-08-20.md).)

### Apply a material to a mesh component
```json
{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.object.ObjectTools","tool_name":"set_properties","arguments":{"instance":{"refPath":"<COMPONENT_REF>"},"properties":{"overrideMaterials":[{"refPath":"/Game/M_Red.M_Red"}]}}}}}
```

### Find content you already own
```json
{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.asset.AssetTools","tool_name":"find_assets","arguments":{"folder_path":"/Game","asset_type":{"refPath":"/Script/Engine.Texture2D"},"name":"Brick","recursive":true}}}}
```

### Remove a mistake
```json
{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.scene.SceneTools","tool_name":"remove_from_scene","arguments":{"actor":{"refPath":"<ACTOR_REF>"}}}}}
```

## Sourcing assets (the "use mine, find online, or make it" rule)

Priority order — ask the user or default to this:

1. **Already in project**: `find_assets` across `/Game` (filter by class: Texture2D,
   StaticMesh, MaterialInstance, SkeletalMesh, DataTable, CurveTable). Search names like
   "Brick", "Concrete", "Wood", "Fort", "Factory".
2. **Engine / Fortnite library**: `/Engine/BasicShapes/*` (Cube, Sphere, Cylinder, Cone),
   `Fortnite`-style packs under `/Game/Packages/...` (e.g. Fortress_Brick_Simple). Use
   `find_assets` to browse them. Textures: `texture.TextureTools.get_size` / `export_png`.
3. **Make it yourself**: primitives + materials + MaterialInstances. Composition (stacking
   cubes) is the fastest route to buildings. Use `material_instance.create` from a good base
   material for different colours rather than compiling many new materials.
4. **Online sourcing**: only with user permission (network/site use, licensing). If asked,
   find the asset provider, download to a temp folder, then import via
   `texture.TextureTools.import_file` / `static_mesh.StaticMeshTools.import`. NEVER hotlink
   or redistribute assets the user doesn't own.

## Materials cheat-sheet

- Prefer **MaterialInstance** over a new material (instances don't recompile shaders).
- New material = `create_material` → build the graph with expression tools
  (`add_expression`, `connect_to_output`, `set_properties` on the expression node) →
  `recompile` → `save_assets`.
- Apply to any mesh component with `set_properties(overrideMaterials=[...])`. Array of
  materials maps to the mesh's material slots (`static_mesh.get_material_slots` lists them).

## Building cities / large layouts (efficiency)

- Plan in a grid first; use Unreal units consistently (100 units = 1 metre), and reuse
  transforms.
- Reuse ONE material/material-instance across many actors instead of duplicating.
- Duplicate structures by spawning a new StaticMeshActor and assigning the same StaticMesh
  (the mesh asset is shared — cheap).
- Batch read-only checks (find_assets, get_material_slots) before mutating.
- Save each batch using the exact asset and level paths changed by the task. An empty
  `save_assets` list saves every dirty asset and must be treated as an explicit save-all.
- Verify with `GetVisibleActors` + `CaptureViewport` after big placements; the editor may
  hitch on many tool calls — pace them (server runs serially on the game thread).

## Verification & cleanup

- Confirm every mutation with the matching read tool (`get_properties`, `get_actor_transform`,
  `find_actors` by name).
- Confirm visual state by inspecting the `CaptureViewport` image as well as its camera and
  `labeledActors` metadata. Metadata alone does not prove appearance, occlusion, scale, or
  composition.
- On failure: read `result.content[0].text` — many tools return human-readable errors in
  `returnValue` rather than JSON-RPC errors; trust the error message's schema over the
  `describe_toolset` schema.
- Remove throwaway actors/materials created during the current task once their exact
  references are confirmed. Do not delete pre-existing content as cleanup.

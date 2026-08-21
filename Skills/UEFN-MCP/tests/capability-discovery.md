# UEFN MCP — Capability Discovery Report

Live session tested against `http://127.0.0.1:8000/mcp` (session `139dc83e466c2d4915b215865cdf0b5f`), UEFN editor PID 36028, project **MCP_KFMAP**, current level `/MCP_KFMAP/MCP_KFMAP`. Date: 2026-08-20.

## Transport / protocol notes

- JSON-RPC 2.0 over HTTP, streamable. Always send `Mcp-Session-Id` header. Use `curl.exe --data-binary "@file"` with ASCII JSON bodies; PowerShell's `Invoke-WebRequest`/`RestMethod` fail non-interactively.
- The server runs in **tool-search mode**: `tools/list` exposes only three meta-tools (`list_toolsets`, `describe_toolset`, `call_tool`). All real tools are behind `tools/call` → `call_tool` with `toolset_name` + unprefixed `tool_name`.
- `resources/list` returns `[]` (no resources). `prompts/list` is **not implemented** (`-32601 unknown method`).
- Responses are plain JSON (not SSE lines) in this mode. Tool results come back as `result.content[0].text` containing a JSON string with a `returnValue` field.
- Image-producing tools (CaptureViewport) additionally return a `content[1]` entry of `type: image` with base64 PNG in `data`.

## What exists (29 toolsets, 386 tools + 3 meta-tools)

### 1. EditorToolset.EditorAppToolset (37 tools)
Editor/application state: console variables (`GetCVarValue`, `SetCVarValue`, `SearchCVars`), selection (`GetSelectedActors`, `SelectActors`, `GetVisibleActors`, `FocusOnActors`), viewport camera (`GetCameraTransform`, `SetCameraTransform`, `WorldPosToScreenCoords`, `ScreenCoordsToWorld`), **image capture** (`CaptureViewport` with optional annotation overlay grid + actor labels, `CaptureEditorImage`, `CaptureAssetImage`, `GetAssetThumbnails`), content browser (`GetContentBrowserPath`, `SetContentBrowserPath`, `GetOpenAssets`), collections (list/create/destroy/add/remove/get), show flags + editor modes, notifications, PIE session control.

**Tested working:** GetSessionStatus, GetGameState, GetCameraTransform, GetSelectedActors, GetCVarValue, SearchCVars, SetCVarValue, GetVisibleActors, CaptureViewport (plain + bShowUI), FocusOnActors, SelectActors, SetCameraTransform, GetOpenAssets, GetContentBrowserPath, ListEditorModes, ListShowFlags.
**Fails:** `CaptureViewport` with `annotations` → `-32700 Invalid JSON body!` in every shape tried (see workarounds).

### 2. EditorToolset.LogsToolset (4 tools)
`GetLogCategories` (5063 categories returned), `GetLogEntries` (regex pattern + category + maxEntries), `GetVerbosity`, `SetVerbosity`. **Tested:** GetLogCategories, GetLogEntries — both work.

### 3. GameplayTagsToolset.GameplayTagsToolset (4 tools)
`ListTags` (70,746 tags), `ListTagsInSource`, `GetTagInfo`, `FindReferencersByTag`. **Tested:** ListTags, GetTagInfo (param is `tagName`). ListTagsInSource param is `tagSource` (INI filename).

### 4-7. NiagaraToolsets (Info 1, Component 4, System 46, Assets 3)
Niagara enum lookups (`UEnum_Info` — tested, works), runtime component variable manipulation, full Niagara System editing (schema/topology/summary introspection + module/renderer/emitter mutation), asset-registry discovery (`FindNiagaraScripts` — tested; returns 873 items but items serialize as `{}` — serialization gap, count is real).

### 8. MVVMToolset.MVVMToolset (15 tools)
UMG MVVM authoring: ViewModel discovery/creation, property additions, view bindings, conversion functions, event bindings, repair. **Tested:** ListViewModels (works, 10 VMs found).

### 9. PhysicsToolsets.PhysicsAssetToolset (17 tools)
Physics asset creation from mesh + body/shape/constraint CRUD. **Tested:** GetBodyNames (works on real physics asset).

### 10. VerseFieldsToolset.VerseFieldsToolset (6 tools)
Verse field authoring on Widget Blueprints (add/edit/remove/duplicate/list + MVVM bind).

### 11. WidgetAnimationToolset.WidgetAnimationToolset (10 tools)
UMG widget animation lifecycle + bindings (works on UMovieSceneSequence).

### 12. UMGToolSet.UMGToolSet (21 tools)
Widget tree manipulation: create widget blueprint, add/remove/move/wrap widgets, named slots, widget classes. **Tested:** ListWidgetBlueprints (works, empty in this project).

### 13. ValkyrieToolset.ValkyriePythonToolset (2 tools)
`IsPythonEnabledInUEFN` (tested → true), `EnablePythonInUEFN`.

### 14. ValkyrieToolset.VerseToolset (10 tools)
Virtual verse filesystem: ListFiles, ReadFile, WriteFile, Copy, Move, Delete, Grep, Replace, CreateDirectory, BuildAll. **Tested:** ListFiles (root = `""`), ReadFile (returns file contents), BuildAll (succeeds, no errors). **Gotcha:** path `"/"` fails with a helpful message telling you to pass `""`.

### 15. ValkyrieToolset.SessionToolset (8 tools)
Fortnite session control: StartSession, StopSession, StartGame, StopGame, PushChanges, GetSessionStatus, GetGameState, GetClientLogEntries. **Tested:** GetSessionStatus ("Disconnected"), GetGameState ("Unconnected"), GetClientLogEntries (requires live client; returns guidance otherwise).

### 16. ValkyrieToolset.DeviceToolset (9 tools)
Device placement + property editing: ListDeviceAssets (383 devices, tested), ListDeviceProperties, GetDeviceProperties, SetDeviceProperty, PlaceDevice, ListEventBindings/Add/Remove, GetBindingOptions. ListDeviceProperties validates the object is a ScriptDevice (returns descriptive error otherwise).

### 17. ValkyrieToolset.EntityToolset (13 tools)
Entity framework: ListEntityClasses (1482 classes, tested), FindEntities (tested, found TycoonCube entity), GetComponents (tested, returns entity components), ListComponentClasses (tested), plus component/property CRUD and transform ops.

### 18-29. editor_toolset.* (all tested where noted)
- **actor.ActorTools (18):** label/transform/tags/components/parenting. Tested get_label, get_actor_transform, get_components.
- **asset.AssetTools (17):** find_assets (search by folder/name/type/tags), list_folders, exists, load_asset, get_asset_class, delete, move, duplicate, create_folder, save/reload, metadata tags, dependencies/referencers. Tested find_assets (by name + by Texture2D/DataTable/CurveTable/SkeletalMesh/PhysicsAsset type), list_folders, exists, get_asset_class, delete.
- **curve_table.CurveTableTools (10):** create, list_rows, get_keys, add/remove/rename row, import. Tested list_rows, get_keys.
- **data_table.DataTableTools (11):** create, list_rows, get_rows, set_rows, add/remove/rename, get_schema, import. Tested get_schema, list_rows.
- **material.MaterialTools (25):** create_material (tested), get_expressions, get_statistics, list_expression_classes, add/delete/connect expressions, layout, recompile, diff. Tested get_expressions, get_statistics, list_expression_classes.
- **material_instance.MaterialInstanceTools (14):** create (tested — created MI from material), list_parameters, get/set scalar/vector/texture/static-switch params. Tested list_parameters (empty for M_Block_Red).
- **object.ObjectTools (6):** list_properties (returns property schema), get_properties, set_properties, reset_properties, get_class, search_subclasses. Tested list_properties, get_properties, get_class, search_subclasses.
- **primitive.PrimitiveTools (4):** add_cube (tested — works when `dimensions` omitted), add_sphere/cylinder/cone.
- **scene.SceneTools (28):** get_current_level, find_actors (by name/type/tag/bounds/data_layer), add_to_scene_from_class (tested — created a StaticMeshActor), remove_from_scene (tested), load_level, create_level, folders, data layers, level instances, trace_world, get_actor_asset_path. Tested get_current_level, find_actors, add_to_scene_from_class, remove_from_scene, get_actor_asset_path, get_folders, get_data_layers.
- **skeletal_mesh.SkeletalMeshTools (22):** bones, sockets, morph targets, materials, LODs, physics asset. Tested get_bone_names.
- **static_mesh.StaticMeshTools (17):** get_bounds, get_material_slots, get_material, LODs, collisions, nanite, import. Tested get_bounds, get_material_slots.
- **texture.TextureTools (4):** get_size (tested — 2048×2048), read_texture, export_png, import_file.

## Key capabilities for an AI agent

1. **Vision:** `CaptureViewport` returns a real PNG plus camera pose + FOV. Annotations (grid + labels) are documented but **currently broken** (−32700) — worth reporting upstream.
2. **Scene understanding:** `GetVisibleActors` (frustum), `find_actors` (rich filters), `get_actor_transform`, `get_components`, `get_label`, OFPA path lookup via `get_actor_asset_path`.
3. **Asset graph:** `find_assets` with class filters, `exists`, `get_asset_class`, dependencies/referencers, metadata tags.
4. **Content authoring:** material/MI creation, expression editing, primitive components, actor spawn/remove, static mesh LOD/collision editing, data/curve tables, textures, physics assets, UMG/MVVM/widget animations, Niagara systems, verse file access + build.
5. **Play session:** start/stop/push, status queries, client log grep.

## Notable limitations / bugs observed

- `prompts/list` → `-32601` (not implemented).
- `CaptureViewport.annotations` → `-32700` regardless of argument shape (null, omitted, or full classFilter ref). Plain capture and `bShowUI` work.
- `SetCameraTransform` → `-32700` if `scale` is included; works when `scale` omitted.
- `PrimitiveTools.add_cube` → `-32700` if `dimensions` is passed; works when omitted (default 100cm cube used).
- `ObjectTools.get_properties` → `-32700` when a requested property name does not exist on the object. Must use exact names from `list_properties`.
- `NiagaraToolset_Assets.FindNiagaraScripts` returns items that serialize as `{}` (count 873 is real, payload empty — serialization gap).
- Some tools return human-readable errors as `returnValue` text instead of JSON-RPC errors (e.g. ListDeviceProperties on non-ScriptDevice, VerseToolset.ListFiles path `"/"`, GetClientLogEntries without a session).
- `EditorToolset.LogsToolset.GetLogEntries` returned `[]` for `category=LogTemp` but matched entries with an empty category + regex pattern — category matching appears case/format sensitive.
- GameplayTags `GetTagInfo`/`ListTagsInSource`/Session `GetClientLogEntries` schema in describe uses different param names than they actually require (`tagName` vs `tag`, `tagSource`, `pattern` required non-empty). Always follow the *error message's* schema over the describe output.

## Environment state at the end of testing

- All test assets created were deleted again (material `M_Test_Ai_Probe_*`, MI, cube actor + component).
- Original camera transform restored; original TycoonCube selection restored.
- Editor left running.
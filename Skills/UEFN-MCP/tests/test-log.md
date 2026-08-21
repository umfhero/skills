# UEFN MCP — Test Log (chronological)

Session: `139dc83e466c2d4915b215865cdf0b5f` · Transport: curl.exe POST to `http://127.0.0.1:8000/mcp` with JSON body files in `C:\Users\umfhe\AppData\Local\Temp\opencode\`. All calls serialized (one at a time).

Legend: PASS = expected success · FAIL = error or wrong result · WARN = success with caveat.

## Discovery

| # | Call | Result | Verdict |
|---|------|--------|---------|
| 1 | `tools/list` | 3 meta-tools: list_toolsets, describe_toolset, call_tool | PASS |
| 2 | `resources/list` | `{"resources":[]}` | PASS (no resources exposed) |
| 3 | `prompts/list` | `-32601 Call to unknown method "prompts/list"` | FAIL (not implemented) |
| 4 | list_toolsets | 29 toolsets listed (raw saved: `raw_list_toolsets.json`) | PASS |
| 5-33 | describe_toolset × 29 | Full schemas for all toolsets (raw: `raw_describe_01..29.json`) | PASS — 386 tools total |

## Functional tests (PASS unless noted)

| # | Toolset / Tool | Args | Result | Verdict |
|---|----------------|------|--------|---------|
| 200 | SessionToolset/GetSessionStatus | {} | `"Disconnected"` | PASS |
| 201 | SessionToolset/GetGameState | {} | `"Unconnected"` | PASS |
| 202 | LogsToolset/GetLogCategories | filter="" | 5063 categories | PASS |
| 203 | LogsToolset/GetLogEntries | category=LogTemp, max=30 | `[]` | WARN — empty (category filter no match) |
| 204 | LogsToolset/GetLogEntries | category="", pattern=MCP | matched real log lines | PASS |
| 205 | EditorAppToolset/GetCameraTransform | {} | loc(-62.4,-81.7,178.6) rot(-37.4,52.6,0) | PASS |
| 206 | EditorAppToolset/GetSelectedActors | {} | [TycoonCube refPath] | PASS |
| 207 | EditorAppToolset/GetCVarValue | r.VSync | `"0"` | PASS |
| 208 | EditorAppToolset/SearchCVars | r.VolumetricFog | JSON dict of cvars+values | PASS |
| 209 | EditorAppToolset/SetCVarValue | r.VSync=0 (no-op write-back) | null | PASS |
| 210 | EditorAppToolset/GetVisibleActors | {} | ~30 actors in frustum | PASS |
| 211 | EditorAppToolset/CaptureViewport | {} | PNG (1.99MB) + camera/FOV/grid/labeledActors; saved `capture_viewport_noannot.png` | PASS |
| 212 | EditorAppToolset/CaptureViewport | annotations{...,classFilter:null,...} | **-32700 Invalid JSON body!** | FAIL |
| 213 | EditorAppToolset/CaptureViewport | annotations{classFilter omitted} | **-32700** | FAIL |
| 214 | EditorAppToolset/CaptureViewport | annotations{classFilter:{refPath:/Script/Engine.Actor}} | **-32700** | FAIL |
| 215 | EditorAppToolset/CaptureViewport | bShowUI=true | PNG returned | PASS |
| 216 | actor.ActorTools/get_label | TycoonCube | `"TycoonCube"` | PASS |
| 217 | actor.ActorTools/get_actor_transform | TycoonCube | loc(0,0,100) | PASS |
| 218 | object.ObjectTools/list_properties | TycoonCube | property schema (large) | PASS |
| 219 | scene.SceneTools/get_current_level | {} | `/MCP_KFMAP/MCP_KFMAP` | PASS |
| 220 | asset.AssetTools/exists | /Game/M_Block_Red.M_Block_Red | true | PASS |
| 221 | asset.AssetTools/exists | /Game | true | PASS |
| 222 | asset.AssetTools/find_assets | name=M_Block, recursive | asset list (M_Block_Red + Blockout meshes) | PASS |
| 223 | asset.AssetTools/list_folders | /Game | 90 folders | PASS |
| 225 | material.MaterialTools/get_expressions | M_Block_Red | 1 expr (Constant3Vector) | PASS |
| 226 | material.MaterialTools/get_statistics | M_Block_Red | instruction counts | PASS |
| 227 | material.MaterialTools/list_expression_classes | M_Block_Red, search=Parameter | 26 classes | PASS |
| 228 | static_mesh.StaticMeshTools/get_bounds | /Engine/BasicShapes/Cube.Cube | min(-50,-50,-50) max(50,50,50) | PASS |
| 229 | static_mesh.StaticMeshTools/get_material_slots | Cube.Cube | `["WorldGridMaterial"]` | PASS |
| 230 | object.ObjectTools/get_properties | [ActorLabel,bHidden,actorGuid,tags] | **-32700** | FAIL (invalid property name) |
| 231 | object.ObjectTools/get_properties | [bHidden] | `{"bHidden":false}` | PASS |
| 232 | object.ObjectTools/get_properties | [bHidden,tags,actorGuid] | valid JSON | PASS |
| 240 | asset.AssetTools/get_asset_class | M_Block_Red | `"Material"` | PASS |
| 241 | asset.AssetTools/find_assets | type=Texture2D, name=T_Bricks | 3 textures | PASS |
| 244 | texture.TextureTools/get_size | T_FORT_Bricks_Big_Cartoon | 2048×2048 | PASS |
| 242 | DeviceToolset/ListDeviceAssets | {} | 383 device assets | PASS |
| 243 | EntityToolset/ListEntityClasses | nameFilter="" | 1482 classes | PASS |
| 250 | EntityToolset/FindEntities | {} | 1 entity (TycoonCubeBP) | PASS |
| 251 | GameplayTagsToolset/ListTags | parentTag="" | 70,746 tags | PASS |
| 252 | ValkyriePythonToolset/IsPythonEnabledInUEFN | {} | true | PASS |
| 253 | NiagaraToolset_Assets/FindNiagaraScripts | all-empty filters | 873 items, each `{}` | WARN (serialization gap) |
| 254 | UMGToolSet/ListWidgetBlueprints | /Game | `[]` | PASS |
| 255 | MVVMToolset/ListViewModels | /Game | 10 VMs | PASS |
| 260 | VerseToolset/ListFiles | path="/" | friendly error: pass "" for root | WARN (helpful error) |
| 261 | VerseToolset/ListFiles | path="" | virtual FS listing | PASS |
| 262 | VerseToolset/ReadFile | /Verse.org (Verse)/Verse.digest.verse | file contents | PASS |
| 270 | material.MaterialTools/create_material | /Game + M_Test_Ai_Probe_20260820_193516 | refPath returned | PASS |
| 271 | material_instance.MaterialInstanceTools/create | parent=test material | MI refPath returned | PASS |
| 272 | scene.SceneTools/add_to_scene_from_class | StaticMeshActor, name+full xform | actor refPath | PASS |
| 273 | scene.SceneTools/find_actors | name=MCP_Test_Cube_... | descriptor with label/bounds | PASS |
| 274 | EditorAppToolset/FocusOnActors | actors=[test cube] | null (camera moved) | PASS |
| 276 | EditorAppToolset/SelectActors | actors=[test cube] | null | PASS |
| 275 | primitive.PrimitiveTools/add_cube | actor, name, dimensions={200,200,200} | **-32700** | FAIL |
| 277 | primitive.PrimitiveTools/add_cube | actor + name only (omit dimensions) | component refPath (default 100cm) | PASS |
| 278 | actor.ActorTools/get_components | test cube | StaticMeshComponent0 + MCP_Test_CubeComp | PASS |
| 280 | scene.SceneTools/remove_from_scene | test cube | true | PASS |
| 281 | asset.AssetTools/delete | test MI | true | PASS |
| 282 | asset.AssetTools/delete | test material | true | PASS |
| 283 | asset.AssetTools/exists | test material | false (verified gone) | PASS |
| 284 | scene.SceneTools/find_actors | name=MCP_Test_Cube_... | `[]` (verified gone) | PASS |
| 285 | scene.SceneTools/find_actors | type=ScriptDevice | `[]` (no devices in map) | PASS |
| 286 | scene.SceneTools/get_folders | {} | `[]` | PASS |
| 287 | EditorAppToolset/SetCameraTransform | full transform incl. scale | **-32700** | FAIL |
| 291 | EditorAppToolset/SetCameraTransform | transform without scale | null (camera restored) | PASS |
| 288 | EditorAppToolset/ListCollections | {} | `[]` | PASS |
| 289 | object.ObjectTools/get_class | PlayerSpawnerProp | BP class refPath | PASS |
| 290 | scene.SceneTools/get_actor_asset_path | PlayerSpawnerProp | OFPA external path | PASS |
| 292 | DeviceToolset/ListDeviceProperties | non-ScriptDevice ref | text error "not valid ScriptDevice" | WARN (type validation) |
| 293 | object.ObjectTools/search_subclasses | Actor + "FortPlayerStart" | 4 subclasses | PASS |
| 294 | scene.SceneTools/get_data_layers | {} | `[]` | PASS |
| 300-303 | asset.find_assets | types DataTable/CurveTable/SkeletalMesh/PhysicsAsset | hundreds of hits | PASS |
| 304 | material_instance.list_parameters | M_Block_Red | `[]` | PASS |
| 310 | PhysicsAssetToolset/GetBodyNames | Fortnite_M_Avg_Player_Physics | 16 bodies | PASS |
| 311 | skeletal_mesh.get_bone_names | SK_M_MALE_Base_Skeleton | ~130 bones | PASS |
| 312 | data_table.get_schema | WorldSettingsOverride | schema JSON | PASS |
| 313 | curve_table.get_keys | NavStrengths row="" | "Row does not exist" | WARN (needs real row) |
| 314 | curve_table.list_rows | NavStrengths | Husk/Smasher/SmasherOverride/HuskyOverride | PASS |
| 315 | curve_table.get_keys | NavStrengths row=Husk | 21 keyframe pairs | PASS |
| 320 | data_table.list_rows | WorldSettingsOverride | `[]` | PASS (no rows) |
| 321 | GameplayTags/GetTagInfo | tag=... | error: required param `tagName` | FAIL (wrong param name guessed) |
| 325 | GameplayTags/GetTagInfo | tagName=... | tag info with source | PASS |
| 322 | SessionToolset/GetClientLogEntries | {} | error: params required | FAIL (needs pattern) |
| 326 | SessionToolset/GetClientLogEntries | pattern="" | "Pattern must not be empty." | FAIL |
| 327 | SessionToolset/GetClientLogEntries | pattern=LogTemp | "No client log found; start PIE first" | WARN (correct for state) |
| 323 | EditorAppToolset/ListEditorModes | {} | 20 editor modes | PASS |
| 324 | EditorAppToolset/ListShowFlags | {} | ~130 show flags | PASS |
| 330 | EditorAppToolset/GetOpenAssets | {} | DaySequence_0 | PASS |
| 331 | EditorAppToolset/GetContentBrowserPath | {} | `/MCP_KFMAP` | PASS |
| 332 | EntityToolset/GetComponents | TycoonCube entity | 4 components | PASS |
| 333 | EntityToolset/ListComponentClasses | nameFilter="" | ~50 classes | PASS |
| 334 | GameplayTags/ListTagsInSource | sourcePath=... | error: required param `tagSource` | FAIL (wrong param guessed) |
| 335 | NiagaraToolset_Info/UEnum_Info | ENiagaraCoordinateSpace | enum values + descriptions | PASS |
| 340 | VerseToolset/BuildAll | {} | `[]` (no errors) | PASS |
| 341 | EditorAppToolset/SelectActors | reselect original TycoonCube | null | PASS (state restored) |

## Workarounds that worked (the "omit optional args" family)

1. **`CaptureViewport.annotations`** — broken in ALL shapes (null / omitted / refPath object). Do not pass `annotations`. Plain `CaptureViewport` and `bShowUI` work.
2. **`SetCameraTransform`** — omit `scale` (and any unneeded vector). `location`+`rotation` alone works.
3. **`PrimitiveTools.add_cube`** — omit `dimensions`; use defaults.
4. **`ObjectTools.get_properties`** — only request property names that appear in `list_properties` output; an unknown name → -32700.
5. **Verse `ListFiles`** — root path is `""`, not `"/"` (server tells you this).
6. **GameplayTags / Session param names** — trust the *error-message schema*, not describe_toolset: `GetTagInfo(tagName)`, `ListTagsInSource(tagSource)`, `GetClientLogEntries(pattern, maxResults, startLine)`.

## State restored at end

- Camera pose → original (-62.44,-81.66,178.59 / -37.40,52.60,0).
- Selection → original TycoonCube.
- Test material, MI, cube actor + cube component → deleted and verified gone.
- Editor still running; session still responsive.
# UEFN MCP — Working Examples (copy-paste ready)

Server: `http://127.0.0.1:8000/mcp`
Headers: `Content-Type: application/json` · `Accept: application/json, text/event-stream` · `Mcp-Session-Id: 139dc83e466c2d4915b215865cdf0b5f`
Method: `POST`, body via `--data-binary "@file"`.

Every body below was executed and returned a successful `result`. Reference actor used:
`/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDAF902_1295502816` (label "TycoonCube").

## Discovery

```json
{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}
{"jsonrpc":"2.0","id":2,"method":"resources/list","params":{}}
{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"call_tool","arguments":{"tool_name":"list_toolsets"}}}
{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"call_tool","arguments":{"tool_name":"describe_toolset","arguments":{"toolset_name":"EditorToolset.EditorAppToolset"}}}}
```

## Session + status

```json
{"jsonrpc":"2.0","id":200,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.SessionToolset","tool_name":"GetSessionStatus","arguments":{}}}}
{"jsonrpc":"2.0","id":201,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.SessionToolset","tool_name":"GetGameState","arguments":{}}}}
```

## Editor app / viewport

```json
{"jsonrpc":"2.0","id":205,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"GetCameraTransform","arguments":{}}}}
{"jsonrpc":"2.0","id":206,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"GetSelectedActors","arguments":{}}}}
{"jsonrpc":"2.0","id":210,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"GetVisibleActors","arguments":{}}}}
{"jsonrpc":"2.0","id":207,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"GetCVarValue","arguments":{"name":"r.VSync"}}}}
{"jsonrpc":"2.0","id":209,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"SetCVarValue","arguments":{"name":"r.VSync","value":"0"}}}}

// Viewport capture → PNG in content[1].data (base64). DO NOT add "annotations" (broken).
{"jsonrpc":"2.0","id":211,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"CaptureViewport","arguments":{}}}}

// Set camera — IMPORTANT: omit "scale" (including it → -32700).
{"jsonrpc":"2.0","id":291,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"SetCameraTransform","arguments":{"transform":{"location":{"x":-62.435978071403412,"y":-81.663234993923211,"z":178.59388031023184},"rotation":{"pitch":-37.399988085031517,"yaw":52.600123792886734,"roll":0}}}}}}

// Select / focus actors
{"jsonrpc":"2.0","id":276,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"SelectActors","arguments":{"actors":[{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDAF902_1295502816"}]}}}}
{"jsonrpc":"2.0","id":274,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"FocusOnActors","arguments":{"actors":[{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDAF902_1295502816"}]}}}}

// Read-only: modes, flags, open assets, content browser path
{"jsonrpc":"2.0","id":323,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"ListEditorModes","arguments":{}}}}
{"jsonrpc":"2.0","id":331,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.EditorAppToolset","tool_name":"GetContentBrowserPath","arguments":{}}}}
```

## Logs

```json
{"jsonrpc":"2.0","id":202,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.LogsToolset","tool_name":"GetLogCategories","arguments":{"filter":""}}}}
{"jsonrpc":"2.0","id":204,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"EditorToolset.LogsToolset","tool_name":"GetLogEntries","arguments":{"category":"","pattern":"MCP","maxEntries":20}}}}
```

## Actor / object introspection

```json
{"jsonrpc":"2.0","id":216,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.actor.ActorTools","tool_name":"get_label","arguments":{"actor":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDAF902_1295502816"}}}}}}
{"jsonrpc":"2.0","id":217,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.actor.ActorTools","tool_name":"get_actor_transform","arguments":{"actor":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDAF902_1295502816"}}}}}}
{"jsonrpc":"2.0","id":278,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.actor.ActorTools","tool_name":"get_components","arguments":{"actor":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDAF902_1295502816"}}}}}}
{"jsonrpc":"2.0","id":218,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.object.ObjectTools","tool_name":"list_properties","arguments":{"instance":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDAF902_1295502816"}}}}}}
// get_properties: use ONLY names returned by list_properties (unknown name → -32700)
{"jsonrpc":"2.0","id":232,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.object.ObjectTools","tool_name":"get_properties","arguments":{"instance":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDAF902_1295502816"},"properties":["bHidden","tags","actorGuid"]}}}}}
{"jsonrpc":"2.0","id":289,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.object.ObjectTools","tool_name":"get_class","arguments":{"instance":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.BP_Creative_Player_Spawner_Prop_C_1"}}}}}}
{"jsonrpc":"2.0","id":293,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.object.ObjectTools","tool_name":"search_subclasses","arguments":{"base_class":{"refPath":"/Script/Engine.Actor"},"class_name":"FortPlayerStart"}}}}
```

## Scene

```json
{"jsonrpc":"2.0","id":219,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.scene.SceneTools","tool_name":"get_current_level","arguments":{}}}}
{"jsonrpc":"2.0","id":273,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.scene.SceneTools","tool_name":"find_actors","arguments":{"name":"MCP_Test_Cube_20260820_193516","collision_channels":[]}}}}
{"jsonrpc":"2.0","id":290,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.scene.SceneTools","tool_name":"get_actor_asset_path","arguments":{"actor":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.BP_Creative_Player_Spawner_Prop_C_1"}}}}}}

// Create a StaticMeshActor at a world transform
{"jsonrpc":"2.0","id":272,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.scene.SceneTools","tool_name":"add_to_scene_from_class","arguments":{"actor_type":{"refPath":"/Script/Engine.StaticMeshActor"},"name":"MCP_Test_Cube_20260820_193516","xform":{"location":{"x":1500,"y":1500,"z":100},"rotation":{"pitch":0,"yaw":0,"roll":0},"scale":{"x":1,"y":1,"z":1}}}}}}

// Remove an actor
{"jsonrpc":"2.0","id":280,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.scene.SceneTools","tool_name":"remove_from_scene","arguments":{"actor":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDBF902_1572915993"}}}}}}
```

## Primitives

```json
// add_cube — IMPORTANT: omit "dimensions" (passing it → -32700); default is 100cm cube
{"jsonrpc":"2.0","id":277,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.primitive.PrimitiveTools","tool_name":"add_cube","arguments":{"actor":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.StaticMeshActor_UAID_74563C41925DDBF902_1572915993"},"name":"MCP_Test_CubeComp"}}}}
```

## Assets

```json
{"jsonrpc":"2.0","id":220,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.asset.AssetTools","tool_name":"exists","arguments":{"path":"/Game/M_Block_Red.M_Block_Red"}}}}
{"jsonrpc":"2.0","id":223,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.asset.AssetTools","tool_name":"list_folders","arguments":{"root_path":"/Game","recursive":false}}}}
{"jsonrpc":"2.0","id":222,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.asset.AssetTools","tool_name":"find_assets","arguments":{"folder_path":"/Game","name":"M_Block","recursive":true}}}}
// find by type (refPath = /Script/Engine.<ClassName>)
{"jsonrpc":"2.0","id":241,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.asset.AssetTools","tool_name":"find_assets","arguments":{"folder_path":"/Game","asset_type":{"refPath":"/Script/Engine.Texture2D"},"name":"T_Bricks","recursive":true}}}}
{"jsonrpc":"2.0","id":240,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.asset.AssetTools","tool_name":"get_asset_class","arguments":{"asset_path":"/Game/M_Block_Red.M_Block_Red"}}}}
{"jsonrpc":"2.0","id":281,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.asset.AssetTools","tool_name":"delete","arguments":{"path":"/Game/MyAsset.MyAsset"}}}}
```

## Materials

```json
// Create a material (shader compile — use sparingly)
{"jsonrpc":"2.0","id":270,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.material.MaterialTools","tool_name":"create_material","arguments":{"folder_path":"/Game","asset_name":"M_Test_Ai_Probe_20260820_193516"}}}}
{"jsonrpc":"2.0","id":226,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.material.MaterialTools","tool_name":"get_statistics","arguments":{"material":{"refPath":"/Game/M_Block_Red.M_Block_Red"}}}}
{"jsonrpc":"2.0","id":225,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.material.MaterialTools","tool_name":"get_expressions","arguments":{"material_or_function":{"refPath":"/Game/M_Block_Red.M_Block_Red"}}}}
{"jsonrpc":"2.0","id":227,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.material.MaterialTools","tool_name":"list_expression_classes","arguments":{"material_or_function":{"refPath":"/Game/M_Block_Red.M_Block_Red"},"search":"Parameter"}}}}

// Material instance (preferred over new material)
{"jsonrpc":"2.0","id":271,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.material_instance.MaterialInstanceTools","tool_name":"create","arguments":{"folder_path":"/Game","asset_name":"M_Test_Ai_Probe_MI_20260820_193516","parent":{"refPath":"/Game/M_Test_Ai_Probe_20260820_193516.M_Test_Ai_Probe_20260820_193516"}}}}}}
```

## Static mesh / skeletal / physics / texture

```json
{"jsonrpc":"2.0","id":228,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.static_mesh.StaticMeshTools","tool_name":"get_bounds","arguments":{"mesh":{"refPath":"/Engine/BasicShapes/Cube.Cube"}}}}
{"jsonrpc":"2.0","id":229,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.static_mesh.StaticMeshTools","tool_name":"get_material_slots","arguments":{"mesh":{"refPath":"/Engine/BasicShapes/Cube.Cube"}}}}
{"jsonrpc":"2.0","id":311,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.skeletal_mesh.SkeletalMeshTools","tool_name":"get_bone_names","arguments":{"mesh":{"refPath":"/Game/Characters/Player/Male/Medium/Base/SK_M_MALE_Base_Skeleton.SK_M_MALE_Base_Skeleton"}}}}
{"jsonrpc":"2.0","id":310,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"PhysicsToolsets.PhysicsAssetToolset","tool_name":"GetBodyNames","arguments":{"physicsAsset":{"refPath":"/Game/Characters/Player/Male/Male_Avg_Base/Fortnite_M_Avg_Player_Physics.Fortnite_M_Avg_Player_Physics"}}}}
{"jsonrpc":"2.0","id":244,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.texture.TextureTools","tool_name":"get_size","arguments":{"texture":{"refPath":"/Game/Packages/Fortress_Brick_Simple/SM/Materials/T_FORT_Bricks_Big_Cartoon.T_FORT_Bricks_Big_Cartoon"}}}}
```

## Data / curve tables

```json
{"jsonrpc":"2.0","id":312,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.data_table.DataTableTools","tool_name":"get_schema","arguments":{"data_table":{"refPath":"/Game/Balance/DataTables/WorldSettingsOverride.WorldSettingsOverride"}}}}
{"jsonrpc":"2.0","id":314,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.curve_table.CurveTableTools","tool_name":"list_rows","arguments":{"curve_table":{"refPath":"/Game/Building/NavigationDataTables/NavStrengths.NavStrengths"}}}}
{"jsonrpc":"2.0","id":315,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"editor_toolset.toolsets.curve_table.CurveTableTools","tool_name":"get_keys","arguments":{"curve_table":{"refPath":"/Game/Building/NavigationDataTables/NavStrengths.NavStrengths"},"row_name":"Husk"}}}}
```

## Gameplay tags

```json
{"jsonrpc":"2.0","id":251,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"GameplayTagsToolset.GameplayTagsToolset","tool_name":"ListTags","arguments":{"parentTag":""}}}}
// NOTE: param is "tagName" (not "tag")
{"jsonrpc":"2.0","id":325,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"GameplayTagsToolset.GameplayTagsToolset","tool_name":"GetTagInfo","arguments":{"tagName":"Abilities.Activities.Demobomb.Armed"}}}}
```

## Entities / devices

```json
{"jsonrpc":"2.0","id":243,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.EntityToolset","tool_name":"ListEntityClasses","arguments":{"nameFilter":""}}}}
{"jsonrpc":"2.0","id":250,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.EntityToolset","tool_name":"FindEntities","arguments":{"bRecursive":true,"nameFilter":""}}}}
{"jsonrpc":"2.0","id":332,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.EntityToolset","tool_name":"GetComponents","arguments":{"entity":{"refPath":"/MCP_KFMAP/MCP_KFMAP.MCP_KFMAP:PersistentLevel.LevelEntity.LevelEntity.TycoonCubeBP_82x17z760qtw_1863518266"}}}}
{"jsonrpc":"2.0","id":242,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.DeviceToolset","tool_name":"ListDeviceAssets","arguments":{}}}}
```

## Verse filesystem + build

```json
// Root path is "" (not "/")
{"jsonrpc":"2.0","id":261,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.VerseToolset","tool_name":"ListFiles","arguments":{"path":"","bRecursive":true}}}}
{"jsonrpc":"2.0","id":262,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.VerseToolset","tool_name":"ReadFile","arguments":{"path":"/Verse.org (Verse)/Verse.digest.verse"}}}}
{"jsonrpc":"2.0","id":340,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.VerseToolset","tool_name":"BuildAll","arguments":{}}}}
```

## Niagara / Python / MVVM / UMG

```json
{"jsonrpc":"2.0","id":335,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"NiagaraToolsets.NiagaraToolset_Info","tool_name":"UEnum_Info","arguments":{"enum":{"refPath":"/Script/Niagara.ENiagaraCoordinateSpace"}}}}}
{"jsonrpc":"2.0","id":252,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"ValkyrieToolset.ValkyriePythonToolset","tool_name":"IsPythonEnabledInUEFN","arguments":{}}}}
{"jsonrpc":"2.0","id":255,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"MVVMToolset.MVVMToolset","tool_name":"ListViewModels","arguments":{"searchPath":"/Game"}}}}
{"jsonrpc":"2.0","id":254,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"UMGToolSet.UMGToolSet","tool_name":"ListWidgetBlueprints","arguments":{"folderPath":"/Game"}}}}
```
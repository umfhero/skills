---
name: uefn-mcp
description: Use when connecting to or operating Epic's official Unreal Editor for Fortnite (UEFN) MCP server, discovering its live toolsets, making raw HTTP calls, or diagnosing current protocol and tool-call failures.
---

# UEFN MCP

The official Model Context Protocol server built into UEFN (shipped 20 August 2026 in
Fortnite v42.00, beta). It embeds an MCP server in the `UnrealEditorFortnite` process;
compatible agents drive the editor over local HTTP.

## Read only what the task needs

Treat the live editor's discovered schemas as authoritative for the installed UEFN build.
Use these versioned references to avoid rediscovering verified v42.00 behaviour:

- For setup, scope, official capabilities, and limitations, read
  [`research/public-info.md`](research/public-info.md).
- For a raw JSON-RPC workflow, read [`tests/working-examples.md`](tests/working-examples.md).
- When selecting a toolset or diagnosing a v42.00 quirk, read
  [`tests/capability-discovery.md`](tests/capability-discovery.md).
- Consult only the relevant section of [`tests/tool-schemas.md`](tests/tool-schemas.md) when
  the live `describe_toolset` result is missing or contradictory.
- Use [`first-run-findings/`](first-run-findings/) for the tested cube/material workflow and
  first-hand transport failures.

## Connection essentials

- Endpoint: `http://127.0.0.1:8000/mcp` (default; port/path set in
  Editor Preferences > General > Model Context Protocol). The documented server name is
  `unreal-mcp`; the first v42.00 test returned an empty `serverInfo`, so do not use the name
  alone as a health check.
- Prerequisites in Project Settings: **Python Editor Scripting** AND **UEFN MCP Toolsets**
  both enabled, else the server will not function.
- Manual start if auto-start is off: console command `ModelContextProtocol.StartServer`
  (backtick key console). Restarting the editor is required to stop/start reliably.
- Transport: Streamable HTTP POST. JSON-RPC 2.0. `initialize` mints an `Mcp-Session-Id`
  (32-hex) that **must** be echoed on every later request.
- Tool-search mode is ON by default: `tools/list` returns only meta-tools
  `list_toolsets`, `describe_toolset`, `call_tool`. Set Enable Tool Search off to get
  eager advertisement (huge payload).
- Tools run **serially on the game thread** — never issue overlapping calls.
- Responses can be plain JSON or SSE (`event: message\ndata: {...}`). Tool results sit in
  `result.content[0].text` as a JSON string with a `returnValue` field. Image tools
  (CaptureViewport) add `content[1]` `{type:"image", data: "<base64 png>"}`.

## Safety and scope

- Keep the endpoint on loopback. Unreal MCP has no authentication layer and is unsafe to
  expose beyond the local machine.
- Before any mutation, confirm the active project, current level, selected targets, and the
  intended outcome. Use stable names and exact `refPath` values instead of acting on the
  first approximate match.
- Read before writing, keep multi-step changes small, and verify each mutation with the
  matching read tool. The beta tool surface and schemas can change between UEFN releases.
- Save only assets changed by the task. `save_assets([])` saves **every** dirty asset, so use
  an empty list only after confirming that saving unrelated dirty work is intended.
- Delete only temporary objects created during the current task, after resolving their exact
  references. Do not treat cleanup as permission to remove pre-existing content.

## The call shape (tool-search mode)

```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"call_tool","arguments":{"toolset_name":"<Toolset>.<Name>","tool_name":"<tool>","arguments":{...}}}}
```

Discovery:

```json
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"call_tool","arguments":{"tool_name":"list_toolsets"}}}
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"call_tool","arguments":{"tool_name":"describe_toolset","arguments":{"toolset_name":"editor_toolset.toolsets.asset.AssetTools"}}}}
```

## Known toolsets (v42.00 snapshot, verified live on 20 August 2026)

- `EditorToolset.EditorAppToolset` — editor state, CVars, selection, camera,
  `CaptureViewport`, content browser, collections, and editor play state.
- `EditorToolset.LogsToolset` — `GetLogCategories`, `GetLogEntries`, verbosity.
- `GameplayTagsToolset.GameplayTagsToolset` — tag lists/info/referencers.
- `NiagaraToolsets.*` — Niagara info/components/systems/assets.
- `MVVMToolset.MVVMToolset`, `VerseFieldsToolset`, `WidgetAnimationToolset`, `UMGToolSet` — UMG/MVVM.
- `PhysicsToolsets.PhysicsAssetToolset`, `editor_toolset.toolsets.skeletal_mesh.*` — physics/skinned meshes.
- `ValkyrieToolset.ValkyriePythonToolset` — only `IsPythonEnabledInUEFN` / `EnablePythonInUEFN`
  (NO arbitrary Python execution in this build).
- `ValkyrieToolset.VerseToolset` — virtual Verse filesystem: `ListFiles`, `ReadFile`,
  `WriteFile`, `Copy`, `Move`, `Delete`, `Grep`, `Replace`, `CreateDirectory`, `BuildAll`.
- `ValkyrieToolset.SessionToolset` — play-session lifecycle (PIC), status, client log.
- `ValkyrieToolset.DeviceToolset` — Creative device catalog, placement, `@editable` properties.
- `ValkyrieToolset.EntityToolset` — Verse Scene Graph entities/components.
- `editor_toolset.toolsets.actor|asset|material|material_instance|object|primitive|scene|
  static_mesh|texture|data_table|curve_table.*` — the UE 5.8 Python toolset family:
  `find_assets`, `create_material`, `create` (MI), `add_to_scene_from_class`, `remove_from_scene`,
  `add_cube/sphere/cylinder/cone`, `find_actors`, `get_properties`/`set_properties`, etc.

## Non-negotiable transport gotchas (learned the hard way)

1. Use `curl.exe`, NOT PowerShell `Invoke-WebRequest`/`RestMethod` (they fail
   non-interactively in this environment). Write the JSON body to a temp ASCII file and
   `--data-binary "@file"`.
2. Always send `Mcp-Session-Id`.
3. One request at a time, serial.
4. `-32700 "Invalid JSON body!"` often means an optional arg has the wrong shape or is null.
   **Retry by omitting the field**, never by passing null:
   - `add_cube`: omit `dimensions` (defaults 100cm cube).
   - `SetCameraTransform`: omit `scale`.
   - `CaptureViewport`: omit `annotations` (broken in every shape).
   - `get_properties`: only property names that exist (check `list_properties` first).
5. `VerseToolset.ListFiles` root path is `""`, not `"/"`.
6. Some describe schemas are wrong — trust the error message's schema over the describe
   output (e.g. `GetTagInfo` needs `tagName`, `ListTagsInSource` needs `tagSource`,
   `GetClientLogEntries` needs a non-empty `pattern`).
7. `CaptureViewport` with annotations → `-32700` (known bug, report upstream). Plain capture works.
8. No general Blueprint-asset factory or arbitrary Python executor was exposed in the tested
   v42.00 UEFN build. UMG-specific Widget Blueprint tools do exist. Discover the current
   surface before choosing placed scene actors or Scene Graph entities as a workaround.
9. UEFN documents an unresolved LUF-to-XYZ transform mismatch in the Python toolsets. For
   spatial work, confirm the coordinate mapping with a small reversible placement before a
   large layout.

## Workflows

- **Discover what's available first**: always `list_toolsets` + `describe_toolset` before
  guessing a tool name or argument.
- **Materials**: prefer a MaterialInstance (`material_instance.MaterialInstanceTools.create`)
  over a new material when possible; a new material costs a shader compile.
- **Placing content**: `scene.SceneTools.add_to_scene_from_class` (e.g.
  `/Script/Engine.StaticMeshActor`), then `primitive.PrimitiveTools.add_cube` on the actor,
  then `object.ObjectTools.set_properties` with `overrideMaterials` to colour it.
- **Actor refs**: discover rather than construct them. A typical shape is
  `/<Project>/<Map>.<Map>:PersistentLevel.<ActorName>.<Id>`.
- **Verify visually**: `FocusOnActors` + `CaptureViewport`; inspect the returned PNG together
  with `labeledActors` metadata (world position, screen position, and distance).
- **Save**: pass the exact created or changed asset paths to `save_assets`. For level actors,
  use the current level/actor save operation exposed by the live schema and verify the dirty
  state afterwards. The v42.00 test found `save_actor` returned `null`; do not equate that
  response with proof that the level was persisted. Reserve `save_assets([])` for an explicit
  save-all operation.

## Official docs to re-check (this ships fast)

- https://dev.epicgames.com/documentation/fortnite/uefn-mcp
- https://www.fortnite.com/news/unreal-mcp-is-now-available-in-uefn
- Full source catalogue: [`research/sources.md`](research/sources.md)

# UEFN MCP — Public Information

**Research compiled:** 20 August 2026; reviewed against Epic's live docs and local v42.00
tool discovery on 21 August 2026.
**Subject:** The Model Context Protocol (MCP) server built into Unreal Editor for Fortnite (UEFN), shipped by Epic Games in Fortnite v42.00 (20 August 2026).
**Scope:** Publicly available information only — official docs, announcements, forums, GitHub, media. Anything not independently confirmed is marked **[UNVERIFIED]**. British English spelling used throughout.

---

## 1. What it is

**UEFN MCP** embeds an MCP server inside the UEFN editor process (`UnrealEditorFortnite`). Any MCP-compatible AI agent — Epic names Claude Code, Cursor, Codex, Gemini, and the MCP Inspector — connects to it over a **local HTTP connection** and drives the editor through typed tools, grouped into **toolsets**.

- Official page: "UEFN MCP embeds an MCP server inside the Unreal Editor for Fortnite process for any MCP-compatible AI agent such as Claude Code, Cursor, or the MCP Inspector can drive the editor over a local HTTP connection." — https://dev.epicgames.com/documentation/fortnite/uefn-mcp
- Unreal MCP is the same plugin that shipped with **Unreal Engine 5.8** (Experimental), now made available in UEFN. — https://www.fortnite.com/news/unreal-mcp-is-now-available-in-uefn
- Announcement date: **20 August 2026**, alongside Fortnite v42.00. — https://forums.unrealengine.com/t/unreal-mcp-is-now-available-in-uefn/2745278
- Status: **beta** ("Unreal MCP in UEFN is in beta, so expect some rough edges and more capabilities on the way.") — https://www.fortnite.com/news/unreal-mcp-is-now-available-in-uefn
- Epic documents the advertised `ServerInfo.name` as **`unreal-mcp`**. The first local
  v42.00 session returned an empty `serverInfo`, so clients should not use that field alone
  as a health check. — https://dev.epicgames.com/documentation/fortnite/uefn-mcp and
  [`../first-run-findings/first-run-2026-08-20.md`](../first-run-findings/first-run-2026-08-20.md)

### Functionality exposed specifically for UEFN (per official docs)
1. Creating and modifying **Verse Scene Graph entities**
2. Reading and writing **Verse files**
3. Placing **Creative devices** and editing their properties
4. Starting, stopping, and inspecting a **play session**

— https://dev.epicgames.com/documentation/fortnite/uefn-mcp

The Fortnite blog adds that this includes "writing and compiling Verse, placing and configuring devices, creating Scene Graph entities, building UI with UMG, and running play sessions to test the results. Everything an agent makes is a real, editable part of your project." — https://www.fortnite.com/news/unreal-mcp-is-now-available-in-uefn

### Relationship to Unreal Engine 5.8's Unreal MCP
The plugin identifier in the engine source tree, `.uplugin` files, C++ symbols, and console commands is **`ModelContextProtocol`**. The friendly name **Unreal MCP** is what surfaces in the Plugin Browser and docs. Toolsets are *not* implemented by Unreal MCP itself; they come from the sibling **Toolset Registry** / **AllToolsets** plugin stack. — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

"Not every toolset from UE 5.8 is compatible with UEFN just yet. We're adding more UEFN features as we bring these development streams together on the road to UE6." — https://forums.unrealengine.com/t/unreal-mcp-is-now-available-in-uefn/2745278

---

## 2. How to enable and configure it

### 2.1 Project Settings (prerequisites)
UEFN MCP requires, in **Project Settings**, both of:
- **Python Editor Scripting** (enabled)
- **UEFN MCP Toolsets** (enabled)

"Both of these must be enabled for UEFN MCP to function." — https://dev.epicgames.com/documentation/fortnite/uefn-mcp

The prerequisite checklist in the docs is: (1) enable Python Editor Scripting, (2) configure MCP auto-start, (3) generate a client configuration file, (4) start an AI agent from the Fortnite UEFN install directory. — https://dev.epicgames.com/documentation/fortnite/uefn-mcp

### 2.2 Editor Preferences — Model Context Protocol
Under **Edit > Editor Preferences > General > Model Context Protocol**:

| Setting | Default | Description |
|---|---|---|
| **Auto Start Server** | `false` | Starts the MCP server automatically every editor launch |
| **Server Port Number** | `8000` | Port bound on `127.0.0.1` |
| **Server URL Path** | `/mcp` | URL path the server serves under |
| **Enable Tool Search** | `true` | `tools/list` returns the three meta-tools (`list_toolsets`, `describe_toolset`, `call_tool`) instead of every Tool schema |

With auto-start on, the server binds to `http://127.0.0.1:8000/mcp`. Port and path can be changed if the defaults conflict with another local service. — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

### 2.3 Starting on demand
- Leave **Auto Start Server** off and enter `ModelContextProtocol.StartServer` in the editor console (backtick key). The UE 5.8 reference documents an optional port as `ModelContextProtocol.StartServer 8000`. — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor
  - *(Note: the UEFN docs page contains a typo `ModelContentProtocol.StartServer` in one spot; the UE 5.8 docs and all console references use `ModelContextProtocol.StartServer`.)*

### 2.4 Console commands, flags, console variables (shared with UE 5.8)

Console commands:
| Command | Purpose |
|---|---|
| `ModelContextProtocol.StartServer [port]` | Start the server, optionally overriding the port |
| `ModelContextProtocol.StopServer` | Stop the server and close all sessions |
| `ModelContextProtocol.RefreshTools` | Re-poll registered tool providers; use after authoring or hot-reloading toolsets |
| `ModelContextProtocol.GenerateClientConfig <Client|All>` | Generate a config file for the named MCP client in the project root |

Command-line flags:
| Flag | Purpose |
|---|---|
| `-ModelContextProtocolStartServer` | Start the server during editor/commandlet startup regardless of Auto Start Server |
| `-ModelContextProtocolPort=N` | Override the listening port (1..65535); invalid values fall back to the setting |

Console variables:
| CVar | Default | Purpose |
|---|---|---|
| `ModelContextProtocol.WrapPODToolResultsInObject` | `true` | Wrap primitive Tool results in `{"result": ...}` for object-shaped responses |
| `ModelContextProtocol.AudioResultOggFormat` | `false` | Encode audio Tool results as OGG instead of WAV |
| `ModelContextProtocol.ProgressIntervalSeconds` | `1.0` | Minimum interval between MCP progress notifications |
| `ModelContextProtocol.PaginationPageSize` | `0` | Max items per paginated response; `0` disables pagination |
| `ModelContextProtocol.EnableAnalytics` | `true` | Gate telemetry emission |

Supported client names for `GenerateClientConfig`: **`ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`, and `All`**. JSON-format configs (Claude Code, Cursor, VS Code, Gemini) merge with existing entries; the Codex TOML config is **write-once** and a stale config must be removed manually. — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

### 2.5 Client configuration file
Each AI agent needs a server list file. UEFN docs walk through creating a `.mcp.json` manually in the project root (create a `.mcp.txt`, paste JSON, rename to `.mcp.json`). Example for Claude:

```json
{
  "mcpServers": {
    "unreal-mcp": {
      "type": "http",
      "url": "http://127.0.0.1:8000/mcp"
    }
  }
}
```

— https://dev.epicgames.com/documentation/fortnite/uefn-mcp

The UE 5.8 docs instead recommend the `ModelContextProtocol.GenerateClientConfig ClaudeCode` command, which writes the same file automatically. — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

### 2.6 Connecting an agent
Launch the AI agent CLI/application **from the project (or workspace) root** where the `.mcp.json` was generated. Troubleshooting tips from the docs:
- Verify the agent was launched from the root where the configs live.
- Try a different port if `8000` is taken (Editor Preferences → Server Port Number).
- Ensure both **Python Editor Scripting** and **UEFN MCP Toolsets** are enabled.
- "To start and stop the server, you must close and re-open the editor." Restart when in doubt.

— https://dev.epicgames.com/documentation/fortnite/uefn-mcp

### 2.7 Optional: Terminal plugin (UE 5.8 path)
UE 5.8 docs describe running the AI agent inside the editor via the **Terminal** plugin, setting `TERM=xterm-256color`, `cd`'ing to the directory where `.mcp.json` was written, then launching `claude`. — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

---

## 3. Protocol details

### 3.1 Endpoint & identity
- **Endpoint:** `http://127.0.0.1:8000/mcp` (loopback only by default; port/path configurable)
- **Server name:** documented as `unreal-mcp`; observed empty in the first local v42.00 test
- **Transport:** **Streamable HTTP** (HTTP POST with JSON responses and/or Server-Sent Events). The `stdio` and WebSocket transports are **not** supported.

### 3.2 JSON-RPC and sessions
- Uses the MCP JSON-RPC message set: `initialize`, `tools/list`, `tools/call`, notifications, etc. — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor
- **Session model:** verified live in UEFN v42.00. `initialize` returns an
  `Mcp-Session-Id`, which the client must echo on subsequent requests. Omitting it produced
  `-32600 Missing required Mcp-Session-Id header`. See
  [`../first-run-findings/first-run-2026-08-20.md`](../first-run-findings/first-run-2026-08-20.md).
- **Synchronisation:** "A key function of the MCP server is to synchronize external requests with the Unreal Engine game thread by executing Tool invocations on the game thread serially, meaning clients should not issue overlapping Tool calls." — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor
- **Security model:** loopback-only; binds per `[HTTPServer.Listeners] DefaultBindAddress` (default `localhost`); rejects non-loopback `Origin` headers; **no authentication layer**; not safe to expose beyond the local machine. — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

### 3.3 Tool Search mode
By default the plugin runs in **tool-search mode** (`bEnableToolSearch = true`). In this mode `tools/list` returns **three discovery meta-tools** instead of every advertised Tool:

| Meta-tool | Purpose |
|---|---|
| `list_toolsets` | Returns available toolset names and descriptions |
| `describe_toolset` | Returns the schemas for a named toolset |
| `call_tool` | Dispatches a named toolset's Tool with the supplied arguments and returns the result on the same turn |

This keeps `tools/list` responses small even when the registry exposes hundreds of Tools. Setting it to `false` reverts to eager advertisement of every Tool (much larger initial schema payload). Tool authors must not rely on eager advertisement. The meta-tools are part of the editor-only adapter. — https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

### 3.4 Toolsets and the Toolset Registry
- A **Toolset** is a class deriving from `UToolsetDefinition` (C++) or `unreal.ToolsetDefinition` (Python), exposing one or more functions marked as Tool calls.
- The **Toolset Registry** collects such classes at startup; Unreal MCP wraps each Tool call as an MCP Tool. The registry is also consumed by other AI surfaces in the engine, so a toolset authored for MCP works elsewhere unmodified.
- Most shipped toolsets (`SceneTools`, `ActorTools`, `MaterialInstanceTools`, `ObjectTools`, …) are authored in **Python** and live under a plugin's `Content/Python/` directory.
- Authoring conventions (Python): `@unreal.uclass()` + inherit `unreal.ToolsetDefinition`; decorate each advertised static method with `@toolset_registry.tool_call`; type hints and Google-style `Args:`/`Returns:` docstrings drive the JSON Schema.
- Authoring conventions (C++): derive from `UToolsetDefinition`, `UCLASS(BlueprintType, Hidden)`, expose `UFUNCTION(meta = (AICallable))`; suppress non-tools with `meta = (AIIgnore)`.
- Direct registration for dynamic tools: `IModelContextProtocolModule::GetChecked().AddTool(Tool);` (ticked from the core ticker, invoked on the game thread).
- After authoring: run `ModelContextProtocol.RefreshTools`. Live Coding picks up changed function bodies but **not** new `UFUNCTION` declarations — adding a Tool needs a full editor restart.

— https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

### 3.5 Debugging
- Startup bind address/port/path are logged to the **Output Log**; failures to bind surface there.
- `LogModelContextProtocol` log category; raise verbosity with `Log LogModelContextProtocol Verbose`.
- **MCP Inspector**: `npx @modelcontextprotocol/inspector`, then point it at `http://127.0.0.1:8000/mcp` over Streamable HTTP.
- `ModelContextProtocol.RefreshTools` re-polls toolsets when schemas look stale.

— https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

---

## 4. Documented UEFN toolsets and capabilities

The UEFN docs describe the functionality through the following feature/toolset mapping (the "What Other Features Does Unreal MCP Interact With?" table):

| Feature | Toolset / notes |
|---|---|
| **Toolset Registry** | How toolsets are discovered and exposed as MCP tools |
| **Verse** | The Verse toolset reads, edits, and compiles project Verse source |
| **Verse Scene Graph (Entities and Components)** | The Entity toolset's subject |
| **Creative Devices** | The Device toolset browses the catalog, places devices, and edits any `@editable` properties |
| **Sessions** | The Session toolset's play loop. UEFN plays using **Play-in-Client (PIC)**, not Play-in-Editor (PIE) like Unreal Engine |
| **Verse File Sandboxing** | Confines Verse file operations to the creator's project |

— https://dev.epicgames.com/documentation/fortnite/uefn-mcp

### 4.1 Suggested prompts per toolset (from official docs)
- **Verse**: list Verse files; read main Verse file and explain; search Verse files for a player-spawner reference; add a log message when the round starts, compile, report build status.
- **Verse Scene Graph Entities**: what entity classes/components can be created; create an entity at origin with a mesh component; read/move an entity's transform; list every entity and its components.
- **Creative Devices**: what devices can be placed; place a player spawner and a timer device.
- **Play Session**: start a play session; check session connectivity; start the game; push only the Verse changes to a running session; check the client log for errors and stop the session.

— https://dev.epicgames.com/documentation/fortnite/uefn-mcp

### 4.2 Toolset groupings reported in the UEFN editor
The local v42.00 discovery run verified that UEFN groups its Fortnite-specific tools into a
small number of top-level toolsets:

- **`EditorToolset`** — base editor tools, containing at least `EditorAppToolset` (editor state, console variables, asset imaging/screenshots, selection, camera) and `LogsToolset` (output-log reading, category listing, verbosity).
- **`ValkyrieToolset`** — the Fortnite-side toolset containing `VerseToolset` (Verse file read/write/compile), `SessionToolset` (play-session lifecycle, PIC), `DeviceToolset` (Creative device catalog/placement/properties), and `EntityToolset` (Verse Scene Graph entities and components).

The two `EditorToolset.*` members are also documented by the UE 5.8 catalog. The
`ValkyrieToolset` grouping and its `VerseToolset`, `SessionToolset`, `DeviceToolset`, and
`EntityToolset` children are verified by the repository's raw `list_toolsets` and
`describe_toolset` captures. Epic's public UEFN page refers to these by their shorter
feature names rather than publishing the full internal identifiers.

### 4.3 The UE 5.8 toolset catalog (for context — UEFN currently ships a subset)
The UEFN announcement says not every UE 5.8 toolset is UEFN-compatible yet. The full UE 5.8 `AllToolsets` surface (52 toolsets / ~830 tools) includes, among others:

- `EditorToolset.EditorAppToolset` (21 tools) — editor state, console variables, screenshots, selection, camera
- `EditorToolset.LogsToolset` (4 tools) — output-log reading and verbosity
- `editor_toolset.toolsets.actor.ActorTools` (17) — actor labels, tags, transforms, components, attachments
- `editor_toolset.toolsets.asset.AssetTools` (21) — asset discovery, metadata, save/load, dependencies
- `editor_toolset.toolsets.blueprint.BlueprintTools` (53) — Blueprint graph authoring, Graph DSL
- `editor_toolset.toolsets.material.MaterialTools` (22), `...material_instance.MaterialInstanceTools` (13)
- `editor_toolset.toolsets.object.ObjectTools` (6) — inspect/modify UObject properties
- `editor_toolset.toolsets.primitive.PrimitiveTools` (4) — primitive geometry components
- `editor_toolset.toolsets.scene.SceneTools` (20) — current level, actor discovery, folders, traces
- `editor_toolset.toolsets.static_mesh.StaticMeshTools` (16), `...skeletal_mesh.SkeletalMeshTools` (22), `...texture.TextureTools` (2)
- `editor_toolset.toolsets.programmatic.ProgrammaticToolset` (2) — batches calls through a sandboxed Python sandbox (includes the powerful `execute_tool_script`)
- Plus Sequencer/animation, Niagara, PCG, Dataflow, Control Rig, StateTree, UMG, Slate Inspector, GameplayTags, GAS, Game Features, Data Tables/Curve/String Tables, automation tests, and more.

— https://tc-imba.github.io/ue-official-mcp/references/toolsets (community-generated `describe_toolset` dump for UE 5.8.0)

---

## 5. Capabilities, workflows, and chaining

From the Fortnite blog, the four headline workflows are designed to **chain**:
1. **Write and iterate on Verse code** — read/write/compile Verse files; search across Verse files; iterate on compile errors until green. "Verse file operations are confined to your project, so an agent only ever touches your own files."
2. **Add and edit devices** — browse the device catalog, place Creative or Verse devices, edit properties (e.g. VFX Spawner with trigger settings).
3. **Create and edit Scene Graph entities** — create entities, add components, edit transforms/properties; inventory every entity and its components.
4. **Start, stop, and debug play sessions** — launch a session, check connectivity, push just the Verse changes to a running session, read the client log to diagnose failed starts.

"ask an agent to write the Verse, wire up the devices, then start a session and check the log to confirm it all works." — https://www.fortnite.com/news/unreal-mcp-is-now-available-in-uefn

### 5.1 Tips for best results (official)
- Be specific with naming ("the Timer device" not "that thing I added").
- Ask agents to list available tools (discovery tools reduce wrong guesses).
- Ask for a plan on multi-step requests and review before execution.
- Keep changes small and reviewable.

— https://dev.epicgames.com/documentation/fortnite/uefn-mcp

---

## 6. Known limitations and known issues

### 6.1 UEFN-specific (official Known Issues list)
1. **Coordinate system / transform translation LUF vs XYZ.** "Currently, the Python Toolsets use the XYZ format instead of the Left-Up-Forward (LUF) coordinate system." Asking an agent to convert sometimes works, but "potential for errors are multiplied."
2. **Hitching editor.** "MCP tool calls can cause the editor to hitch and hang. This is being looked into and evaluating ways to make tool calls more efficient in editor."

— https://dev.epicgames.com/documentation/fortnite/uefn-mcp

### 6.2 Plugin-level limitations (shared with UE 5.8, official)
- Only **HTTP and Server-Sent Events** supported; **no `stdio`, no WebSocket**.
- **Loopback only** by default; rejects non-loopback `Origin` headers; **no authentication layer**; not safe beyond the local machine.
- **No MCP Resources or Prompts** are advertised by any shipping toolset (tools only).
- Toolset Registry adapter is **editor-only**; cooked/shipping builds can host a server but must register tools via `IModelContextProtocolModule::AddTool()`.
- **Live Coding does not propagate new `UFUNCTION` declarations** — adding a Tool requires an editor restart.
- Tool invocations run **serially on the game thread**; overlapping calls should not be issued.
- Tool Search meta-tools are part of the editor-only adapter; cooked-build direct registrations advertise tools eagerly.

— https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor

### 6.3 Operational quirks
- Server start/stop requires an editor restart. — https://dev.epicgames.com/documentation/fortnite/uefn-mcp
- Codex CLI config is write-once (TOML); stale configs must be removed by hand. — https://dev.epicgames.com/documentation/fortnite/uefn-mcp
- Community reports on the UE 5.8 preview noted connections being "instantly dropped" by the experimental server — https://forums.unrealengine.com/t/5-8-experimental-modelcontextprotocol-mcp-server-instantly-drops-connections/2729488
- A known Claude Code client bug can drop the `Mcp-Session-Id` header on Streamable HTTP servers, breaking `tools/list` on session-aware servers (generic MCP issue, likely relevant to any session-based client) — https://github.com/anthropics/claude-code/issues/70386

### 6.4 Security considerations (community-authored, for the UE plugin)
Epic's own Claude Code skills plugin README warns: "Localhost is not a trust boundary. … any process running as the same user on the same machine can connect." It also flags `ProgrammaticToolset.execute_tool_script` as arbitrary-Python execution inside the editor and warns against `--dangerously-skip-permissions`. — https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin

---

## 7. Timeline

| Date | Event |
|---|---|
| ~June 2026 | UE 5.8 ships with Experimental **Unreal MCP** plugin (`ModelContextProtocol`) + Toolset Registry + AllToolsets |
| 17 June 2026 | State of Unreal / Unreal Fest Chicago: UE6 announced, unifying UE5 + UEFN, with MCP + Claude/Gemini cited as the AI path (Early Access ~late 2027) — https://www.bitsminds.com/news/epic-unreal-engine-6-unified-mcp-claude-gemini-2026 |
| 28 June 2026 | Community feature request "Bring Unreal Engine 5.8 MCP Support to UEFN" — https://forums.unrealengine.com/t/bring-unreal-engine-5-8-mcp-support-to-uefn/2732157 |
| 29 June 2026 | horizOn blog covers the request and the MCP-for-UEFN concept — https://horizon.pm/blog/will-epic-games-bring-model-context-protocol-mcp-to-uefn-the-tech-behind-ai-assisted-verse-scripting |
| **20 August 2026** | **UEFN MCP ships in Fortnite v42.00**; announcement, docs, and feedback thread all published |
| 21 August 2026 | "MCP in UEFN" Creating in Fortnite livestream with Magnus Enebakk (2 PM ET) |

---

## 8. Third-party projects and wrappers

### 8.1 Pre-official community MCP bridges for UEFN (all predate v42.00)
These implement their own two-process bridge (external MCP host + in-editor Python listener) because the official server did not exist until August 2026:

| Project | Notes |
|---|---|
| `KirChuvakov/uefn-mcp-server` (MIT, ~62 stars, created 19 Mar 2026) | 28 tools for actors/assets/levels/viewport/Python; `mcp_server.py` (host, needs `pip install mcp`) + `uefn_listener.py` (UEFN embedded Python, stdlib only); main-thread safe via editor tick; heartbeat UI window — https://github.com/kirchuvakov/uefn-mcp-server |
| `quangdang46/uefn-verse-mcp` (9 stars, 166 commits) | FastMCP stdio host (`server/main.py`) + in-editor listener `Content/Python/uefn_tools/tools/mcp_bridge.py`; auto port discovery on 8765–8770; 31 direct tools + 354 `run_tool` registry entries — https://github.com/quangdang46/uefn-verse-mcp |
| `dylannalex/uefn-mcp` and `dylannalex/uefn-ai-toolkit` | Python-remote-execution-based driver; the toolkit is a Claude Code plugin with MCP server + skills + knowledge base — https://github.com/dylannalex/uefn-mcp |
| `meesv` `uefn-mcp` on PyPI (v0.1.6 / internal v1.6) | 47 tools; listener at `127.0.0.1:8766`; Verse-digest parsing; MVVM tooling; HTTP long-poll events — https://pypi.org/project/uefn-mcp |
| `TheGahbi/uefn-mcp-server` | Materials, devices, Verse-linking, scene editing, editor Python — https://github.com/TheGahbi/uefn-mcp-server |
| `hoodtronik/uefn-mcp` | Tools via UEFN Python + editor APIs — https://github.com/hoodtronik/uefn-mcp |
| `yAstrosss/PythonMCP-UEFN` | 42 tools; spawn/move actors, assets, device options, Verse build triggering — https://github.com/yAstrosss/PythonMCP-UEFN |
| `qfoldit/UEFN-VERSE-MCP` | Actor/asset/level/viewport surface with `run_tool`/`list_tools`/`describe_tool` — https://github.com/qfoldit/UEFN-VERSE-MCP |
| `CharonCodenix/uefn-mcp`, `tomv12-uefn-mcp` | Listings on the LobeHub MCP marketplace — https://lobehub.com/mcp/charoncodenix-uefn-mcp |
| **UEFN TOOLBELT** (`iflow-mcp/undergroundrap-uefn-toolbelt`) | 358+ Python tools across 55+ categories, AI-agent-ready dict returns (an automation library, not a standalone MCP server) — https://github.com/iflow-mcp/undergroundrap-uefn-toolbelt |

### 8.2 Ecosystem projects around Unreal MCP (UE 5.8)
| Project | Notes |
|---|---|
| `EpicGames/unreal-engine-skills-for-claude-code-plugin` (official, ~193 stars) | Claude Code plugin (marketplace `claude-plugins-official`) with `unreal-mcp` skill + SessionStart hook; targets UE (not UEFN-specific) — https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin |
| `soatori/unreal-mcp-skills` | Community Claude Code skill for the official Unreal MCP; includes a detailed tools reference (tool-search usage, Blueprint reading playbook, risk classification) — https://github.com/soatori/unreal-mcp-skills |
| `tc-imba/ue-official-mcp` | Offline, versioned `describe_toolset` catalog of the UE 5.8 surface (52 toolsets / 830 tools) for planning without a running editor — https://github.com/tc-imba/ue-official-mcp |
| `UEFN-Ducky/uefn-plugin-materials` | UEFN material editing skill bundle — https://github.com/UEFN-Ducky/uefn-plugin-materials |

---

## 9. Community reactions (short version)

- X (Twitter): "UEFN MCP Toolset is out so you no longer need python for MCP in 42.00" — @chillzuefn / @SupremeUEFN, 20 Aug 2026 — https://x.com/chillzuefn/status/2090329144337019032
- Instagram: fncreate post covering the 42.00 MCP plugin — https://www.instagram.com/p/DcQqvNWljXh/
- MSN Tech: "Speeding up development with AI: UEFN supports 'Unreal MCP' plugin starting Aug 20" — https://www.msn.com/en-us/news/technology/speeding-up-development-with-ai-uefn-supports-unreal-mcp-plugin-starting-aug-20/ar-AA2axVzi
- Forums: official Announcements + dedicated Feedback Thread — https://forums.unrealengine.com/t/unreal-mcp-feedback-thread/2743365

See `community-mentions.md` for the full write-up.

---

*Sources and access dates are catalogued in `sources.md`.*

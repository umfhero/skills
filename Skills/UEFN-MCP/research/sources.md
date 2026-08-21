# Sources — UEFN MCP research

**All URLs accessed on 20 August 2026** unless noted otherwise.

## Official Epic documentation

1. **UEFN MCP | Fortnite Documentation | Epic Developer Community**
   https://dev.epicgames.com/documentation/fortnite/uefn-mcp
   The primary official UEFN MCP page: what it is, prerequisites, enabling Python Editor Scripting + UEFN MCP Toolsets, auto-start config, `.mcp.json` client config, connecting agents, the feature/toolset table (Verse, Entity, Device, Session, Verse File Sandboxing), prompting suggestions, tips, and Known Issues (LUF vs XYZ coords, editor hitching).

2. **Unreal MCP in Unreal Editor | Unreal Engine 5.8 Documentation | Epic Developer Community**
   https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor
   The UE 5.8 parent documentation for the same plugin (`ModelContextProtocol`): plugin identifiers, Toolset Registry, authoring tools (Python + C++), configuration reference (Editor Preferences, console commands, command-line flags, console variables), Tool Search mode (`list_toolsets`/`describe_toolset`/`call_tool`), debugging, editor/runtime availability, and Limitations and Known Issues.

3. **42.00 Fortnite Ecosystem Updates and Release Notes | Epic Dev**
   https://dev.epicgames.com/documentation/fortnite/42-00-fortnite-ecosystem-updates-and-release-notes
   Confirms Unreal MCP shipped to UEFN in v42.00 (20 Aug 2026); links the blog and docs; lists other 42.00 features (touch gestures, Ability System, etc.).

## Official announcements / Epic media

4. **Unreal MCP is now available in UEFN — fortnite.com news (Fortnite and Creative)**
   https://www.fortnite.com/news/unreal-mcp-is-now-available-in-uefn
   Epic's announcement blog: embedded MCP server, agentic tools (Claude Code, Codex, Cursor), four headline workflows (Verse code, devices, Scene Graph entities, play sessions + UMG), beta status, Toolset Registry delivery, road-to-UE6 note, feedback thread link, and the 21 Aug livestream.

5. **Unreal MCP is now available in UEFN — Announcements, Epic Developer Community Forums**
   https://forums.unrealengine.com/t/unreal-mcp-is-now-available-in-uefn/2745278
   Forum announcement (rhyan.smith, 20 Aug 2026 1:00pm): plugin shipped with UE 5.8 now in UEFN; "Not every toolset from UE 5.8 is compatible with UEFN just yet"; links to blog, docs, and the Creating in Fortnite livestream (Unreal Engine / Fortnite Create YouTube + Twitch).

6. **Fortnite Ecosystem v42.00 — Announcements, Epic Developer Community Forums**
   https://forums.unrealengine.com/t/fortnite-ecosystem-v42-00/2745257
   v42.00 announcement; MCP in UEFN lead item; links release notes.

7. **Unreal MCP Feedback Thread — Epic Developer Community Forums**
   https://forums.unrealengine.com/t/unreal-mcp-feedback-thread/2743365
   Official feedback thread (Flak, 20 Aug 2026); invites feedback here and bugs in the Issues & Bug Reporting forums.

## Forum threads (community + Epic staff)

8. **Bring Unreal Engine 5.8 MCP Support to UEFN — Feedback & Requests, Epic Developer Community Forums**
   https://forums.unrealengine.com/t/bring-unreal-engine-5-8-mcp-support-to-uefn/2732157
   Community feature request (HoustonUFN1, 28 June 2026) that predates and anticipated the official feature; lists Verse scripting, error troubleshooting, device setup, Scene Graph, project organisation as desired uses.

9. **5.8 Experimental ModelContextProtocol (MCP) Server instantly drops connections — Epic Developer Community Forums**
   https://forums.unrealengine.com/t/5-8-experimental-modelcontextprotocol-mcp-server-instantly-drops-connections/2729488
   Bug report on the UE 5.8 experimental server: enable Unreal MCP + MCP Client Toolset, run `ModelContextProtocol.StartServer`, connections dropped; context on early UE 5.8 behaviour.

10. **Claude plugin? — Getting Started & Setup, Epic Developer Community Forums**
    https://forums.unrealengine.com/t/claude-plugin/2729449
    Q&A restating how the UE 5.8 Unreal MCP embeds a server in the editor for Claude Code/Cursor/MCP Inspector.

11. **UEFN validation error — Issues and Bug Reporting, Epic Developer Community Forums** (context only)
    https://forums.unrealengine.com/t/uefn-validation-error/1280318
    Old UEFN error log referencing the `valkyrie:application` link type — evidence that "Valkyrie" is an Epic internal Fortnite/application identifier.

12. **[Open-Source Project] UEFN TOOLBELT: 287+ Python Tools — Epic Developer Community Forums**
    https://forums.unrealengine.com/t/open-source-project-uefn-toolbelt-287-python-tools-for-world-building-verse-automation/2709005
    Community project announcement for UEFN Python automation (built for the 2026 Python 3.11 update).

## Third-party projects on GitHub

13. **KirChuvakov/uefn-mcp-server** — https://github.com/KirChuvakov/uefn-mcp-server
    MIT-licensed community MCP server for UEFN (created 19 Mar 2026, ~62 stars, 28 tools): `mcp_server.py` host + `uefn_listener.py` in-editor listener; docs/ setup, tools reference, architecture, troubleshooting.

14. **quangdang46/uefn-verse-mcp** — https://github.com/quangdang46/uefn-verse-mcp
    FastMCP stdio host + in-editor HTTP listener bridge; 31 direct tools + 354 `run_tool` registry entries; auto port discovery 8765–8770; main-thread queue via Slate tick.

15. **dylannalex/uefn-mcp** — https://github.com/dylannalex/uefn-mcp
    MCP server driving UEFN via Python remote execution ("Lets Claude build Fortnite maps for you inside UEFN").

16. **dylannalex/uefn-ai-toolkit** — https://github.com/dylannalex/uefn-ai-toolkit
    Claude Code plugin: MCP server over Python remote execution + skills + Fortnite Creative knowledge base; limits: one editor at a time, Verse compile is a manual click.

17. **TheGahbi/uefn-mcp-server** — https://github.com/TheGahbi/uefn-mcp-server
    Community server for building materials, placing/configuring devices, linking devices to Verse, editing scenes, and running editor Python.

18. **hoodtronik/uefn-mcp** — https://github.com/hoodtronik/uefn-mcp
    MCP tools for controlling UEFN through UEFN-supported Python and editor APIs.

19. **yAstrosss/PythonMCP-UEFN** — https://github.com/yAstrosss/PythonMCP-UEFN
    MCP server with 42 tools; actor/asset/device automation, arbitrary editor Python, Verse build + compile-result reading.

20. **qfoldit/UEFN-VERSE-MCP** — https://github.com/qfoldit/UEFN-VERSE-MCP
    MCP surface for actor/asset/level/viewport workflows with `run_tool`, `list_tools`, `describe_tool`.

21. **EpicGames/unreal-engine-skills-for-claude-code-plugin** — https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
    Official Epic Claude Code plugin (marketplace `claude-plugins-official`, ~193 stars): `unreal-mcp` skill + SessionStart hook for the UE 5.8 Unreal MCP; documents tool search, security, config; UE-targeted.

22. **soatori/unreal-mcp-skills** — https://github.com/soatori/unreal-mcp-skills (references/mcp-tools.md)
    Community Claude Code skill for official Unreal MCP with a detailed tools reference (tool-search usage examples, built-in toolset map, Blueprint reading playbook, limits and diagnostics, risk classification).

23. **tc-imba/ue-official-mcp** — https://github.com/tc-imba/ue-official-mcp
    Offline versioned `describe_toolset` catalog for UE 5.8 Unreal MCP (52 toolsets / 830 tools), with raw + curated Markdown, for planning without a running editor.

24. **tc-imba.github.io/ue-official-mcp/references/toolsets** — https://tc-imba.github.io/ue-official-mcp/references/toolsets
    The raw 52-toolset catalog with tool counts and descriptions (e.g. `EditorToolset.EditorAppToolset` 21, `EditorToolset.LogsToolset` 4, `editor_toolset.toolsets.*` family).

25. **iflow-mcp/undergroundrap-uefn-toolbelt (UEFN TOOLBELT)** — https://github.com/iflow-mcp/undergroundrap-uefn-toolbelt
    358+ UEFN Python tools across 55+ categories with AI-agent-ready structured returns; Python-automation library rather than a standalone MCP server.

26. **UEFN-Ducky/uefn-plugin-materials** — https://github.com/UEFN-Ducky/uefn-plugin-materials
    UEFN material editing/creation skills bundle (skills/materials/SKILL.md).

## Package registries / marketplaces

27. **uefn-mcp on PyPI** — https://pypi.org/project/uefn-mcp
    Community `uefn-mcp` package (v0.1.6, internal v1.6, released 1 May 2026; 47 tools): in-editor listener on 127.0.0.1:8766, stdio host, Verse-digest tooling, MVVM tools, HTTP long-poll events, `wait_for_events`.

28. **UEFN MCP Server by KirChuvakov | PulseMCP** — https://www.pulsemcp.com/servers/gh-kirchuvakov-uefn
    Directory listing of the KirChuvakov server (28 tools, community-classified).

29. **LobeHub MCP marketplace listings** — https://market.lobehub.com/s/plugins/kirchuvakov-uefn-mcp-server , https://market.lobehub.com/s/plugins/thegahbi-uefn-mcp-server , https://market.lobehub.com/s/plugins/charoncodenix-uefn-mcp , https://market.lobehub.com/s/plugins/tomv12-uefn-mcp
    Marketplace entries for community UEFN MCP servers.

30. **mcpmarket.com — UEFN Toolbelt / Verse Docs** — https://mcpmarket.com/server/uefn-toolbelt , https://mcpmarket.com/server/verse-docs
    Listings for UEFN Python automation and a Verse/UEFN API documentation MCP server.

31. **mcpworld.com — UEFN MCP Server / Verse MCP Server** — https://www.mcpworld.com/en/detail/4f898b1753334cada66e39d21dc7c532 , https://www.mcpworld.com/en/detail/225e4d6a6e426ca43c62118b17d6c4fd
    Directory entries (20 Mar 2026) for community UEFN and Verse-docs MCP servers.

32. **mcprepository.com — dylannalex uefn-mcp / uefn-ai-toolkit** — https://mcprepository.com/dylannalex/uefn-mcp
    Directory listing mirroring the dylannalex projects.

## Blogs / media

33. **Will Epic Games Bring Model Context Protocol (MCP) to UEFN? — horizOn Blog**
    https://horizon.pm/blog/will-epic-games-bring-model-context-protocol-mcp-to-uefn-the-tech-behind-ai-assisted-verse-scripting
    (29 June 2026) Analysis of the local-context gap, MCP basics, UE 5.8's experimental MCP plugin, and what native UEFN MCP would enable for Verse scripting; cites the forums feature request.

34. **Epic Unveils Unreal Engine 6, Merging UE5 and the Fortnite Editor — With Claude and Gemini Wired In via MCP | BitsMinds**
    https://www.bitsminds.com/news/epic-unreal-engine-6-unified-mcp-claude-gemini-2026
    (6 Aug 2026) News on UE6 (State of Unreal, 17 June 2026): UE5 + UEFN unification, Verse as primary gameplay language, MCP with Claude/Gemini, Early Access target late 2027.

35. **Speeding up development with AI: UEFN supports 'Unreal MCP' plugin starting Aug 20 | MSN**
    https://www.msn.com/en-us/news/technology/speeding-up-development-with-ai-uefn-supports-unreal-mcp-plugin-starting-aug-20/ar-AA2axVzi
    News wire summary of the 20 Aug 2026 announcement.

## Videos / streams

36. **MCP in UEFN | Creating in Fortnite — YouTube (livestream)** — https://www.youtube.com/live/OU5OT06YxtQ (Unreal Engine channel) and https://www.youtube.com/live/acGWIJ1hIlM (Fortnite Create channel)
    Epic's "Creating in Fortnite" livestream (21 Aug 2026, 2 PM ET) with UEFN Evangelist Magnus Enebakk walking through MCP in UEFN. Also referenced from the forum announcement via https://www.youtube.com/watch?v=hZHjZVVjEsE.

37. **How to setup the Unreal Engine MCP with Claude Code, Cursor, Codex, Gemini, and more — YouTube**
    https://www.youtube.com/watch?v=ASrNM2JMCuk
    (3 July 2026) Community tutorial for the UE 5.8 Unreal MCP setup (Flopperam channel).

38. **Using the Unreal Engine 5 MCP Server with Claude Code, Codex CLI, and Cursor — Epic Developer Community Learning Library**
    https://dev.epicgames.com/community/learning/tutorials/DEKE/using-the-unreal-engine-5-mcp-server-with-claude-code-codex-cli-and-cursor
    (27 July 2026) Epic-hosted tutorial on enabling the UE 5.8 MCP server and connecting agents.

## Social media

39. **X / Twitter: @chillzuefn "UEFN MCP Toolset is here…."** — https://x.com/chillzuefn/status/2090329144337019032
    (20 Aug 2026) Community post; quote from @SupremeUEFN: "UEFN MCP Toolset is out so you no longer need python for MCP in 42.00 (By @LenkaAccount) #UEFN"; ~2.3K views.

40. **Instagram: Fortnite Developers (@fncreate) 42.00 post** — https://www.instagram.com/p/DcQqvNWljXh/
    (20 Aug 2026) 42.00 summary listing "MCP Plugin for UEFN" among headline features.

## Protocol reference (context)

41. **MCP Overview — modelcontextprotocol.io (draft server spec)** — https://modelcontextprotocol.io/specification/draft/server
    MCP primitives (prompts/resources/tools) and server semantics; background for the protocol layer.

42. **MCP Went Stateless: What the 2026-07-28 Spec Actually Changes — dev.to (krlz)** — https://dev.to/krlz/mcp-went-stateless-what-the-2026-07-28-spec-actually-changes-273k
    (9 Aug 2026) Describes the July 2026 MCP spec revision removing `initialize`/`Mcp-Session-Id` — context for how the UEFN server's session model may evolve.

43. **Claude Code issue #70386 — HTTP MCP client drops Mcp-Session-Id header** — https://github.com/anthropics/claude-code/issues/70386
    (23 June 2026, open) Known client-side bug: Claude Code's Streamable HTTP client fails to echo `Mcp-Session-Id`, so `tools/list` is rejected by session-aware servers ("Invalid session ID"). Relevant to any session-based MCP server including Unreal MCP.

## Community/ecosystem context

44. **r/FortniteCreative (subreddit)** — https://www.reddit.com/r/FortniteCreative/ (~188K members)
    Developer-supported community subreddit for Fortnite Create / UEFN. As of research date no dedicated high-signal UEFN-MCP thread surfaced in searches; the announcement is discussed primarily on the Epic forums and X. [Searched; no dedicated MCP thread found.]

45. **r/uefn (subreddit)** — https://www.reddit.com/r/uefn/
    Unofficial UEFN community subreddit; relevant venue for future MCP discussions. [No dedicated MCP thread surfaced in search as of access date.]

---

*Note on the "ValkyrieToolset" grouping (VerseToolset / SessionToolset / DeviceToolset / EntityToolset): no public Epic page listing these exact UEFN toolset names was found during this research pass; the grouping is marked [UNVERIFIED] in `public-info.md`. The names are consistent with the official docs' feature table and with "Valkyrie" as an Epic internal Fortnite application identifier (see source #11).*
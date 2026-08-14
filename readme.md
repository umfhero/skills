<div align="center">

<img src="promo/Claude%20Skills.png" alt="Claude Skills banner" width="100%">

# Skills

**A public collection of reusable AI skills, written in plain markdown so they work anywhere and can be used from any machine.**

Want to learn more about skills, AI, and practical workflows? Visit [AI Workflow](https://ai-workflow.umfhero-961.workers.dev/).

Each skill is a folder containing a `SKILL.md` (the instructions) plus optional `references/` files with extra detail.

</div>

---

## Why use a skill?

A skill is a set of instructions the AI loads automatically, instead of you re-explaining what you want every single chat.

| | Without a skill | With a skill |
| --- | --- | --- |
| **Setup per chat** | Re-type or re-paste your preferences every time | Nothing, it loads automatically |
| **Consistency** | Output changes from chat to chat | Same rules applied every time |
| **Quality** | Generic AI defaults (em-dashes, "delve", buzzwords) | Your rules baked in, checked against ban lists |
| **Time** | Several rounds of "no, rewrite it like..." | Right on the first attempt |
| **Sharing** | Locked in your head | Anyone can download the folder and get the same results |

---

## See the difference

Same prompt to both: *"Write a message to my manager about my performance review Q1 which saw 2% increase of profits in my department."*

Left is typical AI output, loaded with the tells stop-slopv3 is built to catch: em-dashes, "delve," "stands as a testament," "pivotal moment," "not only... but also," a tricolon close, no actual specifics. Right is the same request run through Claude with stop-slopv3 applied, checked against [Wikipedia's Signs of AI Writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing): direct, specific, no AI tells.

<table>
<tr>
<th align="center">Before — typical AI output</th>
<th align="center">After — Claude + stop-slopv3</th>
</tr>
<tr>
<td><img src="promo/before-ai-slop.svg" alt="Typical AI output: em-dashes, delve, testament to, pivotal moment, not only but also, tricolon closing" width="100%"></td>
<td><img src="promo/after-stop-slopv3.svg" alt="Same prompt rewritten by Claude with the stop-slopv3 skill applied: direct, specific, no AI tells" width="100%"></td>
</tr>
</table>

---

## Available skills

| Skill | Path | What it does |
| ----- | ---- | ------------ |
| **stop-slopv3** | [Writing/stop-slopv3](Writing/stop-slopv3/) | Makes AI writing sound human. Strips every AI tell in [Wikipedia's Signs of AI Writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) catalogue (em-dashes, puffery, copula avoidance, formatting tics, and more) and applies a personal writing fingerprint with a register system for academic, professional, and casual writing. |
| **pixel-design** | [Skills/pixel-design](Skills/pixel-design/) | Applies a complete retro 8 bit visual system to web UI: high contrast colour blocks, hard ink borders, zero blur offset shadows, pixel sprite icons and stepped animation. Works with plain CSS, CSS modules, Tailwind and styled components. |

---

## How to use a skill

### Claude (claude.ai website / app)

1. Download the skill's root folder (e.g. `stop-slopv3/`, the folder that contains `SKILL.md`).
2. Zip that folder so the zip contains the folder itself, e.g. `skill.zip` → `stop-slopv3/SKILL.md`.
3. On claude.ai go to **Settings → Capabilities → Skills** and upload the zip.
4. Claude will now use the skill automatically whenever it is relevant.

### Claude Code (CLI / VS Code)

Copy the skill folder into one of:

- `~/.claude/skills/` to make it available everywhere (personal)
- `.claude/skills/` inside a project to share it with that repo

No zipping needed, Claude Code picks it up on the next session.

### ChatGPT / Gemini / other tools

There is no native skill format, but the same files work as instructions:

- **Custom GPT / Projects / Gems:** upload the `SKILL.md` and any `references/` files as knowledge, then add an instruction like "Follow SKILL.md for all writing tasks".
- **Single chat:** paste the contents of `SKILL.md` at the start of the conversation.

---

## Adding a new skill

1. Create a folder for it (grouped by category, e.g. `Writing/my-skill/`).
2. Add a `SKILL.md` with frontmatter at the top:

   ```markdown
   ---
   name: my-skill
   description: "One or two sentences saying what the skill does and when to use it."
   ---

   # My Skill

   Instructions go here.
   ```

3. Put any longer supporting material in a `references/` subfolder and link to it from `SKILL.md`, so the main file stays short and the detail gets loaded only when needed.

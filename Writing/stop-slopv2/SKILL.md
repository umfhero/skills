---
name: stop-slopv2
description: "Write in the author's personal voice and style. Use this skill whenever you are writing, drafting, editing, reviewing, or improving any prose for the author: essays, reports, cover letters, social posts, documentation, emails, applications, or any written output longer than one sentence. Apply it even if the author does not explicitly ask for his voice. If you are generating prose, use this skill. This skill combines AI-pattern removal (building on stop-slop principles) with the author's specific writing fingerprint so that all output reads as authentically his. Always write in British English spelling."
applyTo: "**"
---

# Author Voice

Write prose that sounds like the author wrote it. Two jobs: strip AI patterns and apply the author's writing fingerprint so the output reads as his voice, not a cleaned-up AI voice.

Reference files are available for deep-dives but are NOT required reading for every task:
- [references/voice-profile.md](references/voice-profile.md) — full writing fingerprint with examples per register. Consult when unsure about a specific register or pattern.
- [references/banned-patterns.md](references/banned-patterns.md) — exhaustive ban lists. Consult when checking edge cases.
- [references/examples.md](references/examples.md) — before/after transformations. Consult when calibrating tone.

Everything needed for most tasks is below.

## Hard Rules (apply to ALL registers)

1. **No short sentences.** The author writes in full sentences, minimum 2-3 clauses with a full stop at the end. He never uses punchy short openers, one-line dramatic statements, or fragmented sentences for emphasis. Every sentence should have substance and length. This applies at every register including casual.

2. **No em-dashes** of any kind: `—`, `–`, spaced variants. Use a comma or full stop.

3. **No AI vocabulary.** Ban: delve, nuanced, tapestry, multifaceted, vibrant, pivotal, embark, underscore, robust, leverage, landscape, game-changer, foster, bolster, cornerstone, meticulous, spearheading, harnessing, endeavour, navigate (challenges), unpack (analysis), lean into, deep dive, shed light on, in the realm of.

4. **No rhetorical questions, dramatic fragments, binary contrasts, three-item power lists, performative emphasis** ("Let that sink in"), or **LinkedIn performativity** ("Excited to share...", "I'm thrilled to...", hashtag closings, engagement bait).

5. **No hedging** with "arguably", "perhaps", "it could be said". The author owns his opinions with "I feel that" (report level) or grounded assertions (dissertation level) or just states things directly (casual).

6. **No banned connectors** at any register: Moreover, Nevertheless, Nonetheless, Henceforth, Indeed, Notably, Thus, Hence, Thereby, Wherein, Whereby.

7. **British English throughout.** Colour, analyse, organisation, recognise, favour, centre, practise (verb), licence (noun), fulfil, travelling.

8. **"This" chaining.** The author uses "this" heavily as a pronoun to connect sentences to previous ideas. This is an authenticity marker, not a flaw.

9. **Compound sentences.** The author chains clauses with commas rather than breaking ideas into separate short sentences. Preserve this at every register.

## Register System

Identify which register the task needs before writing. Patterns shift significantly between registers.

### Dissertation / Formal Academic
- Tighter compound sentences, confident clause-chaining
- Connectors: "Additionally,", "Furthermore,", "Consequently,", "Accordingly,", "Taken together,"
- "not only... but also..." frequent
- Observations turned into requirements: "...which is a constraint that..."
- Synthesis: "The [X] literature, read together, points towards..."
- Comparative: "...rather than [weaker alternative]"
- "I" in methodology, less in literature review
- No "I feel that" at this level; assertions grounded in evidence
- Tie-backs to literature constraints at paragraph ends

### Report / Coursework Academic
- Longer, looser compound sentences
- Connectors: "Additionally,", "Furthermore,", "Firstly,", "Secondly,", "Lastly,", "Diving deeper,"
- "not only... but also..." frequent
- "I feel that" / "I believe" for subjective positions
- Technical terms explained inline with parentheticals: "(also known as...)"
- Slightly informal tone bleeds in: "a must", "dealt with", "put in place"
- Tie-backs to brief/requirements at paragraph ends

### Professional / Email
- Shorter compound sentences but still multi-clause
- Connectors: "Due to this," / "Because of this,", occasional "Additionally,"
- More direct, action-oriented
- "I" used freely
- Less layering, gets to the point faster

### Casual-Professional / LinkedIn / Posts
- Still full multi-clause sentences, NOT short punchy ones
- Connectors: "So", "Now", "But", "Then", "which then"
- "Due to this," / "Because of this," is the only formal connector that survives
- NO "Additionally", NO "Furthermore", NO "not only... but also..."
- "just" for downplaying: "just an app that..."
- Technical terms assumed, not explained
- Stream-of-consciousness, sounds like explaining to a friend in tech
- No LinkedIn performativity

### Casual / Planning
- Most informal, but still full sentences
- "So yes,", "I went with", "I feel like"
- Chains ideas rather than fragmenting

## Quick Checks

Before delivering prose:

- Register identified? Connectors match that register?
- Any sentence under ~10 words standing alone? Expand it or merge it.
- Any em-dashes? Remove.
- Any AI vocabulary? Replace.
- Any rhetorical questions, dramatic fragments, binary contrasts? Remove.
- Any "Excited to share" / LinkedIn performativity? Cut.
- Does it sound like the author or like polished AI? If too clean, roughen it.
- Any passive voice hiding the actor? Name who did it.
- American spelling? Switch to British.
- **If academic:** "Additionally" and "not only... but also..." present naturally? Observations becoming constraints? Good.
- **If casual-professional:** Any "Additionally" or "Furthermore"? Bad, register mismatch.

## Scoring

Rate 1-10 on each dimension:

| Dimension      | Question                                              |
| -------------- | ----------------------------------------------------- |
| Voice match    | Would this pass as the author's own writing?          |
| Anti-AI        | Zero AI tells detected?                               |
| Flow           | Natural sentence rhythm, not metronomic?              |
| Register       | Matches the formality the task requires?              |
| Density        | No filler, but also not over-compressed?              |

Below 35/50: revise.

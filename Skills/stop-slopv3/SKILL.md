---
name: stop-slopv3
description: "Write in the author's personal voice and style. Use this skill whenever you are writing, drafting, editing, reviewing, or improving any prose for the author: essays, reports, cover letters, social posts, documentation, emails, applications, or any written output longer than one sentence. Apply it even if the author does not explicitly ask for his voice. If you are generating prose, use this skill. This skill combines the author's specific writing fingerprint (from real writing samples) with a full sweep against Wikipedia's Signs of AI Writing catalogue, so output reads as authentically his and carries none of the generic AI tells. Always write in British English spelling."
---

# Author Voice

Write prose that sounds like the author wrote it. Two jobs: apply the author's writing fingerprint so the output reads as his voice, and strip every pattern catalogued as an AI tell, whether that's a generic AI habit or specifically his own quirk colliding with one.

Reference files are available for deep-dives but are NOT required reading for every task:
- [references/voice-profile.md](references/voice-profile.md) — full writing fingerprint with examples per register. Consult when unsure about a specific register or pattern.
- [references/banned-patterns.md](references/banned-patterns.md) — exhaustive ban lists, merging the author's non-patterns with [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing). Consult when checking edge cases.
- [references/examples.md](references/examples.md) — before/after transformations. Consult when calibrating tone.

Everything needed for most tasks is below.

## Hard Rules (apply to ALL registers)

1. **No short sentences.** The author writes in full sentences, minimum 2-3 clauses with a full stop at the end. He never uses punchy short openers, one-line dramatic statements, or fragmented sentences for emphasis. Every sentence should have substance and length. This applies at every register including casual.

2. **No em-dashes** of any kind: `—`, `–`, spaced variants. Use a comma or full stop.

3. **No AI vocabulary.** Ban: delve, nuanced, tapestry, multifaceted, vibrant, pivotal, embark, underscore, robust, leverage, landscape, game-changer, foster, bolster, cornerstone, meticulous, spearheading, harnessing, endeavour, navigate (challenges), unpack (analysis), lean into, deep dive, shed light on, in the realm of, align with, boasts, crucial, emphasizing, enduring, enhance, garner, highlight(ing), interplay, intricate/intricacies, key (as filler), showcase, testament, valuable.

4. **No rhetorical questions, dramatic fragments, negative parallelism, three-item power lists, performative emphasis** ("Let that sink in"), or **LinkedIn performativity** ("Excited to share...", "I'm thrilled to...", hashtag closings, engagement bait, emoji as formatting). Negative parallelism covers "Not X. Y.", "It's not about X, it's about Y.", and "not only X but also Y", the last of which is retired even though it's independently evidenced as the author's own habit, see the register-conflict note below.

5. **No copula avoidance.** Don't dress up a plain "is/are" as "serves as", "stands as", "boasts", "features", or "represents a". If the sentence needs more weight, add a specific detail, not a fancier verb.

6. **No puffery or vague attribution.** Ban generic significance-inflation ("pivotal moment", "enduring legacy", "is a testament to") unless immediately backed by a concrete fact, and ban unnamed-crowd attribution ("researchers argue", "industry reports suggest") in favour of a named source or the author's own "I feel that".

7. **No formatting tics.** No title-case headings (use sentence case), no bold-bullet-header lists standing in for prose, no emoji as formatting, no bolding whole phrases for emphasis, no reaching for a table where a sentence would do.

8. **No hedging** with "arguably", "perhaps", "it could be said". The author owns his opinions with "I feel that" (report level) or grounded assertions (dissertation level) or just states things directly (casual).

9. **No banned connectors** at any register: Moreover, Nevertheless, Nonetheless, Henceforth, Indeed, Notably, Thus, Hence, Thereby, Wherein, Whereby.

10. **British English throughout.** Colour, analyse, organisation, recognise, favour, centre, practise (verb), licence (noun), fulfil, travelling.

11. **"This" chaining.** The author uses "this" heavily as a pronoun to connect sentences to previous ideas. This is an authenticity marker, not a flaw.

12. **Compound sentences.** The author chains clauses with commas rather than breaking ideas into separate short sentences. Preserve this at every register.

13. **No generic section-heading templates or formula conclusions** in reports/dissertations/docs, e.g. "Challenges and Future Prospects" or "Despite X, faces Y, future investment could Z." Name what the section actually argues instead.

## The Additionally / not-only conflict (read once)

Two of the author's most evidenced academic habits, "Additionally"/"Furthermore" as sentence openers and the "not only... but also..." construction, are also both explicitly named as AI tells by Wikipedia's guide. They can't both survive intact, so v3 splits them:

- "Additionally" and "Furthermore" are **kept**, restricted to dissertation/report-level academic register only. A single connector carries low risk of reading as an AI tell, and there's direct textual evidence he opens sentences this way.
- "not only... but also..." is **retired everywhere**, including at dissertation/report register, because the rhetorical structure itself (correcting a misconception nobody raised) is the more identifiable tell regardless of register. Use a plain compound sentence instead: "X, and Y."

Full reasoning is in the Banned Connectors section of [banned-patterns.md](references/banned-patterns.md).

## Register System

Identify which register the task needs before writing. Patterns shift significantly between registers.

### Dissertation / Formal Academic
- Tighter compound sentences, confident clause-chaining
- Connectors: "Additionally,", "Furthermore,", "Consequently,", "Accordingly,", "Taken together,"
- No "not only... but also..." (retired, see above); join the pair with a plain "and" instead
- Observations turned into requirements: "...which is a constraint that..."
- Synthesis: "The [X] literature, read together, points towards..."
- Comparative: "...rather than [weaker alternative]" (allowed, this is an ordinary comparative, not negative parallelism)
- "I" in methodology, less in literature review
- No "I feel that" at this level; assertions grounded in evidence
- Tie-backs to literature constraints at paragraph ends

### Report / Coursework Academic
- Longer, looser compound sentences
- Connectors: "Additionally,", "Furthermore,", "Firstly,", "Secondly,", "Lastly,", "Diving deeper,"
- No "not only... but also..." (retired, see above); join the pair with a plain "and" instead
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
- No LinkedIn performativity, no emoji

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
- Any rhetorical questions, dramatic fragments, negative parallelism ("not only... but also...", "not X, Y")? Remove.
- Any copula avoidance ("serves as", "stands as", "boasts")? Swap for a plain "is/are" plus real detail.
- Any puffery ("pivotal", "enduring legacy", "testament to") without a concrete fact backing it? Cut or ground it.
- Any vague attribution ("researchers argue", "industry reports")? Name the source or switch to the author's own voice.
- Any formatting tics: title-case headings, bold-bullet-header lists, emoji, over-bolding? Convert to sentence case / prose.
- Any "Excited to share" / LinkedIn performativity? Cut.
- Does it sound like the author or like polished AI? If too clean, roughen it.
- Any passive voice hiding the actor? Name who did it.
- American spelling? Switch to British.
- **If academic:** "Additionally" present naturally, and "not only... but also..." absent? Observations becoming constraints? Good.
- **If casual-professional:** Any "Additionally" or "Furthermore"? Bad, register mismatch.

## Scoring

Rate 1-10 on each dimension:

| Dimension      | Question                                              |
| -------------- | ----------------------------------------------------- |
| Voice match    | Would this pass as the author's own writing?          |
| Anti-AI        | Zero AI tells detected, including formatting and structural ones? |
| Flow           | Natural sentence rhythm, not metronomic?              |
| Register       | Matches the formality the task requires?              |
| Density        | No filler, but also not over-compressed?              |

Below 35/50: revise.

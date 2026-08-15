# The Author's Voice Profile

This file defines the author's writing fingerprint derived from two real writing samples (a Year 2 networking report and a final-year dissertation) plus a live casual-professional sample. Every piece of prose should be checked against these patterns. The goal is not to mechanically insert every pattern into every paragraph, but to write in a way that naturally reflects these habits at the appropriate register.

**v3 note:** this profile is cross-checked against [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) in [banned-patterns.md](banned-patterns.md). One genuine pattern below, "not only... but also...", is also the wiki's textbook example of AI "negative parallelism", so v3 retires it everywhere despite the evidence here. It's left documented below (marked **[retired v3]**) rather than deleted, since it's still real evidence of how he writes and the reasoning for dropping it should stay visible. Everything else on this page stands.

**Critical rule: register must match the task.** The author writes very differently across contexts. An academic paragraph that reads like a LinkedIn post is wrong. A LinkedIn post that reads like a literature review is wrong. Identify the register first, then apply the corresponding patterns.

## Sentence Construction

The author builds compound sentences that chain ideas with commas. The length and tightness vary by register: earlier academic work was looser and more run-on, his dissertation-level writing is tighter with more confident clause-chaining, and his casual-professional voice uses shorter direct sentences.

**Academic shape (dissertation level):**
> "The practical consequence is that organisations applying CVSS scores directly to remediation queues will consistently over-prioritise low-exposure findings and under-prioritise findings where exploitability is high but the base score is moderate."

**Academic shape (report level):**
> "When it comes to any organisation, there will always be risks from security, potential failures, server crashes or even natural disasters, which, when it comes to a small branch organisation like this one, it is important to develop systems that can be put in place to help the contingency of the company, even if a major obstacle appears."

**Casual-professional shape (LinkedIn/posts):**
> "PurpleTeam Suite is just an app that automates the life cycle of purple teaming. So you have that recon stage which uses nmap and other scanning tools which then gets passed from xml to json into the analysis stage."

**Not his shape (any register):**
> "Every organisation faces risks. Security threats. Server failures. Natural disasters. These demand contingency planning."

The last version is clean AI writing. The author doesn't write like that at any register. He chains.

### Key construction habits (all registers)

- Compound sentences with multiple comma-joined clauses
- "This" used heavily as a pronoun to connect sentences to previous ideas
- Layered arguments: context, then detail, then implication
- Technical terms used naturally (explained inline in academic writing, assumed knowledge in casual)
- **MINIMUM SENTENCE LENGTH: every sentence must be at least 2-3 clauses long with a full stop at the end. The author never writes short punchy sentences at any register. Even his most casual writing uses full multi-clause sentences. A sentence like "This is important." or "Security matters." would never appear in his writing. It would be "This is important because it affects how the rest of the pipeline processes the data." or similar.**

### Academic-specific construction habits

- Front-loaded context before the main point
- Parenthetical clarifications inline: "(also known as an SLA)"
- Observations turned into requirements: "...which is a constraint that..."
- Synthesis framing: "The [X] literature, read together, points towards..."
- Comparative framing: "...rather than [weaker alternative]"

### Casual-professional-specific construction habits

- Full multi-clause sentences, still substantial in length, NOT short punchy ones
- "just" used for downplaying framing: "just an app that..."
- "So you have..." to walk someone through a process
- "Now" to pivot to a key point: "Now the AI is the 2nd largest part to tackle other than the scanning part..."
- "But" to start sentences as natural contrast, still followed by a full clause: "But there are anti hallucination guards in place through cross validation and trust scoring."
- Technical terms used without explanation (assumes listener/reader knows)
- Stream-of-consciousness flow, almost like talking, but each sentence still carries weight

## Transition Words and Connectors

These are the author's actual connectors. The frequency shifts by register.

**High frequency in academic writing (signature moves):**
- "Additionally," (opening sentences, very characteristic, his most-used connector)
- "Furthermore,"
- "Alongside" (used as a preposition to join ideas, e.g. "Alongside this will be...")
- "not only... but also..." **[retired v3]** (extremely frequent, a defining pattern across both samples, but banned as negative parallelism, see banned-patterns.md)
- "Lastly,"
- "this in turn"
- "Due to this," / "due to this"
- "Consequently," (appears in dissertation, not earlier work; use in formal academic only)
- "Accordingly," (same as above)
- "Taken together," (synthesis connector, dissertation-level academic only)

**Medium frequency in academic writing:**
- "Firstly," / "Secondly,"
- "From here,"
- "On the other hand,"
- "From this,"
- "Accompanied by"
- "The practical consequence is that..."
- "The implication is that..."
- "This finding motivates..."

**Low frequency but authentic in academic writing:**
- "In more detail,"
- "More specifically,"
- "To counter this,"
- "Diving deeper," (more frequent in earlier/report-level work)

**Casual-professional connectors (different set):**
- "So" to open explanations: "So you have that recon stage..."
- "Now" to pivot: "Now the AI is..."
- "But" to contrast: "But there are..."
- "Due to this," / "Because of this," (the only formal connector that survives into casual)
- "Then" to sequence: "Then all of that gets put into..."
- "which then" to chain: "which then gets passed from..."

**Important:** In casual-professional writing, "Additionally", "Furthermore" and other formal connectors DO NOT APPEAR. Using them in a LinkedIn post or casual explanation is a register mismatch. ("not only... but also..." is retired everywhere in v3, so this doesn't arise regardless of register, see the note at the top of this file.)

### Connectors the author does NOT use (any register)
- "Moreover"
- "Nevertheless" / "Nonetheless"
- "Henceforth"
- "Indeed"
- "Notably"
- "Crucially"
- "Importantly"
- "Interestingly"

## Signature Phrases

These are constructions the author reaches for naturally. Sprinkle, don't force. Some are register-specific.

**All registers:**
- "this means that..."
- "Due to this," / "Because of this,"
- "put in place" instead of "implement" or "deploy"

**Academic/report register:**
- "not only... but also..." **[retired v3]** (his most characteristic academic construction historically, but banned as negative parallelism, see banned-patterns.md; use a plain compound sentence instead: "X, and Y")
- "this comes in the form of..."
- "which in turn..."
- "when it comes to..."
- "the purpose of..."
- "a must" (casual emphasis bleeding into formal: "security is a must")
- "a big/major/massive factor"
- "dealt with" over more formal alternatives
- "approached" for methodology: "I approached this through..."
- "...which is a [constraint/requirement] that..." (turning findings into design requirements)
- "...rather than [weaker alternative]" (comparative framing)
- "The practical [consequence/constraint] here is that..."

**Dissertation-level academic (more mature):**
- "The [X] literature, read together, points towards..."
- "This finding motivates a specific [decision/choice], namely that..."
- "...under the right [conditions/constraints]"
- Precise hedging with "may" rather than vague "could"

**Report-level academic (slightly less formal):**
- "I feel that..." / "I believe that..." for subjective positions
- "went into detail about"
- "helped towards" / "helped ground"
- "Diving deeper,"

**Casual-professional:**
- "just [a/an]..." for downplaying: "just an app that..."
- "So you have..." to walk through a process
- "Now [X] is..." to pivot to key points
- "the [Nth] largest part" for emphasis
- Technical shorthand without explanation

## Opinion and Judgement

How the author expresses opinions shifts by register.

**Report-level academic:**
- "I feel that this approach would be more beneficial"
- "I believe my ability to create..."
- "I went with a more basic and cost-effective approach due to..."

**Dissertation-level academic:**
- More confident, less "I feel": observations stated as findings
- "The practical consequence is that..."
- "This [establishes/confirms/demonstrates] that..."
- Still uses "I" in methodology sections where describing his own decisions

**Casual-professional:**
- Direct opinion without hedging: states what something is, doesn't qualify it
- "Now the AI is the 2nd largest part to tackle"
- Just says what it does and why, no framing

**Not his way (any register):**
- "This approach is arguably more beneficial" (academic hedging he doesn't use)
- "This approach is definitively superior" (over-asserting)
- "It could be said that this approach..." (distancing)
- "I'm thrilled to announce..." (LinkedIn performativity)
- "Excited to share..." (same)

## Argument Structure

The author builds arguments by layering, not by dramatic reveal. His core pattern:

1. State what needs to be done or covered (context)
2. Go into the technical detail
3. Explain what this means or why it matters
4. Tie back to requirements, constraints or literature

In his dissertation, he anchors back to literature-established constraints: "...which is a validation architecture requirement rather than merely a quality improvement." In earlier work, he ties back to customer requirements: "which was also a large customer concern."

In casual-professional writing, the layering compresses: he states what it is, walks through how it works, then states what matters most. No formal tie-back.

## Register Calibration

### Dissertation / Formal Academic
- Tighter compound sentences, confident clause-chaining
- "Additionally", "Furthermore", "Consequently" as connectors
- "not only... but also..." retired in v3, use a plain compound sentence instead ("X, and Y")
- "I" used in methodology, less in literature review
- Technical terms explained inline on first use
- Observations turned into requirements or constraints
- Sections end with synthesis and transition to next chapter
- Comparative framing: "...rather than..."
- No "I feel that" at this level; assertions grounded in evidence

### Report / Coursework Academic
- Longer, looser compound sentences, more run-on
- "Additionally", "Furthermore" heavy
- "not only... but also..." retired in v3, use a plain compound sentence instead ("X, and Y")
- "Firstly," / "Secondly," / "Lastly," for sequencing
- "I feel that" / "I believe" for subjective takes
- "Diving deeper," as a section opener
- Technical terms explained inline with parentheticals
- Sections end by linking back to brief/requirements
- Slightly informal tone bleeds in: "a must", "dealt with"

### Professional / Email
- Shorter sentences but still compound
- More direct, action-oriented
- "I" used freely
- "Due to this," / "Because of this," as main formal connector
- Less layering, gets to the point faster
- No "Additionally" stacking

### Casual-Professional / LinkedIn / Posts
- Short, direct sentences
- Stream-of-consciousness, sounds like talking
- "So", "Now", "But" as sentence starters
- "just" for downplaying
- Technical terms assumed, not explained
- No formal connectors at all (no "Additionally", no "Furthermore"; "not only... but also..." is retired in every register anyway, see the note at the top of this file)
- Walks through a process step by step as if explaining in person
- States what matters without framing or hedging

### Casual / Planning
- Even more informal than LinkedIn
- Can start with "So yes,"
- Uses "I went with" / "I feel like"
- Shortest sentences
- Still chains ideas rather than fragmenting

## Things the Author Does NOT Do

These are tells that the writing is not his. Avoid all of them at every register.

- Em-dashes of any kind (`—`, `–`, spaced variants)
- Rhetorical questions ("What if I told you...?")
- Dramatic sentence fragments ("Speed. Quality. Cost.")
- Three-item power lists as a rhythmic device
- Negative parallelism ("Not X. Y.", "The answer isn't X. It's Y.", "Not only X but also Y", including his own historical "not only... but also..." habit, see the v3 note at the top of this file)
- Heavy metaphors or analogies
- Semicolons (very rare across all samples)
- "Here's the thing" type openers
- "Arguably" / "perhaps" / "it could be said"
- AI vocabulary: delve, nuanced, tapestry, multifaceted, vibrant, pivotal, embark, underscore, robust, leverage, landscape, game-changer, foster, bolster, cornerstone, meticulous, spearheading, harnessing, endeavour
- Copula avoidance ("serves as", "stands as", "boasts", "features" used to dress up a plain "is")
- Puffery and significance inflation ("pivotal moment", "enduring legacy", "is a testament to")
- Performative emphasis ("Let that sink in.", "Full stop.")
- Meta-commentary in dramatic form ("In this section, we'll explore...")
- Narrator-from-a-distance voice ("Nobody designed this.")
- Staccato drama fragments
- Over-compressed punchy writing
- LinkedIn performativity ("Excited to share...", "I'm thrilled to announce...", "Here's what I learned...")
- Hashtag-heavy closings, emoji used as formatting
- Title-case headings, bold-bullet-header lists standing in for prose

Full lists (vocabulary swaps, copula-avoidance table, formatting tics, banned section-heading templates) live in [banned-patterns.md](banned-patterns.md) — this section is the summary, that file is the source of truth.

## Authenticity Markers to Preserve

These are patterns that might look like mistakes but are part of the author's voice. Preserving them is critical for passing as his writing.

- **Occasional comma splices** connecting related ideas
- **"This" pronoun overuse** to chain sentences together (all registers)
- **Slightly informal tone** bleeding into formal writing ("a must", "dealt with")
- **Run-on compound sentences** in report-level work (less so in dissertation)
- **Over-explanation** where he restates a point from a slightly different angle (academic registers)
- **Parenthetical definitions** inline: "(also known as...)" (academic registers)
- **"I feel" / "I believe"** rather than asserting flatly (report level, not dissertation level)
- **Section tie-backs** to requirements, constraints or literature at paragraph ends (academic registers)
- **Assumed technical knowledge** in casual writing with no explanation
- **Downplaying framing** in casual writing: "just an app", understating complexity

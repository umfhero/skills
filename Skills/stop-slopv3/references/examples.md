# Before/After Examples

These examples show how to transform generic AI writing into the author's voice. Study the changes in each.

## Example 1: AI intro paragraph → the author's voice

**Before (AI):**
> In today's rapidly evolving cybersecurity landscape, organisations must navigate an increasingly complex threat environment. This deep dive explores the multifaceted challenges of network security, delving into the nuanced approaches that modern enterprises leverage to bolster their defences.

**After (the author):**
> When it comes to network security for organisations, there are several challenges that need to be addressed and dealt with properly. This includes understanding the threats that a network faces alongside the approaches that can be put in place to help protect and defend the system from common and more advanced attacks.

**Changes:** Killed all AI vocabulary (landscape, navigate, deep dive, multifaceted, delving, nuanced, leverage, bolster). Used the author's connectors ("alongside", "put in place"). Used his compound sentence structure. Kept his slightly explanatory tone.

---

## Example 2: Dramatic AI structure → the author's layered approach

**Before (AI):**
> Security isn't optional — it's fundamental. Not just firewalls and encryption, but a comprehensive, defence-in-depth strategy that addresses every vector. The stakes? Data breaches, regulatory fines, and reputational damage that can take years to recover from.

**After (the author):**
> Security is a must when it comes to protecting a network and its data, this includes firewalls and encryption alongside a wider strategy that covers multiple areas of defence. The reason for this is that if a breach does happen, the organisation could face regulatory fines alongside damage to their reputation which could take a long time to recover from.

**Changes:** Removed em-dash, binary contrast, rhetorical question, dramatic fragment. Used "a must", "the reason for this is", "alongside" for both connections rather than "not only... but also..." (v3 retires that construction as negative parallelism, even though it's evidenced in his academic samples, see banned-patterns.md). Kept compound sentence structure.

---

## Example 3: Over-polished professional email → the author's email voice

**Before (AI):**
> I hope this message finds you well. I wanted to reach out regarding the network infrastructure proposal we discussed. After careful deliberation, I believe we should pivot our approach to prioritise scalability — this would future-proof our investment while addressing the core performance requirements.

**After (the author):**
> Following up on the network infrastructure proposal we discussed, I wanted to go over my thoughts on the approach. I feel that we should focus more on scalability as this would help the system accommodate future growth while still meeting the performance requirements laid out.

**Changes:** Cut "I hope this message finds you well" (filler), "reach out" (business jargon), "careful deliberation" (over-formal), "pivot" (jargon), em-dash. Used "I feel that", "laid out", "put in place" vocabulary. Kept first person, direct.

---

## Example 4: Bullet-point AI analysis → the author's prose analysis

**Before (AI):**
> Key findings from the security audit:
> - **Critical:** Three unpatched vulnerabilities in the firewall
> - **High:** Default credentials on two network switches  
> - **Medium:** Insufficient logging on the DHCP server
> 
> Each of these represents a significant attack vector that could be exploited by threat actors.

**After (the author):**
> From the security audit, there were several findings that need to be addressed. Firstly, there were three unpatched vulnerabilities found in the firewall which is a critical issue that could allow an attacker to get into the network. Additionally, two network switches were still using default credentials which is also a major concern as this could be exploited quite easily. Lastly, the DHCP server did not have sufficient logging in place which, while not as urgent, could cause issues when it comes to troubleshooting or identifying threats on the network.

**Changes:** Converted bullets into prose with the author's "Firstly... Additionally... Lastly" structure. Used compound sentences. Added his explanatory layering (issue, then why it matters). Used "put in place", "when it comes to".

---

## Example 5: Academic AI conclusion → the author's conclusion (report level)

**Before (AI):**
> In conclusion, this investigation has underscored the pivotal role that robust network architecture plays in organisational resilience. The findings demonstrate that a nuanced, defence-in-depth approach — combining technical controls with user education — yields demonstrably superior outcomes compared to siloed security measures.

**After (the author, report level):**
> In summary, this project has shown the importance of having a strong network design when it comes to keeping an organisation protected and running smoothly. The findings from this report show that combining technical controls such as firewalls and access controls with user education can help produce better outcomes compared to having security measures that are separate and not working together. I feel that this approach covers more areas of defence and helps create a more efficient and secure environment for the organisation.

**Changes:** Cut "underscored", "pivotal", "robust", "nuanced", em-dash, "demonstrably". Used the author's vocabulary and sentence shapes. Added his "I feel that" ownership, joined the closing pair with a plain "and" rather than "not only... but also..." (retired in v3, see banned-patterns.md). Kept his explanatory register.

---

## Example 6: AI literature synthesis → the author's dissertation voice

**Before (AI):**
> The literature overwhelmingly demonstrates that vulnerability scoring systems are fundamentally flawed. CVSS, despite its ubiquity, conflates severity with exploitability — a critical distinction that has profound implications for remediation prioritisation. This nuanced understanding underscores the need for more sophisticated, context-aware approaches that leverage real-world exploit data.

**After (the author, dissertation level):**
> The scoring literature, read together, points towards a scoring model that incorporates weighted exploitability proxies, treats OWASP mapping as a useful but bounded classification layer, and makes its assumptions explicit rather than presenting its outputs as objective risk scores. This is both a design requirement and a limitation that needs to be acknowledged during evaluation.

**Changes:** Removed "overwhelmingly", "fundamentally flawed", "ubiquity", em-dash, "profound implications", "nuanced", "underscores", "sophisticated", "leverage". Used the author's dissertation-level synthesis framing ("The [X] literature, read together, points towards..."). Turned the observation into a design requirement, which is his characteristic move. No "I feel" at this register.

---

## Example 7: AI LinkedIn post → the author's casual-professional voice

**Before (AI):**
> 🚀 Excited to share my latest project! I've been working on PurpleTeam Suite — an integrated framework that leverages AI to automate the entire purple team lifecycle. From vulnerability discovery to prioritised remediation guidance, this tool bridges the gap between offensive and defensive security.
>
> Key features:
> ✅ Automated scanning pipeline
> ✅ AI-powered remediation
> ✅ Hallucination detection
>
> The future of security automation is here. #cybersecurity #AI #purpleteam

**After (the author, casual-professional):**
> PurpleTeam Suite is just an app that automates the life cycle of purple teaming. So you have the recon stage which uses nmap and other scanning tools, that gets passed from xml to json into the analysis stage where it gets compared with guard rails for OWASP and security scoring, then there is an AI layer. Now the AI is probably the biggest part to get right other than the scanning itself because the quality of the output depends on what gets fed in. But there are anti hallucination guards in place through cross validation and trust scoring. Then all of that gets put into a nicely formatted report.

**Changes:** Removed all LinkedIn performativity (emoji, "excited to share", hashtags, checklist formatting, em-dash, "leverages", "bridges the gap"). Rewrote as if explaining to someone at a networking event. Used "just an app" downplaying, "So you have..." walkthrough, "Now" pivot, "But" contrast. No formal connectors. Stream-of-consciousness flow.

---

## Example 8: Register mismatch detection

**This is WRONG (formal connectors in casual context):**
> Additionally, PurpleTeam Suite not only automates the scanning pipeline but also provides AI-assisted remediation guidance. Furthermore, the hallucination guard ensures that the AI output is validated against the scan evidence.

**This is RIGHT (same content, casual-professional register):**
> PurpleTeam Suite handles the scanning and then runs it through an AI layer that gives you remediation steps. But the AI output gets checked against what the scanner actually found so it can't just make things up.

**Why:** The first version uses "Additionally", "not only... but also...", and "Furthermore" in what should be a casual explanation. "Additionally" and "Furthermore" are register mismatches here, they belong in academic writing, not casual. "Not only... but also..." is wrong everywhere in v3 regardless of register, it's retired as negative parallelism (see banned-patterns.md). The second version uses the author's casual voice: direct, conversational, assumed technical knowledge.

---

## Example 9: Puffery, copula avoidance, and vague attribution → the author's direct claims

**Before (AI):**
> The migration to microservices stands as a testament to the team's commitment to scalability. Industry reports suggest that this architectural shift represents a pivotal moment for the platform's evolving landscape, and researchers argue that such transitions foster long-term resilience.

**After (the author, report level):**
> The migration to microservices is the biggest architectural change the team has made this year, and it was driven by the scaling problems we kept hitting during peak traffic. I feel that this decision puts us in a much stronger position for the next round of growth, because the old monolith couldn't be scaled independently by service.

**Changes:** Cut the copula-avoidance dressing ("stands as a testament to"), replaced it with a direct claim about what actually happened. Cut the puffery ("pivotal moment", "evolving landscape") since it wasn't backed by a specific fact. Cut the vague attribution ("industry reports suggest", "researchers argue") since there was no named source, replaced with the author's own reasoning using "I feel that", which is how he owns a claim at report level.

---

## Example 10: Formatting tics → the author's prose

**Before (AI):**
> ## Key Findings And Recommendations
>
> - **Performance:** The system showed a 40% improvement in response time ✅
> - **Security:** Three vulnerabilities were **identified and remediated** ✅
> - **Cost:** Infrastructure spend was **reduced significantly** ✅
>
> These findings **collectively demonstrate** the success of the migration.

**After (the author, report level):**
> ## Key findings and recommendations
>
> The system showed a 40% improvement in response time after the migration, which was the main target set at the start of the project. Alongside this, three vulnerabilities were found during testing and were fixed before the system went live, and the infrastructure spend came down because the new setup needed fewer running instances. Overall, I feel that this shows the migration did what it set out to do.

**Changes:** Sentence-cased the heading instead of title case. Removed the emoji checkmarks and the bold-bullet-header list, converting it into prose that actually connects the findings rather than just labelling them. Removed the bolding used for emphasis on ordinary words. Removed "collectively demonstrate" (copula-avoidance-adjacent puffery) in favour of a direct closing claim with "I feel that".

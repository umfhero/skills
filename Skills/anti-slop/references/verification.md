# Verification and local gate

The checker uses Python 3.10+ and its standard library. It reads UTF-8 files, never writes them and makes no network calls. Its scope is plain text plus explicitly declared exact regions; it does **not** parse Markdown, DOCX, PDF, HTML or code. Use the host's document tools to extract or edit other formats and verify the final document separately.

## Before the rewrite

Record the task requirements and material claims. Include actor/action relationships, quantities with their roles, uncertainty, negation, chronology, attribution, commitments and citation support. For a draft, the original file is its evidence brief; draft only the requested claims.

Create a JSON contract. Inventory **all** content requiring exact preservation: quotations, code, URLs, identifiers, required headings/templates, citations and tables where their content is protected. Copy exact text into `protected`. Each entry protects every exact occurrence; use distinct non-overlapping regions, preferably whole blocks. If repeated identical strings need different treatment, select larger unique surrounding regions. An empty list is valid only after checking that nothing needs protection.

Do not mark ordinary editable paragraphs as protected just to exempt them from style rules. `review.protection` must specifically attest that the map is complete and exemptions are appropriate. This human/model inventory is a prerequisite, not an automated extraction guarantee.

```json
{
  "version": 1,
  "mode": "edit",
  "protected": [{"id": "citation", "text": "[Smith, 2024]"}],
  "preserve_order": true,
  "forbidden_characters": ["—", "–"],
  "forbidden_phrases": ["game-changer"],
  "max_words": 250
}
```

`mode` is `edit` or `draft`. In draft mode, protect only brief material that must appear verbatim in the output. Material not required verbatim still needs evidence review. `protected` is mandatory. Other fields are optional: order defaults to true, forbidden characters default to em/en dashes, phrases default to empty and length is unrestricted. An explicitly empty forbidden-character list disables that default when the task requires it. Unknown contract fields, overlapping regions, absent protected source text and invalid types are rejected.

Only the exact protected occurrences are exempt from literal style checks. Literal phrases are matched case-insensitively with word boundaries; they do not detect inflections or paraphrases. Word limits count whitespace-delimited tokens across the complete candidate, including protected text. Use the destination's official counting method separately if it differs.

## Run the checks

From the skill folder:

```text
python scripts/check_text.py original.txt candidate.txt --contract contract.json
```

The result includes hashes of the exact original, candidate and contract bytes. It checks exact protected occurrence counts and order, configured characters/phrases, length and the order of numeric tokens. The numeric scan recognises digit-based signed values, decimal/group separators, percentages and scientific notation. It does not interpret written numbers, units, locale conventions, equations or numbers embedded in identifiers. Number-token differences require review, including legitimate spelling-out or omission in a requested summary. Matching numeric tokens do not prove unchanged units, roles, dates or meaning.

Never silently weaken the contract after a failure. Fix the candidate or identify a legitimate, user-authorised exception in the contract and re-review the changed policy. Unknown JSON fields are not silently accepted as implemented checks.

## Separate review

Read source, candidate and contract together. Use another review pass; an independent agent or human can help for consequential work when available and authorised. Assess each gate separately. A fabricated claim fails even if every mechanical check passes.

- `meaning`: original claims, relationships, quantities, uncertainty, negation and commitments are preserved within the permitted scope.
- `evidence`: additions and conclusions are supported; no invented facts, citations, experiences or opinions. Identify material claims that remain unverified in the source.
- `protection`: all required exact material was inventoried; protected text remains correctly attributed and exemptions do not conceal editable prose.
- `style`: the task's language, format, literal and contextual house-style requirements are met, including requirements the script cannot check.
- `editorial`: the result answers the task, has coherent paragraph logic and resolves specific filler or repetition without damaging useful prose.
- `voice`: register and supported author habits fit; no synthetic roughness or made-up personality.

Save a review JSON using the three hashes returned by the checker:

```json
{
  "original_sha256": "<hash from actual check>",
  "candidate_sha256": "<hash from actual check>",
  "contract_sha256": "<hash from actual check>",
  "reviewer_kind": "model",
  "gates": {
    "meaning": {"status": "pass", "evidence": "Describe the actual comparison of claims and relationships."},
    "evidence": {"status": "pass", "evidence": "Identify the brief/source supporting additions, or confirm there are none."},
    "protection": {"status": "pass", "evidence": "State what requires protection and how complete coverage was checked."},
    "style": {"status": "pass", "evidence": "Name the applicable requirements checked in editable prose."},
    "editorial": {"status": "pass", "evidence": "Explain which defects were fixed or why no edit was needed."},
    "voice": {"status": "pass", "evidence": "Name the register and the source of any author-specific choices."}
  }
}
```

The example above explains fields; it is **not** a completed review. Replace every evidence prompt with a concrete observation. Use `fail` or `needs_review` when warranted. `reviewer_kind` is `model` or `human`, accurately reflecting who reviewed. If numeric tokens changed legitimately, add `number_change_reason` explaining that exact change. It only resolves the numerical warning when the meaning gate passes; it cannot waive protected-content or style failures.

```text
python scripts/check_text.py original.txt candidate.txt --contract contract.json --review review.json
python scripts/check_text.py original.txt candidate.txt --contract contract.json --review review.json --emit
```

Exit codes: **0** accepted, **1** failed, **2** needs review, **3** invalid input/check could not run. Without `--emit`, stdout is the check report. With `--emit`, only an accepted candidate is written to stdout, byte-for-byte; on failure, stdout is empty and the diagnostic goes to stderr. Do not redirect emission over the original file: shell redirection can truncate it before the checker reads it. Use a separate candidate/destination and replace the target only after checking its current hash.

Hash binding prevents accidentally reusing a review after changing a draft or contract. It does not prove the reviewer was correct or honest. A model-written attestation remains model judgement; the gate is not an independent semantic verifier. The host must actually invoke the gate for mechanical enforcement. Never claim this script proves human authorship, factual truth or complete format preservation.

Run local regression tests with `python -B -m unittest discover -s evals -p "test_*.py"`. Behavioural cases in [cases.json](../evals/cases.json) test decisions that literal checks cannot establish. Keep evaluation evidence separate from runtime drafts.

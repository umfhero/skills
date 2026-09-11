#!/usr/bin/env python3
"""Read-only UTF-8 checks and a review-bound output gate. Python 3.10+, stdlib only."""

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import sys

REVIEW_GATES = ("meaning", "evidence", "protection", "style", "editorial", "voice")
NUMBER = re.compile(r"(?<!\w)[+-]?(?:\d+(?:[.,]\d+)*|[.,]\d+)(?:[eE][+-]?\d+)?%?(?!\w)")


def digest(data):
    return hashlib.sha256(data).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def decode_json(data):
    def unique_object(pairs):
        result = {}
        for key, value in pairs:
            require(key not in result, "Duplicate JSON key: " + key)
            result[key] = value
        return result

    def reject_constant(value):
        raise ValueError("Non-finite JSON constant: " + value)

    return json.loads(data.decode("utf-8-sig"), object_pairs_hook=unique_object, parse_constant=reject_constant)


def validate_contract(contract):
    require(isinstance(contract, dict), "Contract must be an object")
    allowed = {"version", "mode", "protected", "preserve_order", "forbidden_characters",
               "forbidden_phrases", "min_words", "max_words"}
    require(not (set(contract) - allowed), "Unknown contract field")
    require(type(contract.get("version")) is int and contract["version"] == 1, "version must be 1")
    require(contract.get("mode") in ("draft", "edit"), "mode must be draft or edit")
    require(isinstance(contract.get("protected"), list), "protected must be an explicit list")
    ids = set()
    for item in contract["protected"]:
        require(isinstance(item, dict) and set(item) == {"id", "text"}, "Protected entries need only id and text")
        require(isinstance(item["id"], str) and bool(item["id"].strip()), "Protected id must be nonempty")
        require(item["id"] not in ids, "Duplicate protected id")
        require(isinstance(item["text"], str) and bool(item["text"]), "Protected text must be nonempty")
        ids.add(item["id"])
    if "preserve_order" in contract:
        require(type(contract["preserve_order"]) is bool, "preserve_order must be boolean")
    for key in ("forbidden_characters", "forbidden_phrases"):
        if key in contract:
            require(isinstance(contract[key], list), key + " must be a list")
            require(all(isinstance(x, str) and x for x in contract[key]), key + " entries must be nonempty strings")
    require(all(len(x) == 1 for x in contract.get("forbidden_characters", [])), "Forbidden characters must be single codepoints")
    for key in ("min_words", "max_words"):
        if key in contract:
            require(type(contract[key]) is int and contract[key] >= 0, key + " must be a nonnegative integer")
    require(contract.get("min_words", 0) <= contract.get("max_words", float("inf")), "Inverted word limits")


def spans(text, protected):
    found = []
    for item in protected:
        for match in re.finditer(r"(?=" + re.escape(item["text"]) + r")", text):
            found.append((match.start(), match.start() + len(item["text"]), item["id"]))
    return sorted(found)


def assess(original_bytes, candidate_bytes, contract_bytes, review=None):
    original = original_bytes.decode("utf-8")
    candidate = candidate_bytes.decode("utf-8")
    contract = decode_json(contract_bytes)
    validate_contract(contract)
    hashes = {"original_sha256": digest(original_bytes), "candidate_sha256": digest(candidate_bytes),
              "contract_sha256": digest(contract_bytes)}
    checks = []

    def record(check_id, status, detail):
        checks.append({"id": check_id, "status": status, "detail": detail})

    before = spans(original, contract["protected"])
    after = spans(candidate, contract["protected"])
    for selected in (before, after):
        require(all(a[1] <= b[0] for a, b in zip(selected, selected[1:])), "Protected specifications overlap; use the outermost span")
    before_counts = Counter(x[2] for x in before)
    after_counts = Counter(x[2] for x in after)
    for item in contract["protected"]:
        require(before_counts[item["id"]] > 0, "Protected text absent from original: " + item["id"])
    exact = before_counts == after_counts
    record("protected.content", "pass" if exact else "fail", "Exact occurrences of declared protected text compared")
    order_ok = not contract.get("preserve_order", True) or [x[2] for x in before] == [x[2] for x in after]
    record("protected.order", "pass" if order_ok else "fail", "Declared protected occurrence order compared")

    editable = list(candidate)
    for start, end, _ in after:
        editable[start:end] = [" " if c not in "\r\n" else c for c in candidate[start:end]]
    editable = "".join(editable)
    forbidden_chars = contract.get("forbidden_characters", ["\u2014", "\u2013"])
    bad_chars = sum(editable.count(c) for c in forbidden_chars)
    record("style.characters", "fail" if bad_chars else "pass", str(bad_chars) + " forbidden character occurrences in editable text")
    bad_phrases = 0
    for phrase in contract.get("forbidden_phrases", []):
        # Whole terms/phrases, case-insensitive; not substrings inside identifiers.
        bad_phrases += len(re.findall(r"(?<!\w)" + re.escape(phrase) + r"(?!\w)", editable, re.IGNORECASE))
    record("style.phrases", "fail" if bad_phrases else "pass", str(bad_phrases) + " forbidden phrase occurrences in editable text")
    words = len(candidate.split())
    length_ok = contract.get("min_words", 0) <= words <= contract.get("max_words", float("inf"))
    record("length", "pass" if length_ok else "fail", str(words) + " whitespace-delimited tokens in complete candidate")
    numeric_change = NUMBER.findall(original) != NUMBER.findall(candidate)
    record("numbers", "needs_review" if numeric_change else "pass",
           "Ordered numeric-token comparison; unchanged tokens do not establish roles or meaning")

    # Review must cover the precise bytes and policy checked here. It is judgement,
    # not an independent mathematical proof of semantic fidelity.
    if review is None:
        record("review", "needs_review", "Six review gates and protection-map coverage have not been attested")
        review_kind = "not_run"
    else:
        require(isinstance(review, dict), "Review must be an object")
        require(not (set(review) - {"original_sha256", "candidate_sha256", "contract_sha256", "reviewer_kind", "gates", "number_change_reason"}), "Unknown review field")
        require(review.get("reviewer_kind") in ("model", "human"), "reviewer_kind must be model or human")
        review_kind = review["reviewer_kind"]
        valid_binding = all(review.get(k) == value for k, value in hashes.items())
        record("review.binding", "pass" if valid_binding else "needs_review", "Review must match original, candidate and contract SHA-256")
        gates = review.get("gates")
        require(isinstance(gates, dict) and set(gates) == set(REVIEW_GATES), "Review must contain exactly the six required gates")
        for name in REVIEW_GATES:
            gate = gates[name]
            require(isinstance(gate, dict), "Review gate must be an object")
            require(set(gate) == {"status", "evidence"}, "Review gates need only status and evidence")
            require(gate.get("status") in ("pass", "fail", "needs_review"), "Invalid review status")
            require(isinstance(gate.get("evidence"), str) and bool(gate["evidence"].strip()), "Each gate needs concrete evidence")
            record("review." + name, gate["status"] if valid_binding else "needs_review", gate["evidence"])
        resolution = review.get("number_change_reason")
        if numeric_change and valid_binding and isinstance(resolution, str) and resolution.strip() and gates["meaning"]["status"] == "pass":
            for check in checks:
                if check["id"] == "numbers":
                    check.update(status="pass", detail="Numeric change accepted by " + review_kind + " review: " + resolution)
    status = "fail" if any(c["status"] == "fail" for c in checks) else (
        "needs_review" if any(c["status"] == "needs_review" for c in checks) else "pass")
    return {"version": 1, "status": status, **hashes, "reviewer_kind": review_kind,
            "checks": checks, "limits": "Explicit protection map only; no document parser, fact lookup, authorship test or semantic proof"}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("original", type=Path, help="Original text or evidence brief")
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--contract", type=Path, required=True)
    parser.add_argument("--review", type=Path)
    parser.add_argument("--emit", action="store_true", help="Print only accepted candidate bytes; otherwise emit no candidate")
    args = parser.parse_args(argv)
    try:
        original = args.original.read_bytes()
        candidate = args.candidate.read_bytes()
        contract = args.contract.read_bytes()
        review = decode_json(args.review.read_bytes()) if args.review else None
        result = assess(original, candidate, contract, review)
    except (OSError, UnicodeError, ValueError, TypeError, KeyError) as error:
        print(json.dumps({"status": "invalid", "error": str(error)}, ensure_ascii=True), file=sys.stderr)
        return 3
    code = {"pass": 0, "fail": 1, "needs_review": 2}[result["status"]]
    if args.emit:
        if code == 0:
            sys.stdout.buffer.write(candidate)
        else:
            print(json.dumps(result, ensure_ascii=True), file=sys.stderr)
    else:
        print(json.dumps(result, ensure_ascii=True, indent=2))
    return code


if __name__ == "__main__":
    sys.exit(main())

"""Observable delivery and preservation checks; no detector-score assertions."""
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "check_text.py"
spec = importlib.util.spec_from_file_location("anti_slop_gate", SCRIPT)
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)


class GateTests(unittest.TestCase):
    def setUp(self):
        self.original = b"The review starts at 10."
        self.candidate = self.original
        self.contract = {"version": 1, "mode": "edit", "protected": []}

    def contract_bytes(self):
        return json.dumps(self.contract, ensure_ascii=False).encode("utf-8")

    def check(self, review=None):
        return gate.assess(self.original, self.candidate, self.contract_bytes(), review)

    def review(self, **overrides):
        result = self.check()
        review = {k: result[k] for k in ("original_sha256", "candidate_sha256", "contract_sha256")}
        review.update(reviewer_kind="model", gates={
            name: {"status": "pass", "evidence": "Synthetic fixture review for " + name}
            for name in gate.REVIEW_GATES})
        review.update(overrides)
        return review

    def test_clean_text_requires_review(self):
        self.assertEqual(self.check()["status"], "needs_review")

    def test_bound_review_accepts(self):
        self.assertEqual(self.check(self.review())["status"], "pass")

    def test_changed_candidate_invalidates_review(self):
        review = self.review()
        self.candidate = b"The review starts at 10. Bring notes."
        self.assertEqual(self.check(review)["status"], "needs_review")

    def test_changed_original_invalidates_review(self):
        review = self.review()
        self.original += b" Bring notes."
        self.assertEqual(self.check(review)["status"], "needs_review")

    def test_changed_contract_invalidates_review(self):
        review = self.review()
        self.contract["max_words"] = 50
        self.assertEqual(self.check(review)["status"], "needs_review")

    def test_declared_quote_is_exempt_from_dash_rule(self):
        self.original = self.candidate = 'She said "Keep this—exactly."'.encode()
        self.contract["protected"] = [{"id": "quote", "text": '"Keep this—exactly."'}]
        self.assertEqual(self.check(self.review())["status"], "pass")

    def test_changed_quote_blocks_even_positive_review(self):
        self.original = b'She said "Keep this exactly."'
        self.candidate = b'She said "Keep this roughly."'
        self.contract["protected"] = [{"id": "quote", "text": '"Keep this exactly."'}]
        self.assertEqual(self.check(self.review())["status"], "fail")

    def test_repeated_protected_occurrence_removed(self):
        self.original, self.candidate = b"[1] supports A; [1] supports B", b"[1] supports A"
        self.contract["protected"] = [{"id": "citation", "text": "[1]"}]
        self.assertEqual(self.check(self.review())["status"], "fail")

    def test_protected_order_change_blocks(self):
        self.original, self.candidate = b"<A> then <B>", b"<B> then <A>"
        self.contract["protected"] = [{"id": "a", "text": "<A>"}, {"id": "b", "text": "<B>"}]
        self.assertEqual(self.check(self.review())["status"], "fail")

    def test_authorised_order_change(self):
        self.original, self.candidate = b"<A> then <B>", b"<B> then <A>"
        self.contract.update(protected=[{"id": "a", "text": "<A>"}, {"id": "b", "text": "<B>"}], preserve_order=False)
        self.assertEqual(self.check(self.review())["status"], "pass")

    def test_dash_outside_protection_blocks(self):
        self.candidate = "The review—at 10—starts.".encode()
        self.assertEqual(self.check(self.review())["status"], "fail")

    def test_phrases_respect_word_boundaries(self):
        self.original = self.candidate = b"We showcase the casework."
        self.contract["forbidden_phrases"] = ["case"]
        self.assertEqual(self.check(self.review())["status"], "pass")

    def test_phrase_match_case_insensitive(self):
        self.candidate = b"A GAME-CHANGER."
        self.contract["forbidden_phrases"] = ["game-changer"]
        self.assertEqual(self.check(self.review())["status"], "fail")

    def test_length_blocks(self):
        self.contract["max_words"] = 2
        self.assertEqual(self.check(self.review())["status"], "fail")

    def test_numeric_order_change_requires_resolution(self):
        self.original, self.candidate = b"From 15 to 10", b"From 10 to 15"
        self.assertEqual(self.check(self.review())["status"], "needs_review")

    def test_legitimate_number_spelling_requires_reason(self):
        self.candidate = b"The review starts at ten."
        review = self.review(number_change_reason="10 is written as ten; same time and event.")
        self.assertEqual(self.check(review)["status"], "pass")

    def test_semantic_failure_cannot_be_offset(self):
        self.original, self.candidate = b"A used 12 GB", b"B used 12 GB"
        review = self.review()
        review["gates"]["meaning"] = {"status": "fail", "evidence": "Actor changed from A to B."}
        self.assertEqual(self.check(review)["status"], "fail")

    def test_missing_gate_rejected(self):
        review = self.review()
        del review["gates"]["protection"]
        with self.assertRaises(ValueError):
            self.check(review)

    def test_empty_gate_evidence_rejected(self):
        review = self.review()
        review["gates"]["meaning"]["evidence"] = " "
        with self.assertRaises(ValueError):
            self.check(review)

    def test_unknown_contract_field_rejected(self):
        self.contract["protect_everything_automatically"] = True
        with self.assertRaises(ValueError):
            self.check()

    def test_string_boolean_rejected(self):
        self.contract["preserve_order"] = "false"
        with self.assertRaises(ValueError):
            self.check()

    def test_missing_source_span_rejected(self):
        self.contract["protected"] = [{"id": "missing", "text": "not in source"}]
        with self.assertRaises(ValueError):
            self.check()

    def test_overlapping_spans_rejected(self):
        self.contract["protected"] = [{"id": "whole", "text": "The review"}, {"id": "part", "text": "review"}]
        with self.assertRaises(ValueError):
            self.check()

    def test_exact_code_table_and_crlf_preserved(self):
        block = '| flag |\r\n| --- |\r\n| --safe |\r\n````\r\n```\r\n````\r\n'
        self.original = self.candidate = ("Details:\r\n" + block).encode()
        self.contract["protected"] = [{"id": "block", "text": block}]
        self.assertEqual(self.check(self.review())["status"], "pass")
        self.candidate = self.candidate.replace(b"--safe", b"-safe")
        self.assertEqual(self.check(self.review())["status"], "fail")

    def test_unicode_not_normalised(self):
        self.original = self.candidate = "Настройки\u200d".encode()
        self.assertEqual(self.check(self.review())["status"], "pass")

    def test_self_overlapping_protected_occurrences_rejected(self):
        self.original, self.candidate = b"ababa", b"aba"
        self.contract["protected"] = [{"id": "repeat", "text": "aba"}]
        with self.assertRaises(ValueError):
            self.check()

    def test_leading_decimal_change_requires_review(self):
        self.original, self.candidate = b"The dose was .5 units", b"The dose was 5 units"
        self.assertEqual(self.check(self.review())["status"], "needs_review")

    def test_scientific_notation_change_requires_review(self):
        self.original, self.candidate = b"The value was 1e3", b"The value was 9e8"
        self.assertEqual(self.check(self.review())["status"], "needs_review")

    def test_duplicate_json_policy_rejected(self):
        data = b'{"version":1,"mode":"edit","protected":[],"max_words":0,"max_words":100}'
        with self.assertRaises(ValueError):
            gate.assess(self.original, self.candidate, data)

    def test_nonfinite_json_rejected(self):
        with self.assertRaises(ValueError):
            gate.decode_json(b'{"max_words": NaN}')

    def test_unimplemented_review_setting_rejected(self):
        review = self.review()
        review["ignore_failures"] = True
        with self.assertRaises(ValueError):
            self.check(review)

    def test_emit_is_exact_and_failure_emits_no_candidate(self):
        self.original = self.candidate = b"The review starts at 10.\r\n"
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "source.txt").write_bytes(self.original)
            (root / "draft.txt").write_bytes(self.candidate)
            (root / "contract.json").write_bytes(self.contract_bytes())
            (root / "review.json").write_text(json.dumps(self.review()), encoding="utf-8")
            command = [sys.executable, "-B", str(SCRIPT), str(root / "source.txt"), str(root / "draft.txt"),
                       "--contract", str(root / "contract.json"), "--emit"]
            missing = subprocess.run(command, capture_output=True)
            self.assertEqual((missing.returncode, missing.stdout), (2, b""))
            accepted = subprocess.run(command + ["--review", str(root / "review.json")], capture_output=True)
            self.assertEqual((accepted.returncode, accepted.stdout), (0, self.candidate))
            self.assertEqual((root / "source.txt").read_bytes(), self.original)
            self.assertEqual((root / "draft.txt").read_bytes(), self.candidate)
            (root / "draft.txt").write_bytes(b"Different text.")
            stale = subprocess.run(command + ["--review", str(root / "review.json")], capture_output=True)
            self.assertEqual((stale.returncode, stale.stdout), (2, b""))


if __name__ == "__main__":
    unittest.main()

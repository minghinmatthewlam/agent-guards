#!/usr/bin/env python3
from __future__ import annotations

import importlib.machinery
import importlib.util
import io
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path


SCRIPT = Path(__file__).with_name("autoreview")
LOADER = importlib.machinery.SourceFileLoader("autoreview_module", str(SCRIPT))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
assert SPEC is not None
AUTOREVIEW = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(AUTOREVIEW)


def finding(priority: str, *, confidence: float = 0.8, line: int = 1) -> dict:
    return {
        "title": f"{priority} finding",
        "body": "Concrete defect.",
        "priority": priority,
        "confidence": confidence,
        "category": "bug",
        "code_location": {"file_path": "app.py", "line": line},
    }


def report(*findings: dict, correctness: str = "patch is incorrect") -> dict:
    return {
        "findings": list(findings),
        "overall_correctness": correctness,
        "overall_explanation": "Review complete.",
        "overall_confidence": 0.9,
    }


class AutoReviewUnitTests(unittest.TestCase):
    def test_default_p1_threshold_keeps_advisory_findings_nonblocking(self) -> None:
        reviewed = report(finding("P2"), finding("P3"))
        self.assertEqual(
            AUTOREVIEW.review_exit_code(
                reviewed,
                tests_status=0,
                fail_on="P1",
                expect_findings=False,
            ),
            0,
        )

    def test_default_p1_threshold_blocks_p0_and_p1(self) -> None:
        for priority in ("P0", "P1"):
            with self.subTest(priority=priority):
                reviewed = report(finding(priority))
                self.assertEqual(
                    AUTOREVIEW.review_exit_code(
                        reviewed,
                        tests_status=0,
                        fail_on="P1",
                        expect_findings=False,
                    ),
                    1,
                )

    def test_validate_report_sorts_findings_by_priority(self) -> None:
        reviewed = report(
            finding("P3", line=3),
            finding("P1", confidence=0.7, line=2),
            finding("P0", line=4),
            finding("P1", confidence=0.9, line=1),
        )
        with tempfile.TemporaryDirectory() as directory:
            AUTOREVIEW.validate_report(reviewed, Path(directory), {"app.py"}, [])
        self.assertEqual(
            [item["priority"] for item in reviewed["findings"]],
            ["P0", "P1", "P1", "P3"],
        )
        self.assertEqual([item["code_location"]["line"] for item in reviewed["findings"]], [4, 1, 2, 3])

    def test_prompt_rejects_hypothetical_compatibility_work(self) -> None:
        prompt = AUTOREVIEW.build_prompt(
            Path("/tmp/repo"),
            "local",
            None,
            "diff",
            "Task intent: replace the old API.",
            "",
        )
        self.assertIn("Do not assume backward compatibility is required", prompt)
        self.assertIn("compatibility shims", prompt)
        self.assertIn("P1 = likely user-facing", prompt)

    def test_report_makes_advisory_threshold_pass_explicit(self) -> None:
        output = io.StringIO()
        with redirect_stdout(output):
            AUTOREVIEW.print_report(report(finding("P2")), fail_on="P1")
        self.assertIn("0 blocking at P1 or higher", output.getvalue())
        self.assertIn("threshold: pass (--fail-on P1)", output.getvalue())

    def test_incorrect_without_findings_is_rejected_as_inconsistent(self) -> None:
        reviewed = report()
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(SystemExit, "without a discrete prioritized finding"):
                AUTOREVIEW.validate_report(reviewed, Path(directory), {"app.py"}, [])

    def test_panel_deduplication_retains_the_most_severe_priority(self) -> None:
        advisory = finding("P2", confidence=0.9, line=7)
        blocking = finding("P1", confidence=0.7, line=7)
        advisory["title"] = blocking["title"] = "Same defect"
        merged = AUTOREVIEW.merge_panel_reports(
            [
                ("codex", report(advisory)),
                ("claude", report(blocking)),
            ]
        )
        self.assertEqual(len(merged["findings"]), 1)
        self.assertEqual(merged["findings"][0]["priority"], "P1")
        self.assertIn("Reviewer: claude", merged["findings"][0]["body"])
        self.assertEqual(
            AUTOREVIEW.review_exit_code(
                merged,
                tests_status=0,
                fail_on="P1",
                expect_findings=False,
            ),
            1,
        )


if __name__ == "__main__":
    unittest.main()

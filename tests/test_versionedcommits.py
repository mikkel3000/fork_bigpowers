"""Exercise free-form commits and unchanged git protections in disposable repos."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class VersionedCommitsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name)
        self.git("init", "-b", "main")
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.invalid")
        self.git("commit", "--allow-empty", "-m", "Initialize repository")
        self.git("checkout", "-b", "feature")

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.repo, text=True, capture_output=True, check=True
        ).stdout.strip()

    def hook(self, path, command):
        return subprocess.run(
            ["bash", str(ROOT / path)], cwd=self.repo, text=True,
            input=json.dumps({"tool_input": {"command": command}}),
            capture_output=True,
        )

    def test_free_form_messages_with_and_without_release_notes(self):
        for path in ("hooks/pre-tool-use.sh", "hooks/pre/bash.sh"):
            for message in (
                "Reorganize internal fixtures",
                "Repair skill lookup\n\n@patch Fixed missing skill links",
                "Add search\n\n@minor Added catalog search\nFind skills by name.\n@minor",
                "Replace public API\n\n@major Changed lookup API\nUse lookupV2.\n@major",
            ):
                with self.subTest(path=path, message=message):
                    result = self.hook(path, "git commit -m '" + message + "'")
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertNotIn('"block"', result.stdout)

    def test_protected_branch_and_destructive_command_still_blocked(self):
        self.git("checkout", "main")
        for path in ("hooks/pre-tool-use.sh", "hooks/pre/bash.sh"):
            for command in ("git commit -m 'Repair lookup'", "git reset --hard"):
                with self.subTest(path=path, command=command):
                    result = self.hook(path, command)
                    self.assertTrue(result.returncode != 0 or '"block"' in result.stdout)

    def test_subject_length_and_attribution_checks_remain(self):
        for message in ("x" * 73, "Repair lookup\n\nCo-authored-by: Agent <a@b.invalid>"):
            result = self.hook("hooks/pre-tool-use.sh", "git commit -m '" + message + "'")
            self.assertEqual(result.returncode, 2)

    def test_landing_preserves_complete_release_message(self):
        (self.repo / "change.txt").write_text("new capability\n")
        self.git("add", "change.txt")
        self.git("commit", "-m", "Implement capability")
        message = "Add catalog search\n\n@minor Added catalog search\nFind skills by name.\n@minor"
        result = subprocess.run(
            ["bash", str(ROOT / "scripts/land-branch.sh"), "feature", message],
            cwd=self.repo, text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.git("log", "-1", "--format=%B"), message)
        self.assertEqual(self.git("branch", "--show-current"), "main")


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Build individual public skill ZIPs and the README. Run with --check for CI/read-only verification."""

import argparse
import hashlib
import io
import json
from pathlib import Path
import stat
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
TEXT_SUFFIXES = {".md", ".txt", ".json", ".yaml", ".yml", ".py", ".js", ".css", ".tsx", ".ts", ".html", ".svg"}
# Explicit public catalogue: local/private skill directories are never auto-discovered.
CATALOGUE = (
    ("Text", "anti-slop", "Anti-slop (latest)", "Recommended writing skill. Natural prose with strict meaning, evidence and style checks."),
    ("Text · legacy", "stop-slopv3", "stop-slopv3", "Earlier author-voice and AI-pattern rules."),
    ("Text · legacy", "stop-slopv2", "stop-slopv2", "Original author-voice rules, kept for compatibility."),
    ("Design", "bareminimum-design", "Bareminimum Design", "Clean typography, layouts and reusable UI foundations."),
    ("Design", "pixel-design", "Pixel Design", "Retro interfaces with pixel icons, hard borders and stepped motion."),
    ("Design", "git-design", "Git Design", "GitHub Universe-inspired layouts, typography and interactions."),
)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def source_files(folder):
    base = ROOT / "Skills" / folder
    if base.is_symlink() or not base.is_dir() or base.resolve().parent != (ROOT / "Skills").resolve():
        raise ValueError("Invalid public skill directory: " + folder)
    if not (base / "SKILL.md").is_file():
        raise ValueError("Missing SKILL.md: " + folder)
    files = {}
    for path in sorted(base.rglob("*")):
        relative = path.relative_to(base)
        if any(part.startswith(".") or part == "__pycache__" for part in relative.parts) or path.suffix == ".pyc":
            continue
        if path.is_symlink() or (hasattr(path, "is_junction") and path.is_junction()):
            raise ValueError("Links are not distributable: " + str(relative))
        if not path.resolve().is_relative_to(base.resolve()):
            raise ValueError("Source escaped skill directory")
        if path.is_file():
            data = path.read_bytes()
            # Match Git's canonical text representation across LF/CRLF checkouts.
            if path.suffix.lower() in TEXT_SUFFIXES:
                data = data.replace(b"\r\n", b"\n")
            files[folder + "/" + relative.as_posix()] = data
    return files


def make_zip(files):
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name, data in sorted(files.items()):
            entry = zipfile.ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
            entry.create_system = 3
            entry.external_attr = (stat.S_IFREG | 0o644) << 16
            entry.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(entry, data, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    result = buffer.getvalue()
    with zipfile.ZipFile(io.BytesIO(result)) as archive:
        if archive.testzip() is not None or set(archive.namelist()) != set(files):
            raise ValueError("Archive verification failed")
        for name, data in files.items():
            if archive.read(name) != data:
                raise ValueError("Archive content mismatch: " + name)
    return result


def readme():
    lines = ["# Skills", "", "**Anti-slop is the latest version of the stop-slop writing skill and the recommended choice.** Earlier versions are listed as legacy.", "",
             "Download one skill below. Each ZIP includes its `SKILL.md` and supporting files.", "",
             "| Category | Skill | Use it for | Download |", "| --- | --- | --- | --- |"]
    for category, folder, label, description in CATALOGUE:
        url = "https://github.com/umfhero/skills/raw/refs/heads/main/downloads/" + folder + ".zip"
        lines.append(f"| {category} | [{label}](Skills/{folder}/) | {description} | [ZIP]({url}) |")
    lines += ["", "Import the ZIP into a tool that supports skill uploads, or extract the skill folder into your tool's skills directory. For Codex, use `~/.codex/skills/`; for Claude Code, use `~/.claude/skills/`. Downloading does not install it automatically.", "",
              "Maintainers: `python scripts/package_skills.py` rebuilds the ZIPs and this table; add `--check` to verify they match the source.", ""]
    return "\n".join(lines).encode("utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    outputs = {}
    manifest = {"version": 1, "skills": []}
    for _, folder, _, _ in CATALOGUE:
        files = source_files(folder)
        zipped = make_zip(files)
        outputs["downloads/" + folder + ".zip"] = zipped
        manifest["skills"].append({"name": folder, "archive": folder + ".zip", "sha256": sha256(zipped),
                                   "files": {name: sha256(data) for name, data in files.items()}})
    outputs["downloads/manifest.json"] = (json.dumps(manifest, indent=2) + "\n").encode("utf-8")
    outputs["readme.md"] = readme()
    extra = set((ROOT / "downloads").glob("*.zip")) - {ROOT / path for path in outputs if path.endswith(".zip")}
    if extra:
        raise ValueError("Unexpected ZIPs in downloads; inspect before removal: " + ", ".join(x.name for x in extra))
    stale = []
    for relative, data in outputs.items():
        target = ROOT / relative
        if target.is_symlink() or (hasattr(target.parent, "is_junction") and target.parent.is_junction()):
            raise ValueError("Output links are not supported")
        if args.check:
            current = target.read_bytes() if target.is_file() else None
            if current is not None and target.suffix.lower() in TEXT_SUFFIXES:
                current = current.replace(b"\r\n", b"\n")
            if current != data:
                stale.append(relative)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
    if stale:
        print("Out of date: " + ", ".join(stale), file=sys.stderr)
        return 1
    print(("Verified" if args.check else "Built and verified") + f" {len(CATALOGUE)} skill ZIPs, manifest and README.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)

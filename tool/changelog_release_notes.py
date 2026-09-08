#!/usr/bin/env python3
"""Read the top entry of CHANGELOG.md, or build dev/staging release notes.

Used by .github/workflows/deploy.yml to feed Firebase App Distribution.

    python3 tool/changelog_release_notes.py                 # -> release notes body
    python3 tool/changelog_release_notes.py --field version  # -> 1.2.0
    python3 tool/changelog_release_notes.py --auto-since-previous-tag v1.3.0-dev.3
        # -> commit subjects since the previous tag in the same stage
        #    (same -dev./-stag. family), for dev/staging builds that have no
        #    hand-written CHANGELOG entry.

The changelog format is one section per release, newest first:

    ## [1.2.0] - 2026-09-08

    Free-text notes for testers...

Anything between the first `## [x.y.z]` heading and the next `## ` heading is the
body. The version is the `x.y.z` inside the brackets.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

HEADING = re.compile(r"^##\s*\[([^\]]+)\]")
# v1.3.0-dev.2 -> stage "dev"; v1.3.0-stag.1 -> stage "stag"; v1.3.0 -> stage "" (production).
STAGE = re.compile(r"^v[^-]+(?:-(dev|stag)\.\d+)?$")


def stage_of(tag: str) -> str:
    match = STAGE.match(tag)
    if not match:
        sys.exit(f"changelog_release_notes: '{tag}' is not a recognized tag shape")
    return match.group(1) or ""


def previous_tag_same_stage(tag: str) -> str | None:
    """The most recent tag before `tag`, in the same stage (dev/stag/production)."""
    stage = stage_of(tag)
    all_tags = subprocess.run(
        ["git", "tag", "--sort=-creatordate"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.splitlines()
    seen_self = False
    for candidate in all_tags:
        if candidate == tag:
            seen_self = True
            continue
        if not seen_self:
            continue
        try:
            if stage_of(candidate) == stage:
                return candidate
        except SystemExit:
            continue  # ignore tags that don't match our shape (e.g. old "flavors")
    return None


def auto_notes_since_previous_tag(tag: str) -> str:
    previous = previous_tag_same_stage(tag)
    range_spec = f"{previous}..{tag}" if previous else tag
    log = subprocess.run(
        ["git", "log", range_spec, "--pretty=format:- %s", "--no-merges"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    return (log or "- No changes recorded since the previous build.") + "\n"


def top_entry(text: str) -> tuple[str, str]:
    version: str | None = None
    body: list[str] = []
    for line in text.splitlines():
        if version is None:
            match = HEADING.match(line)
            if match:
                version = match.group(1).strip()
            continue
        if line.startswith("## "):
            break
        body.append(line)

    if version is None:
        sys.exit("changelog_release_notes: no '## [version]' heading found in CHANGELOG.md")

    return version, "\n".join(body).strip() + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--field", choices=["version", "notes"], default="notes")
    parser.add_argument(
        "--changelog",
        default=str(Path(__file__).resolve().parent.parent / "CHANGELOG.md"),
    )
    parser.add_argument(
        "--auto-since-previous-tag",
        metavar="TAG",
        help="Skip CHANGELOG.md; print commit subjects since the previous tag "
        "in the same stage as TAG (for dev/staging builds).",
    )
    args = parser.parse_args()

    if args.auto_since_previous_tag:
        sys.stdout.write(auto_notes_since_previous_tag(args.auto_since_previous_tag))
        return

    version, notes = top_entry(Path(args.changelog).read_text(encoding="utf-8"))
    sys.stdout.write(version + "\n" if args.field == "version" else notes)


if __name__ == "__main__":
    main()

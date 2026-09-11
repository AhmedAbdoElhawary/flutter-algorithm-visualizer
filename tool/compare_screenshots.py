#!/usr/bin/env python3
"""Diff two directories of A5i device screenshots, pixel by pixel.

The on-device backstop for feature 001-render-performance-60fps. Host-renderer
goldens (`flutter test test/golden`) are the automated gate; this covers the one
thing they cannot see — the device GPU's actual blur output.

    python3 tool/compare_screenshots.py BEFORE_DIR AFTER_DIR

Pairs are matched by filename. Files present in only one directory are reported
as errors, not silently skipped.

    --ignore-top PCT   crop the top PCT% of each image before comparing
                       (default 4.0 — the status bar clock and battery icon
                       change between captures and are not app pixels)
    --tolerance PCT    differing-pixel budget, as a percentage of compared
                       pixels (default 0.0 — exact)
    --diff-dir DIR     write a heatmap for each flagged pair into DIR

Exit code is 0 when every pair is within tolerance, 1 otherwise. The point is to
spend zero human (and zero model) attention on the pairs that are clean, and
spend it only on the pairs this script flags.

Animated surfaces never match exactly: the Home particle ticker and the aurora
background are mid-animation at capture time, so those pairs will exceed any
tolerance. That is expected — they are the pairs a person inspects.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image, ImageChops
except ImportError:
    sys.exit("compare_screenshots: needs Pillow — run 'pip3 install Pillow'")

SUFFIXES = {".png", ".jpg", ".jpeg"}


def load(path: Path, ignore_top: float) -> Image.Image:
    image = Image.open(path).convert("RGB")
    if ignore_top <= 0:
        return image
    top = round(image.height * ignore_top / 100)
    return image.crop((0, top, image.width, image.height))


def compare(before: Path, after: Path, ignore_top: float) -> tuple[int, int, int]:
    """Return (differing pixels, compared pixels, worst channel delta)."""
    first, second = load(before, ignore_top), load(after, ignore_top)
    if first.size != second.size:
        raise ValueError(f"size differs: {first.size} vs {second.size}")

    delta = ImageChops.difference(first, second)
    # One band per channel; a pixel differs if any channel does.
    flat = delta.convert("L").point(lambda value: 255 if value else 0)
    total = first.width * first.height
    differing = total - flat.histogram()[0]
    worst = max(high for _, high in delta.getextrema())
    return differing, total, worst


def write_heatmap(before: Path, after: Path, ignore_top: float, out: Path) -> None:
    first, second = load(before, ignore_top), load(after, ignore_top)
    delta = ImageChops.difference(first, second).convert("L")
    # Amplify so a 1/255 difference is still visible to the eye.
    heatmap = delta.point(lambda value: min(255, value * 16))
    heatmap.thumbnail((600, 600))
    out.parent.mkdir(parents=True, exist_ok=True)
    heatmap.save(out)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("before", type=Path)
    parser.add_argument("after", type=Path)
    parser.add_argument("--ignore-top", type=float, default=4.0)
    parser.add_argument("--tolerance", type=float, default=0.0)
    parser.add_argument("--diff-dir", type=Path)
    args = parser.parse_args()

    for directory in (args.before, args.after):
        if not directory.is_dir():
            sys.exit(f"compare_screenshots: no such directory: {directory}")

    def shots(directory: Path) -> dict[str, Path]:
        return {p.name: p for p in sorted(directory.iterdir()) if p.suffix.lower() in SUFFIXES}

    before_shots, after_shots = shots(args.before), shots(args.after)
    if not before_shots:
        sys.exit(f"compare_screenshots: no images in {args.before}")

    flagged: list[str] = []
    for name in sorted(before_shots.keys() | after_shots.keys()):
        if name not in before_shots or name not in after_shots:
            missing = args.after if name not in after_shots else args.before
            print(f"  MISSING  {name:<40} not in {missing}")
            flagged.append(name)
            continue

        try:
            differing, total, worst = compare(before_shots[name], after_shots[name], args.ignore_top)
        except ValueError as error:
            print(f"  ERROR    {name:<40} {error}")
            flagged.append(name)
            continue

        percent = differing / total * 100
        if percent > args.tolerance:
            print(f"  INSPECT  {name:<40} {differing:>9,} px ({percent:.4f}%)  max Δ {worst}")
            flagged.append(name)
            if args.diff_dir:
                write_heatmap(
                    before_shots[name], after_shots[name], args.ignore_top,
                    args.diff_dir / f"{Path(name).stem}-diff.png",
                )
        else:
            print(f"  ok       {name:<40} {differing:>9,} px ({percent:.4f}%)")

    print()
    if flagged:
        print(f"{len(flagged)} of {len(before_shots)} pairs need a human look: {', '.join(flagged)}")
        if args.diff_dir:
            print(f"Heatmaps written to {args.diff_dir} — bright areas are where the pixels moved.")
        return 1

    print(f"All {len(before_shots)} pairs identical within tolerance. No visual inspection needed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

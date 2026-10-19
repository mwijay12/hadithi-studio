#!/usr/bin/env python3
"""Punguza ukubwa wa PNG za app kwa ajili ya web bundle.

Matumizi:
    python3 tool/optimize_png.py

Huhitaji hoja: orodha ya kazi ipo ndani ya `JOBS` hapa chini.

Kwa nini: taswira za awali zilikuwa 1.4-2.8 MB kila moja (~25 MB jumla),
jambo ambalo lingefanya web bundle kuwa nzito sana kwa mtandao wa Tanzania.
Tunapunguza azimio hadi kile kinachohitajika kwa skrini halisi, kisha
kuhifadhi kwa `optimize=True`.

Inahitaji Pillow: `python3 -m pip install Pillow`.
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent

# (faili, upana wa lengo) — urefu hufuata uwiano wa picha.
JOBS: list[tuple[str, int]] = [
    # Slide za onboarding — zinaonekana kwa upana wa ~420dp, 900px ni ya kutosha
    # hata kwenye skrini za retina.
    ("assets/images/onboarding/onboarding_read.png", 900),
    ("assets/images/onboarding/onboarding_listen.png", 900),
    ("assets/images/onboarding/onboarding_create.png", 900),
    ("assets/images/onboarding/onboarding_language.png", 900),
    # Kadi za kategoria — kadi ni ndogo (nusu ya skrini).
    ("assets/images/categories/cat_animal_stories.png", 560),
    ("assets/images/categories/cat_morals_wisdom.png", 560),
    ("assets/images/categories/cat_science.png", 560),
    ("assets/images/categories/cat_culture.png", 560),
    ("assets/images/categories/cat_poems_songs.png", 560),
    ("assets/images/categories/cat_safari.png", 560),
    # Hero ya Nyumbani — upana kamili wa skrini.
    ("assets/images/hero_home.png", 1100),
    # Mascot — avatar ndogo (splash + app bar).
    ("assets/images/mascot_lion.png", 420),
]


def main() -> int:
    total_before = total_after = 0
    for rel, width in JOBS:
        path = ROOT / rel
        before = path.stat().st_size

        with Image.open(path) as im:
            im = im.convert("RGB")
            height = round(im.height * width / im.width)
            resized = im.resize((width, height), Image.LANCZOS)
            # Picha hizi ni flat-vector zenye rangi chache kwa kila eneo;
            # kuweka palette ya rangi 256 hupunguza sana bila kuonekana.
            # Gradients (anga, mionzi ya jua) zinavumilia vizuri kwa dither.
            quantized = resized.quantize(
                colors=256, method=Image.MEDIANCUT, dither=Image.FLOYDSTEINBERG
            )
            quantized.save(path, format="PNG", optimize=True)

        after = path.stat().st_size
        total_before += before
        total_after += after
        print(
            f"{Path(rel).name:26s} {width}x{height}  "
            f"{before / 1048576:5.2f}MB -> {after / 1048576:5.2f}MB"
        )

    print(
        f"\nJUMLA: {total_before / 1048576:.2f}MB -> "
        f"{total_after / 1048576:.2f}MB "
        f"({total_after / total_before * 100:.0f}%)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

"""Hugeuza picha kuwa PNG yenye background ya wazi (transparent).

Hatua ya pili ya mkataba wa background ya wazi:
  1. Picha imezalishwa ikiwa na background NYEUPE SAFI (#FFFFFF).
  2. Faili hili hufuta background hiyo na kuweka alpha channel halisi.

**Kwa nini si `threshold = 245` ya kimataifa (global) pekee:** ukifuta
kila pikseli iliyo karibu-na-nyeupe, utatoboa sehemu nyeupe zilizo NDANI
ya mchoro — kurasa za vitabu, nguo nyeupe, meno, macho. Hiyo ndiyo
"globally deleting near-white pixels" inayokatazwa.

Suluhisho: **flood fill kutoka ukingo**. Tunaanza kwenye pembe na
kusambaza kwa pikseli zinazoungana (connected) tu. Sehemu nyeupe iliyo
ndani ya mchoro HAIUNGANKI na ukingo, kwa hivyo inabaki wazi. Kisha
tunalainisha ukingo (anti-alias) kwa alpha inayopanda hatua kwa hatua
kwenye ukanda mwembamba — hivyo hakuna mstari mkali wa meno ya msumeno.

Matokeo: picha zina background ya wazi, pembeni laini, na hazina
"checkerboard" iliyochorwa.
"""

from __future__ import annotations

import os

import numpy as np
from PIL import Image, ImageDraw

# Rangi inayotumika kuweka alama ya background wakati wa flood fill.
# Ni ya kipekee vya kutosha kutokuwepo kwenye mchoro.
MARK = (255, 0, 255)

# Ukubwa wa ukanda wa kulainisha ukingo (pikseli).
#
# 4 (si 2): michoro ya AI huachia "glow" hafifu kwenye ukingo, na ukanda
# mwembamba unaacha mstari mweupe unaozunguka mchoro. Ukanda mpana
# unaifuta halo hiyo bila kugusa sehemu za ndani.
FEATHER = 4

# Kikomo cha "karibu na nyeupe" kwa ukanda wa kulainisha.
#
# 205 (si 225): pikseli za mpito kati ya mchoro na background ziko karibu
# na 230-250, si 250+. Kikomo cha juu kiliziacha zikiwa na alpha = 255,
# ndiyo iliyokuwa "white fringe" iliyoonekana kwenye vitabu vinavyoelea.
SOFT_FLOOR = 205

# (chanzo, lengo, upana_wa_lengo, uwiano)
JOBS: list[tuple[str, str, int, float]] = [
    (
        "media-output/img-mvasep8j-93c48a1b.png",
        "assets/images/onboarding/onboarding_read.png",
        1020,
        3 / 2,
    ),
    (
        "media-output/img-mvasdfsi-da4055dd.png",
        "assets/images/onboarding/onboarding_listen.png",
        1020,
        3 / 2,
    ),
    (
        "media-output/img-mvasg6pr-960a6fab.png",
        "assets/images/onboarding/onboarding_create.png",
        1020,
        3 / 2,
    ),
    (
        "media-output/img-mvasdprn-e94a350c.png",
        "assets/images/onboarding/onboarding_language.png",
        1020,
        3 / 2,
    ),
    (
        "media-output/img-mvaqlcw1-abb219a9.png",
        "assets/images/mascot_lion.png",
        420,
        1.0,
    ),
]


def background_mask(rgb: Image.Image) -> np.ndarray:
    """Hupata mask ya background kwa flood fill kutoka ukingo.

    Hurudisha safu ya `bool` yenye umbo (h, w): `True` = background.
    """
    w, h = rgb.size

    # Tafuta pikseli ya ukingo iliyo nyeupe ili kuanzia hapo. Pembe
    # inaweza kuwa sehemu ya mchoro kwenye picha chache.
    seed = None
    for x in range(w):
        for y in (0, h - 1):
            r, g, b = rgb.getpixel((x, y))
            if min(r, g, b) >= 250:
                seed = (x, y)
                break
        if seed:
            break
    if seed is None:
        for y in range(h):
            for x in (0, w - 1):
                r, g, b = rgb.getpixel((x, y))
                if min(r, g, b) >= 250:
                    seed = (x, y)
                    break
            if seed:
                break
    if seed is None:
        raise RuntimeError("Hakuna pikseli nyeupe kwenye ukingo — background si nyeupe")

    marked = rgb.copy()
    # `thresh` hulinganisha na rangi ya mbegu, si jirani. 20 inatosha
    # kuvuka pikseli za mpito (anti-aliased) bila kula sehemu za mchoro.
    ImageDraw.floodfill(marked, seed, MARK, thresh=20)

    arr = np.asarray(marked)
    bg = (arr[:, :, 0] == MARK[0]) & (arr[:, :, 1] == MARK[1]) & (arr[:, :, 2] == MARK[2])
    return bg


def dilate(mask: np.ndarray, radius: int) -> np.ndarray:
    """Hupanua mask kwa `radius` ya pikseli (4-jirani, hatua kwa hatua)."""
    out = mask.copy()
    for _ in range(radius):
        nxt = out.copy()
        nxt[1:, :] |= out[:-1, :]
        nxt[:-1, :] |= out[1:, :]
        nxt[:, 1:] |= out[:, :-1]
        nxt[:, :-1] |= out[:, 1:]
        out = nxt
    return out


def alpha_from_mask(rgb: Image.Image, bg: np.ndarray) -> Image.Image:
    """Huunda RGBA: alpha = 0 kwenye background, 255 kwenye mchoro.

    Ukanda wa mpito (`FEATHER`) hupata alpha inayopanda, ili pembeni
    zisionekane kama meno ya msumeno.
    """
    arr = np.asarray(rgb).astype(np.int16)
    min_channel = arr.min(axis=2)

    alpha = np.full(bg.shape, 255, dtype=np.uint8)
    alpha[bg] = 0

    # Ukanda unaozunguka background: pikseli zilizo karibu-na-nyeupe
    # lakini ZISIZO kwenye background kamili (yaani ukingo wa mchoro).
    halo = dilate(bg, FEATHER) & ~bg & (min_channel >= SOFT_FLOOR)
    span = 255.0 - SOFT_FLOOR
    ramp = ((255.0 - min_channel) / span).clip(0.0, 1.0) * 255.0
    alpha[halo] = ramp[halo].astype(np.uint8)

    rgba = Image.fromarray(
        np.dstack([np.asarray(rgb), alpha]).astype(np.uint8), mode="RGBA"
    )
    return rgba


def place_on_canvas(rgba: Image.Image, width: int, ratio: float) -> Image.Image:
    """Hukata mpaka sekunde ya mchoro, kisha huiweka katikati ya canvas safi.

    Hii inahakikisha picha zote zina ukubwa na uwiano sawa, na mchoro
    unajaza fremu (badala ya kuonekana mdogo katikati ya nafasi tupu).
    """
    box = rgba.getbbox()
    if box is None:
        raise RuntimeError("Picha haina sehemu isiyo ya wazi")
    subject = rgba.crop(box)

    height = int(round(width / ratio))
    # Mchoro unajaza 94% ya upande unaobana — 6% ni nafasi ya kupumua.
    scale = min(width * 0.94 / subject.width, height * 0.94 / subject.height)
    new_size = (
        max(1, int(round(subject.width * scale))),
        max(1, int(round(subject.height * scale))),
    )
    subject = subject.resize(new_size, Image.LANCZOS)

    canvas = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    canvas.paste(
        subject,
        ((width - new_size[0]) // 2, (height - new_size[1]) // 2),
        subject,
    )
    return canvas


def main() -> None:
    for source, target, width, ratio in JOBS:
        rgb = Image.open(source).convert("RGB")
        bg = background_mask(rgb)
        share = 100.0 * bg.sum() / bg.size

        if share < 5.0 or share > 97.0:
            print(f"!! {source}: background ni {share:.1f}% — tengeneza upya")
            continue

        rgba = alpha_from_mask(rgb, bg)
        canvas = place_on_canvas(rgba, width, ratio)

        os.makedirs(os.path.dirname(target), exist_ok=True)
        canvas.save(target, "PNG", optimize=True)

        opaque = 100.0 * (np.asarray(canvas)[:, :, 3] > 8).sum() / (
            canvas.width * canvas.height
        )
        print(
            f"OK {target}: {canvas.size[0]}x{canvas.size[1]}, "
            f"background {share:.1f}%, mchoro {opaque:.1f}%, "
            f"{os.path.getsize(target):,} B"
        )


if __name__ == "__main__":
    main()

# Visuals and narration: production plan

## Current pass

- Leo: five complete poses used by the shared mascot widget; launcher icon uses a larger portrait. Visual review on Android devices remains necessary, including round masks and small screens.
- Ngoma ya Furaha: all five pages have new scene-specific images; check hotspot placement and visual consistency on the phone.
- Kuku na Mwewe: all five pages now have scene-specific images; review the details and hotspot placement on device.
- Chapati za Mama: all six pages have new scene-specific illustrations; review details and hotspots on device.
- Kifaru Mdogo and Twiga Mrefu: existing pages 1–2 reviewed; page 3 for each replaced to depict the warning and flight / animals climbing the rock. Reader now fits the entire illustration; verify visibility on phones and tablets.
- Mti wa Babu: all three existing illustrations reviewed against the story.
- Safari ya Matone: pages 1–2 retained; page 3 replaced to include the river and sea as well as Kilimanjaro. The landscape is illustrative, not a geographic map.
- Safari ya Simba: reviewed all six pages; page 4 now includes the travellers listening to Hare by the flooded river. Hotspots were updated to image coordinates and need device review.
- Mlima Kilimanjaro: all six existing scenes reviewed; adjusted hotspot locations and corrected two explanatory claims. Page 3 depicts the forest portion of a multi-stage journey.
- Nyota za Usiku: reviewed all five pages, replaced pages 3–4 (four-star schematic and one crescent moon), adjusted hotspots and corrected the new-moon explanation. The constellation is schematic rather than an astronomical chart.
- Reader: similar aspect ratios use cover and may crop; mismatched illustrations use a feathered, blurred ambient backdrop. Hotspots use the rendered image transform. Existing placements, crops, feathering, contrast and response bubbles still need visual device review across screen sizes.
- All ten story texts have had an initial illustration review. Further visual quality checks, especially on real devices, remain necessary.

## Future stories submitted by users (not implemented yet)

1. Let the author submit or edit text, age range and language. Obtain appropriate consent and avoid sending personal information unnecessarily.
2. Split the story into pages, prepare a scene description per page, and establish a consistent character/style reference. Show the author the proposed storyboard before generating images.
3. Generate one image per page and cover. Run child-safety and content checks, review character consistency and text-image accuracy, and allow the author to regenerate individual pages.
4. Generate narration in the actual story language, preview pronunciation and pacing, and let the author approve or replace clips. Optional alignment data can support accurate word highlighting.
5. Publish approved assets to a configured storage service and a versioned manifest. Download only when requested, verify integrity, store locally, report errors/progress, and offer deletion. Keep the ten bundled stories working offline.
6. Budget for generation, storage and usage; add safeguarding, rate limits, clear rights and a review/publishing policy before enabling this for children.

There is no generation backend, user upload pipeline, download service, moderation system or asset hosting configured yet. These are design steps, not shipped features.

## Mobile-first illustration prompt template (future production)

For every page, use its exact story text to write a scene-specific description,
then include the consistent character reference and this composition brief:

> Create a full-bleed vertical 9:16 painted children's storybook illustration
> of [specific scene, characters, location, action and time]. Keep recurring
> characters consistent with [approved reference]. The top 15% is quiet
> background, with no faces, heads, or important objects. Place the main action,
> facial expressions and interactive objects within the central 75% of the
> width and the 15%–65% vertical band. The bottom 35% is a natural, relatively
> uncluttered, slightly darker foreground suitable for a text overlay. Paint
> scenery all the way to every edge. No text, lettering, borders, frames, or
> baked-in white or beige margins. No extra limbs; age-appropriate and faithful
> to the story.

Preferred delivery is 9:16. If the image generator cannot output that exact
ratio, use its closest supported portrait format (2:3 or 3:4), then review and
adapt composition instead of stretching. An optional 16:9 variant for wide
screens must depict the same moment and have its own independently reviewed
hotspot coordinates. Do not assume a generator follows the brief: a human must
check each page for anatomy, story accuracy, safe zones and legibility, then
mark each hotspot on the final approved asset. Test with top and bottom controls
visible on small and tall phones, portrait and landscape tablets, and with large
text before publication. Existing wide images use an ambient fallback; they
have not been regenerated by this change. No automatic generation or variant
selection backend exists yet.

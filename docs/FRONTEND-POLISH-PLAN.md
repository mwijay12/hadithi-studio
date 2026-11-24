# Hadithi Studio: 10-phase frontend polish

This is a plan, not a claim that the app is launch-ready. Review each phase on
actual Android hardware and adapt it to the user's feedback before advancing.
Protect reading, local progress and offline access; do not ship fake features.

## Phase 1 — audit and motion foundation (in progress)
- Audit the current mascot, reader and Home; define calm, child-friendly motion.
- Make the existing Leo pose move subtly as a whole, respecting reduced motion
  and disabled tickers. This is not a blink, hand wave, lip-sync or true rig.
- Confirm the current test APK works on the user's phone before judging polish.

## Phase 2 — Leo facial rig (prototype in progress)
- The greeting pose now has an aligned closed-eye composite and a brief blink
  every five seconds. Other poses remain static; this is not a layered face rig.
- The source pose is unchanged outside the eye patches. The generated patches
  were composited onto the original canvas; device and frame-by-frame review
  are still required before approval. Reduced motion and disabled tickers use
  the original open-eye image.
- Produce approved, consistently aligned eye layers or frames for one existing
  pose. Implement a natural, infrequent blink, no extra limbs, no distorted face.
- Review frame-by-frame and on device; preserve the existing static fallback.

## Phase 3 — Leo greeting and gestures (in progress; not enabled)
- A bounded, one-shot wave timing curve and tests are prepared separately;
  it is not connected to the mascot until a usable rig exists.
- The existing wave artwork is flattened. A generated arm-removal plate
  introduced a baked checkerboard background and changed the artwork; a manual
  arm cutout produced a visible seam at the shoulder when rotated. Both were
  rejected, so neither is shipped. A proper transparent layered arm plus
  reconstructed shoulder, registered to the original canvas, is still needed.
- Acceptance: exactly two arms, no detached paw/shoulder gap or duplicated
  pixels at either extreme, no cropping, and the existing blink and rest pose
  preserved. Validate at multiple sizes and against reduced-motion settings.
- Prepare an anatomically correct layered arm with a clean shoulder pivot;
  animate a short wave and settle. No third arm, cropping or disconnected joints.
- Compare and approve the idle, blink and wave in a single working prototype.

## Phase 4 — Home polish (in progress)
- Compact layouts put the greeting before Leo, so the invitation is higher.
- Story cards decode their image at the actual rendered card width and device
  density, instead of decoding the daily hero as a tiny 140dp thumbnail.
- The resume indicator exposes page position to assistive technology rather
  than presenting it as a completion percentage. Device review is pending.
- Refine greeting, resume sheet, daily story and card hierarchy on compact and
  tall phones; gentle, purposeful transitions; usable at larger text sizes.

## Phase 5 — reader art and interaction (in progress)
- Hotspot pulsing respects reduced motion, disabled tickers and inactive pages;
  inactive targets are announced as disabled and cannot be activated.
- A partially clipped hotspot anchors its bubble to the visible hit area.
- Existing cover/ambient geometry and artwork remain unchanged. Coordinate
  math can be tested automatically, but actual object placement and contrast
  still require visual review on devices and across each scene.
- Visually review portrait and landscape artwork, safe areas, feathering,
  contrast, story text and hotspot alignment on real phones/tablets.
- Correct individual scene composition or hotspot coordinates where needed.

## Phase 6 — listening and reader controls (in progress)
- Play/pause now actually pauses and resumes recorded audio instead of stopping
  and restarting it. TTS may restart at the beginning when resume is unsupported.
- Speed and voice sheets scroll on small screens. The voice sheet explains that
  its settings change device TTS rate and pitch, not prerecorded narration;
  device TTS availability and offline behaviour are not guaranteed.
- Changing voice does not restart a recording. TTS preference changes made
  while paused take effect on resume without unexpectedly starting playback.
- Automated tests do not establish real device audio quality or TTS behaviour.
- Clarify playback, speed, page movement and audio availability. Test bundled
  Swahili audio and device-language TTS; no fake lip-sync or unsupported claims.

## Phase 7 — library and story detail (in progress)
- Add a direct all-stories entry to Library and keep reviews private and local.
- Hide unverified catalog ratings, reader counts and publication-year sorting;
  recommendations use relevance and stable ID, not placeholder ratings.
- Refresh offline reports when a detail view changes stories; protect local
  review and bookmark UI from results associated with a different story.
- Large text and device visuals still need real-device review.
- Polish cards, shelves, recommendations, reviews and empty/error states;
  maintain honest demo labels, local privacy and responsive navigation.

## Phase 8 — rewards and celebrations
- Make milestones and completion feel warm but low-pressure. Keep progress
  truthful, respect reduced motion and never punish missed reading days.

## Phase 9 — parent, accessibility and offline UX
- Improve legibility, semantics, touch targets, reduced motion, offline status,
  permissions and deletion explanations. Do not present a settings toggle as
  a PIN-protected parental control or imply reminders are sent.

## Phase 10 — real-device QA and release candidate
- Verify startup, reader, audio, orientation, larger fonts, animations, battery
  and performance on actual devices; resolve critical findings and create a
  clearly identified test APK with reproducible checks.

## Relevant research from the user's repositories

- `mwijaydavie/instagram-agent-skill`, `content-kit/code-video/README.md`:
  establish actual artifacts, explicit motion timings, constraints and QA gates
  instead of generic motion prompts. Its video-generation pipeline is not a
  Flutter runtime animation solution.
- `mwijaydavie/mwijay__davie`, `.agents/skills/noellyne-character-reels/SKILL.md`:
  the useful character principle is separated arm layers with an aligned pivot;
  full-figure poses cannot move individual arms. Its character and art are not
  Leo and are not copied into this app.
- `mwijaydavie/mwijay__davie`, `.agents/skills/reanimate/SKILL.md`: compare
  actual animation frames and timing rather than assuming a rig looks right.
  Its browser capture scripts target web/video; Flutter/device QA needs a
  suitable capture workflow of its own.

An initial image-edit experiment for Leo's closed eyes changed the canvas and
character geometry and produced a white background. It was rejected, not
shipped. Real blinking/waving requires aligned, reviewed layers or a proper
rig; do not claim the existing five flattened WebP poses provide those joints.

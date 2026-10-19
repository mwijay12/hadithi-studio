# HADITHI STUDIO — HANDOFF KWA AGENT Mwingine

> **Lengo la faili hili:** agent nyingine (au mtu) aingie kwenye mradi huu na
> kuelewa **bila kuuliza** — tumeanza wapi, tumefanya nini, nini kipo kweli,
> nini ni placeholder, nini kimeharibika, na wapi tunaenda.
>
> **Tarehe ya mwisho:** 2026-10-17 · **Lugha ya mradi:** Kiswahili + Kiingereza
> (comment zote za msimbo ni Kiswahili kwa makusudi).

---

## 1. MUHTASARI WA SEKUNDE MOJA

**Hadithi Studio** = studio ya hadithi za watoto za Tanzania (Flutter, iOS/Android/Web),
kiingilio cha Kiswahili + Kiingereza, malipo kwa M-Pesa/Tigo/Airtel/Halo.

**Hali ya sasa:** **shell ya UI yenye nguvu** — skrini nyingi zinafanya kazi na
zimepimwa, lakini **hakuna backend, hakuna auth, hakuna malipo halisi, hakuna AI,
na hakuna picha za kila hadithi.** **SI tayari kwa launch.**

| Kipimo | Thamani |
|---|---|
| `flutter analyze` | **0 errors** |
| `flutter test` | **96 passed, 0 failed** |
| Flutter / Dart | **3.16.9 / 3.2.6** |
| SDK path | `/home/accio/tools/flutter` (**SI** `/root/tools/flutter`) |
| l10n keys | en **307** · sw **258** |
| Git | **HAKUNA `.git`** — repository haijaanzishwa |
| Preview | Cloudflare quick tunnel + seva ya gzip/threaded |

---

## 2. JINSI YA KUENDA (kutoka sifuri hadi app inayoendesha)

```bash
export PATH=/home/accio/tools/flutter/bin:$PATH
git config --global --add safe.directory /home/accio/tools/flutter   # LAZIMA
cd <project>
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build web -t lib/main_web_preview.dart --release \
  --web-renderer=html
# ↑ Service worker huwashwa (offline PWA). Kwa preview ya haraka (bila cache):
#   ongeza --pwa-strategy=none
python3 tool/hadithi_preview_server.py build/web 8080
bash tool/hadithi_keepalive.sh      # huanzisha cloudflared + hulog URL
cat /tmp/hadithi_url.txt            # URL ya sasa
```

### Mitego iliyotugharimu saa (usirudie)

1. **`git config safe.directory`** — bila hii Flutter huripoti `0.0.0-unknown` na
   `pub get` **hushindwa kwenye kila package**. Inaonekana kama "packages hazipo".
2. ~~**`google_fonts` LAZIMA ibaki `6.1.0`**~~ — **imeondolewa kabisa.** Fonti
   zimefungwa ndani ya app (`assets/fonts/`), hivyo hakuna utegemezi wa
   mtandao na hakuna mgongano wa `dart2js`.
3. **`--web-renderer=html`, sivyo canvaskit.** CanvasKit ni **4.7 MB** ya wasm; over
   tunnel ya bure (27 KB/s) ni **dakika 5** za skrini nyeupe — mtumiaji hudhani
   link imekufa. HTML renderer = inaanza.
4. **Renderersha ya HTML HAIIUNGI MKONO shaders.** `shimmer` hutumia `ShaderMask`
   → `Unsupported operation: FragmentProgram is not supported for the HTML renderer`.
   Imelindwa (`loading_widget.dart` hurudi kizuizi tuli kwenye web). **Hii inaathiri
   `Rive` ya Prompt 6/8 — shader zake hazitafanya kazi kwenye web-HTML.**
5. **`MaterialApp` hairuhusiwi `builder` mbili.** Ukuta wa makosa umeunganishwa
   ndani ya `builder:` iliyopo (`app.dart`), ambayo hupunguza `textScaleFactor` ≤1.3.
6. **`pkill -f "..."` hujiua yenyewe** kama command yako ina maneno hayo. Tumia
   faili za PID au pattern yenye `[x]`.
7. **Vyanzo vya API vya Flutter 3.16:** `MediaQuery.of`, `textScaleFactor`
   (**sivyo** `TextScaler`), `WillPopScope` (**sivyo** `PopScope`),
   `Color.withOpacity` (**sivyo** `withValues`).

---

## 3. MUUNDO HALISI WA FOLDA (sio kama prompts zinavyosema)

```
lib/
├── app.dart                    ← MaterialApp.router, locale, builder (ukuta + textScale)
├── main.dart                   ← DI init, AppErrorHandler.install(), locale restore
├── main_web_preview.dart       ← hupuka DI kabisa (haina dart:io/Hive)
├── config/
│   ├── constants/asset_constants.dart
│   ├── routes/app_routes.dart          ← ROUTES ZOTE ZIPO HAPA (sivyo core/routing/)
│   └── theme/{colors,spacing,typography,app_theme,dark_theme}.dart
├── core/
│   ├── di/injection_container.dart
│   ├── enums/app_enums.dart            ← StoryCategory, AgeGroup, ReadingLevel, HotspotType, AppLanguage
│   ├── extensions/context_extensions.dart  ← isSwahili, isEnglish, isBilingual, l10n, localised()
│   ├── network/{api_client,api_interceptors,api_constants,network_info}.dart
│   ├── services/{app_error_handler,reading_progress_store}.dart
│   ├── utils/{audio_utils,text_utils,contrast_utils,tz_phone_validator,snackbar_service}.dart
│   └── widgets/{error_widget,loading_widget,bilingual_text,app_error_boundary,mpesa_payment_sheet,...}.dart
├── features/
│   ├── onboarding/  splash/  stories/  profile/(domain+data PEKEE — hakuna pages)
│   └── payments/(domain/entities PEKEE)
├── l10n/{app_en.arb,app_sw.arb,app_locale_controller.dart,l10n.dart,generated/}
└── navigation/app_shell.dart    ← bottom nav + tabs (sivyo presentation/)
```

**Tofauti na prompts (prompts zilidhani vibaya):**
`cubits/`/`states/` → halisi `cubit/`/`state/`; `lib/presentation/app_shell.dart` →
`lib/navigation/app_shell.dart`; **hakuna** `reader_page.dart` (halisi
`story_reader_page.dart`); **hakuna** `word_highlighter.dart` (halisi `AppKaraokeText`);
**hakuna** `WordTiming`/`AudioData`/`User`/`AuthCubit`/`creator/`/`community/`.

---

## 4. KILICHOKAMILIKA (kwa uthibitisho)

### 4.1 Routing, splash, onboarding, home, library — ✅
Splash → onboarding (slidea 4 zenye picha halisi) → shell yenye tabo. Kadi
zinabofya, routes zinafanya kazi. `l10n` inabadilika papo hapo.

### 4.2 Shelf / All Stories / Search+Filter — ✅
`shelf_page.dart` (21 KB), `all_stories_page.dart` (22 KB), filter sheet.
**Ukurasa wa rafu hupokea `StoryShelf.id` (kebab-case: `animal-stories`,
`morals-wisdom`, `science`, `culture`, `poems-songs`, `safari`).** ⚠️
`StoryCategory` **haina `id`** — kuituma kwa rafu hutoa rafu **tupu**.

### 4.3 **Story Detail Page — ✅ kamili (mistari 1,308)**
Jalada 320 px linalojikunja + gradient, chipu za taarifa, nyota + wasomaji,
kadi ya mwandishi (herufi za mwanza + "Fuata" [UI pekee]), muhtasari
unaopanuka, vitufe (Soma Sasa / Sikiliza / Pakua), chipu za rafu
zinazobofya, skelitoni ya shimmer, `AppErrorWidget`.

### 4.4 **Reader — ✅ kamili**
`Stack` ya tabaka 5; karaoke word-highlight (`AppKaraokeText`, **nafasi za
herufi** zinazoendeshwa na `Timer` ya cubit — **sivyo** `onboundary`, kwa sababu
`flutter_tts_web.dart` haiunganishi `onboundary`); vidhibiti vya TTS (80 px,
kitufe 56×56, hatua 7 za kasi, sauti 3: Mama/Baba/Mtoto); paneli ya mipangilio
(fonti 16–28 sp, night mode, modes 3 za kusoma, auto-page 1/2/3/5 s, muziki
imezimwa); aina 6 za hotspot + `_SpeechBubble` (4 s); alama za kurasa
(Sunset Gold + haptics + `ReadingProgressStore`); `WillPopScope` +
`saveProgressNow()`; dialog ya "endelea kutoka ukurasa X?"; sherehe ya kumaliza.

### 4.5 **"Lugha Zote" halisi — ✅ (MPYA)**
`AppLanguage.bilingual` ina ISO `'sw'` kwa makusudi, hivyo `localeName == 'sw'`
ilikuwa **kweli kwa Kiswahili pekee NA Zote** → chaguo lilikuwa halifanyi kitu.
Sasa: `AppLocaleController.isBilingual`, `context.isBilingual`, na
`BilingualText` (SW juu, EN chini, italiki + mstari). Inatumika kwenye ukurasa
wa maelezo (muhtasari) na reader (maandishi ya ukurasa).
**Kwenye reader, Kiswahili pekee kinapata mwanga wa karaoke** — nafasi za herufi
haziwezi kuendana na maandishi mawili; TTS inasoma Kiswahili.

### 4.6 Ufikivu / WCAG AA — ✅ kwa ukurasa wa maelezo
`ContrastUtils` (`ratio`, `blend`, `readableInk`). Nilipima na kupata **hitilafu 7**
(chipu zilikuwa zikitumia rangi ya chapa kama **maandishi** juu ya tint yake:
brightGreen 2.39:1, skyBlue 2.28:1, sunsetGold 1.92:1…). Zimerekebishwa kwa
`readableInk`. **Palette ya skrini nyingine HAJAPIMWA.**

### 4.7 Ukamataji wa makosa — ✅
`AppErrorHandler` (`classify()` → `AppErrorKind`, rekodi 20, `onRecord` hook ya
Crashlytics), `AppErrorBoundary` (**makosa mabaya/fatal pekee**), `CrashRecoveryScreen`,
`SnackbarService` (funguo ya kimataifa).
**Somo:** toleo la kwanza lilisikiliza `FlutterError` yote → skrini nzima ya kosa
ilionekana kwenye onboarding kwa kosa la kupamba. Usirudie.

### 4.8 Gamification (domain pekee) — ✅ mantiki, ❌ UI
`Achievement`, `AchievementCategory`, `BadgeTier`, `AchievementMetric`,
`ReadingStats`, `DailyReading`, `ReadingStreak`, **`ReaderRank`** (daraja 5;
jina hili kwa makusudi — `ReadingLevel` **ipo tayari** na inamaanisha kiwango cha
hadithi), catalog ya **badges 22** (+ Kiswahili/Kiingereza), `AchievementEvaluator`
(+ `newlyUnlocked()` kwa overlay). **Hakuna ukurasa wa kuziona.**

### 4.9 Msingi wa malipo — 🟡
`PaymentProvider` (5: mpesa/tigopesa/airtelMoney/halopesa/card + rangi za chapa +
viambishi), `TzPhoneValidator` (`normalise` hushughulikia `0712…`, `+255…`,
`255 …`, nafasi/dashes/mabano; `detectProvider`). **Ukurasa wa mpango, checkout,
cubit, dialog — hazipo.** ⚠️ Viambishi vya Tanzania **havijathibitishwa** — lazima
vithibitishwe na backend kabla ya pesa halisi.

### 4.10 DI — 🟡
`StoryRepository` imesajiliwa. **Cubits HAZISajiliwa kwa makusudi** — huchukua
`{StoryRepository? repository}` (**jina**, si nafasi) na hujipanga kwa
`resolveStoryRepository()`; kurasa huziunda kwenye `BlocProvider(create:)`.
`Part A` ya Prompt 5 kama ilivyoandikwa **haikukamilika** (hakuna datasources).

### 4.11 Preview / usambazaji — ✅
`tool/hadithi_preview_server.py` (threaded + gzip: 3.05 MB → 869 KB),
`tool/hadithi_keepalive.sh` (hurekebisha URL ikifa), cloudflared 2026.10.1.

---

## 5. PLACEHOLDERS NA "COMING SOON" — orodha kamili

Kila mahali ambapo UI inaahidi kitu ambacho hakipo (kwa makusudi, ili
**isidanganye**):

| Mahali | Unachoonekana | Ukweli |
|---|---|---|
| Detail → **Pakua** | "Upakuaji wa offline unakuja na Prompt 5" | `DownloadManager` haipo |
| Detail → **Sikiliza** | "Kusikiliza moja kwa moja kunakuja hivi punde" | `ReaderPage` hupokea `autoPlay` pekee |
| Reader → upau wa juu **Shiriki/Ripoti/Maelezo** | SnackBar ya ukweli | Hazijajengwa |
| Reader → paneli → **Background Music** | switch **imezimwa** | `assets/sounds/` **tupu** |
| Detail → **Maoni** | "Maoni yatawasili hivi punde" + kitufe **kimezimwa** | `reviewCount` haipo; backend haipo |
| Detail → **Hadithi Zinazofanana** | "Mapendekezo yanakuja na Prompt 6" | injini ya mapendekezo haipo |
| Detail → **Fuata** | inabadilika (UI pekee) | backend haipo |
| Detail → **Alama (bookmark)** | inabadilika kwa kikao | **haihifadhiwi**; haisawazishi na shelf |
| Reader → **hifadhi ya ukurasa** | ✅ **inafanya kazi** | `ReadingProgressStore` (shared_preferences) |
| Tab **Tengeneza** | safu 3 za ikoni | hazina tabia; `features/creator/` haipo |
| Profile → kadi ya "Jiandikishe" | gradient | Haiunganishwi; hakuna auth |
| Badges | — | zipo kama data, **hakuna UI** |
| Muziki / SFX | — | hazipo |

**Maneno ya "coming soon"/"hivi punde" kwenye msimbo ni kwa makusudi** — ni
mkataba wa uaminifu. Usiyaondoe bila kujenga kitu halisi.

---

## 6. MATATIZO YANAYOJULIKANA (bado wazi)

| # | Tatizo | Ushahidi | Ukubwa |
|---|---|---|---|
| **I-1** | ✅ **IMESHUGHULIKA** — slide iko kwenye `SingleChildScrollView`; maudhui hayapotei kwenye skrini fupi | `onboarding_page.dart` | Imefungwa |
| **I-2** | **Picha za hadithi 3 za zamani** (`ngoma`, `kuku`, `chapati`) bado ni za branding; hadithi 7 zina michoro yao halisi (kurasa 29) | `story_sample_data.dart` | Kubwa (maudhui) |
| **I-3** | **Sauti ya Kiswahili ni mbovu** — injini za simu hazina Kiswahili, hivyo husoma maandishi ya Kiswahili kwa sauti ya Kiingereza | Mtumiaji | **Kubwa** |
| **I-4** | ✅ **IMESHUGHULIKA** — fonti zote (Nunito, Poppins, Merriweather, Baloo2) zimefungwa ndani ya `assets/fonts/`; `google_fonts` imeondolewa | `pubspec.yaml`, `lib/config/theme/typography.dart` | Imefungwa |
| **I-5** | ✅ **IMESHUGHULIKA** — build ya default sasa huwasha service worker; app hufanya kazi offline | `README.md`, `docs/HANDOFF.md` | Imefungwa |
| **I-6** | Renderer ya HTML **haistawishi shaders** → `shimmer` imelindwa; `Rive` ya baadaye itashindwa | browser console | Wastani |
| **I-7** | ✅ **IMESHUGHULIKA** — kidonge huruhusu mistari 2 na upana wa 80% wa skrini; hakuna ellipsis | `onboarding_page.dart` | Imefungwa |
| **I-8** | `assets/images/badges/` **tupu** → badges hutumia emoji | `find assets` | Ndogo |
| **I-9** | ✅ **IMESHUGHULIKA** — repo ipo na remote `github.com/mwijay12/hadithi-studio` | `git remote -v` | Imefungwa |
| **I-10** | Tunnel ni quick tunnel — URL hubadilika | `hadithi_keepalive.sh` | Ndogo |
| **I-11** | **Ukaguzi wa click-through wa detail → reader HAUKUFANYIKA KAMWE** | — | **Kubwa (hatari)** |
| **I-12** | Palette ya skrini **nyingine** (home/onboarding/shelf/night) **haijapimwa WCAG** | — | Wastani |

---

## 7. UNAKOSA NINI KABISA (kwa sehemu)

| Sehemu | Hali | Inahitaji |
|---|---|---|
| **Auth + mtumiaji** | **HAKUNA** | `User`/`UserProfile`, auth, hifadhi ya wasifu — **kila kitu cha Profile/familia/udhibiti kinategemea hii** |
| **Profile page** | Haipo | auth + cubit + `ReadingStats` kwa data halisi |
| **Watoto + Udhibiti wa Mzazi** | Haipo | `ChildProfile`, PIN, muda wa skrini, vichujio |
| **Creator Studio** | Haipo | folda yote + wizard 7 + UI ya AI. **Puter.js inapanga hapa** |
| **Malipo** | Msingi pekee | plans, checkout, cubit, routes, dialog za M-Pesa, historia |
| **Offline** | Haipo | `DownloadManager`, Hive, UI ya "Vilivyopakuliwa" |
| **Gamification UI** | Data pekee | ukurasa wa mafanikio, overlay ya kufungua (confetti **haipo**) |
| **Community** | Haipo | maoni, wasifu wa mwandishi, changamoto, leaderboard |
| **Takwimu/charts** | Haipo | **`fl_chart` na `table_calendar` hazipo** — au `CustomPainter` (bora kwa Tecno/Itel) |
| **Notifications + Analytics** | Haipo | packages zipo kwenye pubspec, **lakini hakuna project ya Firebase wala `firebase_options.dart`** → `initializeApp()` **huangusha app**. **Haiwezi kufanyika bila credentials zako** |
| **PWA** | Manifest tu | service worker (I-5) + icons 192/512/maskable + screenshots |
| **Mascots + Rive** | Haipo | character sheets + `assets/rive/` tupu |
| **Music + SFX** | Haipo | `assets/sounds/` tupu |
| **Mini-games / branching** | Haipo | placeholders za Prompt 4 |
| **Tablet 2-page spread** | Haipo | — |
| **Picha halisi za kila ukurasa** | Haipo | **~30 picha** (6 hadithi × ~5 kurasa) |

---

## 8. ORODHA YA PROMPTS (zote zilizotumwa)

### Mfululizo wa awali (7)
1. **Prompt 1** — Routing + kurasa + hadithi zinabofya ✅ (+ v2 REVISION)
2. **Prompt 2** — Story Detail Page ✅
3. **Prompt 3** — Shelf + All Stories + Search/Filter ✅
4. **Prompt 4** — Reader: TTS + word highlight + hotspots ✅
5. **Prompt 5** — Creator Studio + DI + Offline + M-Pesa 🟡 (DI + msingi wa malipo pekee)
6. **Prompt 6** — Profile + Gamification + Community + Parental 🟡 (domain pekee)
7. **Prompt 7** — Polish + Notifications + Analytics + PWA + Launch 🟡 (error handling pekee)

### Mfululizo wa v2
- **2.0** Story Detail + WCAG AA → ✅ (ilifichua hitilafu 7 za rangi)
- **5.0 / 8 / 9 / 10** — zilipendekezwa, hazijaanza

### Mfululizo mpya (ulioboreshwa)
- **Prompt 2** (Story Detail + **True Bilingual**) → ✅ **Part B ilikamilika**
- **Prompt 2.5** — Rangi + Mascots + picha halisi → ❌ haijaanza
- **Prompt 5** — Creator + **Puter.js** + sauti ya Kiswahili + M-Pesa → ❌
- **Prompt 6** — Rive/Lottie + muziki + mini-games → ❌
- **Prompt 7** — Tablet spread + parental + polish → ❌

### Puter.js — uamuzi wa lazima kabla ya Prompt 5
`puter.ai.chat` / `txt2img` / `txt2speech` ni **library ya JavaScript ya browser**.
Inafanya kazi kwenye **web build**, **haiwezi kwenye Android native** — na soko ni
**Android 95%+**. Chagua: (a) **web/PWA iwe bidhaa kuu**, au (b) njia tofauti
kwa Android. **Amua hili kabla ya kuandika msimbo.**

---

## 9. VITU VYA KUJARIBU / KUPIMA (kwa mpangilio)

1. **Click-through kamili** (I-11) — splash → onboarding → home → kadi → detail →
   "Soma Sasa" → reader → geuza kurasa → alama → kurudi. **Hakuna mtu amewahi
   kuifanya kwa macho.** Tumia browser + console.
2. **Screenshot za kila skrini kwa ukubwa 3** (360×640, 390×844, 1280×800) —
   msingi wa Prompt 2.5.
3. **Pima WCAG** ya home/onboarding/shelf/night — tumia `ContrastUtils` kama kwenye
   `test/contrast_utils_test.dart`.
4. **Geuza lugha → reload** — lazima ibaki.
5. **Chagua "Lugha Zote"** → muhtasari na reader vionyeshe SW **na** EN.

---

## 10. KANUNI 15 ZA MRADI (bado zina nguvu)

1. Clean Architecture · 2. BLoC · 3. **Kiswahili NA Kiingereza** katika kila
maandishi ya mtumiaji · 4. Palette ya Tanzania · 5. `Either<Failure, Success>` ·
6. Network kwa neema (offline) · 7. Muundo wa folda · 8. Msimbo wa production
wenye comment · 9. **Reader > Creator** · 10. Widgets zinazorudiwa ·
11. Loading/error/empty states · 14. **Mtiririko wa M-Pesa LAZIMA ufanye kazi** ·
15. **TTS + word highlight imepimwa kwa kina**.

> **Kanuni isiyoandikwa tuliyoongeza:** *usibuni kitu.* Badge iliyokosekana
> inatumia emoji; maoni yasiyopo yanaonyesha hali tupu; bei isiyopo haidhaniwi;
> tarehe ya kufungua badge haitengenezwi. **Uaminifu kwa mtumiaji > UI nzuri.**

---

## 11. HATUA INAYOFUATA (pendekezo)

1. `git init` + commit ya kwanza (I-9)
2. **Click-through** (I-11) — hatari kubwa kuliko yote
3. **Picha halisi** (I-2) — covers 6 + kurasa ~30 (Kilimanjaro ipate Kilimanjaro)
4. **Auth + wasifu wa ndani** → inafungua Profile, familia, udhibiti
5. **Prompt 2.5** — palette + mascots
6. **Puter.js** (baada ya kuamua web-vs-Android) + **sauti ya Kiswahili** (I-3)
7. **Fonti za ndani** (I-4) + **service worker** (I-5)
8. Creator Studio → Malipo → Offline → Gamification UI → Community

*Kila la heri. Msimbo una comment za Kiswahili kwa makusudi — heshimu lugha hiyo.* 🇹🇿

---

## 12. MASCOT: LEO (imeongezwa baada ya Prompt 7)

**Faili:** `lib/core/widgets/leo_mascot.dart` · **Assets:** `assets/images/mascot/leo_*.webp`

Leo ni simba mdogo kutoka **character sheet iliyoidhinishwa** (si simba
mwingine). Poses 5: `wave`, `reading`, `listening`, `celebrate`, `curious`
(majina yanafuata state zilizopendekezwa kwa `LeoStateMachine`).

### Ilipoingizwa

| Mahali | Pose | Kwa nini |
|---|---|---|
| Splash (nembo) | `wave` | Mahali pa kwanza mtumiaji anamuona → salamu |
| Skrini ya kurejesha (kosa) | `curious` | Kosa limetokea; "udadisi" inafaa, sivyo shangwe |
| Sherehe ya kumaliza hadithi | `celebrate` | Wakati muhimu kwa mtoto |

### Mabadiliko ya kiufundi

1. **WebP lossless**, sivyo PNG — alpha imehifadhiwa kikamilifu (**PNG ya
   kupoteza ingeacha halos kwenye manyoya**, kosa kwenye orodha ya rig).
   496 KB → **262 KB**.
2. **Upendeleo wa MFUMO wa reduced-motion:** `MediaQuery.disableAnimations`
   imeongezwa juu ya switch ya mkono ya prototype. Mtumiaji aliyeiweka
   **hataona mwendo** hata app haikuuliza (WCAG 2.3.3).
3. Semantics: maelezo mazuri kwa lugha mbili, `excludeFromSemantics` kwa picha.

### HAIYOFANYIKA — usidanganye

**Hakuna `.riv`.** Kwa hivyo **hatukuandika `RiveAnimation.asset(...)`** —
faili haipo, na msimbo wa faili isiyopo ni udanganyifu. Poses hubadilishwa na
mwendo rahisi wa juu-chini (2.2 s). **Hakuna** kupepesa macho, kupunga mkono
kwa joint, kupumua, wala lip-sync.

Kupata rig halisi: mchoro **layered** (PSD/AI/Krita/Procreate) au ujenzi
makini wa parts, kisha state machine `LeoStateMachine` ndani ya Rive Editor.
Maelezo kamili ya hierarchy ya bones + orodha ya ukaguzi yalikuwa kwenye
`README.md` ya prototype ya Phase 2/3.

### Bado wazi kwa Leo

- Onboarding (slidea 4) — kila slide inaweza kuwa na pose yake
- `app_shell.dart` avatar ya mtoto; `_Art.simba` kwenye story data
- Kila pose mpya inahitaji **laidhinishwe** — character sheet ndiyo ukweli

### Sarekanao (marekebisho ya nyaraka)

Comment kwenye `app_error_boundary.dart` ilisema
`assets/images/mascot_lion.png` **haipo kwenye diski**. **Ilirudi si kweli** —
faili ipo (byte 225,589). Uamuzi wa Leo ni wa **mtindo**. Imerekebishwa.

## 13. MICHORO YA KILA UKURASA (imeongezwa 2026-10-18)

### Tatizo lililokuwa
Kurasa **33** zote zilikuwa zikichukua picha moja ya branding
(`hero_home.png`, `cat_safari.png`, `onboarding_read.png`…). Mtoto alikuwa
akisoma ukurasa kuhusu pango wakati pichani kuna jua. `_Art` ilikuwa na
**constants 12** pekee kwa kurasa 33.

### Kilichofanyika
Hadithi **tatu za kuanzia** zimepata mchoro wake kwa kila ukurasa —
**17 kwa jumla**:

```
assets/images/stories/pages/safari-ya-simba/page_01.webp … page_06.webp
assets/images/stories/pages/mlima-kilimanjaro/page_01.webp … page_06.webp
assets/images/stories/pages/nyota-za-usiku/page_01.webp … page_05.webp
```

* Ukubwa: **1536×2048** (3:4), WebP quality 82.
* **96.6 MB (PNG) → 8.4 MB (WebP)**. Usibadilishe kurudi PNG.
* Mtindo mmoja kwa hadithi zote: gouache ya mkono, rangi za amber/ochre/teal.
* **Kanuni ya muundo:** kichwa cha habari na sura zote ziko **juu ya 55%**
  ya fremu, kwa sababu `_TextOverlay` hufunika **chini 40%** kwa gradient
  na maandishi. Ukitengeneza mchoro mpya, usiweke uso chini ya 60%.

### Kanuni ya majina
`page_01`, `page_02`… — **ndiyo kanuni ile ile ya sauti na ya timing JSON**
(`assets/audio/<story-id>/page_01.mp3`). Hivyo mchoro, sauti na maneno ya
ukurasa mmoja husafiri pamoja. Ukibadilisha jina, `Image.asset` haitangushi
app — itaonyesha ikoni tupu **kimya kimya**. Jaribio
`test/story_illustration_assets_test.dart` hulinda hili.

### Hadithi zilizobaki
`chapati-za-mama`, `kuku-na-mwewe`, `ngoma-ya-furaha` (kurasa **16**) bado
zinatumia michoro ya branding. Kuwapa michoro yao: tengeneza faili kwa
kanuni hiyo hiyo, kisha badilisha `illustration:` kwenye
`lib/features/stories/data/datasources/story_sample_data.dart` — **hakuna
skrini inayohitaji kubadilishwa**.

### Njia ya kuzalisha michoro zaidi
Prompt iliyofanya kazi (kwa Kiswahili/Kingereza):
> Warm 2D storybook illustration, hand-painted gouache texture, soft edges,
> East African palette (amber, ochre, terracotta, teal). Portrait 3:4,
> 1536×2048. NO text, no lettering, no watermarks. Keep the main subject in
> the UPPER 55% — the app draws a dark gradient with story text over the
> bottom 40%.

Kwa kila ukurasa: weka **kitu cha muhimu cha hadithi** (jua, twiga, pango…)
mahali panapolingana na `left`/`top` ya hotspot yake, ili mtoto aguse kile
anachokiona.

## 14. HALI YA MWISHO (2026-10-18) — muhtasari wa kuhamia akaunti nyingine

### Maudhui
- **Hadithi 10** (6 za awali + 4 mpya kwenye faili za pekee):
  `story_kifaru_mdogo.dart`, `story_twiga_mrefu.dart`,
  `story_mti_wa_babu.dart`, `story_safari_ya_matone.dart`.
  Zinaunganishwa kupitia imports + orodha ya `StorySampleData.all`.
- **Michoro 29 za kurasa** (`assets/images/stories/pages/<id>/page_0N.webp`).
- **Kundi jipya** `StoryCategory.wanyama` + `AssetConstants.categoryWanyama`.

### Makosa makubwa yaliyorekebishwa (na kinga)
1. `AssetConstants` ilikuwa ikiita **faili 14 ambazo hazikuwepo**
   (`categories/ngano.png` n.k.). Zote zimeelekezwa kwenye `cat_*.png`.
   **Kinga:** `test/content_assets_test.dart`.
2. Maktaba ilikuwa ikionyesha **rafu tupu**. Sasa `StorySampleData.activeShelves`
   + `countInShelf`. **Kinga:** jaribio la `activeShelves`.
3. Hotspot `Container` ilijaa kisanduku chote → duara la ~160 px. Sasa
   `min(box×0.52, 64)`.
4. Scrim ya maandishi ilikuwa na rangi 2 pekee → maandishi meupe juu ya
   mchoro mweupe. Sasa vituo 3 (0 → 0.55 → 0.92) + kivuli cha tabaka 2.
5. Upau wa sauti ulifunika mstari wa mwisho (100 → **148 px**).
6. Kibonge cha hotspot kilifichwa chini ya upau wa sauti; swali lilikuwa
   14 px sawa na jibu. Sasa `bottomReserve: 150`, swali 16 px w800 + ikoni.

### Nyimbo
- `lib/features/songs/` — `SongCatalog` (AssetManifest discovery),
  `SongsPage` (just_audio), route `/songs`, entry chip kwenye Maktaba.
- Folda `assets/audio/songs/` + README yenye kanuni na onyo la hakimiliki.
- **Hakuna faili ya nyimbo bado** — ukurasa unaonyesha hali tupu kwa uwazi.

### Nyaraka mpya
- `README.md` — imeandikwa upya (ilikuwa stub ya Flutter).
- `docs/PRODUCT-VISION.md` — utambulisho, sifa 7 za kipekee, mfumo wa
  biashara, vipimo, mpango wa siku 90.
- `docs/GAME-IDEAS.md` — uchambuzi wa ZIP ya `Story Safari` + michezo 3.

### APK
**Haikujengwa.** `flutter doctor` → *Unable to locate Android SDK*; folda
`android/` haipo. Kwenye mashine yenye SDK:
```bash
flutter create --platforms=android .
flutter build apk --release
```
Bila keystore, APK hutumia **debug key** — haifai Play Store.

### Kinachobaki (kwa urithi)
- Sauti: hakuna MP3; TTS ndiyo inayosoma. Timing JSON haijaunganishwa.
- Hadithi 3 za zamani (`ngoma`, `kuku`, `chapati`) zina picha za branding.
- Hadithi 4 mpya zina **kurasa 3** pekee.
- Mchezo: maoni tu.
- Ukaguzi wa macho: haukukamilika (bridge ya browser).

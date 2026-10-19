# Hadithi Studio 🇹🇿

**App ya hadithi za watoto kwa Kiswahili — iliyotengenezwa Tanzania, kwa watoto wa Tanzania.**

Hadithi Studio ni Flutter app inayompa mtoto hadithi **10** zenye michoro, sauti,
na mwingiliano — na inafanya kazi **bila mtandao** tangu sekunde ya kwanza.
Fonti, picha na hadithi zote zimefungwa ndani ya app.

> **Hali ya mradi:** `0.1.0` — inajengwa, inajaribiwa (majaribio 185), na
> inaweza kufunguliwa kwenye kivinjari au simu. Hii bado si toleo la duka la
> app: tazama [Kinachobaki](#kinachobaki) kabla ya kuchapisha.

---

## Kwa nini app hii ni tofauti

App nyingi za watoto zinazopatikana Tanzania ni **tafsiri** — maandishi ya
Kiingereza yaliyogeuzwa, mandhari ya Ulaya, na sauti ya roboti. Hadithi Studio
imejengwa kinyume:

| Kanuni | Maana yake kivitendo |
|---|---|
| **Kiswahili kwanza, sivyo tafsiri** | Kila hadithi imeandikwa kwa Kiswahili halisi, kisha Kiingereza. Si `translate()` |
| **Tanzania si mandhari — ni nyumbani** | Serengeti, Kilimanjaro, Zanzibar, ngoma, chapati za mama. Mtoto anajiona |
| **Bila mtandao ni hali ya kawaida** | Hadithi, michoro, sauti na **fonti** ziko ndani ya app. Hakuna "loading" ya mtandao |
| **Sauti ya mtu, sivyo TTS** | TTS ni *akiba* tu. Sauti halisi ya Kiswahili ndiyo njia kuu |
| **Ukweli, sivyo ujanja** | Kitu kisichofanya kazi kinaonyeshwa kama hakifanyi kazi. Hakuna vitufe vya kubuni |
| **Simu ya bei ndogo kwanza** | Picha WebP, hakuna shader, hakuna animation nzito, `reduce motion` inaheshimiwa |

### Msimbo unaojilinda

Mradi huu una **majaribio 185** yanayolinda sifa, sivyo muonekano pekee:

- **Utofautishaji (contrast)** — `theme_contrast_test.dart` hupima jozi za
  `ColorScheme` na kushindwa chini ya **4.5:1** (maandishi) na **3:1** (vidhibiti).
  Jaribio hili liligundua kwamba `onSurfaceVariant` **haikuwa imewekwa** kwenye
  theme yoyote — maandishi yalikuwa `#49454F` juu ya `#1C1F27` (**1.8:1**).
- **Maudhui** — `content_assets_test.dart` huthibitisha kila picha inayotajwa
  **ipo kwenye diski**. Liligundua **faili 14 za makundi** ambazo hazikuwepo.
- **Hifadhi** — `library_store_test.dart` huandika, kisha **hufungua mfano mpya**
  na kusoma tena. Ndiyo maana ya "kudumu".
- **Michoro** — kila ukurasa wa hadithi unapaswa kuwa na picha **yake**;
  kurudia mchoro mmoja kwenye kurasa mbili hushindwa.

---

## Vipengele vilivyopo

### Kusoma
- **Hadithi 10** kwenye makundi 6: Ngano, Maadili, Historia, Sanaa, Wanyama, Mazingira, Sayansi
- **Michoro 29 za kurasa** — kila ukurasa wa hadithi 7 una mchoro wake
- **Uonyeshaji wa neno kwa neno** (karaoke) wakati sauti inasoma
- **Mguso wa neno** — kugusa neno kunalisoma peke yake (msamiati)
- **Vitu vinavyogusika** (hotspots) — vitu 24: sauti, maelezo, mchezo, uamuzi
- **Hali ya usiku** na ukubwa wa maandishi unaodhibitiwa
- **Rafu Yangu** — inaonyesha maendeleo **halisi**, sivyo asilimia ya kubuni

### Lugha na muonekano
- **Kiswahili / Kiingereza** — hubadilishwa kwenye Mipangilio na kuhifadhiwa
- **Nuru / Giza / Mfumo** — kibadilishi cha mandhari kinachohifadhiwa
- **Sauti ya kifaa (TTS)** kama akiba pale sauti iliyorekodiwa haipo

### Maudhui na uhifadhi
- **Tengeneza** — mhariri wa hadithi za ndani (kichwa, kurasa, rasimu)
- **Wasifu wa mtoto** — jina na kikundi cha umri, kifaa pekee
- **Nyimbo** — katalogi inayogundua faili kwenye `assets/audio/songs/`
- **Sera ya Faragha** — PDPA 2022 / PDPC, bila kuahidi kinachojulikana
- **Safisha data** — kufuta kila kitu kwa kitufe kimoja

---

## Usanifu (architecture)

```
lib/
├── core/            # enums, theme, services (library_store, theme_controller), widgets
├── config/          # routes, constants, theme
├── features/
│   ├── stories/     # domain / data / presentation (clean architecture + Cubit)
│   ├── reader/      # ndani ya stories: reader_cubit, story_audio_player
│   ├── settings/    # lugha, muonekano, faragha, arifa
│   ├── songs/       # katalogi ya nyimbo (AssetManifest discovery)
│   ├── create/      # mhariri wa hadithi
│   └── onboarding/, splash/, profile/
└── l10n/            # Kiswahili + Kiingereza
```

- **State:** `flutter_bloc` (Cubit) kwa hali ya hadithi; `ChangeNotifier` kwa
  hifadhi ya kifaa (`LibraryStore`) na mandhari (`ThemeController`).
- **Navigation:** `go_router`.
- **Hifadhi:** `shared_preferences` (inafanya kazi simu **na** kivinjari).
- **Sauti:** `just_audio` (faili) + `flutter_tts` (akiba).

---

## Kuanza

### Mahitaji
- Flutter **3.16.9** (stable) au zaidi
- Dart 3.x

```bash
flutter pub get
flutter run                  # simu iliyounganishwa
flutter run -d chrome        # kivinjari
```

### Majaribio

```bash
flutter analyze              # inapaswa kuwa 0 errors
flutter test                 # 185 majaribio
```

### Kujenga APK

```bash
# 1. Ongeza folda ya Android ikiwa haipo
flutter create --platforms=android .

# 2. Jenga APK ya majaribio
flutter build apk --release

# Matokeo:
# build/app/outputs/flutter-apk/app-release.apk
```

Kwa build ya haraka ya majaribio (haipendekezwi kwa usambazaji):

```bash
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

**Kwa toleo la duka**, tengeneza keystore na usanidi `android/key.properties`
(tazama [hati ya Flutter](https://docs.flutter.dev/deployment/android)).
Bila keystore, `--release` hutumia **debug key** — hiyo haifai kwa Play Store.

### Kujenga web

```bash
# Toleo la offline/PWA (service worker huwasha, app hufanya kazi bila mtandao)
flutter build web -t lib/main_web_preview.dart --release

# Toleo la haraka la preview (hakuna cache — kila reload inapata toleo jipya)
flutter build web -t lib/main_web_preview.dart --release --pwa-strategy=none
```

---

## Mwongozo wa maudhui (bila kubadilisha msimbo)

### Picha za kurasa

```
assets/images/stories/pages/<story-id>/page_01.webp
```

- **1536×2048**, WebP, ubora 82 (KB 80–900)
- Weka kitu muhimu **juu 55%** — app huweka gradient na maandishi **chini 40%**
- Ongeza folda kwenye `pubspec.yaml` (Flutter haisomi folda kwa kurudia)

### Sauti ya hadithi

```
assets/audio/<story-id>/page_01.mp3      # sauti
assets/audio/<story-id>/page_01.json     # muda wa maneno (karaoke)
```

Ukikosa faili, app hurudi kwenye **TTS** — haianguki.

### Fonti

Fonti zote zimefungwa ndani ya app — **hakuna upakuaji wa mtandao**:

```
assets/fonts/Nunito-{Regular,SemiBold,Bold}.ttf
assets/fonts/Poppins-{Regular,SemiBold,Bold}.ttf
assets/fonts/Merriweather-{Regular,Bold}.ttf
assets/fonts/Baloo2-{Regular,Bold}.ttf
```

Zimetangazwa kwenye `pubspec.yaml` na kutumika kupitia
`lib/config/theme/typography.dart`.

### Nyimbo

```
assets/audio/songs/01_kichwa.mp3
assets/audio/songs/01_kichwa.json   # hiari: titleSw, titleEn, artist
```

Nambari ya mwanzo = mpangilio. `_` → nafasi. Tazama
`assets/audio/songs/README.md` kuhusu **hakimiliki**.

---

## Kinachobaki

Hii ni orodha ya **ukweli**, sivyo ya matumaini:

| Eneo | Hali |
|---|---|
| **Sauti iliyorekodiwa** | Hakuna faili yoyote ya MP3 bado — TTS inatumika |
| **Karaoke kwa sauti halisi** | Timing JSON haijaunganishwa na `ReaderCubit` |
| **Hadithi 3 za zamani** | `ngoma`, `kuku`, `chapati` bado zinatumia picha za branding (kurasa 15) |
| **Hadithi mpya 4** | Zina kurasa **3** pekee — hazijakamilika kwa maudhui |
| **Mchezo** | Maoni na mpango pekee (`docs/GAME-IDEAS.md`) |
| **Pakua / mtandao** | Hadithi zote ziko ndani; hakuna seva, hakuna upakuaji |
| **Akaunti / malipo** | Hakuna. M-Pesa/Tigo/Airtel hazijasanidiwa |
| **Arifa** | Mapendeleo huhifadhiwa; push haijasanidiwa |
| **Ukaguzi wa macho** | Ulikwama (bridge ya browser); marekebisho mengine hayajaonwa kwa macho |

---

## Nyaraka

| Hati | Inaeleza |
|---|---|
| [`docs/HANDOFF.md`](docs/HANDOFF.md) | Hali kamili, usanifu, vitu vilivyobaki, mwendelezo |
| [`docs/GAME-IDEAS.md`](docs/GAME-IDEAS.md) | Maoni matatu ya mchezo + mpango wa utekelezaji |
| [`docs/PRODUCT-VISION.md`](docs/PRODUCT-VISION.md) | Utambulisho wa bidhaa na mwelekeo wa kipekee |
| [`docs/AUDIO-SCRIPT.md`](docs/AUDIO-SCRIPT.md) | Maandishi ya kurekodi sauti, ukurasa kwa ukurasa |
| [`docs/HADITHI-ZOTE.txt`](docs/HADITHI-ZOTE.txt) | Maandishi yote, Kiswahili na Kiingereza |

---

## Leseni

Msimbo: bado haujaamuliwa — **usisambaze kabla ya kuweka leseni**.
Maudhui (hadithi, michoro) ni mali ya mradi. Nyimbo zinazoongezwa **lazima**
ziwe Public Domain au CC0.

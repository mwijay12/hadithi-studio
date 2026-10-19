# PLAN.md — Mpango Kamili wa Kile Kisichopo (Hadithi Studio)

> **Tarehe:** Oktoba 2026 · **Hali:** app msingi inafanya kazi (hadithi 10, reader, TTS fallback,
> onboarding, web build) — backend, database, malipo, sauti halisi na Creator Studio **bado hazipo.**
> Hati hii ni mpango wa kuzijenga, kwa mpangilio wa faida/gharama, tukiwa na lengo la
> **demo nzuri kwa wazazi/investors katika wiki 4–6.**

---

## 0. Muhtasari wa maamuzi (TL;DR)

| Uamuzi | Chaguo | Kwa nini |
|---|---|---|
| Database + backend | **Supabase** (Postgres) | SQL ya kweli, RLS, bei ya kubashiri, open-source — tazama §3 |
| Sauti ya hadithi | **Gemini 3.8 Flash-Lite TTS** (AI Studio API) | Kiswahili kizuri, ~$0.009 kwa dakika — tazama §2 |
| Picha za hadithi | **`gemini-3.1-flash-image`** (Nano Banana 2) | Imagen 4 **imezima** kwenye Gemini API (17 Ago 2026) — tazama §2 |
| Malipo ya Tanzania | **ClickPesa** (au Selcom) | BoT-licensed; M-Pesa, Airtel Money, Mixx, HaloPesa, kadi kwa API moja — §5 |
| Malipo ya kimataifa | **Paddle** (Merchant of Record) | Stripe **haipatikani kwa kampuni ya TZ**; Paddle hulipa TZ na hushughulikia VAT — §5 |
| Creator Studio (mtoto hutengeneza hadithi) | **Supabase Edge Function** inaita Gemini; **sio app moja kwa moja** | API key haiwezi kufichwa kwenye app — §6 |
| n8n | **Kwa matengenezo ya ndani (batch), sio UX ya app** | §6.3 |
| Sauti ya hadithi za sasa (demo) | **AI TTS kwanza** (uamuzi wa Mmiliki) | Rekodi ya mtu baadaye, mradi tuonekane wa kweli — §2 |

---

## 1. Kile kilichopo vs. kile kinachokosekana

### Kinachofanya kazi sasa (imethibitishwa)
- Reader (kurasa 6/hadithi), karaoke highlight ya TTS, bookmark, auto-page-turn.
- Onboarding, shelves, detail page, share, l10n (sw/en), fonts zimefungwa ndani (offline).
- Web build + click-through imepita (Playwright, makosa 0). Tests: 185.

### Kinachokosekana (orodha kamili — kutoka `docs/HANDOFF.md` §7)
| # | Kipengele | Kimeegemea |
|---|---|---|
| 1 | **Sauti za hadithi halisi** (`assets/audio/<story>/page_NN.mp3`) | Gemini TTS + script (§2) |
| 2 | **Nyimbo za kitoto** (`assets/audio/songs/*.mp3`) | Leseni/originals (§2.3) |
| 3 | **Picha za hadithi 3 za zamani** (`ngoma`, `kuku`, `chapati`) | Gemini Image (§2.2) |
| 4 | **Auth + profaili** (mzazi/mtoto) | Supabase Auth (§3) |
| 5 | **Database** (maendeleo, library, purchases) | Supabase Postgres (§3) |
| 6 | **Downloads + "Zilizopakuliwa" UI** | CDN + manifest (§4) |
| 7 | **Malipo** (M-Pesa + kimataifa) | ClickPesa + Paddle (§5) |
| 8 | **Creator Studio** (mtoto hutengeneza hadithi kwa picha + sauti) | Edge Functions + Gemini (§6) |
| 9 | **Gamification UI**, community, notifications | Baada ya §6 |
| 10 | Creator payments, moderation queue | §5 + §6 |

---

## 2. Phase 0 — Maudhui (SASA: wiki 1–2, hakuna backend)

### 2.1 Sauti ya hadithi — Gemini TTS (uamuzi: AI kwanza)
**Modeli (Okt 2026):**
- `gemini-3.8-flash-tts` — studio-grade, lugha 130+, voice design & replication
- `gemini-3.8-flash-lite-tts` — nafuu, kasi, **inapendekezwa kwa batch** yetu

**Bei (halisi, kutoka Google Cloud TTS pricing):**
- Input (text): $0.50 / 1M tokens (hadi 31 Des 2026; $1.00 baada)
- Output (audio): $6.00 / 1M tokens (Flash-Lite) · $9.00 / 1M (Flash TTS)
- **1 sekunde ya audio = 25 tokens** → dakika 1 ≈ tokens 1,500.

**Gharama yetu kamili:** hadithi 7 × kurasa ~6 × sekunde ~30 ≈ **dakika 30 za sauti** ≈
**$0.27 – $0.40 (TZS ~1,000)**. Hata tukirudia mara 10, ni chini ya $5. **Ushauri: tumia
Flash-Lite kwa demo; Flash (studio) kwa toleo la mwisho.**

**Mpango wa utekelezaji:**
1. Tumia `docs/AUDIO-SCRIPT.md` (tayari ipo!) kama maandishi ya kusoma.
2. Script ya batch (`tool/generate_audio.dart` au Python) inaita Gemini TTS kwa kila ukurasa →
   `assets/audio/<story-id>/page_NN.wav` → convert `mp3` (bitrate 64k, kama `bundled_stories.dart:61`).
3. Ongeza `assets/audio/` kwenye `pubspec.yaml` (kumbuka: bado haijaongezwa).
4. App **haitohitaji code mpya** — `story_audio_player.dart:14` inasoma faili zikiongezwa.
5. Baadaye (Premium): word timestamps kwa karaoke ya audio (`page_NN.json`, `hasPageTimings`).

**Tahadhari:** AI TTS inaweza kukosea majina ya Kiswahili (mif. "Kilimanjaro", majina ya watu).
Sikiliza kila clip; rudia zile mbovu (bei ni ndogo). Kwa toleo la kutolewa kwa wazazi: review ya mtu.

### 2.2 Picha — Gemini Image (sio Imagen!)
**Imagen 4 fast/standard/ultra zilizimwa kwenye Gemini API tarehe 17 Ago 2026.** Tumia badala yake:

| Modeli | Bei kwa picha (1K) | Batch |
|---|---|---|
| `gemini-3.1-flash-image` (Nano Banana 2) | $0.067 | $0.034 |
| `gemini-3.1-flash-lite-image` | nafuu zaidi | — |
| `gemini-3-pro-image` (Pro) | $0.134 (1K/2K), $0.24 (4K) | $0.067 |

- Hadithi 3 za zamani × kurasa 5 × $0.067 ≈ **$1.0** (batch ≈ $0.5). Rendering thabiti ya
  mtindo mmoja (`style reference`/prompt template) — character consistency ni muhimu.
- **Usianze** na `gemini-2.5-flash-image` (inazimwa 2 Okt 2026).

### 2.3 Nyimbo za kitoto (`assets/audio/songs/`)
Code **ipo tayari**: `songs_page.dart` + `song_catalog.dart` hujigundua faili zote za
`assets/audio/songs/*.mp3` zenyewe. Unachohitaji ni faili pekee:
- **Leseni ni muhimu:** usichukue recording za YouTube. Chaguzi:
  a) Nyimbo za jadi (public domain) — **rekodi zetu** (au TTS haifai; nyimbo zinahitaji melodi).
  b) Originals za mtunzi wa ndani (kukodi kwa TZS ndogo au share ya mapato).
  c) CC0/CC-BY za library (angalia leseni ya kila faili; weka credit).
- Weka 5–8 nyimbo kwa demo; majina ya faili: `01_kichwa.mp3` … (catalog hupanga kwa namba).
- `pubspec.yaml` inahitaji `assets/audio/` (au `assets/audio/songs/`) kuongezwa.

**Matokeo ya Phase 0:** app inaonekana "real" — kila hadithi inasoma kwa sauti, kuna nyimbo,
picha za kale zimebadilishwa. Haya ndio hasa yanayoonekana kwenye demo kwa wazazi/investors.

---

## 3. Phase 1 — Backend-lite: CDN + Downloads (wiki 3–4)

**Lengo:** kuweka hadithi/sauti mpya **bila** kuupdate APK; mtumiaji apakue wakati ana mtandao.

### 3.1 Muundo
```
Cloudflare R2 (au Supabase Storage)
└── content/
    ├── manifest.json          ← orodha: hadithi, version, sizes, hashes
    ├── <story-id>/
    │   ├── story.json         ← maandishi (sw/en), metadata
    │   ├── page_01.jpg …
    │   └── audio/page_01.mp3 …
```
- App hupakua `manifest.json` (ndogo, inaweza ku-cache), kulinganisha na `bundled_stories.dart` +
  Hive, kisha kupakua pakiti za hadithi kwa `dio` (ipo tayari) + `archive` kwa zip ikiwa nafuu.
- **DownloadManager**: Hive record (`downloadedAt`, `version`), progress UI, retry, delete.
- UI mpya: sehemu ya "Zilizopakuliwa" (tayari kuna kitufe kwenye detail page — `Zilizopakuliwa`).

### 3.2 Kwa nini CDN kwanza, sio database?
- Hatuwezi kubadilisha ovyo content ya bundled bila app update — CDN hiyo inasuluhisha.
- Hatuihitaji Auth/DB kwa kazi hii. R2 = $0 kwa 10 GB; Cloudflare Pages inatoa hosting.
- CDN hii **itaitumika** baadaye na Creator Studio (kuhifadhi hadithi za watumiaji — kwa Supabase Storage).

---

## 4. Phase 2 — Database: Supabase (wiki 4–6)

### 4.1 Kwa nini Supabase, sio Firebase? (swali lako)
| Kigezo | Supabase | Firebase |
|---|---|---|
| Database | **Postgres** (SQL, joins, foreign keys, transactions) | Firestore (NoSQL, haiwezi joins; denormalize) |
| Data yetu | **Relational kabisa** (mzazi → watoto → maendeleo → manunuzi → hadithi) | Ingatulazimu ku-copy data sehemu nyingi |
| Bei kwa kukua | **Flat tiers; ~3–5× nafuu** kwa mzigo mkubwa | Pay-per-operation (inapanda kwa mshangao) |
| Security | **RLS (SQL policies)** — sheria zipo kwenye DB yenyewe | Security Rules (pekee kwa Firestore/Storage) |
| Malipo | Ledger inahitaji **transactions + unique constraints** (double-spend!) — Postgres bora | Haiwezi constraints; hatari ya malipo mawili |
| Kuhamisha (exit) | **Open source; export ya SQL; self-host** | Proprietary; kutoa data ni kazi |
| Offline sync | Client SDK nyepesi → **tunaiweka wenyewe** (Hive ipo tayari, `supabase_offline_sync` pattern) | Bora kabisa (offline cache built-in) |
| Push notifications | Haitoi → OneSignal/FCM (bure) | FCM ipo ndani ya ecosystem |

**Hitimisho:** Firebase hushinda kwa "mobile offline sync" pekee. Sisi **tayari** tuna offline-first
(Hive + bundled assets + content manifest ya Phase 1) — tunahitaji DB ambayo ni **relational,
ya kubashiri bei, na isiyotufunga**. Supabase inashinda kwa sababu hizo. Push = OneSignal (free tier)
baadaye. Realtime features (dashboards za wazazi?) = Supabase Realtime v2.

**Note:** Supabase free tier: DB 500MB, Auth 50K MAU, Storage 1GB, Edge Functions — inatosha Phase 2/3.

### 4.2 Schema rasimu (v1)
```sql
-- profiles (1:1 na auth.users)
profiles(id uuid pk ref auth.users, display_name text, locale text, plan text default 'free',
         created_at timestamptz)

-- watoto (profaili ndani ya app; PIN ya mzazi inalinda)
children(id uuid pk, parent_id uuid ref profiles, name text, age_group text,
         avatar text, created_at timestamptz)

-- hadithi (mirror ya content manifest; bundled zina id zinazolingana)
stories(id text pk, title_sw text, title_en text, shelf text, age_group text,
        cover_url text, version int, published_at timestamptz)

-- ukurasa mmoja wa hadithi ya remote
story_pages(story_id text ref stories, page_no int, text_sw text, text_en text,
            image_url text, audio_url text, timings_url text,
            primary key(story_id, page_no))

-- maendeleo ya kusoma (sync ya Hive <-> Supabase)
reading_progress(child_id uuid ref children, story_id text, page_no int,
                 seconds_read int, completed_at timestamptz,
                 updated_at timestamptz, primary key(child_id, story_id))

-- library ya downloads
downloads(child_id uuid ref children, story_id text, version int,
          downloaded_at timestamptz, primary key(child_id, story_id))

-- malipo: intents na ledger
payment_intents(id uuid pk, profile_id uuid, provider text, -- clickpesa|paddle
                amount int, currency text, status text, external_ref text,
                created_at timestamptz)
transactions(id uuid pk, intent_id uuid ref payment_intents, provider_txn_id text unique,
             status text, raw jsonb, created_at timestamptz)  -- webhook ndio huandika

-- entitlements (nani ana haki ya nini)
entitlements(profile_id uuid, feature text, -- premium|creator_studio
             expires_at timestamptz, source_txn uuid, primary key(profile_id, feature))

-- Creator Studio (Phase 4)
creator_projects(id uuid pk, child_id uuid, title text, status text, -- draft|generating|review|published|rejected
                 story_id text null, created_at timestamptz)
creator_pages(project_id uuid, page_no int, text text, image_url text,
              audio_url text, primary key(project_id, page_no))
moderation_reviews(project_id uuid, reviewer text, decision text, notes text, created_at timestamptz)
```

**RLS kwa ufupi:** mzazi anasoma/anaandika safu zake pekee (`parent_id = auth.uid()`);
`stories`/`story_pages` zinasomwa na kila mtu aliyeingia; `transactions` zinaandikwa na
webhook pekee (service role); `entitlements` zinasomwa na mmiliki pekee.

### 4.3 Auth
- **Email OTP / magic link** kwa wazazi (rahisi, hakuna password kwa watoto).
- Google Sign-In baadaye. **Watoto hawana accounts** — wako chini ya mzazi (`children`).
- Anonymous auth haifai (malipo yanahitaji identity ya kudumu).

### 4.4 Sync ya maendeleo
- Hive (local) ndio source of truth wakati wa kusoma (offline!).
- Sync worker (kwenye `reading_progress`): push kila kufungwa kwa reader; pull wakati wa
  kuingia; conflict = "newest `updated_at` wins" (kama `supabase_offline_sync`).

---

## 5. Phase 3 — Malipo (baada ya demo: wiki 6+)

### 5.1 Tanzania: ClickPesa (inafaa MVP)
- **BoT-licensed** (NBPSL No. 0000-31), Dar es Salaam. API moja: **M-Pesa (USSD-Push/Lipa Namba),
  Airtel Money, Mixx by Yas, HaloPesa, EzyPesa, benki, kadi** (Mastercard/Visa/UnionPay).
- **Jisajili kwa dakika 5** (requires business registration docs) → API keys → hosted checkout
  au API (`POST` init + webhook callback). API docs + API Explorer ipo.
- Mbadala: **Selcom** (enterprise, RSA-signed gateway) — chaguo la pili ikiwa ClickPesa haitoshelezi.

**Mchakato:** app → Edge Function `create-payment` (inamiliki API key ya ClickPesa) →
order ref → ClickPesa USSD push kwa mtumiaji → webhook `payment.confirmed` → Edge Function
huandika `transactions` (idempotent kwa `provider_txn_id`) → huongeza `entitlements` → app inaona.

### 5.2 Kimataifa: Paddle (Stripe haipatikani!)
- **Stripe haina Tanzania** kwenye nchi zake 49 → kampuni ya TZ haiwezi kufungua account ya kawaida.
  (Kama una entity ya UK/US, hiyo ni njia nyingine.)
- **Paddle = Merchant of Record:** hulipa kwa nchi 177/199, hushughulikia VAT/sales tax zote,
  huchukua chargebacks. Ada: **5% + $0.50** kwa checkout. Inafaa "digital products/software".
- Paddle checkout inaweza kufungwa kwenye app kwa `url_launcher` (checkout link) → webhook →
  `entitlements`. (Weka pia: Paddle inaruhusu bidhaa za digital pekee — sisi ni digital 🤝).
- **PayPal:** receiving TZ haijulikani waziwazi; inawezekana kupitia payout ya MoR
  (Lemon Squeezy inaruhusu PayPal payouts). **Ushauri: Paddle ndio kwanza; PayPal baadaye.**

### 5.3 Mfano wa bei (pendekeza; unabadilisha)
| Plan | Bei | Kwa nini |
|---|---|---|
| Bure | TZS 0 | hadithi 3 + nyimbo 2 |
| Premium Hadi Mwisho | TZS 2,000/mwezi | hadithi zote + audio zote + offline downloads |
| Creator Studio | TZS 5,000/mwezi | mtoto hutengeneza hadithi zake (AI) — §6 |

*(Gharama ya AI kwa hadithi 1 ya mtoto: picha 6 × $0.067 + TTS ~3 dk × $0.009 ≈ **$0.43** —
hivyo TZS 5,000/mwezi inatosha sana kwa hadithi ~10/mwezi. Weka ukurasa wa matumizi!)*

### 5.4 Ushauri wa utekelezaji
1. **Ledger kwanza, UI baadaye:** Edge Function + webhook + `transactions`/`entitlements` +
   tests za idempotency (webhook kurudiwa mara 2 = malipo moja).
2. Kisha UI: plans page (ipo skeleton? angalia §7 ya HANDOFF), M-Pesa dialog (namba ya simu),
   polling ya hali (au Realtime).
3. Kadi kimataifa = Paddle checkout link pekee (huhitaji PCI compliance lolote).

---

## 6. Phase 4 — Creator Studio (mtoto hutengeneza hadithi kwa picha + sauti)

### 6.1 Mtiririko (child flow, kupitia gate ya mzazi)
```
Mzazi/MToto (PIN gate) → "Tengeneza Hadithi Yangu"
  1. Mtoto / mzazi huandika wazo (au AI inasaidia: title + plot)
  2. AI (Gemini text) hutengeneza kurasa 4–6 za hadithi (Kiswahili, lugha rahisi)
  3. AI (gemini-3.1-flash-image) huchora picha kwa kila ukurasa (style template thabiti)
  4. AI (gemini-3.8-flash-tts) husoma kila ukurasa → sauti
  5. Preview ndani ya app → mtoto huchagua rangi/kauli; azima/ruhusu apublish
  6. Moderation (AI + review ya mtu/queue) → "published" (private kwa familia; public
     kwa idhini ya mzazi + review)
  7. Hadithi huingia kwenye shelf ya familia (au public shelf baada ya review)
```
- Kila hatua inaonyesha **hali ya maendeleo** (`creator_projects.status`: draft→generating→review→published).
- **Hii ni kipengele cha kulipia** (Creator Studio plan, §5.3).

### 6.2 Usanifu (API keys zinafichwa — MUHIMU)
**Kosa la kawaida: kuweka `GEMINI_API_KEY` kwenye app ya Flutter = mtu huchukua key siku moja.**
```
App (Flutter)
  └── supabase.functions.invoke('create-story', {project_id})
        └── Supabase Edge Function (Deno) — ina GEMINI_API_KEY (secret env)
              ├── Gemini text  → plot + kurasa   → creator_pages
              ├── gemini-3.1-flash-image → picha → Supabase Storage
              ├── gemini-3.8-flash-tts   → sauti → Supabase Storage
              └── moderation pass → status='review'
```
- Edge Function hurudisha job id; app huangalia hali (`realtime` au poll kila sekunde 3).
- **Gharama kwa hadithi:** ≈ $0.43 (§5.3). Timeout ya Edge Functions inatosha kwa kazi hizi
  ikigawanywa kwa hatua (picha moja = call moja).

### 6.3 n8n — wapi inafaa na wapi haifai
| Zuri kwa n8n | Baya kwa n8n |
|---|---|
| **Pipeline ya ndani:** kuzalisha sauti za hadithi zetu 7 kwa batch (TTS 60 clips), picha za
  hadithi 3 za zamani, kurudia clips zilizokosewa | UX ya mtoto inayosubiri sekunde 10–30 (n8n si
  realtime engine; latency + ops) |
| Webhook ya webhook events (Failed → Telegram alert kwako) | Kuficha API keys badala ya Edge Functions |
| Scheduled: "kagua content mpya", "tuma WhatsApp hali ya demo kwa wazazi" | Kubadilisha app moja kwa moja (app iendelee kuongea Supabase) |
| Prototyping ya haraka ya workflow za AI bila kujenga backend | |

**Ushauri:** n8n kwenye VPS ile ile ya preview (au n8n Cloud ~$24/mo) kwa **internals** zetu.
App (Creator Studio ya mtoto) = Supabase Edge Functions. Hii inatupa: keys salama, retries,
na sehemu moja ya kurekebisha.

### 6.4 Usalama wa watoto (MUST, kabla ya public)
- Mzazi PIN inalinda studio; mtoto hawezi kutuma kitu public bila idhini.
- Moderation: Gemini safety filters + keyword denylist + **review ya mtu** kabla ya public.
- Hakuna chat/ufichuaji wa taarifa binafsi. Privacy policy + sheria za Tanzania + GDPR-K basics.
- Logs: kege `moderation_reviews` kila maamuzi (audit).

---

## 7. Phase 5 — Baada ya Creator Studio
- Notifications (OneSignal/FCM): streak reminders, "hadithi mpya".
- Gamification UI (badges 22 tayari kwenye domain!), ReadingStats dashboard.
- Community (maoni, public shelves), analytics.
- Tablet 2-page spread; mascots (Rive — kumbuka I-6: shaders hazifanyi kazi kwenye HTML renderer).

---

## 8. Ratiba + bajeti (wiki 4–6, lengo: demo)
| Wiki | Kazi | Gharama (est.) |
|---|---|---|
| 1 | Phase 0: sauti TTS hadithi 7 + nyimbo 5 | <$5 API + nyimbo (leseni TBD) |
| 1–2 | Picha hadithi 3 za zamani (batch) | ~$0.5–1 |
| 2 | Polish: demo script route (onboarding→story→audio), screenshots | $0 |
| 3–4 | Phase 1: R2 + manifest + DownloadManager + UI | $0 (R2 free tier) |
| 4–6 | Phase 2: Supabase (auth, schema, sync, RLS) | $0 (free tier) |
| Baada ya demo | Phase 3 (malipo), Phase 4 (creator) | ClickPesa ada TBD; Paddle 5%+50¢ |

**Malengo ya demo:** mzazi/mwekezaji anaona: hadithi inasoma kwa sauti ya Kiswahili safi,
nyimbo, picha nzuri, na (slide ya) "mtoto anaweza kutengeneza hadithi yake mwenyewe — hii ni
premium". Hiyo inauza.

---

## 9. Hatari + maamuzi yanayohitajika
| # | Hatari/ombi | Ushauri |
|---|---|---|
| R1 | AI TTS kutokosea jina la Kiswahili | Sikiliza kila clip; rudia mbovu (bei ndogo); review ya mwisho |
| R2 | Leseni ya nyimbo | Rekodi za jadi + originals za ndani; weka files za leseni kwenye `docs/` |
| R3 | Stripe haipatikani TZ | Paddle (au entity ya nje). PayPal = baadaye kama payout |
| R4 | ClickPesa inahitaji business registration | Anza jisajili wiki hii (docs zinachukua muda) |
| R5 | API keys zinafichwa | Edge Functions pekee; kamwe sio kwenye app |
| R6 | Gharama ya Creator Studio inakua | Cap ya hadithi/mwezi kwa plan + usage page |
| R7 | Moderation ya watoto | Review ya mtu kabla ya public — usiruke hii |

**Maamuzi yanayosubiri wewe:**
1. **Business registration ya ClickPesa** — unayo? (inahitajika kwa M-Pesa halisi)
2. **Nyimbo:** originals za ndani (nani?) au CC0 library kwanza?
3. **Bei:** plans za §5.3 — kubali/badilisha?
4. **Paddle:** uko tayari kuwa MoR (5%+50¢) kwa kadi za kimataifa?

---

## 10. Sources (zilizothibitishwa Okt 2026)
- Gemini TTS bei: `cloud.google.com/text-to-speech/pricing` (Gemini 3.8 Flash TTS / Flash-Lite)
- Gemini Image bei + taarifa za deprecation: `ai.google.dev/gemini-api/docs/pricing`
- Supabase vs Firebase: `bytebase.com`, `supabase.com/alternatives/supabase-vs-firebase`, dev.to 2026
- ClickPesa (BoT license, API, M-Pesa): `clickpesa.com` · Selcom: `developer.selcom.business`
- Stripe nchi 49 + MoR (Paddle 177/199): `getpaidatlas.com/stripe-alternatives` (17 Okt 2026)
- Paddle/Polar/LS ada: `techloghub.com` (15 Okt 2026)

---

*Hati hii ni mpango — hakuna kitu kimejengwa bado isipokuwa Phase 0 inaweza kuanza mara moja.*
*Rejea: `docs/HANDOFF.md` (hali ya sasa ya kiufundi) · `docs/AUDIO-SCRIPT.md` (maandishi ya sauti).*

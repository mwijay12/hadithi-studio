# Michezo ndani ya Hadithi Studio — maoni na mpango

> Hati hii inajibu swali: *"nimewaza kuongeza game ndani ya app — kama ile
> ya `website-83c52536` lakini bora zaidi."*

---

## 1. Kile kilichopo kwenye ZIP (nilikisoma)

Mchezo mmoja wa `index.html` (mistari 694), unaoitwa **"Leo na Hadithi —
Story Safari"**. Ni **endless runner** ya canvas:

| Kipengele | Kilichopo |
|---|---|
| Udhibiti | Mguso mmoja = kuruka; **kuruka mara mbili** (double jump) |
| Malengo | Kukusanya kurasa (+10), kufikia hadithi (+50) |
| Hatari | Vizuizi (miamba, vichaka) |
| Maisha | Mioyo 3, kisha `gameOver` |
| Kasi | `speed` huanza 320 na kuongezeka +7 kwa sekunde hadi 700 |
| Bonasi | Kipepeo (`bfly`) anayepatikana kwa muda |
| Rekodi | `localStorage['leoBest']` |
| Hisia | `setMood` — furaha, udadisi, kusikiliza, sherehe |
| Sauti | `tone()` ya synthesized (square wave) |
| Picha | `vectorLeo()` — Leo amechorwa kwa mkono kwenye canvas |

### Kwa nini ni nzuri
- Mzunguko wa mchezo unaeleweka kwa sekunde mbili: **ruka, kusanya, endelea**.
- Kasi inaongezeka → changamoto inakua bila maelezo.
- Inaunganisha mchezo na kusoma ("kukusanya kurasa").

### Kwa nini haitoshi kwa app ya watoto wa miaka 3–8
1. **Hakuna mwisho.** Mtoto anashindwa hatua fulani na kuacha — hakuna
   hisia ya "nimemaliza".
2. **Kushindwa kunaadhibu.** Mioyo 3 inaisha katika sekunde 40 kwa mtoto
   mdogo, kisha `gameOver` — hii inafundisha kujiepusha, sivyo kujaribu.
3. **Hakuna kujifunza.** Unakusanya "kurasa" lakini hakuna neno, sauti, wala
   maana inayobaki.
4. **Kasi isiyodhibitiwa.** Mtoto wa miaka 3 hawezi kufuata 700 px/s.
5. **Haijaunganishwa na hadithi.** Unacheza "Story Safari" lakini hadithi
   unayoisoma haina uhusiano na level.
6. **Ufikivu.** Hakuna `reduce motion`, hakuna mode ya rangi, na sauti ni
   `square wave` — hiyo inauma masikioni kwa sekunde 30.

---

## 2. Maoni matatu (kwa gharama na athari)

### Wazo A — **"Safari ya Leo"** (recommended)
**Mtindo:** level-based, sekunde 60–90, ina mwisho.

Leo anatembea safari **inayolingana na hadithi anayoisoma**. Kila level ni
ukurasa mmoja wa hadithi. Lengo si "kuishi muda mrefu" — ni **kufika mwisho**
na kukusanya **maneno 3** ya sentensi.

- Maneno yanaelea angani; ukigusа neno, Leo **analisoma kwa sauti** (TTS).
- Mwisho wa level, maneno yale yanaundа sentensi — **ile ile ya ukurasa**.
- Hakuna `gameOver`. Ukigusa kizuizi, Leo anacheka, unapoteza neno moja,
  na unaendelea. Mwisho ni **daima** kufika.
- Kila level ina nyota 3: kufika, maneno yote, na kutokugusa kizuizi.

**Kwa nini bora:** inafundisha **kusoma** kwa kucheza, ina mwisho, na
inaunganisha mchezo na hadithi. Mzazi anaona maana.

### Wazo B — **"Sauti ya Wanyama"** (wa miaka 3–5)
Skrini moja, wanyama 8 waliotawanyika. Sauti inasema *"Nani anasema
mii-au?"* — mtoto agusa simba. Sahihi: simba anacheza, sauti inasema
*"Simba! Simba ananguruma."*

- Hakuna muda, hakuna kushindwa.
- Hufundisha **msamiati wa Kiswahili** + kutambua sauti.
- Rahisi kutekeleza: hakuna physics, hakuna canvas — ni picha + sauti.

### Wazo C — **"Chagua Hatima"** (wa miaka 7+)
Kila hadithi ina **vituo 2–3 vya uamuzi**. Mtoto achague: *"Simba aende
kwa mto au kwa mti?"* — na hadithi inaendelea tofauti.

- Hii sio mchezo wa mwendo; ni **hadithi inayogusa**.
- Inatumia `HotspotType.story_choice` iliyopo tayari kwenye msimbo lakini
  ambayo **haijatekelezwa** (inatoa "inakuja" kwa sasa).
- Ndiyo njia ya haraka zaidi ya kuongeza "game feel" bila injini.

---

## 3. Pendekezo: A + C, na B kama kianzio

| Awamu | Kazi | Muda | Kwa nini |
|---|---|---|---|
| **1** | **C — Chagua Hatima** kwenye hadithi 2 | siku 2–3 | Hakuna injini mpya; `story_choice` ipo; huongeza mchezo kwenye kusoma |
| **2** | **B — Sauti ya Wanyama** | siku 3–4 | Rahisi, inafaa miaka 3–5, inafundisha msamiati |
| **3** | **A — Safari ya Leo** (levels 5) | wiki 2–3 | Inahitaji physics + mwendo + hali |

Anza na **C**, kwa sababu inatumia kile kilichopo na haihitaji uamuzi mkubwa
wa kiufundi. Ndiyo "game" ya kwanza yenye maana.

---

## 4. "Safari ya Leo" — vipimo (kama tutaifanya)

### Mzunguko wa mchezo
1. Level inaanza: Leo anakimbia kwenda kulia, mandhari ya ukurasa.
2. Maneno 3 yanaelea; mguso mmoja = kuruka kuyakamata.
3. Kizuizi kimoja au viwili; kugusa = kupoteza neno (si maisha).
4. Mwisho: sentensi inaundwa, TTS inaisoma, nyota zinaonekana.
5. "Endelea" → ukurasa unaofuata wa hadithi (au kurudi kwenye reader).

### Kanuni za kubuni (hizi ndizo "better")
- **Hakuna kushindwa kwa kudumu.** Kila level ina mwisho unaofikiwa.
- **Kasi inayodhibitiwa:** 220 px/s (miaka 3–5), 320 (6–8), 420 (9+).
  Mtoto/mzazi anaweza kubadilisha kwenye Mipangilio.
- **Mguso mmoja tu.** Hakuna double-jump, hakuna vitufe viwili.
- **Sauti laini**, si `square wave`. Nyimbo ya background inaweza kuzimwa.
- **Reduce motion:** bila tetemeko (`shake`), bila chembe nyingi.
- **Rangi salama kwa upofu wa rangi:** kizuizi kina **umbo** tofauti, sivyo
  rangi pekee.
- **Hakuna matangazo, hakuna malipo, hakuna mtandao.**

### Ufundi (Flutter)
- **Usianze na Flame.** `CustomPainter` + `Ticker` inatosha kwa level ya
  mstari mmoja; inaepusha dependency nzito kwenye simu za bei ndogo.
- Hitakikisha 60 fps kwenye simu ya 2GB RAM: **picha 1 tu** ya Leo kwa
  kila pose (sprite sheet ya fremu 6), sivyo `vectorLeo` ya kila frame.
- Hali ya mchezo iwe **`ChangeNotifier` ndogo**, sivyo kuingia kwenye
  `ReaderCubit`.
- Data: `assets/game/levels/<story-id>_<page>.json` —
  `{ words: [...], obstacles: [...], speed: 220 }`. Hii inaruhusu kuunda
  level bila kubadilisha msimbo.

### Jinsi inavyounganishwa na kusoma
- Nyota → alama kwenye wasifu (`LibraryStore`).
- Neno lililokusanywa → linaingia kwenye "maneno niliyojifunza".
- Level inafunguliwa **baada ya** kusoma ukurasa — sivyo kuchukua nafasi ya
  kusoma.

---

## 5. Uamuzi unaohitaji wewe

1. **Wapi mchezo uanze?** Kwenye reader (baada ya ukurasa), kwenye tab
   yake, au kwenye Nyumbani kama kadi?
2. **Umri wa kwanza:** 3–5 (rahisi, Wazo B) au 6–8 (A)?
3. **Je, tunatumia sauti za wanyama halisi?** Zinahitaji leseni; CC0 zipo
   (freesound.org) lakini ni kazi ya kuchagua na kuhariri.

Bila majibu hayo, ninapendekeza: **anza na Wazo C** (Chagua Hatima) kwenye
hadithi mbili zilizopo, kwa sababu ni siku 2–3 za kazi na inatumia
`story_choice` iliyopo tayari.

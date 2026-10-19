/// KANUNI YA ENUMS ZINAZOTUMIKA KWENYE FEATURE ZAIDI YA MOJA.
///
/// Enums zote ambazo zinavuka mipaka ya feature moja (mfano: `AppLanguage`
/// inatumika kwenye settings, onboarding, reader na creator) zinaishi hapa
/// ili kuwa na chanzo kimoja cha ukweli (single source of truth) na kuepuka
/// kunakili (duplication) kwenye kila feature.
///
/// Enums zilizo maalum kwa feature moja (mfano `OnboardingSlide`) zinaishi
/// kwenye folder ya feature husika.
library;

import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// LUGHA
// ---------------------------------------------------------------------------

/// Lugha za app. `bilingual` haimaanishi Locale tofauti — inamaanisha
/// kuonyesha Kiswahili na Kiingereza kwenye ukurasa mmoja (tazama Reader).
///
/// Named `AppLanguage` (badala ya `Language`) ili kuepuka mgongano wa jina
/// na classes nyingine za Flutter/Dart.
enum AppLanguage {
  swahili('sw', 'Kiswahili', 'Swahili'),
  english('en', 'Kiingereza', 'English'),
  bilingual('sw', 'Lugha Zote', 'Bilingual');

  const AppLanguage(this.code, this.labelSw, this.labelEn);

  /// ISO 639-1 language code inayotumika kwenye `Locale`.
  final String code;

  /// Jina kwa Kiswahili — lugha ya msingi ya app.
  final String labelSw;

  /// Jina kwa Kiingereza.
  final String labelEn;

  Locale get locale => Locale(code);

  bool get isBilingual => this == AppLanguage.bilingual;

  /// Hubadilisha code (mfano 'sw') kwenda `AppLanguage`.
  /// Hurudisha [AppLanguage.swahili] kama code haijulikani — Kiswahili ni
  /// lugha ya msingi ya app.
  static AppLanguage fromCode(String? code) {
    switch (code) {
      case 'en':
        return AppLanguage.english;
      case 'sw':
      default:
        return AppLanguage.swahili;
    }
  }

  static List<Locale> get supportedLocales =>
      const [Locale('sw'), Locale('en')];
}

// ---------------------------------------------------------------------------
// UMRL / VIWANGO VYA KUSOMA
// ---------------------------------------------------------------------------

/// Makundi ya umri — yanatumika kuchuja hadithi na kupanga mapendekezo.
enum AgeGroup {
  miaka_3_5(3, 5, 'Miaka 3-5', 'Ages 3-5'),
  miaka_6_8(6, 8, 'Miaka 6-8', 'Ages 6-8'),
  miaka_9_12(9, 12, 'Miaka 9-12', 'Ages 9-12'),
  miaka_13_15(13, 15, 'Miaka 13-15', 'Ages 13-15'),
  miaka_16_plus(16, 99, 'Miaka 16+', 'Ages 16+');

  const AgeGroup(this.minAge, this.maxAge, this.labelSw, this.labelEn);

  final int minAge;
  final int maxAge;
  final String labelSw;
  final String labelEn;

  /// Hupata kundi la umri kulingana na umri halisi wa mtoto.
  static AgeGroup fromAge(int age) {
    for (final group in AgeGroup.values) {
      if (age >= group.minAge && age <= group.maxAge) {
        return group;
      }
    }
    return AgeGroup.miaka_16_plus;
  }
}

/// Kiwango cha kusoma — hubadilisha maneno, sentensi na urefu wa hadithi.
enum ReadingLevel {
  mtoto_mdogo('Mtoto Mdogo', 'Toddler'),
  darasa_1_2('Darasa la 1-2', 'Grade 1-2'),
  darasa_3_4('Darasa la 3-4', 'Grade 3-4'),
  darasa_5_7('Darasa la 5-7', 'Grade 5-7'),
  sekondari('Sekondari', 'Secondary'),
  watu_wazima('Watu Wazima', 'Adults');

  const ReadingLevel(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;

  /// Maneno yanayopendekezwa kwa ukurasa kwa kila kiwango.
  /// Hii inatumika kwenye AI prompt (tazama creator feature).
  int get recommendedWordsPerPage {
    switch (this) {
      case ReadingLevel.mtoto_mdogo:
        return 12;
      case ReadingLevel.darasa_1_2:
        return 25;
      case ReadingLevel.darasa_3_4:
        return 45;
      case ReadingLevel.darasa_5_7:
        return 80;
      case ReadingLevel.sekondari:
        return 130;
      case ReadingLevel.watu_wazima:
        return 200;
    }
  }
}

// ---------------------------------------------------------------------------
// HADITHI
// ---------------------------------------------------------------------------

/// Makundi ya hadithi — yanajumuisha makundi maalum ya Tanzania.
enum StoryCategory {
  hadithi_za_kiswahili('Hadithi za Kiswahili', 'Swahili Tales'),
  hadithi_za_kisasa('Hadithi za Kisasa', 'Modern Stories'),
  ngano('Ngano', 'Folk Tales'),
  methali_na_nahau('Methali na Nahau', 'Proverbs & Idioms'),
  historia_ya_tanzania('Historia ya Tanzania', 'Tanzanian History'),
  sayansi_na_teknolojia('Sayansi na Teknolojia', 'Science & Technology'),
  mazingira('Mazingira', 'Environment'),
  maadili('Maadili', 'Moral Stories'),
  // **Kundi jipya.** Watoto hupenda hadithi za wanyama kuliko kundi lolote
  // lingine, na kundi hili liko tofauti na `ngano` (ambalo ni hadithi za
  // jadi zenye ujanja): hapa ni hadithi za kisasa zenye mafunzo kuhusu
  // wanyama wa Tanzania.
  wanyama('Wanyama', 'Animals'),
  ujasiriamali('Ujasiriamali', 'Entrepreneurship'),
  burudani('Burudani', 'Entertainment'),
  elimu('Elimu', 'Educational'),
  dini('Dini', 'Religious'),
  michezo('Michezo', 'Sports'),
  sanaa('Sanaa', 'Arts');

  const StoryCategory(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;

  /// Slug inayotumika kwenye API: `GET /api/v1/stories/category/:slug`
  String get slug => name.replaceAll('_', '-');

  static StoryCategory? fromSlug(String slug) {
    final normalized = slug.replaceAll('-', '_');
    for (final category in StoryCategory.values) {
      if (category.name == normalized) {
        return category;
      }
    }
    return null;
  }
}

/// Hali ya hadithi kwenye mfumo wa kuchapisha.
enum StoryStatus {
  draft('Rasimu', 'Draft'),
  review('Inakaguliwa', 'In Review'),
  published('Imechapishwa', 'Published'),
  archived('Imehifadhiwa', 'Archived');

  const StoryStatus(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;
}

// ---------------------------------------------------------------------------
// MTINDO WA SANAA
// ---------------------------------------------------------------------------

/// Mitindo ya picha inayotumika kwenye AI illustration generation.
enum IllustrationStyle {
  tinga_tinga('Tinga Tinga', 'Tinga Tinga'),
  watercolor_tanzania('Rangi ya Maji ya Tanzania', 'Tanzanian Watercolor'),
  digital_cartoon('Katuni ya Kisasa', 'Modern Digital Cartoon'),
  traditional_art('Sanaa ya Jadi', 'Traditional African Art'),
  realistic('Ya Kweli', 'Realistic'),
  pencil_sketch('Penseli', 'Pencil Sketch'),
  collage('Mchanganyiko', 'Collage'),
  pop_art('Pop Art', 'Pop Art'),
  storybook_classic('Hadithi za Zamani', 'Classic Storybook');

  const IllustrationStyle(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;

  /// Maelezo yanayoingizwa kwenye prompt ya AI image generation.
  String get aiPromptDescriptor {
    switch (this) {
      case IllustrationStyle.tinga_tinga:
        return 'Tinga Tinga style, traditional Tanzanian naive art, bold '
            'outlines, bright enamel colors, decorative patterns';
      case IllustrationStyle.watercolor_tanzania:
        return 'soft watercolor children book illustration, warm earthy '
            'African palette';
      case IllustrationStyle.digital_cartoon:
        return 'modern digital cartoon, clean vector lines, friendly faces';
      case IllustrationStyle.traditional_art:
        return 'traditional African art, geometric kanga and kitenge motifs, '
            'earth pigments';
      case IllustrationStyle.realistic:
        return 'photo-realistic, natural warm lighting, high detail';
      case IllustrationStyle.pencil_sketch:
        return 'hand-drawn pencil and charcoal sketch, cross hatching';
      case IllustrationStyle.collage:
        return 'mixed media collage, textured paper cutouts, fabric offcuts';
      case IllustrationStyle.pop_art:
        return 'bold African pop art, high saturation, halftone dots';
      case IllustrationStyle.storybook_classic:
        return 'classic golden-age storybook illustration, subtle grain, '
            'gentle shading';
    }
  }
}

// ---------------------------------------------------------------------------
// INTERACTIVITY
// ---------------------------------------------------------------------------

/// Aina za hotspot zinazowekwa juu ya picha.
enum HotspotType {
  character_speak('Mhusika Anena', 'Character speaks'),
  sound_effect('Sauti', 'Sound effect'),
  animation('Mchoro', 'Animation'),
  info_popup('Maelezo', 'Info popup'),
  mini_game('Mchezo Mdogo', 'Mini game'),
  story_choice('Chaguo la Hadithi', 'Story choice');

  const HotspotType(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;
}

/// Miundo (layouts) ya ukurasa wa hadithi.
enum PageLayout {
  fullIllustrationTextBottom,
  fullIllustrationTextOverlay,
  splitLeftImageRightText,
  splitTopImageBottomText,
  textOnly,
  illustrationOnly,
  panoramic,
}

// ---------------------------------------------------------------------------
// WATUMIAJI / MALIPO
// ---------------------------------------------------------------------------

enum UserRole {
  reader('Msomaji', 'Reader'),
  creator('Mwandishi', 'Creator'),
  parent('Mzazi', 'Parent'),
  admin('Msimamizi', 'Admin');

  const UserRole(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;
}

/// Ngazi za usajili: bure = Free, msingi = Basic, vip = Premium,
/// familia = Family.
enum PlanTier {
  bure('Bure', 'Free'),
  msingi('Msingi', 'Basic'),
  vip('VIP', 'Premium'),
  familia('Familia', 'Family');

  const PlanTier(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;
}

enum BillingCycle {
  monthly('kwa mwezi', 'monthly'),
  quarterly('kwa robo mwaka', 'quarterly'),
  yearly('kwa mwaka', 'yearly');

  const BillingCycle(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;
}

/// Watoa huduma za malipo Tanzania.
///
/// Kila provider ina jina kwa Kiswahili na Kiingereza (kanuni #4: strings zote
/// zinazomfikia mtumiaji ziwe katika lugha zote mbili) pamoja na `providerCode`
/// inayotumwa kwa backend (`vodacom`, `tigo`, `airtel`, `halotel`, `card`).
enum PaymentProvider {
  mpesa('M-Pesa', 'M-Pesa', 'vodacom'),
  tigoPesa('Tigo Pesa', 'Tigo Pesa', 'tigo'),
  airtelMoney('Airtel Money', 'Airtel Money', 'airtel'),
  halopesa('Halopesa', 'Halopesa', 'halotel'),
  card('Kadi ya Benki', 'Bank Card', 'card');

  const PaymentProvider(this.labelSw, this.labelEn, this.providerCode);

  /// Jina la provider kwa Kiswahili (lugha ya msingi).
  final String labelSw;

  /// Jina la provider kwa Kiingereza.
  final String labelEn;

  /// Code inayotumwa kwa backend API.
  final String providerCode;

  /// Provider ya mobile money (SI kadi ya benki).
  bool get isMobileMoney => this != PaymentProvider.card;
}

enum PaymentStatus {
  pending('Inasubiri', 'Pending'),
  processing('Inafanyika', 'Processing'),
  completed('Imekamilika', 'Completed'),
  failed('Imeshindwa', 'Failed'),
  cancelled('Imesitishwa', 'Cancelled');

  const PaymentStatus(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;
}

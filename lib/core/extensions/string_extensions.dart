/// Nyongeza (extensions) za `String` zinazotumika kote kwenye Hadithi Studio.
///
/// Kila kitu hapa ni `extension`, hivyo tunaweza kuita
/// `'karibu'.capitalised` popote bila kuunda class mpya au kuimport kitu
/// zaidi ya faili hili. Kwa mantiki ya Kiswahili (digraph, hesabu ya maneno)
/// tunategemea [SwahiliTextUtils] ili sheria zibaki mahali pamoja.
library;

import '../utils/text_utils.dart';

extension StringX on String {
  // ---------------------------------------------------------------------------
  // Ukaguzi wa msingi
  // ---------------------------------------------------------------------------

  /// `true` kama maandishi ni tupu au yana nafasi tupu pekee.
  ///
  /// Hutumika kwenye `validator` za fomu badala ya `isEmpty`, kwa sababu
  /// mtumiaji anaweza kuandika space moja na fomu isingeona kosa.
  bool get isBlank => trim().isEmpty;

  /// Kinyume cha [isBlank].
  bool get isNotBlank => !isBlank;

  /// Rudisha `null` kama maandishi ni tupu — rahisi kwa kuandika JSON.
  String? get nullIfBlank => isBlank ? null : this;

  /// Rudisha `this` kama si tupu, la sivyo [fallback].
  String orIfBlank(String fallback) => isBlank ? fallback : this;

  // ---------------------------------------------------------------------------
  // Herufi kubwa / ndogo
  // ---------------------------------------------------------------------------

  /// Herufi ya kwanza kuwa kubwa, zilizobaki zikibaki kama zilivyo.
  ///
  /// Tunatumia hii badala ya `toTitleCase` kwa majina ya Kiswahili kama
  /// "Neema" au "dAR" (mtumiaji aliyeandika vibaya).
  String get capitalised {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Kila neno kuanza kwa herufi kubwa.
  ///
  /// Hutumika kwa vichwa vya hadithi: `"hadithi ya juma"` →
  /// `"Hadithi Ya Juma"`.
  String get titleCased => split(' ').map((w) => w.capitalised).join(' ');

  /// Herufi zote kuwa ndogo — jina la kawaida kwa slug.
  String get slugified => SwahiliTextUtils.normalise(this)
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-');

  // ---------------------------------------------------------------------------
  // Kiswahili
  // ---------------------------------------------------------------------------

  /// Hesabu ya maneno kwa kuzingatia digraph za Kiswahili.
  int get wordCount => SwahiliTextUtils.wordCount(this);

  /// Makadirio ya sekunde za kusoma kwa kasi ya [wordsPerMinute].
  int readingSecondsAt(int wordsPerMinute) =>
      SwahiliTextUtils.estimateReadingSeconds(this, wordsPerMinute);

  /// Kukata maandishi bila kuvunja neno.
  String truncated(int maxChars, {String ellipsis = '…'}) =>
      SwahiliTextUtils.truncate(this, maxChars, ellipsis: ellipsis);

  /// Umbo la kutafuta (digraph zimekunjwa) — kwa utafutaji wa ndani.
  String get searchFolded => SwahiliTextUtils.foldForSearch(this);

  /// `true` kama maandishi haya yana hoja ya utafutaji [query].
  bool matchesQuery(String query) => SwahiliTextUtils.matches(this, query);

  // ---------------------------------------------------------------------------
  // Kubadilisha aina (parsing)
  // ---------------------------------------------------------------------------

  /// Kugeuza kuwa `int` bila kurusha exception.
  int? get tryInt => int.tryParse(trim());

  /// Kugeuza kuwa `double` bila kurusha exception.
  double? get tryDouble => double.tryParse(trim());

  /// Kugeuza kuwa `bool` — inakubali `true/false`, `1/0`, `ndiyo/hapana`.
  ///
  /// Fomu za Kiswahili hutumia `ndiyo`/`hapana`, na API zetu zinaweza
  /// kurudisha `1`/`0`, hivyo tunashughulikia zote.
  bool? get tryBool {
    switch (SwahiliTextUtils.normalise(this)) {
      case 'true':
      case '1':
      case 'yes':
      case 'ndiyo':
      case 'ndio':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'hapana':
        return false;
      default:
        return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Muonekano
  // ---------------------------------------------------------------------------

  /// Herufi za mwanzo za majina (kwa avatar): `"Baraka Mwita"` → `"BM"`.
  String initialsOf([int max = 2]) => SwahiliTextUtils.initials(this, max: max);

  /// Nambari ya simu iliyofichwa: `"+255712345678"` → `"****5678"`.
  String get maskedPhone => SwahiliTextUtils.maskPhone(this);

  /// Barua pepe iliyofichwa: `"neema@x.com"` → `"n••••@x.com"`.
  String get maskedEmail => SwahiliTextUtils.maskEmail(this);
}

extension NullableStringX on String? {
  /// `true` kama ni `null` au tupu.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// `true` kama si `null` na si tupu.
  bool get isNotNullOrBlank => !isNullOrBlank;

  /// Rudisha maandishi kama yapo, la sivyo `''`.
  String get orEmpty => this ?? '';

  /// Rudisha maandishi kama yapo, la sivyo [fallback].
  String orDefault(String fallback) => isNullOrBlank ? fallback : this!;
}

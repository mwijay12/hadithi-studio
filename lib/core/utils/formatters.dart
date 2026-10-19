/// FORMATTERS — kubadilisha namba, muda na maandishi kuwa umbo la kuonyesha.
///
/// Kwa nini faili hili lipo: kila skrini ya Hadithi Studio huonyesha namba —
/// muda wa kusoma, `pageCount`, idadi ya maneno, `rating`, ukubwa wa cache.
/// Kuandika `toString()` kila mahali kunatoa "12000" badala ya "12,000" na
/// "1.0" badala ya "1" — jambo linaloonekana vibaya kwa mtumiaji wa Tanzania
/// anayelipa TZS 12,000.
///
/// **Kanuni ya kutokurudia (delegate, don't duplicate):**
/// faili hili halitekelezi mantiki ya Kiswahili yenyewe. Kinachohitaji
/// kufahamu digraph, apostrophe au maneno hupitishwa kwa [SwahiliTextUtils];
/// namba za simu hupitishwa kwa [TanzaniaPhoneUtils]; na namba za biashara
/// hutoka [AppConstants]. Hapa tunabadilisha **umbo** pekee.
///
/// Mwongozo kwa UI: strings za lugha mbili hapa ni **fallback** kwa maeneo
/// yasiyo na `BuildContext` (notifications, logs, crash reports). Kwenye
/// widget, tumia `context.l10n` badala yake ili tafsiri zibaki kwenye ARB.
library;

import '../../config/constants/app_constants.dart';
import '../enums/app_enums.dart';
import 'phone_utils.dart';
import 'text_utils.dart';

/// Hufomati namba, muda na maandishi kwa kuonyesha kwa mtumiaji.
abstract final class Formatters {
  // ---------------------------------------------------------------------------
  // Namba
  // ---------------------------------------------------------------------------

  /// Namba kamili yenye vitenganishi vya maelfu: `12000` → `12,000`.
  ///
  /// Tanzania hutumia koma kama kitenganishi (mfano `TZS 12,000`), si nafasi
  /// wala nukta kama baadhi ya nchi za Ulaya.
  static String integer(num value) {
    final isNegative = value < 0;
    final whole = value.abs().truncate().toString();
    return '${isNegative ? '-' : ''}${_groupDigits(whole)}';
  }

  /// Namba yenye desimali: `4.5` → `4.5`, `1234.5` → `1,234.5`.
  ///
  /// `decimals` hufunga idadi ya tarakimu baada ya nukta. Hii hutumika kwa
  /// `rating` (nyota 1 desimali) na kwa bei zenye senti.
  static String decimal(double value, {int decimals = 1}) {
    final safeDecimals = decimals < 0 ? 0 : decimals;
    final isNegative = value < 0;
    final fixed = value.abs().toStringAsFixed(safeDecimals);
    final parts = fixed.split('.');
    final whole = _groupDigits(parts.first);
    final result = parts.length > 1 ? '$whole.${parts[1]}' : whole;
    return '${isNegative ? '-' : ''}$result';
  }

  /// Kiwango (rating) kwa nyota moja ya desimali: `4.0` → `4.0`.
  ///
  /// Hatumwonyeshi mtumiaji "4" pekee kwa sababu alama za nyota zinaonyesha
  /// `4.5` — kuacha desimali kunafanya safu ya nyota isilingane kwa macho.
  static String rating(double value) => decimal(value, decimals: 1);

  /// Asilimia kutoka uwiano: `0.7` → `70%`.
  ///
  /// [ratio] ni uwiano kati ya 0 na 1 (kama `creatorRevenueShare` = 0.70).
  /// Tumia [withSign] kuonyesha `+` kwa ongezeko (mfano ukuaji wa wasomaji).
  static String percent(
    double ratio, {
    int decimals = 0,
    bool withSign = false,
  }) {
    final percentage = ratio * 100;
    final text = '${decimal(percentage, decimals: decimals)}%';
    return withSign && percentage > 0 ? '+$text' : text;
  }

  /// Namba kwa ufupi — hutumika kwenye kadi ndogo za KPIs na analytics.
  ///
  /// `12000` → `12K`, `5000000` → `5M`, `1200000000` → `1.2B`.
  ///
  /// Kwa nini: kadi ya "Wasomaji" kwenye dashibodi ya mwandishi haina nafasi
  /// ya "1,234,567", na spec §15 hutumia umbo hili hasa ("TZS 5M").
  static String compact(num value) {
    final magnitude = value.abs();
    final sign = value < 0 ? '-' : '';
    if (magnitude < 1000) return '$sign${integer(magnitude)}';
    if (magnitude < 1000000) return '$sign${_trimZero(magnitude / 1000)}K';
    if (magnitude < 1000000000) {
      return '$sign${_trimZero(magnitude / 1000000)}M';
    }
    return '$sign${_trimZero(magnitude / 1000000000)}B';
  }

  /// Ukubwa wa faili kwa vitengo vya kibaiti (1 KB = baiti 1024).
  ///
  /// Hutumika kwenye `storage_settings_page.dart` ("Umepakua 45 MB kati ya
  /// 120 MB") na kwenye maonyesho ya download progress.
  static String fileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';

    const units = <String>['KB', 'MB', 'GB', 'TB'];
    var value = bytes / 1024;
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }
    return '${_trimZero(value)} ${units[unitIndex]}';
  }

  /// Matumizi ya nafasi: `45 MB / 120 MB`.
  static String storageUsage({required int usedMb, required int totalMb}) =>
      '${integer(usedMb)} MB / ${integer(totalMb)} MB';

  // ---------------------------------------------------------------------------
  // Muda
  // ---------------------------------------------------------------------------

  /// Muda kwa umbo la kicheza sauti: `1:05`, `12:30`, `1:02:03`.
  ///
  /// Sekunde na dakika hupambwa kwa `0` ili urefu usibadilike kila sekunde
  /// (kama ilivyo kawaida kwenye player yoyote).
  static String duration(Duration value) {
    final totalSeconds = value.isNegative ? 0 : value.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final paddedSeconds = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$paddedSeconds';
    }
    return '$minutes:$paddedSeconds';
  }

  /// Kuhesabu kushuka (countdown) — hudhibitishwa kwa sifuri.
  ///
  /// Hutumika kwenye skrini ya OTP: `otpValidity` ni dakika 10, hivyo
  /// mtumiaji huona `9:58`, `9:57`, ... Hatuonyeshi `-0:01` hata mara moja.
  static String countdown(Duration remaining) => duration(remaining);

  // ---------------------------------------------------------------------------
  // Maandishi ya hadithi (Kiswahili)
  // ---------------------------------------------------------------------------

  /// Makadirio ya dakika za kusoma kwa maandishi (hesabu kwenda juu).
  ///
  /// Hatumwonyeshi mtumiaji "dakika 0" kwa hadithi fupi — tunarudisha `0`
  /// hapa ili mwitaji aamue maneno yake ("Chini ya dakika 1").
  static int readingMinutes(String text) {
    final seconds = SwahiliTextUtils.estimateReadingSeconds(
      text,
      AppConstants.wordsPerMinute,
    );
    if (seconds <= 0) return 0;
    return (seconds / 60).ceil();
  }

  /// Muda wa kusoma kwa maneno: `dakika 3` / `3 min`.
  static String readingTime(String text, {bool swahili = true}) {
    final minutes = readingMinutes(text);
    if (minutes <= 0) {
      return swahili ? 'Chini ya dakika 1' : 'Less than 1 min';
    }
    return swahili ? 'dakika $minutes' : '$minutes min';
  }

  /// Hesabu ya maneno kwa Kiswahili (digraph zinahesabiwa sawa).
  ///
  /// Tunatumia [SwahiliTextUtils.wordCount] ili "ng'ombe" ihesabiwe kama neno
  /// **moja** — `text.split(' ').length` ingetupa idadi ya uongo.
  static String words(int count, {bool swahili = true}) =>
      swahili ? 'maneno ${integer(count)}' : '${integer(count)} words';

  /// Naga la ukurasa: `3 / 10`.
  ///
  /// Hatumtumii "of" wala "/" kwa maneno kwa sababu sehemu hii huonekana
  /// ndani ya `page_number_indicator.dart` yenye nafasi ndogo sana.
  static String pageFraction(int current, int total) {
    final safeCurrent = current < 1 ? 1 : current;
    final safeTotal = total < 0 ? 0 : total;
    return '$safeCurrent / $safeTotal';
  }

  /// Kukata jina la hadithi bila kuvunja neno.
  ///
  /// `maxChars` hutoka `AppConstants.maxStoryTitleLength` (80) kwa fomu, na
  /// hutumika thamani ndogo kwenye kadi.
  static String storyTitle(
    String title, {
    int maxChars = AppConstants.maxStoryTitleLength,
  }) =>
      SwahiliTextUtils.truncate(title, maxChars);

  /// Muhtasari (synopsis) uliokatwa kwa kadi ya hadithi.
  static String synopsis(
    String text, {
    int maxChars = 120,
  }) =>
      SwahiliTextUtils.truncate(text, maxChars);

  /// Herufi za mwanzo za jina kwa avatar: `"Baraka Mwita"` → `"BM"`.
  static String initials(String name, {int max = 2}) =>
      SwahiliTextUtils.initials(name, max: max);

  // ---------------------------------------------------------------------------
  // Namba za simu (Tanzania)
  // ---------------------------------------------------------------------------

  /// Namba ya kupiga: `0712 345 678`.
  ///
  /// Hii ni umbo ambalo Watanzania wanaijua. Kama namba haisomeki, tunarudisha
  /// maandishi kama yalivyo ili mtumiaji aone alichoandika (na validator
  /// ndiyo inayoripoti kosa).
  static String phone(String? raw) =>
      TanzaniaPhoneUtils.formatNational(raw ?? '');

  /// Namba ya kimataifa: `+255 712 345 678`.
  static String phoneInternational(String? raw) =>
      TanzaniaPhoneUtils.formatInternational(raw ?? '');

  /// Namba iliyofichwa kwa kuonyesha tarakimu nne za mwisho pekee.
  ///
  /// Sheria ya usalama (spec §11): namba kamili haionyeshwi kwenye skrini za
  /// umma wala kwenye logs.
  static String phoneMasked(String? raw) => TanzaniaPhoneUtils.mask(raw ?? '');

  // ---------------------------------------------------------------------------
  // Lebo za enums (delegate — si kurudia)
  // ---------------------------------------------------------------------------

  /// Lebo ya kundi la hadithi kwa lugha iliyochaguliwa.
  ///
  /// Tunatumia `StoryCategory.labelSw` / `labelEn` badala ya kuandika
  /// "Hadithi za Kiswahili" hapa — enum ndiyo chanzo kimoja cha ukweli.
  static String category(StoryCategory value, {bool swahili = true}) =>
      swahili ? value.labelSw : value.labelEn;

  /// Lebo ya kiwango cha kusoma.
  static String readingLevel(ReadingLevel value, {bool swahili = true}) =>
      swahili ? value.labelSw : value.labelEn;

  /// Lebo ya kundi la umri.
  static String ageGroup(AgeGroup value, {bool swahili = true}) =>
      swahili ? value.labelSw : value.labelEn;

  // ---------------------------------------------------------------------------
  // Helpers za ndani
  // ---------------------------------------------------------------------------

  /// Kuingiza koma kila tarakimu tatu kutoka kulia: `1234567` → `1,234,567`.
  ///
  /// Tunaitekeleza kwa mkono badala ya `intl`'s `NumberFormat` kwa sababu
  /// `NumberFormat` yenye locale inahitaji `initializeDateFormatting`-style
  /// setup ya wakati wa runtime — hatua ambayo ingeongeza risk kwenye simu
  /// za 2GB RAM na ingepandisha ukubwa wa APK bila faida (tarakimu zetu ni
  /// za Kiarabu daima).
  static String _groupDigits(String digits) {
    if (digits.length <= 3) return digits;
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  /// Kuondoa `.0` ya uongo: `12.0` → `12`, lakini `12.5` → `12.5`.
  static String _trimZero(double value) {
    final text = value.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }
}

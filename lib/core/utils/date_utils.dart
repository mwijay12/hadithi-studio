/// DATE & TIME UTILS — tarehe, muda na muda wa jamaa (relative time).
///
/// Kwa nini faili hili lipo: Hadithi Studio huonyesha tarehe na muda kila
/// mahali — tarehe ya kuchapishwa kwa hadithi, "Jana" kwenye historia ya
/// kusoma, `streak` ya siku, countdown ya OTP, siku ya malipo ya mwandishi.
///
/// **Kwa nini `AppDateUtils` na si `DateUtils`:** `package:flutter/material.dart`
/// ina class `DateUtils` (kwa `dateOnly`, `monthDelta` n.k.). Kuipa faili hili
/// jina hilo hilo kungeleta mgongano wa jina kwenye kila faili inayoimportiwa
/// na Flutter — hivyo tunaongeza kiambishi `App`.
///
/// **Kwa nini hatutumii `intl`'s `DateFormat` kwa Kiswahili:** `DateFormat`
/// yenye locale `'sw'` inahitaji `initializeDateFormatting('sw')` ya wakati wa
/// runtime, hatua ya async inayoweza kushindwa kimya kimya kwenye simu za
/// bajeti (Tecno/Itel, Android 6) na kutuacha na Kiingereza bila kujua. Majina
/// ya miezi na siku za Kiswahili ni **fixed** — hakuna kuzalishwa kwa wakati
/// wa runtime — hivyo tunayaweka kama `const`. Hii inafanya tarehe zifanye
/// kazi bila mtandao na bila setup.
///
/// Mwongozo kwa UI: strings za lugha mbili hapa ni **fallback**. Kwenye widget
/// yenye `BuildContext`, tumia `context.l10n` ili tafsiri zibaki kwenye ARB —
/// lugha iliyochaguliwa na mtumiaji inaheshimiwa huko.
library;

import '../../config/constants/app_constants.dart';
import 'formatters.dart';

/// Sehemu ya siku inayoamua salamu (asubuhi / mchana / jioni).
///
/// Tunarudisha enum badala ya `String` ili widget ichague tafsiri kutoka ARB
/// (`goodMorning` / `goodAfternoon` / `goodEvening`) badala ya kulazimishwa
/// kutumia maandishi yaliyowekwa hapa.
enum GreetingPeriod { morning, afternoon, evening }

/// Hufomati na kulinganisha tarehe na muda kwa muktadha wa Tanzania.
abstract final class AppDateUtils {
  // ---------------------------------------------------------------------------
  // Majina ya miezi na siku (Kiswahili)
  // ---------------------------------------------------------------------------

  /// Miezi kwa Kiswahili — Januari hadi Desemba.
  static const List<String> monthsSw = <String>[
    'Januari',
    'Februari',
    'Machi',
    'Aprili',
    'Mei',
    'Juni',
    'Julai',
    'Agosti',
    'Septemba',
    'Oktoba',
    'Novemba',
    'Desemba',
  ];

  /// Miezi kwa ufupi kwa Kiswahili — hutumika kwenye chati na chips.
  static const List<String> monthsShortSw = <String>[
    'Jan',
    'Feb',
    'Mac',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Miezi kwa Kiingereza.
  static const List<String> monthsEn = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Miezi kwa ufupi kwa Kiingereza.
  static const List<String> monthsShortEn = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Siku za wiki kwa Kiswahili, kuanzia Jumatatu.
  ///
  /// Orodha hii inalingana na `DateTime.weekday` (Jumatatu = 1 ... Jumapili = 7),
  /// hivyo nafasi ni `weekday - 1`.
  static const List<String> daysSw = <String>[
    'Jumatatu',
    'Jumanne',
    'Jumatano',
    'Alhamisi',
    'Ijumaa',
    'Jumamosi',
    'Jumapili',
  ];

  /// Siku kwa ufupi kwa Kiswahili kwa mfumo wa kitaifa: `J2`, `J3`, ... `J1`.
  ///
  /// Tanzania hutumia mfumo huu (J1 = Jumapili, J2 = Jumatatu ... J7 = Jumamosi)
  /// kwenye kalenda na ratiba za shule. Ni mfupi kuliko "Jumatatu" na unajulikana
  /// kwa kila mtumiaji — muhimu kwenye `streak_calendar.dart` yenye seli ndogo.
  static const List<String> daysShortSw = <String>[
    'J2',
    'J3',
    'J4',
    'J5',
    'J6',
    'J7',
    'J1',
  ];

  /// Siku kwa Kiingereza, kuanzia Jumatatu.
  static const List<String> daysEn = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Siku kwa ufupi kwa Kiingereza.
  static const List<String> daysShortEn = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  // ---------------------------------------------------------------------------
  // Sehemu za tarehe
  // ---------------------------------------------------------------------------

  /// Jina la mwezi (1–12). Hurudisha `''` kama mwezi haupo.
  static String monthName(int month, {bool swahili = true}) {
    if (month < 1 || month > 12) return '';
    return swahili ? monthsSw[month - 1] : monthsEn[month - 1];
  }

  /// Jina la mwezi kwa ufupi (1–12).
  static String monthShort(int month, {bool swahili = true}) {
    if (month < 1 || month > 12) return '';
    return swahili ? monthsShortSw[month - 1] : monthsShortEn[month - 1];
  }

  /// Jina la siku la tarehe iliyotolewa.
  static String dayName(DateTime date, {bool swahili = true}) {
    final index = date.weekday - 1;
    return swahili ? daysSw[index] : daysEn[index];
  }

  /// Jina la siku kwa ufupi (`J2` kwa Kiswahili, `Mon` kwa Kiingereza).
  static String dayShort(DateTime date, {bool swahili = true}) {
    final index = date.weekday - 1;
    return swahili ? daysShortSw[index] : daysShortEn[index];
  }

  // ---------------------------------------------------------------------------
  // Kufomati tarehe
  // ---------------------------------------------------------------------------

  /// Tarehe kwa maneno: `15 Oktoba 2026` / `15 October 2026`.
  ///
  /// Hii ndiyo fomu ya `publishDate` ("Tarehe ya Kuchapishwa") kwenye ukurasa
  /// wa hadithi.
  static String formatDate(DateTime date, {bool swahili = true}) =>
      '${date.day} ${monthName(date.month, swahili: swahili)} ${date.year}';

  /// Tarehe kwa tarakimu: `15/10/2026`.
  ///
  /// Tarehe ya Tanzania huandikwa siku/mwezi/mwaka, si mwezi/siku/mwaka.
  static String formatDateNumeric(DateTime date, {String separator = '/'}) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day$separator$month$separator${date.year}';
  }

  /// Tarehe na saa: `15 Oktoba 2026, 14:30`.
  ///
  /// Tumia hii kwenye historia ya malipo na historia ya kusoma.
  static String formatDateTime(DateTime date, {bool swahili = true}) =>
      '${formatDate(date, swahili: swahili)}, ${formatTime(date)}';

  /// Saa kwa umbo la saa 24: `14:30`.
  ///
  /// Tanzania hutumia saa 24 kwenye miamala na ratiba (M-Pesa, shule), hivyo
  /// hatutumii AM/PM.
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Siku na tarehe: `Jumatatu, 15 Oktoba`.
  ///
  /// Hutumika kama kichwa cha kalenda ya `streak`.
  static String formatDayAndDate(DateTime date, {bool swahili = true}) =>
      '${dayName(date, swahili: swahili)}, ${date.day} '
      '${monthName(date.month, swahili: swahili)}';

  /// Tarehe kwa umbo la ISO 8601 (`2026-10-15`) — kwa API na funguo za Hive.
  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Muda kamili kwa ISO 8601 (`2026-10-15T14:30:00.000`) — kwa kuhifadhi Hive.
  static String isoDateTime(DateTime date) =>
      '${isoDate(date)}T${formatTime(date)}:'
      '${date.second.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------------------
  // Kulinganisha siku
  // ---------------------------------------------------------------------------

  /// `true` kama tarehe mbili ziko siku moja (bila kujali saa).
  ///
  /// Hii ndiyo injini ya `readingStreak`: kusoma leo tena hakupaswi kuongeza
  /// `streak` mara ya pili.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// `true` kama tarehe ni leo.
  static bool isToday(DateTime date, {DateTime? now}) =>
      isSameDay(date, now ?? DateTime.now());

  /// `true` kama tarehe ni jana.
  static bool isYesterday(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return isSameDay(date, reference.subtract(const Duration(days: 1)));
  }

  /// Mwanzo wa siku (00:00:00).
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Mwisho wa siku (23:59:59.999) — kwa masafa ya utafutaji (queries).
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  /// Idadi ya siku kati ya tarehe mbili (chanya kama [to] iko baadaye).
  static int daysBetween(DateTime from, DateTime to) =>
      startOfDay(to).difference(startOfDay(from)).inDays;

  /// `true` kama [date] iko ndani ya siku [days] zilizopita.
  ///
  /// Hutumika kwa "Hadithi zilizopakuliwa hivi karibuni" na kwa `streak`.
  static bool isWithinLastDays(
    DateTime date, {
    required int days,
    DateTime? now,
  }) {
    final difference = daysBetween(date, now ?? DateTime.now());
    return difference >= 0 && difference < days;
  }

  // ---------------------------------------------------------------------------
  // Salamu (greetings)
  // ---------------------------------------------------------------------------

  /// Sehemu ya siku kwa salamu: asubuhi, mchana au jioni.
  ///
  /// Mipaka inafuata mazoea ya Tanzania: asubuhi hadi saa 12, mchana hadi
  /// saa 18, jioni baada ya hapo.
  static GreetingPeriod greetingPeriod(DateTime now) {
    if (now.hour < 12) return GreetingPeriod.morning;
    if (now.hour < 18) return GreetingPeriod.afternoon;
    return GreetingPeriod.evening;
  }

  /// Salamu kwa maneno: `Habari ya Asubuhi!` / `Good morning!`.
  static String greeting(DateTime now, {bool swahili = true}) {
    switch (greetingPeriod(now)) {
      case GreetingPeriod.morning:
        return swahili ? 'Habari ya Asubuhi!' : 'Good morning!';
      case GreetingPeriod.afternoon:
        return swahili ? 'Habari ya Mchana!' : 'Good afternoon!';
      case GreetingPeriod.evening:
        return swahili ? 'Habari ya Jioni!' : 'Good evening!';
    }
  }

  // ---------------------------------------------------------------------------
  // Muda wa jamaa (relative time)
  // ---------------------------------------------------------------------------

  /// "Yaliyopita" kwa Kiswahili: `Jana`, `Dakika 5 zilizopita`, `Wiki 2 zilizopita`.
  ///
  /// Kwa nini hapa na si kwenye ARB: ARB haina funguo za muda wa jamaa
  /// (tulizikagua — `leo`/`jana`/`ago` hazipo), na kuziongeza kungehitaji
  /// kuandika funguo **mbili** kwa mpangilio sawa ili kanuni ya parity
  /// isivunjike. Kwa kuwa thamani hizi ni fupi na za hisabati, tunazibakiza
  /// hapa kama fallback, kama tulivyofanya kwenye `Validators`.
  static String relativeSw(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final seconds = reference.difference(date).inSeconds;

    if (seconds < 0) return formatDate(date);
    if (seconds < 60) return 'Sasa hivi';

    final minutes = seconds ~/ 60;
    if (minutes < 60) return 'Dakika $minutes zilizopita';

    final hours = minutes ~/ 60;
    if (hours < 24) return 'Saa $hours zilizopita';

    final days = daysBetween(date, reference);
    if (days == 0) return 'Leo';
    if (days == 1) return 'Jana';
    if (days < 7) return 'Siku $days zilizopita';

    final weeks = days ~/ 7;
    if (days < 30) return 'Wiki $weeks zilizopita';

    final months = days ~/ 30;
    if (days < 365) return 'Mwezi $months uliopita';

    final years = days ~/ 365;
    return 'Mwaka $years uliopita';
  }

  /// "Ilivyopita" kwa Kiingereza: `Yesterday`, `5 min ago`, `2 weeks ago`.
  static String relativeEn(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final seconds = reference.difference(date).inSeconds;

    if (seconds < 0) return formatDate(date, swahili: false);
    if (seconds < 60) return 'Just now';

    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min ago';

    final hours = minutes ~/ 60;
    if (hours < 24) return '$hours hr ago';

    final days = daysBetween(date, reference);
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';

    final weeks = days ~/ 7;
    if (days < 30) return '$weeks weeks ago';

    final months = days ~/ 30;
    if (days < 365) return '$months months ago';

    final years = days ~/ 365;
    return '$years years ago';
  }

  /// Muda wa jamaa kwa lugha iliyochaguliwa.
  static String relative(
    DateTime date, {
    bool swahili = true,
    DateTime? now,
  }) =>
      swahili
          ? relativeSw(date, now: now)
          : relativeEn(date, now: now);

  // ---------------------------------------------------------------------------
  // Muda wa kibiashara (OTP, malipo, retry)
  // ---------------------------------------------------------------------------

  /// Muda ambao OTP iliyotumwa [sentAt] inaisha.
  static DateTime otpExpiryFrom(DateTime sentAt) =>
      sentAt.add(AppConstants.otpValidity);

  /// `true` kama OTP iliyotumwa [sentAt] imeisha muda wake.
  ///
  /// Inatumia `AppConstants.otpValidity` (dakika 10) ili sera ibadilike
  /// mahali kimoja tu.
  static bool isOtpExpired(DateTime sentAt, {DateTime? now}) =>
      (now ?? DateTime.now()).isAfter(otpExpiryFrom(sentAt));

  /// Sekunde zilizosalia za OTP (0 kama imeisha).
  static Duration otpRemaining(DateTime sentAt, {DateTime? now}) {
    final remaining =
        otpExpiryFrom(sentAt).difference(now ?? DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Countdown ya OTP kwa umbo la `9:58` — hudhibitishwa kwa sifuri.
  static String otpCountdown(DateTime sentAt, {DateTime? now}) =>
      Formatters.countdown(otpRemaining(sentAt, now: now));

  /// Tarehe ya malipo ya mwandishi inayofuata baada ya [from].
  ///
  /// Waandishi hulipwa siku ya `AppConstants.payoutDayOfMonth` (28) ya kila
  /// mwezi. Kama [from] ipo baada ya siku hiyo, tunarudi mwezi unaofuata —
  /// hivyo matokeo huwa **daima** ya baadaye.
  static DateTime nextPayoutDate(DateTime from) {
    const day = AppConstants.payoutDayOfMonth;
    final thisMonth = DateTime(from.year, from.month, day);
    if (from.isBefore(thisMonth) || isSameDay(from, thisMonth)) {
      return thisMonth;
    }
    // `DateTime` hushughulikia mwezi wa 13 yenyewe (Desemba → Januari).
    return DateTime(from.year, from.month + 1, day);
  }

  /// Siku zilizosalia hadi malipo yanayofuata.
  static int daysUntilPayout(DateTime from, {DateTime? now}) =>
      daysBetween(now ?? DateTime.now(), nextPayoutDate(from));

  /// Muda wa kusubiri kabla ya jaribio la mtandao la namba [attempt].
  ///
  /// Exponential backoff: 2s, 4s, 8s, 16s, kisha kikomo cha 30s. Kikomo ni
  /// muhimu kwenye mtandao wa Tanzania: bila kikomo, jaribio la 10 lingesubiri
  /// dakika 34 na mtumiaji angeona app "imekwama".
  static Duration retryDelay(
    int attempt, {
    Duration cap = const Duration(seconds: 30),
  }) {
    final safeAttempt = attempt < 0 ? 0 : attempt;
    final multiplier = 1 << safeAttempt;
    final delay = AppConstants.baseRetryDelay * multiplier;
    return delay > cap ? cap : delay;
  }

  // ---------------------------------------------------------------------------
  // Rejeleo la muda uliowekwa (single source of truth = AppConstants)
  // ---------------------------------------------------------------------------

  /// Muda ambao splash inaonyeshwa kabla ya kuamua pa kwenda.
  ///
  /// KUMBUKA: `AppSpacing.splash` (spacing.dart) ina thamani ile ile (2200 ms)
  /// kwa **animation** ya nembo. Kwa kuamua lini kuondoka kwenye splash, hii
  /// (`AppConstants.splashMinimumDuration`) ndiyo yenye mamlaka — kwa hivyo
  /// hakuna skrini inayopaswa kuandika `2200` yenyewe.
  static Duration get splashMinimumDuration => AppConstants.splashMinimumDuration;

  /// Muda wa kuchelewesha utafutaji (search debounce).
  static Duration get searchDebounce => AppConstants.searchDebounce;

  /// Muda ambao ujumbe (snackbar) hukaa kwenye skrini.
  static Duration get snackBarDuration => AppConstants.snackBarDuration;

  /// Muda wa auto-save ya rasimu.
  static Duration get draftAutoSaveInterval => AppConstants.draftAutoSaveInterval;

  /// Muda wa kusubiri kwa jaribio la kwanza la mtandao.
  static Duration get baseRetryDelay => AppConstants.baseRetryDelay;

  /// Siku ya malipo ya waandishi kila mwezi.
  static int get payoutDayOfMonth => AppConstants.payoutDayOfMonth;
}

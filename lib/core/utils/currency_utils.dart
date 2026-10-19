/// CURRENCY UTILS — fedha za Tanzania (TZS).
///
/// Kwa nini faili hili lipo: Hadithi Studio ni app ya biashara. Ina bei za
/// vifurushi (BURE / MSINGI / VIP / FAMILIA), bei ya hadithi inayouzwa,
/// mapato ya mwandishi, na kiwango cha chini cha kutoa fedha. Namba hizo
/// zinatoka [AppConstants] (chanzo kimoja cha ukweli), lakini **umbo** la
/// kuonyesha linahitaji sheria za Tanzania — na ndiyo kazi ya faili hili.
///
/// SHERIA ZA TANZANIA ZILIZOWEKWA HAPA:
///
/// 1. TZS haitumii senti kwa maisha ya kila siku. Sarafu ndogo kabisa
///    inayotumika ni shilingi 1, hivyo **hatuonyeshi desimali kabisa** kwenye
///    bei. Kwa hiyo `Formatters.decimal` haitumiwi kwa fedha; tunatumia
///    `Formatters.integer` (koma kama kitenganishi cha maelfu).
/// 2. Koma ni kitenganishi cha maelfu: `TZS 12,000` — si `TZS 12.000`
///    (Ujerumani) wala `TZS 12 000` (Ufaransa).
/// 3. Kifurushi huonyeshwa kwa mwezi (`perMonth` = "kwa mwezi"). Bei ya robo
///    mwaka/mwaka huonyeshwa kama **jumla ya kulipa kwa kipindi kizima**
///    pamoja na punguzo, si bei ya mwezi pekee — mtanzania anayeuliza "robo
///    mwaka ni shilingi ngapi?" anataka jumla ya kulipa siku hiyo.
///
/// **Kanuni ya kutokurudia (delegate, don't duplicate):** punguzo
/// (`quarterlyDiscount`, `yearlyDiscount`), mgawanyo wa mapato
/// (`creatorRevenueShare`, `platformRevenueShare`), bei zote na mipaka ya
/// kutoa fedha hutoka [AppConstants]. Faili hili halina namba ya biashara
/// iliyoandikwa kwa mkono — kubadilisha sera ya bei ni mahali kimoja.
///
/// Mwongozo kwa UI: lebo za hapa ni **fallback** kwa maeneo yasiyo na
/// `BuildContext` (notifications, logs, crash reports). Kwenye widget, tumia
/// `context.l10n` (`price`, `free`, `perMonth`, `subscribe`) ili tafsiri
/// zibaki kwenye ARB.
library;

import '../../config/constants/app_constants.dart';
import '../enums/app_enums.dart';
import 'formatters.dart';

/// Hufomati na kukokotoa fedha za Tanzania (TZS).
abstract final class TanzaniaCurrencyUtils {
  // ---------------------------------------------------------------------------
  // Msimbo na alama
  // ---------------------------------------------------------------------------

  /// Msimbo wa sarafu: `TZS`.
  static const String code = AppConstants.currencyCode;

  /// Alama inayoonyeshwa mbele ya kiasi: `TZS`.
  ///
  /// Tunatumia `TZS` (si `Tsh` wala `/=`) kwa sababu benki, M-Pesa na
  /// risiti za Tigo Pesa zote hutumia msimbo huo — mtumiaji anautambua.
  static const String symbol = AppConstants.currencySymbol;

  // ---------------------------------------------------------------------------
  // Bei za vifurushi
  // ---------------------------------------------------------------------------

  /// Bei ya mwezi mmoja kwa kifurushi [tier], bila punguzo.
  static int monthlyPriceFor(PlanTier tier) {
    switch (tier) {
      case PlanTier.bure:
        return AppConstants.priceBureTZS;
      case PlanTier.msingi:
        return AppConstants.priceMsingiTZS;
      case PlanTier.vip:
        return AppConstants.priceVipTZS;
      case PlanTier.familia:
        return AppConstants.priceFamiliaTZS;
    }
  }

  /// Miezi iliyomo kwenye mzunguko wa malipo [cycle].
  static int monthsIn(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return 1;
      case BillingCycle.quarterly:
        return 3;
      case BillingCycle.yearly:
        return 12;
    }
  }

  /// Punguzo la mzunguko [cycle] kama uwiano (0.0 – 1.0).
  static double discountFor(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return 0;
      case BillingCycle.quarterly:
        return AppConstants.quarterlyDiscount;
      case BillingCycle.yearly:
        return AppConstants.yearlyDiscount;
    }
  }

  /// Jumla **kabla** ya punguzo kwa mzunguko mzima.
  ///
  /// Mfano: VIP kwa mwaka = `12,000 x 12` = TZS 144,000.
  static int grossFor(PlanTier tier, BillingCycle cycle) =>
      monthlyPriceFor(tier) * monthsIn(cycle);

  /// Jumla ya kulipa kwa mzunguko mzima **baada** ya punguzo.
  ///
  /// Tunazungusha kwa `round()` kwa sababu TZS haitumii senti — matokeo
  /// yanayomalizika kwa `.5` yasimuifikie mtumiaji kama `11,999.5`.
  ///
  /// Mfano: VIP kwa mwaka = 144,000 x 0.80 = TZS 115,200.
  static int totalFor(PlanTier tier, BillingCycle cycle) {
    final gross = grossFor(tier, cycle);
    if (gross <= 0) return 0;
    final discounted = gross * (1 - discountFor(cycle));
    return discounted.round();
  }

  /// Kiasi kinachookolewa kwa kulipa mzunguko mzima badala ya mwezi kwa mwezi.
  static int savingsFor(PlanTier tier, BillingCycle cycle) =>
      grossFor(tier, cycle) - totalFor(tier, cycle);

  /// Bei ya mwezi mmoja ikigawanywa kutoka jumla ya mzunguko mzima.
  ///
  /// Hii hutumika kwenye `plan_card.dart` kuonyesha "sawa na TZS 4,000 kwa
  /// mwezi" — ndiyo hoja inayouza mzunguko mrefu kwa wazazi.
  /// Mfano: MSINGI kwa mwaka = 48,000 / 12 = TZS 4,000.
  static int monthlyEquivalentFor(PlanTier tier, BillingCycle cycle) {
    final months = monthsIn(cycle);
    if (months <= 1) return monthlyPriceFor(tier);
    return (totalFor(tier, cycle) / months).round();
  }

  /// `true` kama kifurushi hiki ni cha bure.
  static bool isFreeTier(PlanTier tier) => monthlyPriceFor(tier) <= 0;

  // ---------------------------------------------------------------------------
  // Kuonyesha kiasi
  // ---------------------------------------------------------------------------

  /// Kiasi kwa umbo la Tanzania: `12000` → `TZS 12,000`.
  static String format(int amountTZS, {bool withSymbol = true}) {
    final digits = Formatters.integer(amountTZS);
    return withSymbol ? '$symbol $digits' : digits;
  }

  /// Kiasi kwa ufupi kwa kadi za KPI: `12000` → `TZS 12K`.
  ///
  /// Spec §15 hutumia umbo hili hasa ("TZS 5M monthly revenue") — kadi ya
  /// dashibodi ya mwandishi haina nafasi ya "1,234,567".
  static String formatCompact(int amountTZS, {bool withSymbol = true}) {
    final short = Formatters.compact(amountTZS);
    return withSymbol ? '$symbol $short' : short;
  }

  /// Bei ya hadithi: `0` → `Bure` / `Free`, vinginevyo `TZS 500`.
  ///
  /// Hatuonyeshi `TZS 0` kwa hadithi ya bure — neno "Bure" linaeleweka mara
  /// moja na linahifadhi nafasi kwenye kadi ndogo.
  static String storyPriceLabel(int amountTZS, {bool swahili = true}) {
    if (amountTZS <= 0) return swahili ? 'Bure' : 'Free';
    return format(amountTZS);
  }

  /// Bei kamili ya kifurushi pamoja na mzunguko: `TZS 5,000 kwa mwezi`.
  ///
  /// Kwa mzunguko wa robo mwaka/mwaka tunatumia [totalFor] (jumla ya kipindi)
  /// na si bei ya mwezi — maskini aliyeuliza "robo mwaka ni ngapi?" asione
  /// bei ya mwezi na kudhani ndiyo jibu.
  static String planPriceLabel(
    PlanTier tier, {
    BillingCycle cycle = BillingCycle.monthly,
    bool swahili = true,
  }) {
    if (isFreeTier(tier)) return swahili ? 'Bure' : 'Free';
    final price = cycle == BillingCycle.monthly
        ? monthlyPriceFor(tier)
        : totalFor(tier, cycle);
    return '${format(price)} ${swahili ? cycle.labelSw : cycle.labelEn}';
  }

  /// Kiwango cha bei cha hadithi inayouzwa: `TZS 500 – TZS 5,000`.
  static String storyPriceRangeLabel() =>
      '${format(AppConstants.minStoryPriceTZS)} – '
      '${format(AppConstants.maxStoryPriceTZS)}';

  /// Kiwango cha chini cha kutoa mapato: `TZS 10,000`.
  static String payoutThresholdLabel() => format(AppConstants.minPayoutTZS);

  /// Sehemu ya mwandishi kama asilimia: `70%`.
  static String creatorShareLabel({int decimals = 0}) =>
      Formatters.percent(AppConstants.creatorRevenueShare, decimals: decimals);

  /// Sehemu ya jukwaa kama asilimia: `30%`.
  static String platformShareLabel({int decimals = 0}) =>
      Formatters.percent(AppConstants.platformRevenueShare, decimals: decimals);

  // ---------------------------------------------------------------------------
  // Mapato ya mwandishi
  // ---------------------------------------------------------------------------

  /// Mapato ya mwandishi kwa mauzo ya [grossTZS].
  ///
  /// Mfano: hadithi ya TZS 1,000 → mwandishi hupata TZS 700.
  static int creatorEarning(int grossTZS) {
    if (grossTZS <= 0) return 0;
    return (grossTZS * AppConstants.creatorRevenueShare).round();
  }

  /// Sehemu ya jukwaa kwa mauzo ya [grossTZS].
  ///
  /// Tunaitoa kwa **kutoa** badala ya kuzidisha kwa 30%: hivyo
  /// `creatorEarning + platformCut` ni sawa kabisa na [grossTZS], bila
  /// shilingi inayopotea kwa kuzungusha (`(700.4).round()` + `(300.4).round()`
  /// = 1,001 au 999 kama tungezidisha pande zote mbili).
  static int platformCut(int grossTZS) =>
      grossTZS <= 0 ? 0 : grossTZS - creatorEarning(grossTZS);

  // ---------------------------------------------------------------------------
  // Bei ya hadithi (mipaka)
  // ---------------------------------------------------------------------------

  /// `true` kama [amountTZS] iko ndani ya mipaka inayoruhusiwa.
  static bool isValidStoryPrice(int amountTZS) =>
      amountTZS >= AppConstants.minStoryPriceTZS &&
      amountTZS <= AppConstants.maxStoryPriceTZS;

  /// Kubana bei ndani ya mipaka — hutumika kwenye slider ya bei.
  ///
  /// Tumeandika `if` kwa mkono badala ya `amountTZS.clamp(...)`: `num.clamp`
  /// hurudisha `num`, hivyo ingehitaji `.toInt()` kila mahali na ingeruhusu
  /// kosa la aina (type) lisiloonekana.
  static int clampStoryPrice(int amountTZS) {
    if (amountTZS < AppConstants.minStoryPriceTZS) {
      return AppConstants.minStoryPriceTZS;
    }
    if (amountTZS > AppConstants.maxStoryPriceTZS) {
      return AppConstants.maxStoryPriceTZS;
    }
    return amountTZS;
  }

  // ---------------------------------------------------------------------------
  // Kutoa mapato (payout)
  // ---------------------------------------------------------------------------

  /// `true` kama salio limefika kiwango cha chini cha kutoa fedha.
  static bool canRequestPayout(int balanceTZS) =>
      balanceTZS >= AppConstants.minPayoutTZS;

  /// Kiasi kinachoweza kutolewa sasa (0 kama kiwango hakijafikiwa).
  ///
  /// Haturuhusu kutoa nusu ya salio — M-Pesa payout ni ombi moja kwa kiasi
  /// kizima, hivyo `earnings_dashboard.dart` huficha kitufe kabisa kama
  /// kiwango hakijafikiwa.
  static int withdrawableAmount(int balanceTZS) =>
      canRequestPayout(balanceTZS) ? balanceTZS : 0;

  /// Kiasi kinachobaki kufikia kiwango cha kutoa fedha.
  static int amountToPayoutThreshold(int balanceTZS) {
    final remaining = AppConstants.minPayoutTZS - balanceTZS;
    return remaining > 0 ? remaining : 0;
  }

  // ---------------------------------------------------------------------------
  // Vikomo vya kifurushi (allowances)
  // ---------------------------------------------------------------------------

  /// Idadi iliyobaki kwenye kikomo cha mwezi (haitokuwa chini ya 0).
  ///
  /// Hutumika kwa hadithi za bure (`freeStoriesPerMonth` = 3), za MSINGI
  /// (`msingiStoriesPerMonth` = 15) na uundaji wa MSINGI
  /// (`msingiStoriesToCreatePerMonth` = 2).
  static int remainingAllowance({required int allowance, required int used}) {
    final remaining = allowance - used;
    return remaining > 0 ? remaining : 0;
  }

  /// `true` kama mtumiaji hawezi kuendelea kwa sababu kikomo kimefika.
  static bool hasReachedLimit({required int allowance, required int used}) =>
      remainingAllowance(allowance: allowance, used: used) == 0;

  // ---------------------------------------------------------------------------
  // Malipo (delegate — lebo zinatoka enums)
  // ---------------------------------------------------------------------------

  /// Lebo ya mtoa huduma: `M-Pesa`, `Tigo Pesa`, `Airtel Money`, ...
  static String providerLabel(PaymentProvider provider, {bool swahili = true}) =>
      swahili ? provider.labelSw : provider.labelEn;

  /// Lebo ya hali ya malipo: `Imekamilika`, `Imeshindwa`, ...
  static String statusLabel(PaymentStatus status, {bool swahili = true}) =>
      swahili ? status.labelSw : status.labelEn;

  /// `true` kama malipo bado yanaendelea — mtumiaji aone spinner, asiondoke.
  static bool isInProgress(PaymentStatus status) =>
      status == PaymentStatus.pending || status == PaymentStatus.processing;

  /// `true` kama malipo yamekamilika.
  static bool isSuccessful(PaymentStatus status) =>
      status == PaymentStatus.completed;
}

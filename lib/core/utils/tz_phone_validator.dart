/// Uthibitishaji na uumbizaji wa namba za simu za Tanzania.
///
/// **Kwa nini faili hili lipo peke yake:** namba ya simu ni **lango la
/// pesa**. Kama uthibitishaji ni mkali kupita kiasi, mzazi anashindwa
/// kulipa; kama ni mlegevu, ombi huenda kwa mtoa huduma usio sahihi na
/// mtumiaji hukwama. Kwa hivyo mantiki iko mahali pamoja, **huru** (pure)
/// na inayopimwa — si ndani ya widget ya fomu.
///
/// ## Tatizo la kwanza: watu huandika namba kwa namna nne
///
/// ```
/// 0712345678        ← ya kawaida Tanzania (sifuri mwanzoni)
/// 712345678         ← bila sifuri
/// +255712345678     ← kimataifa
/// 255 712 345 678   ← kimataifa, na nafasi
/// ```
///
/// Spec ya Prompt 5 ilikuwa na `RegExp(r'^(7|6)\d{8}$')` juu ya maandishi
/// yenye nafasi zilizoondolewa pekee. Hiyo **hukataa `0712345678`** — ambayo
/// ndiyo namna ambayo Watanzania wengi huiandika kwenye fomu. Kwa hivyo
/// [normalise] huondoa kabisa vitu vyote visivyo tarakimu **na** kile
/// kiambishi cha nchi/sifuri, kisha kila kitu kingine hufanya kazi kwa
/// umbo moja.
///
/// ## Kanuni
///
/// * Namba ya kitaifa ina **tarakimu 9**, huanza na `7` au `6`.
/// * Umbo la ndani (canonical): `712345678`.
/// * Umbo la API: `+255712345678`.
/// * Umbo la kuonyesha: `712 345 678`.
library;

import '../../features/payments/domain/entities/payment_provider.dart';

/// Uthibitishaji wa namba za simu za Tanzania.
abstract final class TzPhoneValidator {
  /// Kiambishi cha nchi.
  static const String countryCode = '+255';

  /// Idadi ya tarakimu za namba ya kitaifa (bila `+255`).
  static const int nationalLength = 9;

  /// Vitu vyote visivyo tarakimu (nafasi, `-`, `(`, `)`, `.`).
  static final RegExp _nonDigit = RegExp(r'\D');

  /// Namba halali: huanza na `7` au `6`, kisha tarakimu 8.
  static final RegExp _national = RegExp(r'^[76]\d{8}$');

  /// Huondoa nafasi/alama na kiambishi cha nchi au sifuri ya mwanzo.
  ///
  /// Hurudisha tarakimu tupu pekee. Haithibitishi — angalia [isValid].
  ///
  /// ```
  /// normalise('0712 345 678')    // '712345678'
  /// normalise('+255 712345678')  // '712345678'
  /// normalise('255-712-345-678') // '712345678'
  /// ```
  static String normalise(String input) {
    // 1. Ondoa kila kitu kisichokuwa tarakimu.
    String digits = input.replaceAll(_nonDigit, '');

    // 2. Ondoa kiambishi cha nchi (`255`) — lakini tu kama kuna tarakimu
    //    za kutosha baada yake. Bila sharti hili, namba kama `255` tupu
    //    ingekuwa tupu bila sababu ya wazi.
    if (digits.startsWith('255') && digits.length > nationalLength) {
      digits = digits.substring(3);
    }

    // 3. Ondoa sifuri moja ya mwanzo (namna ya kawaida ya Tanzania).
    if (digits.startsWith('0') && digits.length > nationalLength) {
      digits = digits.substring(1);
    }

    return digits;
  }

  /// `true` = namba ni sahihi Tanzania.
  static bool isValid(String phone) => _national.hasMatch(normalise(phone));

  /// `true` = mtumiaji ameandika kitu, lakini si sahihi bado.
  ///
  /// Hii hutumika kuonyesha kosa **tu baada ya mtumiaji kuandika**, si
  /// kwenye uwanja tupu — kosa kwenye uwanja ambao mtumiaji hajagusa ni
  /// kero, si msaada.
  static bool hasError(String phone) =>
      phone.replaceAll(_nonDigit, '').isNotEmpty && !isValid(phone);

  /// Umbo la kuonyesha: `712 345 678`.
  ///
  /// Kama namba haijakamilika, hurudisha [input] kama ilivyo — fomu
  /// haiandiki upya kile mtumiaji anaandika.
  static String format(String phone) {
    final String digits = normalise(phone);
    if (digits.length != nationalLength) return phone;
    return '${digits.substring(0, 3)} '
        '${digits.substring(3, 6)} '
        '${digits.substring(6)}';
  }

  /// Umbo la API: `+255712345678`.
  static String toInternational(String phone) =>
      '$countryCode${normalise(phone)}';

  /// Humpendekeza mtoa huduma kutoka kiambishi cha namba.
  ///
  /// `null` = kiambishi hakijulikani — mtumiaji **huchagua kwa mkono**.
  ///
  /// TANBIHI: viambishi vinatoka [PaymentProvider.prefixes], ambavyo
  /// bado havijathibitishwa na backend (tazama doc ya faili hilo). Kwa
  /// hivyo matokeo ni **pendekezo**, si uamuzi.
  static PaymentProvider? detectProvider(String phone) {
    final String digits = normalise(phone);
    if (digits.length < 2) return null;

    final String prefix = digits.substring(0, 2);
    for (final PaymentProvider provider in PaymentProvider.values) {
      if (provider.prefixes.contains(prefix)) return provider;
    }
    return null;
  }
}

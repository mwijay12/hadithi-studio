/// Zana za nambari za simu za Tanzania (+255).
///
/// Kwa nini tunashughulikia nambari kwa mkono badala ya kutegemea package:
/// mtumiaji wa Tanzania huandika nambari yake kwa njia nyingi — `0712345678`,
/// `712 345 678`, `+255712345678`, `00255712345678`, mpaka `+255 0712 345 678`
/// (zero ya mwanzo akiiacha kwa makosa). Kila moja lazima ifike kwenye umbo
/// moja kabla ya kutumwa kwa M-Pesa au Tigo Pesa, kwa sababu API za malipo
/// hazikubali `0` ya mwanzo.
///
/// Kanuni yetu: **umbo moja la ndani** — `+255` + tarakimu 9, mfano
/// `+255712345678`. Kila kitu kingine ni maonyesho tu.
library;

import '../../config/constants/app_constants.dart';
import 'text_utils.dart';

abstract final class TanzaniaPhoneUtils {
  /// Kiambishi cha kimataifa kinachotumiwa mahali pa `+` (`00255...`).
  static const String _internationalPrefix = '00';

  /// Tarakimu inayoanza nambari ya simu ya mkononi Tanzania (`06x` / `07x`).
  static const String _mobileFirstDigits = '67';

  /// Ramani ya makadirio: kiambishi cha ndani (`0XX`) → code ya mtoa huduma.
  ///
  /// Codes zinalingana na zile zinazotumika kwenye `PaymentException.providerCode`
  /// (`'vodacom' | 'tigo' | 'airtel' | 'halotel'`).
  ///
  /// TANBIHI: TCRA hupanga upya viambishi mara kwa mara na baadhi ya nambari
  /// huhamishwa kati ya mitandao. Ramani hii ni **kidokezo tu** — hiari ya
  /// mtumiaji (kuchagua M-Pesa/Tigo Pesa mwenyewe) ndiyo yenye mamlaka.
  /// Thibitisha orodha hii na TCRA kabla ya kuzindua production.
  static const Map<String, String> providerHints = <String, String>{
    '075': 'vodacom', '076': 'vodacom',
    '071': 'tigo', '065': 'tigo', '067': 'tigo',
    '068': 'airtel', '069': 'airtel', '078': 'airtel', '079': 'airtel',
    '061': 'halotel', '062': 'halotel',
    '073': 'ttcl',
    '077': 'zantel',
  };

  // ---------------------------------------------------------------------------
  // Kusafisha (normalising)
  // ---------------------------------------------------------------------------

  /// Herufi za tarakimu pekee — huondoa `+`, nafasi, hyphen na mabano.
  static String digitsOnly(String raw) => raw.replaceAll(RegExp(r'\D'), '');

  /// Tarakimu 9 za kitaifa (bila `+255` na bila `0`), au `null` kama si sahihi.
  ///
  /// Mfano: `'0712 345 678'` → `'712345678'`.
  static String? nationalNumber(String raw) {
    var digits = digitsOnly(raw);
    if (digits.isEmpty) return null;

    // `00` hufanya kazi kama `+` kwenye baadhi ya simu.
    var guard = 0;
    while (digits.startsWith(_internationalPrefix) && guard < 2) {
      digits = digits.substring(_internationalPrefix.length);
      guard++;
    }

    if (digits.startsWith(AppConstants.countryCallingCode)) {
      digits = digits.substring(AppConstants.countryCallingCode.length);
    } else {
      // Ondoa zero za mwanzo za kupiga ndani ("0712..." → "712...").
      // Tunaruhusu zero moja tu ya ziada ili `'00712...'` isipitishwe kimakosa.
      var stripped = 0;
      while (stripped < 2 &&
          digits.length > AppConstants.phoneNationalLength &&
          digits.startsWith('0')) {
        digits = digits.substring(1);
        stripped++;
      }
    }

    if (digits.length != AppConstants.phoneNationalLength) return null;
    return digits;
  }

  // ---------------------------------------------------------------------------
  // Ukaguzi (validation)
  // ---------------------------------------------------------------------------

  /// `true` kama nambari ni ya simu ya mkononi ya Tanzania.
  static bool isMobile(String raw) {
    final national = nationalNumber(raw);
    if (national == null) return false;
    return _mobileFirstDigits.contains(national[0]);
  }

  /// Kama [isMobile] — jina la wazi kwa kutumia kwenye validators.
  static bool isValid(String raw) => isMobile(raw);

  /// Nambari mbili ni zile zile (hata zimeandikwa tofauti).
  static bool sameNumber(String a, String b) {
    final left = normalise(a);
    final right = normalise(b);
    return left != null && left == right;
  }

  // ---------------------------------------------------------------------------
  // Mabadiliko ya umbo (conversion)
  // ---------------------------------------------------------------------------

  /// Umbo la ndani la app: `+255712345678`, au `null` kama si sahihi.
  ///
  /// Hili ni umbo linalotumwa kwa API za malipo na kuhifadhiwa kwenye akaunti.
  static String? normalise(String raw) {
    final national = nationalNumber(raw);
    return national == null ? null : '${AppConstants.dialCode}$national';
  }

  /// MSISDN bila `+` (`255712345678`) — baadhi ya API za mobile money
  /// hutaka umbo hili.
  static String? toMsisdn(String raw) {
    final national = nationalNumber(raw);
    return national == null ? null : '${AppConstants.countryCallingCode}$national';
  }

  /// Kugeuza MSISDN (`255712345678`) kurudi kwenye umbo la ndani.
  static String? fromMsisdn(String msisdn) => normalise(msisdn);

  // ---------------------------------------------------------------------------
  // Maonyesho (display)
  // ---------------------------------------------------------------------------

  /// Umbo la kupiga ndani: `0712 345 678`.
  static String formatNational(String raw) {
    final national = nationalNumber(raw);
    if (national == null) return raw.trim();
    return '0${national.substring(0, 3)} ${national.substring(3, 6)} '
        '${national.substring(6, 9)}';
  }

  /// Umbo la kimataifa lenye nafasi: `+255 712 345 678`.
  static String formatInternational(String raw) {
    final national = nationalNumber(raw);
    if (national == null) return raw.trim();
    return '${AppConstants.dialCode} ${national.substring(0, 3)} '
        '${national.substring(3, 6)} ${national.substring(6, 9)}';
  }

  /// Nambari iliyofichwa kwa kuonyesha tarakimu 4 za mwisho pekee.
  ///
  /// Tunatumia utekelezaji mmoja tu (`SwahiliTextUtils.maskPhone`) ili sheria
  /// ya usiri ibaki mahali pamoja.
  static String mask(String raw) => SwahiliTextUtils.maskPhone(raw);

  // ---------------------------------------------------------------------------
  // Mtoa huduma (operator)
  // ---------------------------------------------------------------------------

  /// Kidokezo cha mtoa huduma kutoka kiambishi (`'vodacom'`, `'tigo'`, ...).
  ///
  /// Rudisha `null` kama kiambishi hakijulikani. Tazama [providerHints] kuhusu
  /// kwa nini hii ni kidokezo tu.
  static String? providerHint(String raw) {
    final national = nationalNumber(raw);
    if (national == null) return null;
    return providerHints['0${national.substring(0, 2)}'];
  }
}

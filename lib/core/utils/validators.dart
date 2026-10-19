import '../../config/constants/app_constants.dart';
import '../errors/failures.dart';
import 'phone_utils.dart';
import 'text_utils.dart';

/// VALIDATORS — ukaguzi wa taarifa zitolewazo na mtumiaji.
///
/// Kanuni ya 6: makosa yanatembelewa kwa `Either<Failure, Success>`.
/// Kwa hivyo **hakuna validator hapa inayotupa exception** — kila kanuni
/// ikishindwa, hurudisha [ValidationFailure] yenye jina la sehemu na
/// sababu kwa **Kiswahili na Kiingereza** (kanuni ya 4 na 8).
///
/// `null` humaanisha "taarifa ni sahihi". Hii inaruhusu kuunganisha
/// kanuni kadhaa kwa `List` bila kuandika `if` kila mahali.
///
/// Mfano:
/// ```dart
/// final failure = Validators.first(<ValidationFailure?>[
///   Validators.required(phone, fieldSw: FieldLabels.phoneSw, fieldEn: FieldLabels.phoneEn),
///   Validators.phone(phone),
/// ]);
/// if (failure != null) return Left(failure);
/// ```
abstract final class Validators {
  // ---------------------------------------------------------------------------
  // Lebo za sehemu (field labels)
  // ---------------------------------------------------------------------------

  /// Lebo za sehemu zinazotumika mara kwa mara.
  ///
  /// Zimewekwa hapa ili mtengenezaji asiandike "Nambari ya simu" mara
  /// ishirini kwenye feature tofauti — kubadilisha jina iwe mahali kimoja.
  static const String phoneFieldSw = 'Nambari ya simu';
  static const String phoneFieldEn = 'Phone number';

  static const String emailFieldSw = 'Barua pepe';
  static const String emailFieldEn = 'Email';

  static const String passwordFieldSw = 'Neno la siri';
  static const String passwordFieldEn = 'Password';

  static const String confirmPasswordFieldSw = 'Neno la siri la pili';
  static const String confirmPasswordFieldEn = 'Password confirmation';

  static const String otpFieldSw = 'Namba ya uthibitisho';
  static const String otpFieldEn = 'Verification code';

  static const String pinFieldSw = 'PIN ya mzazi';
  static const String pinFieldEn = 'Parental PIN';

  static const String nameFieldSw = 'Jina';
  static const String nameFieldEn = 'Name';

  static const String titleFieldSw = 'Jina la hadithi';
  static const String titleFieldEn = 'Story title';

  static const String synopsisFieldSw = 'Maelezo ya hadithi';
  static const String synopsisFieldEn = 'Story synopsis';

  static const String pageTextFieldSw = 'Maandishi ya ukurasa';
  static const String pageTextFieldEn = 'Page text';

  static const String pageCountFieldSw = 'Idadi ya kurasa';
  static const String pageCountFieldEn = 'Page count';

  static const String priceFieldSw = 'Bei';
  static const String priceFieldEn = 'Price';

  static const String ageFieldSw = 'Umri';
  static const String ageFieldEn = 'Age';

  static const String tagsFieldSw = 'Lebo za hadithi';
  static const String tagsFieldEn = 'Story tags';

  static const String urlFieldSw = 'Kiungo';
  static const String urlFieldEn = 'Link';

  // ---------------------------------------------------------------------------
  // Sababu za kukataa (reasons)
  // ---------------------------------------------------------------------------

  static const String _requiredSw = 'sehemu hii inahitajika';
  static const String _requiredEn = 'this field is required';

  static const String _tooShortSw = 'ni fupi mno';
  static const String _tooShortEn = 'is too short';

  static const String _tooLongSw = 'ni ndefu mno';
  static const String _tooLongEn = 'is too long';

  static const String _invalidFormatSw = 'umbo si sahihi';
  static const String _invalidFormatEn = 'has an invalid format';

  static const String _dontMatchSw = 'maneno mawili hayafanani';
  static const String _dontMatchEn = 'the two values do not match';

  // ---------------------------------------------------------------------------
  // Kanuni za jumla (generic rules)
  // ---------------------------------------------------------------------------

  /// Kukagua kwamba sehemu imejazwa (na si nafasi tupu tu).
  ///
  /// `trim()` inatumika kwa sababu mtumiaji mara nyingi huacha nafasi
  /// mwanzoni wakati wa kunakili namba ya simu.
  static ValidationFailure? required(
    String? value, {
    required String fieldSw,
    required String fieldEn,
  }) {
    if (value == null || value.trim().isEmpty) {
      return ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: _requiredSw,
        reasonEn: _requiredEn,
      );
    }
    return null;
  }

  /// Kukagua urefu wa chini kabisa (bila kuhesabu nafasi za pembeni).
  static ValidationFailure? minLength(
    String? value,
    int min, {
    required String fieldSw,
    required String fieldEn,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return required(value, fieldSw: fieldSw, fieldEn: fieldEn);
    }
    if (trimmed.length < min) {
      return ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: '$_tooShortSw — iwe na herufi $min au zaidi',
        reasonEn: '$_tooShortEn — must be at least $min characters',
      );
    }
    return null;
  }

  /// Kukagua urefu wa juu kabisa.
  ///
  /// Urefu huu ni muhimu hasa kwa Tanzania: kikomo cha [AppConstants.maxPageTextLength]
  /// kinazuia ukurasa mzima usiwe mrefu kuliko uwezo wa TTS kusoma bila
  /// kukatika, na [AppConstants.maxPasswordLength] inazuia tatizo la
  /// bcrypt kukata kimya kimya baada ya baiti 72.
  static ValidationFailure? maxLength(
    String? value,
    int max, {
    required String fieldSw,
    required String fieldEn,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > max) {
      return ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: '$_tooLongSw — kikomo ni herufi $max',
        reasonEn: '$_tooLongEn — maximum is $max characters',
      );
    }
    return null;
  }

  /// Kukagua urefu ulio kati ya chini na juu.
  static ValidationFailure? lengthBetween(
    String? value,
    int min,
    int max, {
    required String fieldSw,
    required String fieldEn,
  }) {
    return first(<ValidationFailure?>[
      minLength(value, min, fieldSw: fieldSw, fieldEn: fieldEn),
      maxLength(value, max, fieldSw: fieldSw, fieldEn: fieldEn),
    ]);
  }

  /// Kukagua kwamba thamani ni namba kamili (integer).
  static ValidationFailure? integer(
    String? value, {
    required String fieldSw,
    required String fieldEn,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return required(value, fieldSw: fieldSw, fieldEn: fieldEn);
    }
    if (int.tryParse(trimmed) == null) {
      return ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: '$_invalidFormatSw — weka namba kamili',
        reasonEn: '$_invalidFormatEn — enter a whole number',
      );
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Barua pepe (email)
  // ---------------------------------------------------------------------------

  /// Kanuni ya barua pepe.
  ///
  /// Regex hii ni ya wastani kwa makusudi: ukaguzi mkali sana wa RFC 5322
  /// hukataa barua halali, na seva ndiyo yenye uamuzi wa mwisho.
  static ValidationFailure? email(
    String? value, {
    bool isRequired = true,
  }) {
    const fieldSw = emailFieldSw;
    const fieldEn = emailFieldEn;
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return isRequired ? required(value, fieldSw: fieldSw, fieldEn: fieldEn) : null;
    }

    final pattern = RegExp(r'^[\w.!#$%&’*+/=?^`{|}~-]+@[\w-]+(\.[\w-]+)+$');
    if (!pattern.hasMatch(trimmed)) {
      return const ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: 'umbo la barua pepe si sahihi (mfano jina@mfano.co.tz)',
        reasonEn: 'invalid email format (example name@example.co.tz)',
      );
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Nambari ya simu ya Tanzania
  // ---------------------------------------------------------------------------

  /// Kanuni ya nambari ya simu ya Tanzania.
  ///
  /// Huruhusu aina zote ambazo Watanzania huziandika kwa kawaida:
  /// `0712 345 678`, `712345678`, `+255712345678`, `00255712345678`.
  /// Kazi yote ya kusafisha na kuangalia imo ndani ya [TanzaniaPhoneUtils];
  /// hapa tunatafsiri tu matokeo kuwa [ValidationFailure].
  static ValidationFailure? phone(String? value) {
    const fieldSw = phoneFieldSw;
    const fieldEn = phoneFieldEn;

    final failure = required(value, fieldSw: fieldSw, fieldEn: fieldEn);
    if (failure != null) return failure;

    final national = TanzaniaPhoneUtils.nationalNumber(value!);

    if (national == null) {
      return const ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw:
            'weka namba ${AppConstants.phoneNationalLength} za simu '
            '(mfano ${AppConstants.dialCode}712345678)',
        reasonEn:
            'enter a ${AppConstants.phoneNationalLength}-digit number '
            '(example ${AppConstants.dialCode}712345678)',
      );
    }

    if (!TanzaniaPhoneUtils.isMobile(value)) {
      return const ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: 'namba hii si ya simu ya mkononi (anza na 06 au 07)',
        reasonEn: 'this is not a mobile number (must start with 06 or 07)',
      );
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Neno la siri (password)
  // ---------------------------------------------------------------------------

  /// Kanuni ya neno la siri kwa kiwango cha chini.
  ///
  /// Hukagua urefu tu (na kukataa nafasi tupu ndani ya neno). Kwa kanuni
  /// zaidi za usalama (mchanganyiko wa herufi na namba) tumia
  /// [strongPassword].
  static ValidationFailure? password(
    String? value, {
    bool isRequired = true,
  }) {
    const fieldSw = passwordFieldSw;
    const fieldEn = passwordFieldEn;
    final trimmed = value ?? '';

    if (trimmed.isEmpty) {
      return isRequired ? required(value, fieldSw: fieldSw, fieldEn: fieldEn) : null;
    }

    if (trimmed.length < AppConstants.minPasswordLength) {
      return const ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw:
            'iwe na herufi ${AppConstants.minPasswordLength} au zaidi',
        reasonEn:
            'must be at least ${AppConstants.minPasswordLength} characters',
      );
    }

    if (trimmed.length > AppConstants.maxPasswordLength) {
      return const ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw:
            'iwe na herufi zisizozidi ${AppConstants.maxPasswordLength}',
        reasonEn:
            'must not exceed ${AppConstants.maxPasswordLength} characters',
      );
    }

    if (trimmed.contains(RegExp(r'\s'))) {
      return const ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: 'kusiwe na nafasi tupu ndani ya neno la siri',
        reasonEn: 'must not contain spaces',
      );
    }

    return null;
  }

  /// Kanuni kali zaidi: herufi **na** namba, pamoja na urefu wa chini.
  ///
  /// Inatumika kwenye usajili wa waandishi (creator) ambapo akaunti
  /// inashikilia mapato — si lazima kwa msomaji wa kawaida.
  static ValidationFailure? strongPassword(String? value) {
    final basic = password(value);
    if (basic != null) return basic;

    final text = value!;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(text);
    final hasDigit = RegExp(r'\d').hasMatch(text);

    if (!hasLetter || !hasDigit) {
      return const ValidationFailure(
        fieldSw: passwordFieldSw,
        fieldEn: passwordFieldEn,
        reasonSw: 'iwe na herufi na namba zote mbili',
        reasonEn: 'must contain both letters and numbers',
      );
    }
    return null;
  }

  /// Kukagua kwamba neno la pili linafanana na la kwanza.
  static ValidationFailure? confirmPassword(String? value, String? original) {
    const fieldSw = confirmPasswordFieldSw;
    const fieldEn = confirmPasswordFieldEn;

    final failure = required(value, fieldSw: fieldSw, fieldEn: fieldEn);
    if (failure != null) return failure;

    if (value != original) {
      return const ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: _dontMatchSw,
        reasonEn: _dontMatchEn,
      );
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // OTP na PIN
  // ---------------------------------------------------------------------------

  /// Kanuni ya namba ya uthibitisho (OTP) — tarakimu [AppConstants.otpLength] pekee.
  static ValidationFailure? otp(String? value) {
    const fieldSw = otpFieldSw;
    const fieldEn = otpFieldEn;

    final failure = required(value, fieldSw: fieldSw, fieldEn: fieldEn);
    if (failure != null) return failure;

    final digits = value!.trim();
    if (digits.length != AppConstants.otpLength || !_isAllDigits(digits)) {
      return const ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: 'weka tarakimu ${AppConstants.otpLength} pekee',
        reasonEn: 'enter exactly ${AppConstants.otpLength} digits',
      );
    }
    return null;
  }

  /// Kanuni ya PIN ya mzazi — tarakimu [AppConstants.pinLength] pekee.
  static ValidationFailure? pin(String? value) {
    const fieldSw = pinFieldSw;
    const fieldEn = pinFieldEn;

    final failure = required(value, fieldSw: fieldSw, fieldEn: fieldEn);
    if (failure != null) return failure;

    final digits = value!.trim();
    if (digits.length != AppConstants.pinLength || !_isAllDigits(digits)) {
      return const ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: 'PIN iwe na tarakimu ${AppConstants.pinLength} pekee',
        reasonEn: 'PIN must be exactly ${AppConstants.pinLength} digits',
      );
    }

    // PIN ya '1111' au '1234' ni rahisi mno kwa mtoto kubashiri.
    if (_isWeakPin(digits)) {
      return const ValidationFailure(
        fieldSw: pinFieldSw,
        fieldEn: pinFieldEn,
        reasonSw: 'PIN hii ni rahisi sana — chagua nyingine',
        reasonEn: 'this PIN is too easy to guess — choose another',
      );
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Majina ya watu
  // ---------------------------------------------------------------------------

  /// Kanuni ya jina la mtu (msomaji, mwandishi au mtoto).
  ///
  /// Huruhusu herufi, nafasi, kistari na apostrofi — majina kama
  /// "Neema Mwangi", "Abdul-Rahman", "N'goma" yanapaswa kupita.
  static ValidationFailure? personName(String? value, {int min = 2, int max = 60}) {
    const fieldSw = nameFieldSw;
    const fieldEn = nameFieldEn;

    final failure = required(value, fieldSw: fieldSw, fieldEn: fieldEn);
    if (failure != null) return failure;

    final trimmed = value!.trim();

    if (trimmed.length < min) {
      return ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: 'jina ni fupi mno — herufi $min au zaidi',
        reasonEn: 'name is too short — at least $min characters',
      );
    }

    if (trimmed.length > max) {
      return ValidationFailure(
        fieldSw: fieldSw,
        fieldEn: fieldEn,
        reasonSw: 'jina ni ndefu mno — kikomo ni herufi $max',
        reasonEn: 'name is too long — maximum $max characters',
      );
    }

    if (!RegExp(r"^[A-Za-z\u00C0-\u024F' \-]+$").hasMatch(trimmed)) {
      return const ValidationFailure(
        fieldSw: nameFieldSw,
        fieldEn: nameFieldEn,
        reasonSw: 'tumia herufi, nafasi, kistari au apostrofi pekee',
        reasonEn: 'use only letters, spaces, hyphens or apostrophes',
      );
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Maudhui ya hadithi (story content)
  // ---------------------------------------------------------------------------

  /// Kanuni ya jina la hadithi — [AppConstants.maxStoryTitleLength] herufi.
  static ValidationFailure? storyTitle(String? value) {
    return lengthBetween(
      value,
      3,
      AppConstants.maxStoryTitleLength,
      fieldSw: titleFieldSw,
      fieldEn: titleFieldEn,
    );
  }

  /// Kanuni ya maelezo (synopsis) — [AppConstants.maxSynopsisLength] herufi.
  static ValidationFailure? synopsis(String? value, {bool isRequired = true}) {
    final failure = isRequired
        ? required(value, fieldSw: synopsisFieldSw, fieldEn: synopsisFieldEn)
        : null;
    if (failure != null) return failure;

    if ((value?.trim() ?? '').isEmpty) return null;

    return lengthBetween(
      value,
      10,
      AppConstants.maxSynopsisLength,
      fieldSw: synopsisFieldSw,
      fieldEn: synopsisFieldEn,
    );
  }

  /// Kanuni ya maandishi ya ukurasa mmoja.
  ///
  /// Kikomo cha [AppConstants.maxPageTextLength] kinahusiana moja kwa moja
  /// na TTS: ukurasa mrefu mno huchukua muda mrefu kusomwa na hufanya
  /// kufuatilia alama za maneno (word highlighting) kushindwa.
  static ValidationFailure? pageText(String? value) {
    final failure = required(value, fieldSw: pageTextFieldSw, fieldEn: pageTextFieldEn);
    if (failure != null) return failure;

    return lengthBetween(
      value,
      1,
      AppConstants.maxPageTextLength,
      fieldSw: pageTextFieldSw,
      fieldEn: pageTextFieldEn,
    );
  }

  /// Kanuni ya idadi ya kurasa — kati ya [AppConstants.minStoryPages] na
  /// [AppConstants.maxStoryPages].
  static ValidationFailure? pageCount(int? value) {
    if (value == null) {
      return const ValidationFailure(
        fieldSw: pageCountFieldSw,
        fieldEn: pageCountFieldEn,
        reasonSw: _requiredSw,
        reasonEn: _requiredEn,
      );
    }
    if (value < AppConstants.minStoryPages ||
        value > AppConstants.maxStoryPages) {
      return const ValidationFailure(
        fieldSw: pageCountFieldSw,
        fieldEn: pageCountFieldEn,
        reasonSw:
            'iwe kati ya ${AppConstants.minStoryPages} na '
            '${AppConstants.maxStoryPages}',
        reasonEn:
            'must be between ${AppConstants.minStoryPages} and '
            '${AppConstants.maxStoryPages}',
      );
    }
    return null;
  }

  /// Kanuni ya bei ya hadithi — TZS [AppConstants.minStoryPriceTZS] hadi
  /// [AppConstants.maxStoryPriceTZS]. `0` huruhusiwa (hadithi ya bure).
  static ValidationFailure? storyPrice(int? value) {
    if (value == null) {
      return const ValidationFailure(
        fieldSw: priceFieldSw,
        fieldEn: priceFieldEn,
        reasonSw: _requiredSw,
        reasonEn: _requiredEn,
      );
    }
    if (value == 0) return null;

    if (value < AppConstants.minStoryPriceTZS ||
        value > AppConstants.maxStoryPriceTZS) {
      return const ValidationFailure(
        fieldSw: priceFieldSw,
        fieldEn: priceFieldEn,
        reasonSw:
            'iwe bure au kati ya TZS ${AppConstants.minStoryPriceTZS} na '
            'TZS ${AppConstants.maxStoryPriceTZS}',
        reasonEn:
            'must be free or between TZS ${AppConstants.minStoryPriceTZS} and '
            'TZS ${AppConstants.maxStoryPriceTZS}',
      );
    }
    return null;
  }

  /// Kanuni ya umri wa mtoto — [AppConstants.minChildAge] hadi
  /// [AppConstants.maxChildAge].
  ///
  /// Kikomo cha juu ni muhimu kwa usalama wa maudhui: hadithi za watu
  /// wazima zisimfikie mtoto aliyeandikishwa kama mtoto.
  static ValidationFailure? childAge(int? value) {
    if (value == null) {
      return const ValidationFailure(
        fieldSw: ageFieldSw,
        fieldEn: ageFieldEn,
        reasonSw: _requiredSw,
        reasonEn: _requiredEn,
      );
    }
    if (value < AppConstants.minChildAge || value > AppConstants.maxChildAge) {
      return const ValidationFailure(
        fieldSw: ageFieldSw,
        fieldEn: ageFieldEn,
        reasonSw:
            'iwe kati ya miaka ${AppConstants.minChildAge} na '
            '${AppConstants.maxChildAge}',
        reasonEn:
            'must be between ${AppConstants.minChildAge} and '
            '${AppConstants.maxChildAge} years',
      );
    }
    return null;
  }

  /// Kanuni ya lebo (tags) za hadithi — [AppConstants.maxStoryTags] kikomo.
  ///
  /// Huruhusu orodha tupu (lebo ni hiari).
  static ValidationFailure? storyTags(List<String>? tags) {
    final list = tags ?? const <String>[];
    if (list.length > AppConstants.maxStoryTags) {
      return const ValidationFailure(
        fieldSw: tagsFieldSw,
        fieldEn: tagsFieldEn,
        reasonSw: 'chagua lebo zisizozidi ${AppConstants.maxStoryTags}',
        reasonEn: 'choose no more than ${AppConstants.maxStoryTags} tags',
      );
    }

    final hasBlank = list.any((String tag) => tag.trim().isEmpty);
    if (hasBlank) {
      return const ValidationFailure(
        fieldSw: tagsFieldSw,
        fieldEn: tagsFieldEn,
        reasonSw: 'kusiwe na lebo tupu',
        reasonEn: 'tags must not be empty',
      );
    }
    return null;
  }

  /// Kanuni nyepesi ya kiungo (URL) — http au https pekee.
  static ValidationFailure? url(String? value, {bool isRequired = false}) {
    const fieldSw = urlFieldSw;
    const fieldEn = urlFieldEn;
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return isRequired ? required(value, fieldSw: fieldSw, fieldEn: fieldEn) : null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return const ValidationFailure(
        fieldSw: urlFieldSw,
        fieldEn: urlFieldEn,
        reasonSw: 'kiungo kianze na http:// au https://',
        reasonEn: 'link must start with http:// or https://',
      );
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Utaratibu wa mwisho (result handling)
  // ---------------------------------------------------------------------------

  /// Hurudisha failure ya kwanza isiyo `null` — kanuni hukatizwa mapema.
  static ValidationFailure? first(List<ValidationFailure?> results) {
    for (final ValidationFailure? result in results) {
      if (result != null) return result;
    }
    return null;
  }

  /// Hukusanya failures zote (bila zile `null`).
  ///
  /// Inatumika kwenye fomu ndefu (mfano wizard ya kutengeneza hadithi)
  /// ambapo tunataka kuonyesha makosa yote kwa mtumiaji kwa mpigo mmoja.
  static List<ValidationFailure> collect(List<ValidationFailure?> results) {
    return results.whereType<ValidationFailure>().toList(growable: false);
  }

  /// Hubadili failures kuwa `Map` ya `field → ujumbe` inayolingana na
  /// [ValidationException.fieldErrors] inayorudishwa na seva.
  ///
  /// Hii hufanya makosa ya ndani na ya seva kuonekana kwa mtumiaji kwa
  /// namna ile ile — sehemu ile ile, ujumbe ule ule.
  static Map<String, String> toFieldErrors(
    List<ValidationFailure> failures, {
    required bool swahili,
  }) {
    final Map<String, String> map = <String, String>{};
    for (final ValidationFailure failure in failures) {
      final String key = swahili ? failure.fieldSw : failure.fieldEn;
      map[key] = failure.message(swahili: swahili);
    }
    return map;
  }

  /// Hutengeneza validator ya `TextFormField` kutoka kwa kanuni kadhaa.
  ///
  /// `TextFormField` hutaka `String? Function(String?)`, wakati kanuni
  /// zetu hurudisha [ValidationFailure]. Hapa ndipo tunapounganisha.
  ///
  /// Mfano:
  /// ```dart
  /// TextFormField(
  ///   validator: Validators.formField(
  ///     <ValidationFailure? Function(String?)>[
  ///       (v) => Validators.required(v, fieldSw: 'Jina', fieldEn: 'Name'),
  ///       Validators.personName,
  ///     ],
  ///     swahili: context.isSwahili,
  ///   ),
  /// )
  /// ```
  static String? Function(String?) formField(
    List<ValidationFailure? Function(String?)> rules, {
    required bool swahili,
  }) {
    return (String? value) {
      final ValidationFailure? failure =
          first(rules.map((rule) => rule(value)).toList(growable: false));
      return failure?.message(swahili: swahili);
    };
  }

  // ---------------------------------------------------------------------------
  // Wasaidizi wa ndani (private helpers)
  // ---------------------------------------------------------------------------

  static bool _isAllDigits(String value) {
    if (value.isEmpty) return false;
    for (final int unit in value.codeUnits) {
      if (unit < 0x30 || unit > 0x39) return false;
    }
    return true;
  }

  /// Hukagua PIN dhaifu: tarakimu zote sawa, au mfululizo rahisi.
  static bool _isWeakPin(String digits) {
    final bool allSame = digits.split('').every((String d) => d == digits[0]);
    if (allSame) return true;

    const List<String> weak = <String>['1234', '4321', '0000', '0123', '1111'];
    return weak.contains(digits);
  }

  /// Hurudisha idadi ya maneno kwenye ukurasa — hutumika kuonyesha mwendo
  /// wa maandishi kwa mwandishi wakati wa kuhariri.
  static int wordCountOf(String? text) =>
      SwahiliTextUtils.wordCount(text ?? '');
}

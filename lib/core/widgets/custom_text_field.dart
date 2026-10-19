import 'package:flutter/material.dart';
// `material.dart` haitoi `TextInputFormatter` — hiyo iko kwenye `services.dart`.
import 'package:flutter/services.dart';

import '../../config/theme/app_theme.dart';
import '../../config/theme/spacing.dart';
import '../errors/failures.dart';
import '../extensions/context_extensions.dart';
import 'custom_button.dart';

/// Aina ya uwanja wa maandishi.
enum AppTextFieldVariant {
  /// Kijazo cheupe chenye mpaka mwembamba — chaguo-msingi kwenye forms.
  filled,

  /// Bila kijazo, mpaka pekee — kwa sehemu zenye background yenye rangi.
  outlined,

  /// Umbo la kidonge kwa utafutaji — aikoni ya utafutaji na kitufe cha kufuta.
  search,
}

/// Uwanja wa maandishi (text field) wa Hadithi Studio.
///
/// ## Kwa nini label ipo **juu** ya uwanja, si ndani yake
///
/// `InputDecoration.labelText` hupungua na kuhama juu wakati mtumiaji
/// anaandika — ni mzuri kwenye simu za haraka. Lakini hapa:
///
/// 1. **Mtumiaji anasoma** — label iliyobaki mahali pake inaepusha mtumiaji
///    kusahau alikuwa anaandika nini (mfano "Neno la siri la pili").
/// 2. **Alama ya lazima** — tunaweza kuweka `*` kwa rangi bila kuandika
///    sentensi ya ziada kwa lugha mbili.
/// 3. **GPU** — hakuna uhuishaji wa label kwenye kila uwanja; kwenye form
///    yenye sehemu 8 kwenye simu ya 2GB RAM hiyo inaonekana.
///
/// ## Makosa ya uthibitisho
///
/// Pitisha `failureValidator` (inarudisha [ValidationFailure]) na widget
/// itaonyesha **sababu pekee** — `failure.reasonSw` / `failure.reasonEn` —
/// kwa sababu label ya sehemu tayari inaonekana juu. `Failure.message`
/// kamili ("Nambari ya simu: iwe tarakimu 9") ingerudia jina la sehemu.
/// `message` kamili inafaa pale inapoonekana mbali na uwanja (snackbar,
/// orodha ya makosa juu ya form) — hiyo ni kazi ya `Validators.formField`.
///
/// Matumizi:
/// ```dart
/// AppTextField(
///   labelSw: Validators.phoneFieldSw,
///   labelEn: Validators.phoneFieldEn,
///   hintSw: '0712 345 678',
///   hintEn: '0712 345 678',
///   keyboardType: TextInputType.phone,
///   isRequired: true,
///   failureValidator: Validators.phone,
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelSw,
    this.labelEn,
    this.hintSw,
    this.hintEn,
    this.helperSw,
    this.helperEn,
    this.failureValidator,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.showObscureToggle = true,
    this.prefixIcon,
    this.variant = AppTextFieldVariant.filled,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.isRequired = false,
    this.textAlign = TextAlign.start,
    this.style,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : assert(
          labelSw == null || labelEn != null,
          'labelSw ipo bila labelEn — kanuni ya 4 inataka lugha zote mbili.',
        );

  /// Uwanja wa utafutaji — umbo la kidonge, aikoni ya utafutaji, kitufe cha
  /// kufuta, na hakuna label.
  ///
  /// Kitufe cha kufuta kinahitaji [controller] ili kujua uwanja una maandishi;
  /// bila controller, hakuna kitufe (tunakataa kuonyesha kitufe kisichofanya
  /// kazi).
  const AppTextField.search({
    super.key,
    this.controller,
    this.focusNode,
    this.hintSw,
    this.hintEn,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.textInputAction = TextInputAction.search,
  })  : labelSw = null,
        labelEn = null,
        helperSw = null,
        helperEn = null,
        failureValidator = null,
        validator = null,
        onTap = null,
        keyboardType = TextInputType.text,
        textCapitalization = TextCapitalization.none,
        inputFormatters = null,
        maxLines = 1,
        maxLength = null,
        obscureText = false,
        showObscureToggle = false,
        prefixIcon = null,
        variant = AppTextFieldVariant.search,
        readOnly = false,
        isRequired = false,
        textAlign = TextAlign.start,
        style = null,
        autovalidateMode = AutovalidateMode.disabled;

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Lebo iliyo juu ya uwanja, kwa Kiswahili.
  final String? labelSw;

  /// Lebo iliyo juu ya uwanja, kwa Kiingereza.
  final String? labelEn;

  /// Maelekezo ndani ya uwanja (placeholder), kwa Kiswahili.
  final String? hintSw;
  final String? hintEn;

  /// Maelezo ya msaada chini ya uwanja (mfano "Tarakiramu 10 bila +255").
  final String? helperSw;
  final String? helperEn;

  /// Kanuni inayorudisha [ValidationFailure]. **Hii ndiyo njia ya kawaida.**
  ///
  /// Ni `ValidationFailure? Function(String?)` — si `String? Function(String?)`
  /// — ili uwanja uweze kuamua mwenyewe kuonyesha sababu pekee kwa lugha
  /// sahihi.
  final ValidationFailure? Function(String?)? failureValidator;

  /// Validator ya kawaida ya Flutter. Inachukua nafasi ya [failureValidator]
  /// kama zote mbili zimewekwa (mfano wakati unatumia `Validators.formField`
  /// tayari — lakini kumbuka itaonyesha jina la sehemu mara mbili).
  final String? Function(String?)? validator;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// `1` = mstari mmoja (urefu wa [AppSpacing.inputHeight]).
  final int maxLines;

  /// Kikomo cha herufi. Kinatumika **pia** kama kizuizi cha kuingiza
  /// (`LengthLimitingTextInputFormatter`) hata kama kikomo hakionyeshwi.
  final int? maxLength;

  final bool obscureText;

  /// `true` = kitufe cha kuonyesha/kuficha neno la siri (kwa
  /// `obscureText: true`).
  final bool showObscureToggle;

  final IconData? prefixIcon;
  final AppTextFieldVariant variant;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  /// `true` = onyesha nyota nyekundu kwenye lebo.
  final bool isRequired;

  final TextAlign textAlign;
  final TextStyle? style;

  /// Chaguo-msingi `onUserInteraction`: mtumiaji haoni kosa kabla ya kuandika.
  ///
  /// Kosa linalojitokeza wakati mtumiaji bado anaandika linaonekana kama
  /// app inamkosoa. Kwa form inayotumwa kwa mara ya kwanza, tumia
  /// `AutovalidateMode.disabled` na uonyeshe makosa wakati wa `submit`.
  final AutovalidateMode autovalidateMode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final label = _resolve(widget.labelSw, widget.labelEn);
    final hint = _resolve(widget.hintSw, widget.hintEn);
    final helper = _resolve(widget.helperSw, widget.helperEn);
    final isSearch = widget.variant == AppTextFieldVariant.search;
    final border = isSearch ? AppSpacing.borderRadiusPill : AppSpacing.borderRadiusMd;

    // Dark mode: `AppTheme.lightInputFill` ni ya mandhari ya mwanga pekee;
    // kwenye giza tunatumia `colorScheme.surface` (`darkSurface`) — la sivyo
    // uwanja ungekuwa mweupe kwenye skrini nyeusi.
    final fillColor = context.isDarkMode
        ? context.colorScheme.surface
        : AppTheme.lightInputFill;

    final field = TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      style: widget.style ?? context.textTheme.bodyMedium,
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      validator: _effectiveValidator(context),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface.withOpacity(0.4),
        ),
        helperText: helper,
        helperMaxLines: 2,
        // Makosa ya lugha mbili yanaweza kuwa marefu ("Nambari ya simu:
        // iwe tarakimu 10 kuanzia 07…"); mstari mmoja ungekata nusu ya ujumbe.
        errorMaxLines: 2,
        // `outlined` haijazwi; mengine yote yanajazwa (kwenye `#FAFAF8`
        // uwanja usiojazwa unaonekana kama maandishi yaliyoachwa huru).
        filled: widget.variant != AppTextFieldVariant.outlined,
        fillColor: fillColor,
        isDense: false,
        prefixIcon: _buildPrefixIcon(context, isSearch),
        suffixIcon: _buildSuffixIcon(context),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: widget.maxLines > 1 ? AppSpacing.md : AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: border,
          borderSide: BorderSide(color: context.theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: border,
          borderSide: BorderSide(color: context.theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: border,
          // Unene wa 2 kwa wakati wa kuandika: kwenye simu yenye jua kali
          // (Tanzania) mabadiliko ya rangi pekee yanaweza yasionekane.
          borderSide: BorderSide(color: context.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: border,
          borderSide: BorderSide(color: context.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: border,
          borderSide: BorderSide(color: context.colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: border,
          borderSide: BorderSide(
            color: context.theme.dividerColor.withOpacity(0.6),
          ),
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TANBIHI: `AppTypography.textTheme` haitoi `labelMedium` wala
            // `labelLarge` ya Poppins — inatoa `titleMedium` (Poppins 16 w600),
            // ambayo ndiyo inafaa kwa lebo inayokaa juu ya uwanja.
            Flexible(
              child: Text(
                label,
                style: context.textTheme.titleMedium,
              ),
            ),
            if (widget.isRequired)
              Text(
                ' *',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Urefu wa chini unafuata `AppSpacing.inputHeight` ili sehemu zote
        // kwenye form zilingane — bila hii, uwanja mmoja wenye hint fupi
        // unaonekana mfupi kuliko mwenzake.
        if (widget.maxLines == 1)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.inputHeight),
            child: field,
          )
        else
          field,
      ],
    );
  }

  /// Hutafsiri jozi ya lugha mbili kuwa kitu kimoja kwa lugha ya sasa.
  ///
  /// `null` kama Kiingereza hakipo: tunarudi kwenye Kiswahili badala ya
  /// kuonyesha uwanja bila lebo kabisa.
  String? _resolve(String? swahili, String? english) {
    if (swahili == null) return english;
    if (english == null) return swahili;
    return context.isSwahili ? swahili : english;
  }

  /// Validator inayotumika: ya Flutter kwanza, kisha ya [Failure].
  String? Function(String?)? _effectiveValidator(BuildContext context) {
    if (widget.validator != null) return widget.validator;

    final rule = widget.failureValidator;
    if (rule == null) return null;

    return (String? value) {
      final ValidationFailure? failure = rule(value);
      if (failure == null) return null;
      // Sababu pekee — jina la sehemu linaonekana juu ya uwanja.
      return context.isSwahili ? failure.reasonSw : failure.reasonEn;
    };
  }

  Widget? _buildPrefixIcon(BuildContext context, bool isSearch) {
    final icon = isSearch ? Icons.search_rounded : widget.prefixIcon;
    if (icon == null) return null;
    return Icon(
      icon,
      size: AppSpacing.iconMd,
      color: context.colorScheme.onSurface.withOpacity(0.55),
    );
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (widget.obscureText && widget.showObscureToggle && !widget.readOnly) {
      return AppIconButton(
        icon: _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
        // Hakuna funguo za ARB kwa "onyesha/ficha neno la siri" kwa sasa;
        // tunaandika lugha zote mbili hapa chini kama ilivyo kwenye
        // `Validators` na `date_utils.dart`.
        tooltipSw: _obscure ? 'Onyesha neno la siri' : 'Ficha neno la siri',
        tooltipEn: _obscure ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }

    if (widget.variant != AppTextFieldVariant.search) return null;

    final controller = widget.controller;
    // Bila controller hatujui uwanja una maandishi au la; kitufe cha kufuta
    // kisichojua hali yake ni kitufe kinachodanganya.
    if (controller == null || widget.readOnly || !widget.enabled) return null;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        if (value.text.isEmpty) return const SizedBox.shrink();
        return AppIconButton(
          icon: Icons.close_rounded,
          tooltipSw: 'Futa maandishi',
          tooltipEn: 'Clear text',
          onPressed: () {
            controller.clear();
            // `TextFormField` haisikii `clear()` kwa `onChanged`; tunaita
            // mwenyewe ili orodha ya matokeo ipungue mara moja.
            widget.onChanged?.call('');
          },
        );
      },
    );
  }
}

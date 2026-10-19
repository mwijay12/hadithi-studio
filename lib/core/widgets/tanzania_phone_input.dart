import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/spacing.dart';
import '../enums/app_enums.dart';
import '../errors/failures.dart';
import '../extensions/context_extensions.dart';
import '../utils/phone_utils.dart';
import '../utils/validators.dart';
import 'custom_text_field.dart';

/// Uwanja wa nambari ya simu ya Tanzania (+255).
///
/// ## Kazi yake
///
/// Nambari ya simu ni sehemu moja ambayo mtumiaji wa Tanzania hawezi kuikosea:
/// ndiyo anayolipa kwa M-Pesa, na ndiyo akaunti yake. `TanzaniaPhoneUtils`
/// tayari inajua aina zote ambazo Watanzania huziandika (`0712 345 678`,
/// `712345678`, `+255712345678`, `00255712345678`). Widget hii inaunganisha
/// ujuzi huo na [AppTextField] ili kila skrini isirudie mantiki hiyo.
///
/// Inatoa:
/// 1. Kibodi ya simu (`TextInputType.phone`) na tarakimu pekee.
/// 2. Lebo na maelekezo kwa **lugha mbili** (kanuni ya 4).
/// 3. Kosa la ndani ya uwanja kupitia [Validators.phone] — kama
///    `ValidationFailure.reasonSw` / `reasonEn`.
/// 4. Uthibitisho unaoonekana **mara moja** nambari ikiwa sahihi, kwa umbo
///    la kawaida `+255 712 345 678`, pamoja na kidokezo cha mtoa huduma.
///
/// Matumizi:
/// ```dart
/// final phone = TextEditingController();
/// TanzaniaPhoneInput(
///   controller: phone,
///   textInputAction: TextInputAction.done,
/// )
/// // Baadaye, kwa API ya malipo:
/// final msisdn = TanzaniaPhoneUtils.toMsisdn(phone.text); // '255712345678'
/// ```
///
/// ## Kwa nini HAKUNA kibonge cha `+255` kwenye uwanja
///
/// Njia ya kawaida ni kuweka `prefixText: '+255'` na kisha kumfanya mtumiaji
/// aandike tarakimu 9 pekee. Tulikataa kwa sababu mbili:
///
/// 1. **Uwongo unaoonekana.** Watanzania huandika nambari zao kwa `0` ya
///    mwanzo (`0712345678`). Kama uwanja unaonyesha `+255` mbele, mtumiaji
///    akiandika `0712345678` skrini inasoma `+255 0712345678` — umbo ambalo
///    halipo na ambalo APIs za malipo hulikataa. Kuficha hilo tungebidi
///    kuandika upya maandishi wakati mtumiaji anaandika, na kurekebisha
///    `selection` kwa mkono kila herufi. Kwenye uwanja wa malipo, mwingiliano
///    unaobadilisha maandishi ya mtumiaji kimya kimya haukubaliki.
/// 2. **`TanzaniaPhoneUtils` tayari inasafisha.** Kila aina inayokubalika
///    hufikia umbo moja la ndani. Hivyo hatuhitaji kuubadilisha kabla ya
///    kuituma; tunahitaji **kumwonyesha** mtumiaji umbo hilo kabla ya
///    kulipa — na hilo ndilo analofanya [TanzaniaPhoneInput] kwenye mstari
///    wa uthibitisho chini ya uwanja.
///
/// Maneno ya maelekezo hayakuandikwa hapa kwa sababu hakuna funguo za ARB
/// kwa "unaweza kuandika 0712... au +255712..."; badala yake hint huonyesha
/// umbo la kawaida la ndani, na `Validators.phone` hufundisha umbo la
/// kimataifa kwenye ujumbe wake wa kosa (lugha zote mbili). Nambari
/// yenyewe haibadiliki kwa lugha.
class TanzaniaPhoneInput extends StatefulWidget {
  const TanzaniaPhoneInput({
    super.key,
    this.controller,
    this.focusNode,
    this.labelSw = Validators.phoneFieldSw,
    this.labelEn = Validators.phoneFieldEn,
    this.isRequired = true,
    this.enabled = true,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.showConfirmation = true,
    this.showProviderHint = true,
  });

  /// Kidhibiti cha maandishi. Bila hii, widget hujitengenezea yake ya ndani
  /// (kwa hivyo mstari wa uthibitisho unafanya kazi hata hapa), lakini
  /// mtumiaji wa widget hawezi kusoma thamani — kwa malipo, ipitishe yako.
  final TextEditingController? controller;

  final FocusNode? focusNode;

  /// Lebo kwa Kiswahili. Chaguo-msingi linatoka [Validators] ili lebo ya
  /// sehemu hii isiandikwe mara mbili mahali tofauti.
  final String? labelSw;

  /// Lebo kwa Kiingereza.
  final String? labelEn;

  /// `true` = nyota nyekundu kwenye lebo.
  final bool isRequired;

  final bool enabled;
  final bool autofocus;

  /// Kanuni mbadala. Chaguo-msingi ni [Validators.phone].
  ///
  /// Aina yake ni [ValidationFailure] (si `String`) ili uwanja uonyeshe
  /// **sababu pekee** — jina la sehemu tayari linaonekana juu.
  final ValidationFailure? Function(String?)? validator;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Aina ya kitufe cha kibodi. Bandari ya simu haina kitufe cha "endelea",
  /// kwa hivyo hatuwei chaguo-msingi — mwito ndiye anayejua uwanja uko wapi.
  final TextInputAction? textInputAction;

  /// Chaguo-msingi `disabled` kwa makusudi.
  ///
  /// `onUserInteraction` humwonyesha mtumiaji kosa baada ya herufi ya kwanza
  /// ("Nambari ya simu: weka namba 9 za simu") wakati bado anaandika — ni
  /// kumkosoa kabla ya kumaliza. Badala yake, [TanzaniaPhoneInput] hutoa
  /// maoni **chanya** mara moja nambari ikiwa sahihi (mstari wa uthibitisho),
  /// na kosa hujitokeza mtumiaji anapotuma form (`Form.validate()`).
  /// Skrini inayotaka ukaguzi wa moja kwa moja inaweza kuweka
  /// `AutovalidateMode.onUserInteraction`.
  final AutovalidateMode autovalidateMode;

  /// `true` = onyesha umbo la kawaida `+255 712 345 678` chini ya uwanja
  /// mara nambari ikiwa sahihi.
  final bool showConfirmation;

  /// `true` = onyesha kidokezo cha mtoa huduma kando ya uthibitisho.
  ///
  /// Weka `false` kwenye skrini ya malipo: hapo mtumiaji **amechagua** njia
  /// ya malipo (M-Pesa, Tigo Pesa, ...), na hiari yake ndiyo yenye mamlaka.
  /// Kidokezo hiki hakiwezi kuipinga — `providerHints` ni makadirio kutoka
  /// kiambishi cha nambari (tazama `TanzaniaPhoneUtils.providerHints`).
  final bool showProviderHint;

  /// Mtoa huduma anayekisiwa kutoka kiambishi cha nambari, au `null`.
  ///
  /// Hurudisha [PaymentProvider] **tu** pale kiambishi kinapolingana na mmoja
  /// wa watoa huduma tunaowajua (`vodacom` → M-Pesa, `tigo` → Tigo Pesa,
  /// `airtel` → Airtel Money, `halotel` → Halopesa). Kiambishi cha mtandao
  /// ambao hauna huduma ya malipo kwetu (`ttcl`, `zantel`) hurudisha `null`
  /// badala ya kubuni jina.
  ///
  /// Ni kazi safi (pure) — inajaribiwa moja kwa moja bila widget.
  static PaymentProvider? paymentProviderHint(String raw) {
    final code = TanzaniaPhoneUtils.providerHint(raw);
    if (code == null) return null;
    for (final provider in PaymentProvider.values) {
      if (provider.isMobileMoney && provider.providerCode == code) {
        return provider;
      }
    }
    return null;
  }

  @override
  State<TanzaniaPhoneInput> createState() => _TanzaniaPhoneInputState();
}

class _TanzaniaPhoneInputState extends State<TanzaniaPhoneInput> {
  /// Kidhibiti cha ndani — hutengenezwa tu kama mwito hakutoa kimoja.
  TextEditingController? _internalController;

  /// Umbo la pili la nambari linakubalika; mfano ni lile linaloonekana
  /// kwenye hint. Nambari haitafsiriwi, hivyo Swahili na Kiingereza ni
  /// sawa.
  static const String _example = '0712 345 678';

  /// Tarakimu pekee, kisha kikomo cha tarakimu 14.
  ///
  /// Kwa nini hii ni salama (haitupi taarifa): `TanzaniaPhoneUtils` inasafisha
  /// `00`, `255`, `+` na `0` za mwanzo yenyewe. Tarakimu pekee zinatosha kwa
  /// aina zote zilizoandikwa kwenye nyaraka zake —
  /// `0712345678` (10), `712345678` (9), `255712345678` (12),
  /// `00255712345678` (14). Kikomo cha 14 kinazuia kelele pekee; hakiwezi
  /// kukata nambari halali.
  /// TANBIHI: `final`, si `const` — `FilteringTextInputFormatter.digitsOnly`
  /// ni `static final` kwenye Flutter (imeundwa kwa `RegExp`), hivyo orodha
  /// hii haiwezi kuwa `const`.
  static final List<TextInputFormatter> _formatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(14),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
  }

  @override
  void didUpdateWidget(TanzaniaPhoneInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mmiliki wa kidhibiti anaweza kubadilika kati ya builds (mfano skrini
    // inayounda kidhibiti chake baada ya kusoma hali). Bila kushughulikia
    // hapa, kidhibiti cha ndani kingeachwa bila `dispose` — uvujaji wa kumbukumbu
    // kwenye simu ya 2GB RAM.
    if (oldWidget.controller == null && widget.controller != null) {
      _internalController?.dispose();
      _internalController = null;
    } else if (oldWidget.controller != null && widget.controller == null) {
      _internalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Kidhibiti cha mwito hakigusiwi — mwito ndiye mwenye kukifuta.
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? _internalController!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppTextField(
          controller: controller,
          focusNode: widget.focusNode,
          labelSw: widget.labelSw,
          labelEn: widget.labelEn,
          hintSw: _example,
          hintEn: _example,
          prefixIcon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          textInputAction: widget.textInputAction,
          inputFormatters: _formatters,
          isRequired: widget.isRequired,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          autovalidateMode: widget.autovalidateMode,
          failureValidator: widget.validator ?? Validators.phone,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
        if (widget.showConfirmation)
          // `ValueListenableBuilder` badala ya `setState` kwenye `onChanged`:
          // kusikiliza kidhibiti moja kwa moja kunafanya kazi hata pale mwito
          // anabadilisha maandishi bila kupitia widget hii (mfano "tumia
          // nambari ya akaunti yangu").
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (BuildContext context, TextEditingValue value, _) =>
                _buildConfirmation(context, value.text),
          ),
      ],
    );
  }

  /// Mstari wa uthibitisho — unaonekana **tu** nambari ikiwa sahihi.
  ///
  /// Hatuonyeshi kosa hapa: kosa ni kazi ya [AppTextField] (kupitia
  /// [Validators.phone]), na kuonyesha makosa mawili kwa wakati mmoja ni
  /// kumchanganya mtumiaji.
  Widget _buildConfirmation(BuildContext context, String raw) {
    if (!TanzaniaPhoneUtils.isMobile(raw)) return const SizedBox.shrink();

    final international = TanzaniaPhoneUtils.formatInternational(raw);
    final provider = widget.showProviderHint
        ? TanzaniaPhoneInput.paymentProviderHint(raw)
        : null;

    // Aikoni haina `semanticLabel`, hivyo TalkBack hairushi; mstari unasomwa
    // kama nambari kamili pamoja na jina la mtoa huduma (kama umeonyeshwa).
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.check_circle_rounded,
            size: AppSpacing.iconSm,
            // `colorScheme.primary` inasomeka kwenye mandhari zote mbili:
            // kijani cha safari kwenye nyeupe, turquoise kwenye giza.
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              international,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (provider != null) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            _ProviderHintChip(provider: provider),
          ],
        ],
      ),
    );
  }
}

/// Kibonge kidogo cha kidokezo cha mtoa huduma (mfano "M-Pesa").
///
/// Ni kibonge cha **kidokezo**, si uthibitisho: hakuna alama ya tiki ndani
/// yake, kwa sababu mtandao unaweza kuwa umehamisha nambari (tazama
/// `TanzaniaPhoneUtils.providerHints`). Rangi yake ni ya `primary` kwa
/// uwazi mdogo — haiwezi kudaiwa kuwa ni hali ya mafanikio.
class _ProviderHintChip extends StatelessWidget {
  const _ProviderHintChip({required this.provider});

  final PaymentProvider provider;

  @override
  Widget build(BuildContext context) {
    final tint = context.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        // Uwazi wa 0.10 — kama `chipTheme` ya app (0.08), lakini kidogo zaidi
        // ili kisichanganyike na kibonge cha kuchagua.
        color: tint.withValues(alpha: 0.10),
        borderRadius: AppSpacing.borderRadiusPill,
      ),
      child: Text(
        context.isSwahili ? provider.labelSw : provider.labelEn,
        style: context.textTheme.labelSmall?.copyWith(
          color: tint,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

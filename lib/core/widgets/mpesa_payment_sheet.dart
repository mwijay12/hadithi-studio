/// MPESA PAYMENT SHEET — karatasi ya malipo ya simu.
///
/// Hadithi Studio inauza vifurushi (MSINGI/VIP/FAMILIA) na hadithi moja moja
/// kwa M-Pesa, Tigo Pesa, Airtel Money, Halopesa na kadi. Malipo ni sehemu
/// pekee ya app ambapo kosa **linagharimu mtumiaji fedha halisi**, kwa hivyo
/// faili hili linaweka sheria tatu:
///
/// 1. **Mtumiaji hawezi kulipa mara mbili.** Wakati ombi linaenda, kitufe
///    kinajizima (`AppButton.isLoading`) **na** skrini yote inafunikwa
///    ([AppLoadingOverlay]) — na overlay sasa ina `ModalBarrier` pamoja na
///    `WillPopScope` ili "Lipa" ya pili na kitufe cha nyuma vikataliwe
///    (kanuni ya 14: "Ensure the M-Pesa payment flow works correctly").
/// 2. **Nambari inaonekana kabla ya kulipa.** `TanzaniaPhoneUtils` inasafisha
///    kila umbo (`0712...`, `712...`, `+255...`) kufikia MSISDN moja
///    (`255712345678`), na [AppPaymentSummary] inaonyesha umbo hilo kwa
///    mtumiaji kabla ya pesa kutoka. Fedha zinatoka kwa nambari ile
///    inayoonekana — si kwa kile mtumiaji alidhani aliandika.
/// 3. **Kiasi kinaonekana wazi.** Kwa Kiswahili cha Tanzania: `TZS 5,000`,
///    si `5,000.00 TZS`. Umbile linatoka `TanzaniaCurrencyUtils` (chanzo
///    kimoja cha ukweli) — faili hili haliandiki bei kwa mkono.
///
/// ## Kwa nini widget hii haijui BLoC
///
/// [AppPaymentSheet] haifanyi ombi lolote la mtandao. Inakusanya tu kile
/// mtumiaji alichochagua kwenye [PaymentRequest] na kuita `onSubmit`. BLoC
/// (`PaymentBloc`) ndiye anayeita repository, na `data/` layer ndiyo inayotupa
/// `AppException` → `PaymentFailure`. Hivyo widget hii inaweza kupimwa
/// (tested) bila mtandao, na haijui kuhusu `TextEditingController` ya nje.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../config/theme/colors.dart';
import '../../config/theme/spacing.dart';
import '../../config/theme/typography.dart';
import '../enums/app_enums.dart';
import '../errors/failures.dart';
import '../extensions/context_extensions.dart';
import '../../l10n/l10n.dart';
import '../utils/currency_utils.dart';
import '../utils/phone_utils.dart';
import 'custom_button.dart';
import 'loading_widget.dart';
import 'tanzania_phone_input.dart';

// -----------------------------------------------------------------------------
// Ombi la malipo
// -----------------------------------------------------------------------------

/// Kile mtumiaji alichochagua kwenye karatasi ya malipo.
///
/// Ni `Equatable` kwa sababu BLoC hulitumia kwenye `emit` na kwenye `props`;
/// ombi lilelile lisileteshe hali mpya (kanuni ile ile iliyotumika kwenye
/// [Failure]).
@immutable
class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.provider,
    required this.amountTZS,
    this.msisdn,
  });

  /// Mtoa huduma aliyechaguliwa (`mpesa`, `tigoPesa`, ...).
  final PaymentProvider provider;

  /// Kiasi kinacholipwa. TZS haitumii senti, kwa hivyo ni `int`.
  final int amountTZS;

  /// Nambari kwa umbo la MSISDN: `255712345678` (bila `+`).
  ///
  /// Ni `null` kwa malipo ya kadi — hakuna nambari ya simu inayohusika.
  /// Umbo hili ndilo API za Vodacom/Tigo/Airtel zinatarajia, na
  /// `TanzaniaPhoneUtils.toMsisdn` imelithibitisha.
  final String? msisdn;

  @override
  List<Object?> get props => <Object?>[provider, amountTZS, msisdn];
}

// -----------------------------------------------------------------------------
// Muhtasari wa malipo
// -----------------------------------------------------------------------------

/// Muhtasari unaoonyeshwa juu ya kitufe cha "Lipa".
///
/// Mtumiaji wa Tanzania anayejiuliza "ninalipa kiasi gani, na kwa nini?"
/// anapata jibu hapa kabla ya kubonyeza — ndiyo sababu kiasi na kusudi
/// zinaonekana **kabla** ya kitufe, si kwenye risiti baada ya makato.
class AppPaymentSummary extends StatelessWidget {
  const AppPaymentSummary({
    super.key,
    required this.amountTZS,
    required this.purposeSw,
    required this.purposeEn,
    required this.provider,
    this.phone,
    this.showProvider = true,
  });

  /// Kiasi kwa shilingi.
  final int amountTZS;

  /// Unacholipia, kwa Kiswahili (mfano jina la hadithi).
  final String purposeSw;

  /// Unacholipia, kwa Kiingereza.
  final String purposeEn;

  /// Njia ya malipo inayoonyeshwa.
  final PaymentProvider provider;

  /// Nambari ya simu (umbo lolote linalokubalika) — `null` kwa kadi.
  ///
  /// `TanzaniaPhoneUtils` inaisafisha kabla ya kuonyeshwa, kwa hivyo
  /// `'0712 345 678'` na `'+255712345678'` zote zinaonekana
  /// `+255 712 345 678`.
  final String? phone;

  /// Ficha safu ya mtoa huduma kama kadi inatumika pekee.
  final bool showProvider;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final String prettyPhone = _prettyPhone(phone);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // Rangi hafifu kutoka `primary` — `primary` ni `safariGreen` kwenye
        // mandhari ya mchana na `zanzibarTurquoise` kwenye ya usiku, hivyo
        // kijani kibichi hakionekani kwenye mandhari ya usiku (tazama
        // `dark_theme.dart`).
        color: scheme.primary.withOpacity(0.06),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _SummaryRow(
            label: context.localised(
              swahili: 'Unacholipia',
              english: 'Paying for',
            ),
            value: context.localised(swahili: purposeSw, english: purposeEn),
          ),
          if (showProvider)
            _SummaryRow(
              label: context.localised(
                swahili: 'Njia ya malipo',
                english: 'Payment method',
              ),
              value: TanzaniaCurrencyUtils.providerLabel(
                provider,
                swahili: context.isSwahili,
              ),
            ),
          if (prettyPhone.isNotEmpty)
            _SummaryRow(
              // Funguo hii ipo kwenye ARB (app_sw.arb:185).
              label: context.l10n.phoneNumber,
              value: prettyPhone,
            ),
          Divider(
            height: AppSpacing.xl,
            color: scheme.onSurface.withOpacity(0.12),
          ),
          _SummaryRow(
            label: context.localised(
              swahili: 'Kiasi cha kulipa',
              english: 'Amount to pay',
            ),
            // Umbile la TZS linatoka `TanzaniaCurrencyUtils` → `TZS 5,000`.
            value: TanzaniaCurrencyUtils.format(amountTZS),
            emphasize: true,
          ),
        ],
      ),
    );
  }

  /// Hugeuza umbo lolote la nambari kuwa `+255 712 345 678`.
  ///
  /// Tunaipitisha kwenye `normalise` kwanza (`+255...`) kwa sababu huo ni
  /// umbo ambalo `formatInternational` imethibitishwa nalo kwenye
  /// `TanzaniaPhoneInput`. Kama nambari haieleweki, tunaonyesha kile
  /// mtumiaji aliandika — si kuficha tatizo.
  static String _prettyPhone(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final String? normalised = TanzaniaPhoneUtils.normalise(raw);
    return TanzaniaPhoneUtils.formatInternational(normalised ?? raw);
  }
}

/// Mstari mmoja wa muhtasari: lebo kushoto, thamani kulia.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;

  /// `true` kwa kiasi cha kulipa — kinakuwa kikubwa na kizito.
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.bodyMedium?.copyWith(color: _muted(context)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: emphasize
                  ? theme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
                  : theme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Hali ya malipo
// -----------------------------------------------------------------------------

/// Hali ya malipo: ikoni, rangi, na ujumbe — kwa lugha mbili.
///
/// Hii ni kwa ajili ya hali **zilizoisha** (imekamilika, imeshindwa,
/// imesitishwa). Hali zinazoendelea (`pending`/`processing`) hazionyeshwi hapa
/// kwa sababu [AppLoadingOverlay] inashughulikia skrini wakati huo.
class AppPaymentStatusView extends StatelessWidget {
  const AppPaymentStatusView({
    super.key,
    required this.status,
    this.failure,
  });

  /// Hali ya malipo kutoka `PaymentStatus`.
  final PaymentStatus status;

  /// Kosa lililorudishwa na BLoC, kama lipo. Ujumbe wake wa lugha mbili
  /// unachukua nafasi ya ujumbe wa chaguo-msingi.
  final Failure? failure;

  /// Ikoni ya hali — chanzo kimoja kwa skrini zote.
  ///
  /// TANBIHI: ikoni hizi zote zipo kwenye Flutter 3.2 (hatutumii ikoni
  /// zilizoongezwa baadaye — kanuni ile ile ya toleo la `context_extensions`).
  static IconData iconFor(PaymentStatus status) => switch (status) {
        PaymentStatus.pending => Icons.access_time_rounded,
        PaymentStatus.processing => Icons.autorenew_rounded,
        PaymentStatus.completed => Icons.check_circle_rounded,
        PaymentStatus.failed => Icons.error_rounded,
        PaymentStatus.cancelled => Icons.cancel_rounded,
      };

  /// Rangi ya hali. Kijani cha mafanikio kinatoka [AppColors] (si
  /// `colorScheme.primary`) ili "imekamilika" isichanganyike na "chapa ya app".
  static Color colorFor(BuildContext context, PaymentStatus status) =>
      switch (status) {
        PaymentStatus.pending => context.colorScheme.primary,
        PaymentStatus.processing => context.colorScheme.primary,
        PaymentStatus.completed => AppColors.success,
        PaymentStatus.failed => context.colorScheme.error,
        PaymentStatus.cancelled => _muted(context),
      };

  @override
  Widget build(BuildContext context) {
    final Color tint = colorFor(context, status);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(iconFor(status), size: AppSpacing.iconXl, color: tint),
        const SizedBox(height: AppSpacing.md),
        Text(
          _headline(context),
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(
            color: tint,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _message(context),
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(color: _muted(context)),
        ),
      ],
    );
  }

  /// Kichwa cha habari. Kwa mafanikio na kushindwa tunatumia funguo za ARB
  /// (`paymentSuccessful` app_sw.arb:165, `paymentFailed` app_sw.arb:166)
  /// kwa sababu watafsiri wanazijua; hali nyingine zinatumia lebo ya enum.
  String _headline(BuildContext context) {
    switch (status) {
      case PaymentStatus.completed:
        return context.l10n.paymentSuccessful;
      case PaymentStatus.failed:
        return context.l10n.paymentFailed;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
      case PaymentStatus.cancelled:
        return TanzaniaCurrencyUtils.statusLabel(
          status,
          swahili: context.isSwahili,
        );
    }
  }

  /// Ujumbe wa maelezo. Kosa halisi (kama lipo) linashinda — `PaymentFailure`
  /// tayari ina maneno ya Kiswahili na Kiingereza.
  ///
  /// Funguo za ARB hazipo kwa sentensi hizi (tazama `AppPaymentSheet`), kwa
  /// hivyo zinaandikwa hapa kwa lugha mbili — mfano ule ule wa
  /// `custom_text_field.dart` na `Validators`.
  String _message(BuildContext context) {
    final Failure? error = failure;
    if (error != null) return error.message(swahili: context.isSwahili);

    switch (status) {
      case PaymentStatus.completed:
        return context.localised(
          swahili: 'Malipo yamekamilika. Unaweza kuanza kusoma sasa.',
          english: 'Payment complete. You can start reading now.',
        );
      case PaymentStatus.failed:
        return context.localised(
          swahili: 'Malipo hayakufanikiwa. Hakuna kiasi kilichokatwa.',
          english: 'Payment did not go through. No amount was deducted.',
        );
      case PaymentStatus.cancelled:
        return context.localised(
          swahili: 'Umesitisha malipo. Hakuna kiasi kilichokatwa.',
          english: 'Payment cancelled. No amount was deducted.',
        );
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return context.localised(
          swahili: 'Tunashughulikia malipo yako...',
          english: 'We are processing your payment...',
        );
    }
  }
}

// -----------------------------------------------------------------------------
// Kwenyeo (handle) na vipengele vidogo
// -----------------------------------------------------------------------------

/// Kipande kidogo kinachoonyesha kuwa karatasi inaweza kuvutwa chini.
Widget _dragHandle(BuildContext context) => Center(
      child: Container(
        width: 40,
        height: AppSpacing.xs,
        decoration: BoxDecoration(
          color: context.colorScheme.onSurface.withOpacity(0.20),
          borderRadius: AppSpacing.borderRadiusPill,
        ),
      ),
    );

/// Lebo ndogo ya sehemu ndani ya karatasi.
Widget _sectionLabel(BuildContext context, String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: _muted(context),
        ),
      ),
    );

/// Rangi hafifu ya maandishi ya pili.
///
/// HAITUMII `colorScheme.onSurfaceVariant`: rangi hiyo hairuhusiwi kubadilishwa
/// kwenye project hii (tazama `AppTheme`), kwa hivyo haitoi kauli yetu ya
/// kijani/turquoise. Tunaitoa kwa uwazi kutoka `onSurface`.
Color _muted(BuildContext context) =>
    context.colorScheme.onSurface.withOpacity(0.60);

/// Ikoni ya mtoa huduma — simu kwa malipo ya simu, kadi kwa kadi.
IconData _providerIcon(PaymentProvider provider) => provider.isMobileMoney
    ? Icons.phone_android_rounded
    : Icons.credit_card_rounded;

/// Lebo ya kitufe kikubwa, kutoka funguo za ARB zilizopo.
///
/// Kwa nini `switch` hapa: funguo za ARB zipo tayari kwa kila mtoa huduma
/// (`payWithMpesa` app_sw.arb:158 ... `payWithCard` app_sw.arb:162), kwa hivyo
/// hatuandiki sentensi mpya — tunachagua funguo sahihi.
String _payLabel(BuildContext context, PaymentProvider provider) {
  switch (provider) {
    case PaymentProvider.mpesa:
      return context.l10n.payWithMpesa;
    case PaymentProvider.tigoPesa:
      return context.l10n.payWithTigoPesa;
    case PaymentProvider.airtelMoney:
      return context.l10n.payWithAirtelMoney;
    case PaymentProvider.halopesa:
      return context.l10n.payWithHalopesa;
    case PaymentProvider.card:
      return context.l10n.payWithCard;
  }
}

/// Chaguo moja la mtoa huduma (kadi ndogo inayobonyezwa).
class _ProviderOption extends StatelessWidget {
  const _ProviderOption({
    required this.provider,
    required this.isSelected,
    this.onTap,
  });

  final PaymentProvider provider;
  final bool isSelected;

  /// `null` = chaguo halibonyezeki (kwa mfano mtumiaji hawezi kubadilisha
  /// mtoa huduma kwenye skrini hii), lakini bado linaonyeshwa.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color tint =
        isSelected ? scheme.primary : scheme.onSurface.withOpacity(0.60);
    final String label = TanzaniaCurrencyUtils.providerLabel(
      provider,
      swahili: context.isSwahili,
    );

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      enabled: onTap != null,
      label: label,
      // Bila hii, screen reader inasoma lebo yetu KISHA maandishi ya `Text`
      // mara ya pili — kasoro ile ile iliyorekebishwa kwenye
      // `swahili_text_widget.dart`.
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          // Kitufe kidogo lazima kifikie kipimo cha chini cha kugusa (48dp)
          // kwa vidole vya watumiaji wa simu za bei nafuu.
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary.withOpacity(0.10) : null,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: isSelected
                  ? scheme.primary
                  : scheme.onSurface.withOpacity(0.20),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(_providerIcon(provider), size: AppSpacing.iconSm, color: tint),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: tint,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Karatasi ya malipo
// -----------------------------------------------------------------------------

/// Karatasi ya malipo (bottom sheet) inayoshughulikia M-Pesa na wenzake.
///
/// Matumizi ya kawaida:
/// ```dart
/// AppPaymentSheet.show(
///   context,
///   builder: (BuildContext context) => BlocProvider.value(
///     value: paymentBloc,
///     child: BlocBuilder<PaymentBloc, PaymentState>(
///       builder: (context, state) => AppPaymentSheet(
///         amountTZS: 5000,
///         purposeSw: 'MSINGI kwa mwezi mmoja',
///         purposeEn: 'BASIC for one month',
///         isSubmitting: state.isSubmitting,
///         status: state.status,
///         failure: state.failure,
///         onSubmit: (request) => paymentBloc.add(SubmitPayment(request)),
///         onProviderChanged: (provider) =>
///             paymentBloc.add(SelectProvider(provider)),
///         onRetry: () => paymentBloc.add(RetryPayment()),
///       ),
///     ),
///   ),
/// );
/// ```
///
/// **Widget hii haiiti BLoC wala API.** Inatoa [PaymentRequest] na kuacha
/// BLoC ifanye kazi yake — ndiyo maana haina `BuildContext` ya `Navigator` ndani
/// yake isipokuwa `onClose` isipokuwa ikipewa.
class AppPaymentSheet extends StatefulWidget {
  const AppPaymentSheet({
    super.key,
    required this.amountTZS,
    required this.purposeSw,
    required this.purposeEn,
    required this.onSubmit,
    this.provider = PaymentProvider.mpesa,
    this.status = PaymentStatus.pending,
    this.isSubmitting = false,
    this.failure,
    this.phoneController,
    this.onProviderChanged,
    this.onRetry,
    this.onClose,
    this.titleSw,
    this.titleEn,
  }) : assert(
          amountTZS > 0,
          'Karatasi ya malipo haiitwi kwa kiasi 0 — hadithi za bure '
          'zinafunguliwa moja kwa moja bila malipo.',
        );

  /// Kiasi kinacholipwa kwa shilingi (TZS).
  final int amountTZS;

  /// Unacholipia, kwa Kiswahili.
  final String purposeSw;

  /// Unacholipia, kwa Kiingereza.
  final String purposeEn;

  /// Huitwa mtumiaji anapobonyeza "Lipa" **baada** ya nambari kuthibitishwa.
  ///
  /// `msisdn` tayari ni MSISDN iliyosafishwa — BLoC haihitaji kuisafisha tena.
  final ValueChanged<PaymentRequest> onSubmit;

  /// Mtoa huduma anayeonyeshwa kama amechaguliwa.
  final PaymentProvider provider;

  /// Hali ya malipo kutoka BLoC.
  final PaymentStatus status;

  /// `true` wakati ombi la malipo linaenda (STK push imetumwa, tunasubiri).
  final bool isSubmitting;

  /// Kosa lililorudishwa, kama lipo.
  final Failure? failure;

  /// Kidhibiti cha nambari ya simu. Bila hii, widget inajitengenezea yake.
  ///
  /// Ipitishe yako kama unahitaji kusoma nambari (mfano kuhifadhi kwenye BLoC
  /// kwa ombi la pili).
  final TextEditingController? phoneController;

  /// Huitwa mtumiaji anapobadilisha mtoa huduma.
  ///
  /// **Bila hii, orodha ya watoa huduma haiwezi kubadilishwa** — inaonyeshwa
  /// tu. Hii inaepusha hali ya kuchanganya: widget hii haihifadhi mtoa huduma
  /// (BLoC/`widget.provider` ndiye mwenye mamlaka), kwa hivyo kubadilisha
  /// ndani yake kungeunda vyanzo viwili vya ukweli.
  final ValueChanged<PaymentProvider>? onProviderChanged;

  /// Huitwa kwenye "Jaribu tena" baada ya malipo kushindwa au kusitishwa.
  final VoidCallback? onRetry;

  /// Huitwa kwenye "Ghairi"/"Tayari". Bila hii, karatasi inajifunga yenyewe.
  final VoidCallback? onClose;

  /// Kichwa maalum kwa Kiswahili (chaguo-msingi: `confirmPayment`).
  final String? titleSw;

  /// Kichwa maalum kwa Kiingereza.
  final String? titleEn;

  /// Hufungua karatasi kwa mipangilio sahihi ya malipo.
  ///
  /// `isScrollControlled: true` ni **lazima** kwa karatasi yenye uwanja wa
  /// maandishi: bila hiyo karatasi inabanwa kwenye nusu ya skrini na kibodi
  /// kufunika uwanja. `backgroundColor: Colors.transparent` inaruhusu
  /// [AppPaymentSheet] kuweka pembe zake za juu.
  static Future<void> show(
    BuildContext context, {
    required WidgetBuilder builder,
    bool dismissible = true,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: dismissible,
        enableDrag: dismissible,
        backgroundColor: Colors.transparent,
        builder: builder,
      );

  @override
  State<AppPaymentSheet> createState() => _AppPaymentSheetState();
}

class _AppPaymentSheetState extends State<AppPaymentSheet> {
  /// Funguo ya form — `validate()` huonyesha kosa **ndani ya uwanja**.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Kidhibiti cha ndani, kikitumika tu tusipo pewa kimoja.
  late TextEditingController _phone;

  /// `true` kama kidhibiti ni chetu — ndiyo maana ni **sisi** tunaohusika
  /// kulifuta. Kwenye simu ya 2GB RAM, `TextEditingController` isiyofutwa ni
  /// uvujaji wa kumbukumbu halisi.
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _phone = widget.phoneController ?? TextEditingController();
    _ownsController = widget.phoneController == null;
  }

  @override
  void didUpdateWidget(covariant AppPaymentSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mwenye widget anaweza kubadilisha kidhibiti (mfano baada ya kuingia
    // akaunti nyingine). Tunafuta chetu kisha tunachukua kipya.
    if (widget.phoneController != oldWidget.phoneController) {
      if (_ownsController) _phone.dispose();
      _phone = widget.phoneController ?? TextEditingController();
      _ownsController = widget.phoneController == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _phone.dispose();
    super.dispose();
  }

  /// `true` kama malipo yameshaisha — tunaonyesha matokeo badala ya form.
  bool get _isResolved =>
      widget.status == PaymentStatus.completed ||
      widget.status == PaymentStatus.failed ||
      widget.status == PaymentStatus.cancelled;

  /// `true` kama ombi linaendelea — overlay inafunika skrini yote.
  bool get _isBusy =>
      widget.isSubmitting || TanzaniaCurrencyUtils.isInProgress(widget.status);

  bool get _isCard => widget.provider == PaymentProvider.card;

  /// Hutuma ombi baada ya kuthibitisha nambari.
  ///
  /// Kwa nini hatuzuii kitufe kabla ya nambari kuwa sahihi: kitufe
  /// kinachojizima kimya kimya hakielezi kwa nini. Badala yake kitufe
  /// kinabonyezwa, `validate()` inaonyesha **sababu** chini ya uwanja
  /// (`Validators.phone` inatoa mfano `+255712345678`), na ombi halitumwi.
  void _submit(String raw) {
    if (_isBusy || _isResolved) return;

    if (!_isCard) {
      final bool isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) return;
    }

    widget.onSubmit(
      PaymentRequest(
        provider: widget.provider,
        amountTZS: widget.amountTZS,
        // `toMsisdn` inarudisha `null` kama nambari si sahihi; kwa kuwa
        // tumeisha hakikisha kwa `validate()`, hii ni kinga ya mwisho tu.
        msisdn: _isCard ? null : TanzaniaPhoneUtils.toMsisdn(raw),
      ),
    );
  }

  void _close() {
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AppLoadingOverlay(
      isLoading: _isBusy,
      // TANBIHI: hakuna funguo za ARB kwa ujumbe huu mahususi; tunaandika
      // lugha zote mbili hapa (mfano wa `Validators`/`custom_text_field.dart`)
      // badala ya kuunda funguo mpya kwenye ARB.
      messageSw: 'Tunasindika malipo yako... Usifunge app.',
      messageEn: 'Processing your payment... Do not close the app.',
      child: _buildSheet(context),
    );
  }

  Widget _buildSheet(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        // Kibodi ya simu ya 5" hufunika nusu ya skrini; tunasogeza karatasi
        // juu ili uwanja wa nambari usifichwe.
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.md,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        // Kwenye skrini ndogo, maudhui yote yanaweza kuzidi urefu — kwa hivyo
        // yanajipanga ndani ya kitu cha kusogeza badala ya kuvunjika
        // (kanuni ya 13: loading/error/empty states, lakini pia layout salama).
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            // `ValueListenableBuilder` inasikiliza kidhibiti ili muhtasari
            // (na hali ya kitufe) ujipange upya kila mtumiaji anapoandika.
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _phone,
              builder: (
                BuildContext context,
                TextEditingValue value,
                Widget? child,
              ) {
                final String raw = value.text;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _dragHandle(context),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _title(context),
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPaymentSummary(
                      amountTZS: widget.amountTZS,
                      purposeSw: widget.purposeSw,
                      purposeEn: widget.purposeEn,
                      provider: widget.provider,
                      phone: _isCard ? null : raw,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (_isResolved)
                      ..._buildResolved(context)
                    else
                      ..._buildForm(context, raw),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Kichwa: kile mwito ulichotoa, la sivyo `confirmPayment` ya ARB.
  String _title(BuildContext context) {
    final String? sw = widget.titleSw;
    final String? en = widget.titleEn;
    if (sw == null || en == null) return context.l10n.confirmPayment;
    return context.localised(swahili: sw, english: en);
  }

  /// Form ya malipo: mtoa huduma, nambari, na vitufe.
  List<Widget> _buildForm(BuildContext context, String raw) {
    final bool interactive = widget.onProviderChanged != null;

    return <Widget>[
      _sectionLabel(
        context,
        context.localised(
          swahili: 'Njia ya malipo',
          english: 'Payment method',
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: PaymentProvider.values
            .map(
              (PaymentProvider option) => _ProviderOption(
                provider: option,
                isSelected: option == widget.provider,
                onTap: interactive
                    ? () => widget.onProviderChanged!(option)
                    : null,
              ),
            )
            .toList(),
      ),
      const SizedBox(height: AppSpacing.xl),
      if (_isCard) ...<Widget>[
        _hint(
          context,
          icon: Icons.credit_card_rounded,
          textSw:
              'Utahamishwa kwenye ukurasa salama wa benki kukamilisha malipo kwa kadi.',
          textEn:
              'You will be taken to a secure bank page to complete the card payment.',
        ),
      ] else ...<Widget>[
        _sectionLabel(context, context.l10n.enterPhoneNumber),
        const SizedBox(height: AppSpacing.sm),
        TanzaniaPhoneInput(
          controller: _phone,
          textInputAction: TextInputAction.done,
          // Kitufe cha "endelea" cha kibodi kimaliza ombi moja kwa moja —
          // hatua moja pungufu kwa mtumiaji anayelipa kwa haraka.
          onSubmitted: _submit,
        ),
        const SizedBox(height: AppSpacing.md),
        _hint(
          context,
          icon: Icons.phone_android_rounded,
          textSw:
              'Utapokea ombi kwenye simu yako. Weka PIN yako kukamilisha malipo.',
          textEn:
              'You will receive a prompt on your phone. Enter your PIN to complete the payment.',
        ),
      ],
      const SizedBox(height: AppSpacing.xl),
      Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              // `cancel` ipo kwenye ARB (app_sw.arb:33).
              labelSw: context.l10n.cancel,
              labelEn: context.l10n.cancel,
              variant: AppButtonVariant.outline,
              onPressed: _close,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: AppButton(
              // Lebo inatoka funguo za ARB za mtoa huduma; `context.l10n`
              // tayari imetafsiri, kwa hivyo thamani ile ile inapitishwa kwa
              // lugha zote mbili (mfano wa `custom_button.dart`).
              labelSw: _payLabel(context, widget.provider),
              labelEn: _payLabel(context, widget.provider),
              // Kitufe kinajizima wakati ombi linaenda — kinga ya kwanza
              // dhidi ya malipo ya mara mbili (kanuni ya 14).
              isLoading: widget.isSubmitting,
              onPressed: _isBusy ? null : () => _submit(raw),
            ),
          ),
        ],
      ),
    ];
  }

  /// Matokeo: hali ya malipo pamoja na vitufe vinavyofaa.
  List<Widget> _buildResolved(BuildContext context) {
    // Kushindwa na kusitishwa zote zinaweza kujaribiwa tena; kukamilika
    // hakuwezi (tayari mtumiaji amepata bidhaa).
    final bool canRetry = widget.status == PaymentStatus.failed ||
        widget.status == PaymentStatus.cancelled;

    return <Widget>[
      AppPaymentStatusView(status: widget.status, failure: widget.failure),
      const SizedBox(height: AppSpacing.xl),
      Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              // `done` ipo kwenye ARB (app_sw.arb:36).
              labelSw: context.l10n.done,
              labelEn: context.l10n.done,
              variant: AppButtonVariant.outline,
              onPressed: _close,
            ),
          ),
          if (canRetry) ...<Widget>[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: AppButton(
                labelSw: context.l10n.tryAgain,
                labelEn: context.l10n.tryAgain,
                // Bila `onRetry` kitufe kinajizima — mwito ndiye anayejua
                // jinsi ya kurudia ombi.
                onPressed: widget.onRetry,
              ),
            ),
          ],
        ],
      ),
    ];
  }

  /// Mstari wa maelezo yenye ikoni — kwa maelekezo ya STK push na kadi.
  Widget _hint(
    BuildContext context, {
    required IconData icon,
    required String textSw,
    required String textEn,
  }) {
    final Color tint = _muted(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: AppSpacing.iconSm, color: tint),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            context.localised(swahili: textSw, english: textEn),
            style: context.textTheme.bodySmall?.copyWith(
              // `sizeCaption` haipo kwenye `AppTypography.textTheme`, kwa
              // hivyo tunaipunguza kwa kutaja chanzo kimoja (kanuni:
              // "delegate, don't duplicate").
              fontSize: AppTypography.sizeCaption,
              color: tint,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

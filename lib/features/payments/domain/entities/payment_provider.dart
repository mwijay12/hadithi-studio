/// Watoa huduma za malipo ya Tanzania (mobile money + kadi).
///
/// Kila kitu kuhusu mtoa huduma kimo hapa mahali pamoja: `id` ya API, jina
/// kwa lugha mbili, rangi ya chapa, na viambishi vya namba za simu. Kwa hivyo
/// kuongeza mtoa huduma mpya ni mabadiliko ya **moja** mahali.
///
/// **Kwa nini rangi ya chapa ipo hapa na si `AppColors`:** hizi ni rangi za
/// **kampuni nyingine** (Vodacom nyekundu, Tigo bluu), si rangi za Tanzania
/// zilizochaguliwa na sisi. `AppColors` ni palette yetu; hizi ni za wengine.
/// `StoryShelf` ilifanya uamuzi huu huu kwa `accent` yake.
///
/// **TANBIHI MUHIMU — viambishi havijathibitishwa.** Orodha ya viambishi hapa
/// chini inafuata spec ya Prompt 5. Ugawaji wa viambishi wa Tanzania
/// **hubadilika** (TCRA hutoa upya), hivyo orodha hii **lazima ithibitishwe**
/// na backend kabla ya kuzindua kwa pesa halisi. [TzPhoneValidator] hutumia
/// viambishi hivi kuchagua mtoa huduma **kwa mapendekezo pekee** — mtumiaji
/// anaweza kubadilisha mwenyewe. Kwa hivyo kosa la kiambishi huumiza kidogo
/// (mtumiaji huchagua kwa mkono) badala ya kuzuia malipo.
library;

import 'package:flutter/material.dart';

/// Mtoa huduma wa malipo.
enum PaymentProvider {
  /// Vodacom M-Pesa — mkubwa zaidi Tanzania.
  mpesa(
    'mpesa',
    'M-Pesa',
    'M-Pesa',
    'Vodacom',
    Color(0xFFE60000),
    <String>['74', '75', '76'],
  ),

  /// Tigo Pesa (Mixx by Yas).
  tigopesa(
    'tigopesa',
    'Tigo Pesa',
    'Tigo Pesa',
    'Tigo',
    Color(0xFF0066CC),
    <String>['71', '65', '67'],
  ),

  /// Airtel Money.
  airtelMoney(
    'airtelmoney',
    'Airtel Money',
    'Airtel Money',
    'Airtel',
    Color(0xFFED1C24),
    <String>['78', '69'],
  ),

  /// Halopesa (Halotel).
  halopesa(
    'halopesa',
    'Halopesa',
    'Halopesa',
    'Halotel',
    Color(0xFFFFD700),
    <String>['62'],
  ),

  /// Kadi ya benki (Visa/Mastercard).
  ///
  /// Haina viambishi, na **haihitaji namba ya simu** — hii ni tofauti
  /// muhimu kwenye fomu ya malipo.
  card(
    'card',
    'Kadi ya Benki',
    'Bank Card',
    'Visa / Mastercard',
    Color(0xFF1B4F72),
    <String>[],
  );

  const PaymentProvider(
    this.id,
    this.labelSw,
    this.labelEn,
    this.brandName,
    this.brand,
    this.prefixes,
  );

  /// Kitambulisho cha API (`POST /payments/initiate`).
  final String id;

  /// Jina kwa Kiswahili.
  final String labelSw;

  /// Jina kwa Kiingereza.
  final String labelEn;

  /// Jina la kampuni mama (Vodacom, Tigo…) — kwa maelezo madogo.
  final String brandName;

  /// Rangi ya chapa ya mtoa huduma.
  final Color brand;

  /// Viambishi vya namba za simu (tarakimu mbili za kwanza baada ya `0`).
  ///
  /// Tupu kwa [card]. Tazama TANBIHI kwenye doc ya faili hili.
  final List<String> prefixes;

  /// `true` = malipo yanahitaji namba ya simu.
  bool get requiresPhoneNumber => this != PaymentProvider.card;

  /// Jina kwa lugha iliyochaguliwa sasa.
  String label({required bool swahili}) => swahili ? labelSw : labelEn;

  /// Hupata mtoa huduma kutoka [id] ya API. `null` = haijulikani.
  static PaymentProvider? fromId(String id) {
    for (final PaymentProvider provider in PaymentProvider.values) {
      if (provider.id == id) return provider;
    }
    return null;
  }

  /// Watoa huduma wanaohitaji namba ya simu, kwa mpangilio wa kuonyesha.
  static List<PaymentProvider> get mobileMoney => PaymentProvider.values
      .where((PaymentProvider p) => p.requiresPhoneNumber)
      .toList();
}

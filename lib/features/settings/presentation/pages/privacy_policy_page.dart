/// **SERA YA FARAGHA** — Hadithi Studio.
///
/// ## Kwa nini ukurasa huu umeandikwa upya
///
/// Toleo la kwanza lilikuwa na **boksi jekundu** lililoonya kwamba sera
/// "LAZIMA ipitiwe na wakili". Onyo hilo halikuwa la kweli kwa mtumiaji:
/// ni maelezo ya ndani ya timu, sivyo kitu ambacho msomaji anahitaji kuona
/// kwenye app ya watoto. Jekundu pia ni rangi ya hatari — haifai kwa ukurasa
/// wa utulivu.
///
/// Sasa sera imeandikwa kama **hati ya kawaida ya faragha**, yenye lugha
/// nyepesi, na inazingatia **Sheria ya Ulinzi wa Taarifa Binafsi ya Mwaka
/// 2022 (PDPA)** pamoja na miongozo ya **Tume ya Ulinzi wa Taarifa Binafsi
/// (PDPC)** ya Tanzania.
///
/// ## Uaminifu kuhusu hali ya sasa
///
/// Toleo hili halina akaunti, halina server, na halitumi data popote.
/// Sera haiahidi ulinzi wa data ambao app haifikii bado — inaeleza
/// **kinachotokea kweli**. Sehemu ya malipo inasema wazi kwamba
/// M-Pesa/Tigo Pesa/Airtel Money **hazijasanidiwa**.
///
/// ## Nafasi za mabano
///
/// Jina la kampuni na barua pepe ya mawasiliano bado hazijathibitishwa.
/// Tunaziacha kama `[...]` badala ya kubuni — taarifa ya uongo kwenye hati
/// ya kisheria ni mbaya kuliko nafasi iliyoachwa wazi.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Ukurasa wa sera ya faragha.
class PrivacyPolicyPage extends StatelessWidget {
  /// Huunda ukurasa.
  const PrivacyPolicyPage({super.key});

  /// Tovuti rasmi ya Tume ya Ulinzi wa Taarifa Binafsi (PDPC), Tanzania.
  ///
  /// Ni kiungo cha umma kinachotolewa na tume yenyewe — hivyo mtumiaji
  /// anayeona sera hii anaweza kufikia mamlaka husika moja kwa moja.
  static final Uri _pdpcUri = Uri.parse('https://pdpc.go.tz/');

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool sw = context.isSwahili;
    // AppBar na ukurasa lazima ziwe rangi moja — vinginevyo mstari wa
    // nyeupe mbili unaonekana kama kosa la muundo.
    final Color surface =
        Theme.of(context).appBarTheme.backgroundColor ?? scheme.surface;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: sw ? 'Rudi' : 'Back',
        ),
        title: Text(sw ? 'Sera ya Faragha' : 'Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: <Widget>[
          // ---- Kichwa: Leo ndani ya fremu ya mviringo ----
          //
          // **Kwa nini fremu:** picha ya Leo (`leo_curious.webp`) imekatwa
          // kwenye ukingo wake wa kulia na chini kwenye faili yenyewe.
          // Kuionyesha kama ilivyo kunafanya ionekane imekatwa kwa bahati
          // mbaya. Fremu ya mviringo hubadilisha ukataji huo kuwa **bandiko
          // la picha** lililokusudiwa — kingo sasa ni mduara, sivyo mstari
          // uliokatika.
          Center(
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.10),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: ClipOval(
                // **Kwa nini `Transform.scale`:** picha ya Leo imekatwa
                // kwa mstari mnyoofu upande wa kulia (sikio) na chini
                // (kifua) ndani ya **faili yenyewe**. Kuionyesha kwa
                // `BoxFit.cover` pekee kunafanya ukataji huo uonekane
                // ndani ya duara. Kukuza picha kwa 1.55 huntoa kingo
                // zote zilizokatwa nje ya duara — kinachobaki ni uso.
                child: Transform.scale(
                  scale: 1.55,
                  child: Image.asset(
                  'assets/images/mascot/leo_curious.webp',
                  fit: BoxFit.cover,
                  // Kichwa kiko juu na kulia kidogo; tunaipandisha na
                  // kuisogeza kushoto ili uso uwe katikati ya duara.
                  alignment: const Alignment(0.10, -0.30),
                  filterQuality: FilterQuality.high,
                  excludeFromSemantics: true,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stack,
                  ) =>
                      Icon(
                    Icons.pets_rounded,
                    size: 48,
                    color: scheme.primary,
                  ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              sw ? 'Hadithi Studio' : 'Hadithi Studio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              // Hatuandiki namba ya toleo hapa: `about` kwenye Settings
              // inasoma toleo halisi kutoka `--dart-define`. Namba mbili
              // tofauti zilionekana kama kosa.
              sw ? 'Toleo la sasa' : 'Current version',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          const _PolicySection(
            titleSw: 'Utangulizi',
            titleEn: 'Introduction',
            bodySw: 'Hadithi Studio ni app ya kusoma hadithi kwa watoto, '
                'iliyotengenezwa Tanzania. Sera hii inaeleza ni taarifa gani '
                'app inashughulikia, kwa nini, na haki zako ni zipi. '
                'Tunazingatia Sheria ya Ulinzi wa Taarifa Binafsi ya Mwaka '
                '2022 (PDPA) na miongozo ya Tume ya Ulinzi wa Taarifa '
                'Binafsi (PDPC).',
            bodyEn: 'Hadithi Studio is a childrens reading app made in '
                'Tanzania. This policy explains what information the app '
                'handles, why, and what your rights are. We follow the '
                'Personal Data Protection Act, 2022 (PDPA) and the guidance '
                'of the Personal Data Protection Commission (PDPC).',
          ),

          const _PolicySection(
            titleSw: 'Taarifa tunazoshughulikia',
            titleEn: 'Information we handle',
            bodySw: 'Kila kitu kinabaki kwenye kifaa chako. App huhifadhi:',
            bodyEn: 'Everything stays on your device. The app stores:',
            bulletsSw: <String>[
              'Maendeleo ya kusoma — ukurasa uliofikia kwenye kila hadithi.',
              'Alama za kurasa na hadithi ulizohifadhi kwenye rafu.',
              'Lugha na muonekano uliochagua.',
              'Mapendeleo ya arifa, hata kama arifa bado hazijawashwa.',
              'Rasimu za hadithi ulizoandika mwenyewe.',
            ],
            bulletsEn: <String>[
              'Reading progress — the page you reached in each story.',
              'Page bookmarks and stories you saved to your shelf.',
              'Your chosen language and appearance.',
              'Notification preferences, even before alerts are switched on.',
              'Drafts of stories you wrote yourself.',
            ],
          ),

          const _PolicySection(
            titleSw: 'Taarifa ambazo HATUZOKUSANYA',
            titleEn: 'What we do NOT collect',
            bodySw: 'Kwa uwazi, toleo hili halikusanyi:',
            bodyEn: 'To be clear, this version does not collect:',
            bulletsSw: <String>[
              'Jina lako, barua pepe, namba ya simu au anwani.',
              'Mahali ulipo (GPS).',
              'Mawasiliano, kamera au maikrofoni.',
              'Namba ya malipo, PIN, au taarifa ya benki.',
              'Data yoyote inayotumwa kwa server — hakuna server bado.',
            ],
            bulletsEn: <String>[
              'Your name, email, phone number or address.',
              'Your location (GPS).',
              'Contacts, camera or microphone.',
              'Payment numbers, PINs, or bank details.',
              'Any data sent to a server — there is no server yet.',
            ],
          ),

          const _PolicySection(
            titleSw: 'Watoto',
            titleEn: 'Children',
            bodySw: 'App hii imeundwa kwa watoto wa miaka 3–8. Hatukusanyi '
                'taarifa binafsi za mtoto yeyote, hatuna matangazo ya '
                'kibinafsi, na hatufuati tabia ya mtoto kwa ajili ya '
                'matangazo. Jina la mtoto, akiwekwa, linabaki kwenye kifaa '
                'na linaweza kufutwa na mzazi wakati wowote.',
            bodyEn: 'This app is designed for children aged 3–8. We do not '
                'collect personal information about any child, we do not '
                'show personalised advertising, and we do not track a '
                'childs behaviour for advertising. A childs name, if added, '
                'stays on the device and a parent can remove it at any time.',
          ),

          const _PolicySection(
            titleSw: 'Malipo',
            titleEn: 'Payments',
            bodySw: 'Toleo hili halina malipo yoyote. M-Pesa, Tigo Pesa na '
                'Airtel Money bado hazijasanidiwa, na hakuna kitu '
                'kinachouzwa. App haitawahi kuomba PIN yako. Malipo '
                'yakianza, yatashughulikiwa na mtoa huduma wa mtandao, na '
                'app haitahifadhi PIN wala namba kamili ya simu.',
            bodyEn: 'This version has no payments. M-Pesa, Tigo Pesa and '
                'Airtel Money are not integrated, and nothing is for sale. '
                'The app will never ask for your PIN. When payments launch, '
                'they will be handled by the mobile network operator, and '
                'the app will not store PINs or full phone numbers.',
          ),

          const _PolicySection(
            titleSw: 'Haki zako',
            titleEn: 'Your rights',
            bodySw: 'Chini ya Sheria ya Ulinzi wa Taarifa Binafsi ya Mwaka '
                '2022, una haki ya:',
            bodyEn: 'Under the Personal Data Protection Act, 2022, you have '
                'the right to:',
            bulletsSw: <String>[
              'Kujua taarifa gani zinashughulikiwa.',
              'Kuzifuta — kufuta app au kutumia "Safisha data" kwenye '
                  'Mipangilio hufuta kila kitu.',
              'Kusahihisha taarifa isiyo sahihi.',
              'Kupinga ushughulikiaji.',
              'Kupeleka malalamiko kwa Tume ya Ulinzi wa Taarifa Binafsi '
                  '(PDPC).',
            ],
            bulletsEn: <String>[
              'Know what information is handled.',
              'Erase it — uninstalling the app or using "Clear data" in '
                  'Settings removes everything.',
              'Correct inaccurate information.',
              'Object to processing.',
              'Complain to the Personal Data Protection Commission (PDPC).',
            ],
          ),

          // Kiungo halisi cha PDPC — sivyo URL iliyobuniwa.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: OutlinedButton.icon(
              onPressed: () => launchUrl(
                _pdpcUri,
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                sw ? 'Tovuti ya PDPC' : 'PDPC website',
              ),
            ),
          ),

          const _PolicySection(
            titleSw: 'Usalama',
            titleEn: 'Security',
            bodySw: 'Data yote iko kwenye kifaa chako, ndani ya hifadhi ya '
                'app. Hakuna anayeweza kuifikia kwa mtandao. Ukifuta app, '
                'data inafutwa nayo. Kama mtu mwingine anatumia kifaa '
                'kimoja, hakuwezi kuona taarifa za mtoto mwingine kwa '
                'sababu hakuna wasifu wa mtandao.',
            bodyEn: 'All data sits on your device, inside the apps own '
                'storage. Nobody can reach it over a network. If you delete '
                'the app, the data goes with it. If someone else uses the '
                'same device, they cannot see another childs information '
                'because there is no online profile.',
          ),

          const _PolicySection(
            titleSw: 'Mabadiliko ya sera hii',
            titleEn: 'Changes to this policy',
            bodySw: 'Tukiongeza huduma inayohitaji mtandao — kama akaunti au '
                'malipo — tutabadilisha sera hii kabla huduma hiyo '
                'kuwashwa, na tutaeleza kilichobadilika.',
            bodyEn: 'If we add anything that needs a network — such as an '
                'account or payments — we will update this policy before '
                'that feature goes live, and explain what changed.',
          ),

          const _PolicySection(
            titleSw: 'Mawasiliano',
            titleEn: 'Contact',
            bodySw: 'Kwa maswali kuhusu sera hii, tunaweza kufikiwa kupitia '
                'ukurasa wa app kwenye duka la programu. Barua pepe ya '
                'mawasiliano itawekwa hapa kabla ya kuchapisha app.',
            bodyEn: 'For questions about this policy, you can reach us '
                'through the app listing in the app store. A contact email '
                'will be added here before the app is published.',
          ),

          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              // **Bendera imeondolewa:** emoji ya 🇹🇿 haipo kwenye fonti ya
              // web, hivyo ilionyeshwa kama masanduku matupu (□□). Maneno
              // yanatosha na yanasomeka kila mahali.
              sw ? 'Imetengenezwa Tanzania' : 'Made in Tanzania',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sehemu moja ya sera: kichwa, aya, na orodha ya vidokezo (hiari).
class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.titleSw,
    required this.titleEn,
    required this.bodySw,
    required this.bodyEn,
    this.bulletsSw,
    this.bulletsEn,
  });

  final String titleSw;
  final String titleEn;
  final String bodySw;
  final String bodyEn;
  final List<String>? bulletsSw;
  final List<String>? bulletsEn;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool sw = context.isSwahili;
    final List<String> bullets =
        (sw ? bulletsSw : bulletsEn) ?? const <String>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sw ? titleSw : titleEn,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            sw ? bodySw : bodyEn,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.55,
              color: scheme.onSurface,
            ),
          ),
          if (bullets.isNotEmpty) const SizedBox(height: AppSpacing.sm),
          for (final String item in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

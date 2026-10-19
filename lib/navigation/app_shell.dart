/// Shell ya app — tabu tano za chini na body inayobadilika.
///
/// **Kwa nini `StatefulNavigationShell` na si `IndexedStack` ya mkono:**
/// `StatefulNavigationShell` hutoka kwenye `StatefulShellRoute` ya
/// `go_router`, ambayo huweka `Navigator` **tofauti** kwa kila tabu. Kwa
/// hivyo kusukuma ukurasa wa hadithi ndani ya Maktaba kunabaki ndani ya
/// Maktaba: scroll position na back-stack ya Nyumbani hazigusiwi.
///
/// Tabu tano (kwa mpangilio wa [AppRoutes.tabLocations]):
/// 1. Nyumbani — hadithi za leo, mapendekezo
/// 2. Maktaba — hadithi zote kwa kundi/umri
/// 3. Tengeneza — kitovu (kimeinuliwa, ndiyo hatua kuu ya app)
/// 4. Rafu Yangu — zilizohifadhiwa, zinazoendelea
/// 5. Wasifu — mtoto, malipo, mipangilio
///
/// **Hali ya kurasa hizi:** ni mifano ya muundo (layout placeholders) yenye
/// data ya kubuni. Hazina BLoC wala mtandao bado — zinaonyesha mwonekano
/// halisi (rangi, typography, nafasi) ili muundo uweze kuhakikiwa mapema.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/routes/app_routes.dart';
import '../core/enums/app_enums.dart';
import '../core/extensions/context_extensions.dart';
import '../core/services/library_store.dart';
import '../core/widgets/leo_mascot.dart';
import '../l10n/app_locale_controller.dart';
import '../../config/theme/colors.dart';
import '../../config/theme/spacing.dart';
import '../features/stories/data/datasources/story_sample_data.dart';
import '../features/stories/domain/entities/story.dart';
import '../features/stories/domain/entities/story_shelf.dart';
import '../features/stories/presentation/story_navigation.dart';
import '../features/stories/presentation/widgets/shelf_tile.dart';
import '../features/stories/presentation/widgets/story_artwork.dart';
import '../features/stories/presentation/widgets/story_card.dart';
import '../l10n/l10n.dart';

/// Hadithi yenye `id` iliyotolewa, au `null` kama haipo.
///
/// **C9 — kosa lililokuwa hapa:** kazi hii ilirudisha `StorySampleData
/// .all.first` kwa `id` yoyote isiyojulikana. Yaani kadi iliyoandikwa
/// `'ngoma-ya-furaha'` ingeonyesha **Safari ya Simba** — hadithi isiyo
/// sahihi, ikiwa na kichwa cha hadithi nyingine. Mtumiaji hakuna namna
/// angejua; na kwenye orodha ya hadithi, kosa la aina hii husababisha
/// mtoto kufungua kitu asichokitaka.
///
/// Sasa: `id` isiyojulikana hurudisha `null`, na *kadi hiyo haijengwi*.
/// Hadithi inayokosekana **inaonekana** kama haipo — sivyo kama hadithi
/// nyingine yenye jina la uongo.
Story? storyById(String id) {
  for (final Story story in StorySampleData.all) {
    if (story.id == id) return story;
  }
  return null;
}

/// Hadithi kwa orodha ya `id`, zikipuuzwa zisizopatikana.
List<Story> storiesByIds(List<String> ids) =>
    ids.map(storyById).whereType<Story>().toList(growable: false);

/// Tabu moja ya shell.
enum AppShellTab {
  home,
  library,
  create,
  bookshelf,
  profile;

  /// Nembo ya tabu.
  IconData get icon {
    switch (this) {
      case AppShellTab.home:
        return Icons.home_rounded;
      case AppShellTab.library:
        return Icons.menu_book_rounded;
      case AppShellTab.create:
        return Icons.auto_awesome_rounded;
      case AppShellTab.bookshelf:
        return Icons.bookmark_rounded;
      case AppShellTab.profile:
        return Icons.person_rounded;
    }
  }

  /// Nembo iliyochaguliwa (inajaa).
  IconData get activeIcon {
    switch (this) {
      case AppShellTab.home:
        return Icons.home_rounded;
      case AppShellTab.library:
        return Icons.menu_book_rounded;
      case AppShellTab.create:
        return Icons.auto_awesome_rounded;
      case AppShellTab.bookshelf:
        return Icons.bookmark_rounded;
      case AppShellTab.profile:
        return Icons.person_rounded;
    }
  }

  /// Lebo kutoka ARB — hutafsiriwa wakati wa `build`, si hapa.
  String label(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    switch (this) {
      case AppShellTab.home:
        return l10n.home;
      case AppShellTab.library:
        return l10n.library;
      case AppShellTab.create:
        return l10n.create;
      case AppShellTab.bookshelf:
        return l10n.bookshelf;
      case AppShellTab.profile:
        return l10n.profile;
    }
  }
}

/// Shell yenye bottom navigation ya tabu tano.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  /// Shell ya `go_router` — huamua body na hutupa `goBranch`.
  final StatefulNavigationShell navigationShell;

  /// Hubadilisha tabu.
  ///
  /// `initialLocation: true` husukuma tabu hadi mzizi wake mtupu —
  /// hii ni tabia inayotarajiwa: kugusa tabu unayoisimamia huku
  /// umesukuma kurasa ndani yake hukurudisha mwanzo; kugusa tena
  /// ndipo kurudisha.
  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      // Body ni `StatefulNavigationShell` yenyewe — hairudishi `Navigator`
      // mpya, kwa hivyo hali ya kila tabu inahifadhiwa.
      body: navigationShell,
      bottomNavigationBar: Container(
        height: AppSpacing.bottomNavHeight + bottomInset,
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          // Kona za juu zilizozungushwa (24) — upau unaonekana kama kadi
          // inayoelea juu ya maudhui, sivyo ukuta wa kona kali.
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          // Kivuli chepesi hutenganisha nav na maudhui bila mstari mzito.
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTabSelected,
          // `fixed` ni muhimu: kwa `shifting`, kubonyeza tabu husababisha
          // rangi kubadilika na ukubwa kuruka — kelele isiyo na faida.
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          // Vitu visivyochaguliwa hutumia `onSurfaceVariant` ya theme — ndiyo
          // jukumu sahihi kwa maandishi ya pili, na linabadilika na mode.
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: AppShellTab.values.map((AppShellTab tab) {
            final int index = tab.index;
            return BottomNavigationBarItem(
              icon: tab == AppShellTab.create
                  ? _CreateBadge(
                      icon: tab.icon,
                      selected: navigationShell.currentIndex == index,
                    )
                  : Icon(tab.icon),
              activeIcon: tab == AppShellTab.create
                  ? _CreateBadge(icon: tab.activeIcon, selected: true)
                  : Icon(tab.activeIcon),
              label: tab.label(context),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Nembo ya "Tengeneza" — duara lililoinuliwa.
///
/// Kitovu cha app kinapaswa kuonekana tofauti: ndiyo hatua ambayo
/// hutengeneza thamani (na mapato). Duara hutumia rangi ya theme ili
/// ibaki sahihi kwenye mwanga na giza.
class _CreateBadge extends StatelessWidget {
  const _CreateBadge({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    // **Kwa nini 32 na si 48:** kwenye `BottomNavigationBar` yenye
    // `type: fixed`, kila kitufe ni cha urefu mmoja. Duara la 48 liliongeza
    // 24 px juu ya ikoni ya kawaida (24), likasuuza lebo yake chini —
    // "Tengeneza" iligongana na "Rafu Yangu". Duara la 32 hutoshea bila
    // kuvunja mstari, na bado linaonekana maalum kwa sababu ya gradient.
    return Container(
      width: AppSpacing.iconLg,
      height: AppSpacing.iconLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            selected ? primary : AppColors.kangaOrange,
            selected ? AppColors.zanzibarTurquoise : AppColors.sunsetGold,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: AppSpacing.iconSm, color: Colors.white),
    );
  }
}

// ---------------------------------------------------------------------------
// Kurasa za tabu — mifano ya muundo
// ---------------------------------------------------------------------------

/// Kichwa cha sehemu ndani ya tabu.
class _TabHeader extends StatelessWidget {
  const _TabHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            // **Rangi hutoka theme:** `AppColors.darkText` (#333) juu ya
            // mandhari NYEUSI ya dark mode ni karibu 1.2:1 — kichwa
            // hakionekani. Theme hutoa rangi sahihi kwa kila mode.
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}


/// Tabu 1 — Nyumbani.
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    // **C9:** kila kadi hutafuta hadithi yake kwa `id` HALISI. `id`
    // isiyojulikana hurudisha `null` na kadi hiyo **haijengwi** — badala ya
    // kuonyesha hadithi nyingine kwa jina la uongo.
    final Story? daily = storyById('safari-ya-simba');
    final List<Story> featured = storiesByIds(const <String>[
      'mlima-kilimanjaro',
      'nyota-za-usiku',
      'ngoma-ya-furaha',
    ]);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: <Widget>[
            _TabHeader(
              title: l10n.appName,
              subtitle: l10n.splashTagline,
            ),
            // Kadi kuu — hadithi ya leo. Ni kubwa kuliko kadi nyingine kwa
            // sababu ndiyo hatua moja tunayotaka mtumiaji aichukue kwanza.
            if (daily != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: StoryCard(
                  story: daily,
                  badge: l10n.dailyStory,
                  height: 200,
                  titleStyle: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                l10n.featured,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      // Theme: #333 juu ya mandhari nyeusi haisomeki.
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              // Kadi za wima (portrait) zinatosha kwa kifuniko cha kitabu —
              // 150x170 ni kubwa vya kutosha kuonyesha mchoro.
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                // Orodha hutengenezwa kutoka `featured`, hivyo `id` moja
                // ikikosekana hakuna kadi ya uongo na hakuna nafasi tupu.
                children: <Widget>[
                  for (int i = 0; i < featured.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 140,
                      child: StoryCard(
                        story: featured[i],
                        height: double.infinity,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tabu 2 — Maktaba.
///
/// **Kwa nini `StatefulWidget`:** vichujio vya lugha vinagusa na
/// vinabadilika. Ni hali ya skrini pekee (haitoki nje), kwa hivyo
/// `setState` inatosha — `Cubit` haitaleta faida yoyote hapa.
class LibraryTabPage extends StatefulWidget {
  const LibraryTabPage({super.key});

  @override
  State<LibraryTabPage> createState() => _LibraryTabPageState();
}

class _LibraryTabPageState extends State<LibraryTabPage> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    // Kikundi cha Maktaba hakitoki kwenye orodha ya ndani tena: kadi sita
    // hujengwa kutoka [StoryShelf.values] (tazama gridi ya `categories` chini).
    // Orodha ya zamani ya `<List<Object>>` iliacha picha, jina na rangi
    // vikitofautiana na `StoryShelf` — nakala mbili za ukweli mmoja.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: <Widget>[
            _TabHeader(
              title: l10n.library,
              subtitle: l10n.chooseInterestsSubtitle,
            ),
            // Kiungo kimoja badala ya chipu tatu za lugha.
            //
            // **Kwa nini:** chipu zilikuwa zikionekana kama kuchagua LUGHA YA
            // APP, kumbe zilikuwa kuchuja hadithi. Mtumiaji alishindwa kupata
            // mahali pa kubadilisha lugha. Sasa chaguo halisi kiko Settings,
            // na hapa tunatoa kiungo kinachoonyesha lugha ya sasa.
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Material(
                color: AppColors.safariGreen.withValues(alpha: 0.10),
                borderRadius: AppSpacing.borderRadiusMd,
                child: InkWell(
                  borderRadius: AppSpacing.borderRadiusMd,
                  onTap: () => context.pushNamed(AppRoutes.settingsName),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.translate_rounded,
                          size: AppSpacing.iconMd,
                          color: AppColors.safariGreen,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                l10n.appLanguage,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.safariGreen,
                                ),
                              ),
                              Text(
                                // Jina la lugha kwa lugha inayotumika sasa.
                                // `AppLanguage` haina `label(...)`, hivyo
                                // tunachagua `labelSw`/`labelEn` kwa mkono.
                                AppLocaleController.instance.language ==
                                        AppLanguage.swahili
                                    ? AppLocaleController
                                        .instance.language.labelSw
                                    : AppLocaleController
                                        .instance.language.labelEn,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.safariGreen,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                l10n.categories,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      // Theme: #333 juu ya mandhari nyeusi haisomeki.
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                // Kadi za wima: uwiano wa 0.78 huwapa nafasi picha
                // ionekane vizuri badala ya kubanwa.
                childAspectRatio: 0.78,
                children: <Widget>[
                  // Rafu sita kutoka [StoryShelf] moja kwa moja. Mpango wa
                  // vitufe na mpango wa enum ni ule ule, kwa hivyo hakuna
                  // orodha ya tatu ya kuweka sawa kila rafu mpya inapoongezwa.
                  for (final StoryShelf shelf in StoryShelf.values)
                    ShelfTile(
                      shelf: shelf,
                      onTap: () => openShelf(context, shelf),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tabu 3 — Tengeneza.
///
/// **C1 ilikuwa hapa:** ukurasa huu ulikuwa na vitufe **sifuri**. Safu tatu
/// za mapambo ("andika, paka rangi, rekodi sauti") zilionekana kama
/// hatua zinazoweza kubofywa, lakini ni `Container` tupu. Njia kuu ya app
/// ilikuwa imefungwa.
///
/// Sasa kuna vitendo viwili halisi:
/// * **Tengeneza Hadithi Mpya** — hufungua mhariri;
/// * **Hadithi Zangu** — orodha ya rasimu zilizohifadhiwa kwenye kifaa.
///
/// Rasimu huonyeshwa chini kama **taarifa** (bila `chevron`, bila mguso):
/// kuzifanya zibofye kungeahidi kitu ambacho hakipo — kufungua rasimu moja
/// kwa moja hufanyika ndani ya "Hadithi Zangu".
class CreateTabPage extends StatelessWidget {
  const CreateTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        // `ListenableBuilder` ili idadi ya rasimu ibadilike papo hapo
        // mtoto anaporudi kutoka mhariri.
        child: ListenableBuilder(
          listenable: LibraryStore.instance,
          builder: (BuildContext context, Widget? _) {
            final List<DraftStory> drafts = LibraryStore.instance.drafts;

            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: <Widget>[
                _TabHeader(
                  title: l10n.create,
                  subtitle: context.localised(
                    swahili: 'Andika hadithi yako mwenyewe',
                    english: 'Write your own story',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: StoryArtwork(
                    title: context.localised(
                      swahili: 'Utaweza kuandika hadithi yako',
                      english: 'You can write your own story',
                    ),
                    asset: 'assets/images/onboarding/onboarding_create.png',
                    accent: AppColors.kangaOrange,
                    height: 160,
                  ),
                ),

                // KITENDO KIKUU — mhariri.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.pushNamed(AppRoutes.createStoryName),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: Text(
                        context.localised(
                          swahili: 'Tengeneza Hadithi Mpya',
                          english: 'Create a New Story',
                        ),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // KITENDO CHA PILI — rasimu zilizopo. Namba ni halisi.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.pushNamed(AppRoutes.myStoriesName),
                      icon: const Icon(Icons.library_books_rounded),
                      label: Text(
                        drafts.isEmpty
                            ? context.localised(
                                swahili: 'Hadithi Zangu',
                                english: 'My Stories',
                              )
                            : context.localised(
                                swahili: 'Hadithi Zangu (${drafts.length})',
                                english: 'My Stories (${drafts.length})',
                              ),
                      ),
                    ),
                  ),
                ),

                // Muhtasari wa rasimu — taarifa, sivyo vitufe.
                if (drafts.isNotEmpty) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      context.localised(
                        swahili: 'Rasimu za karibuni',
                        english: 'Recent drafts',
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  for (final DraftStory draft in drafts.take(3))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          // `surfaceContainerHighest` ni ya Material 3
                          // mpya zaidi; Flutter 3.16 haina. `surfaceVariant`
                          // ndiyo jukumu lake hapa.
                          color:
                              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: AppSpacing.borderRadiusMd,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.description_outlined,
                              size: AppSpacing.iconSm,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                context.isSwahili
                                    ? draft.titleSw
                                    : draft.titleEn,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '${draft.pageCount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                // Ukweli kuhusu kile ambacho bado hakipo.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Text(
                    context.localised(
                      swahili: 'Kwa sasa unaandika maandishi pekee. Picha, '
                          'sauti na uchapishaji wa umma bado havijajengwa.',
                      english: 'For now you write text only. Pictures, audio '
                          'and public publishing are not built yet.',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Tabu 4 — Rafu Yangu.
///
/// **C9 ilikuwa hapa:** ukurasa huu ulionyesha kadi **moja** iliyoandikwa kwa
/// mkono — `'safari-ya-simba'` yenye `progress: 0.45`. Mtoto hakuwa
/// ameanza hadithi hiyo, na asilimia 45 ilikuwa ya kubuni.
///
/// Sasa kila kitu hutoka [LibraryStore] halisi:
/// * "Endelea Kusoma" — hadithi zenye ukurasa uliohifadhiwa, kwa upau
///   unaotokana na `page / pageCount`;
/// * "Zilizohifadhiwa" — alama za mtumiaji (C8);
/// * hakuna kitu kama hakuna kitu — na UI inasema hivyo.
class BookshelfTabPage extends StatelessWidget {
  const BookshelfTabPage({super.key});

  /// Maendeleo halisi ya [story] (`0.0`–`1.0`).
  ///
  /// Ni `0` kama hakuna ukurasa uliohifadhiwa au hadithi haina kurasa —
  /// hatubuni namba.
  static double progressOf(Story story) {
    final int? page = LibraryStore.instance.lastPage(story.id);
    if (page == null || story.pageCount == 0) return 0;
    return ((page + 1) / story.pageCount).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    // `ListenableBuilder` hujenga upya ukurasa huu wakati hifadhi inabadilika
    // (mfano mtoto anahifadhi hadithi kwenye reader, kisha anarudi hapa).
    return ListenableBuilder(
      listenable: LibraryStore.instance,
      builder: (BuildContext context, Widget? _) {
        final LibraryStore store = LibraryStore.instance;
        final List<Story> inProgress =
            storiesByIds(store.inProgressStoryIds);
        final List<Story> saved = storiesByIds(store.savedStories.toList());

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: <Widget>[
                _TabHeader(
                  title: l10n.bookshelf,
                  subtitle: context.localised(
                    swahili: 'Hadithi unazosoma na ulizohifadhi',
                    english: 'Stories you are reading and have saved',
                  ),
                ),

                if (inProgress.isEmpty && saved.isEmpty)
                  const _EmptyShelf()
                else ...<Widget>[
                  if (inProgress.isNotEmpty) ...<Widget>[
                    _ShelfSectionTitle(
                      title: l10n.continueReading,
                    ),
                    for (final Story story in inProgress)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        child: StoryArtwork(
                          title: story.title(swahili: context.isSwahili),
                          asset: story.coverAsset,
                          accent: story.accent,
                          badge: l10n.continueReading,
                          // Upau hutokana na ukurasa halisi uliohifadhiwa.
                          progress: progressOf(story),
                          height: 170,
                          // "Endelea kusoma" humpeleka mtumiaji **moja kwa
                          // moja** kwenye reader, si kwenye maelezo: hatua
                          // inayotarajiwa ni kuendelea kusoma.
                          onTap: () =>
                              openReader(context, story, autoPlay: true),
                        ),
                      ),
                  ],
                  if (saved.isNotEmpty) ...<Widget>[
                    _ShelfSectionTitle(
                      title: context.localised(
                        swahili: 'Zilizohifadhiwa',
                        english: 'Saved',
                      ),
                    ),
                    for (final Story story in saved)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        child: StoryArtwork(
                          title: story.title(swahili: context.isSwahili),
                          asset: story.coverAsset,
                          accent: story.accent,
                          height: 140,
                          onTap: () => openStory(context, story),
                        ),
                      ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Kichwa cha sehemu ndani ya Rafu Yangu.
class _ShelfSectionTitle extends StatelessWidget {
  const _ShelfSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Rafu tupu — inasema ukweli na kuonyesha njia ya kuanza.
///
/// **Kwa nini si kadi ya mfano:** kadi ya hadithi isiyoanzwa ingeonekana kama
/// mtoto anaendelea kusoma kitu — uongo mdogo, lakini wa kila siku.
class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        children: <Widget>[
          const LeoMascot(pose: LeoPose.curious, height: 120),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.localised(
              swahili: 'Rafu yako ni tupu bado',
              english: 'Your shelf is still empty',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.localised(
              swahili: 'Anza kusoma hadithi, au ihifadhi kwa alama — '
                  'zitaonekana hapa.',
              english: 'Start reading a story, or save one with a bookmark — '
                  'they will appear here.',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.goNamed(AppRoutes.libraryName),
            icon: const Icon(Icons.menu_book_rounded, size: AppSpacing.iconSm),
            label: Text(
              context.localised(
                swahili: 'Nenda Maktaba',
                english: 'Go to Library',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabu 5 — Wasifu.
///
/// **C2 ilikuwa hapa:** safu ya mtoto ilikuwa na `chevron_right` lakini
/// `onTap` haipo — alama ya kawaida ya "bofya hapa" bila kitu kinachotokea.
/// Kadi ya "Jiandikishe" nayo ilikuwa picha tupu.
///
/// Sasa zote mbili zinafanya kazi halisi:
/// * safu ya mtoto → [AppRoutes.childProfile] (jina + kundi la umri,
///   huhifadhiwa kwenye **kifaa pekee**);
/// * kadi ya usajili → [AppRoutes.subscription], ukurasa unaosema ukweli
///   kwamba malipo bado hayajasanidiwa.
class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: LibraryStore.instance,
          builder: (BuildContext context, Widget? _) {
            final String childName = LibraryStore.instance.childName;

            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: <Widget>[
                _TabHeader(
                  title: l10n.profile,
                  subtitle: context.localised(
                    swahili: 'Wasifu wako na mipangilio',
                    english: 'Your profile and settings',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    children: <Widget>[
                      // ---- Mipangilio — JUU, ionekane bila kuskroli ----
                      //
                      // **Kwa nini ipo juu:** mtumiaji aliripoti kwamba
                      // hakupata Settings kwenye Wasifu — aliifikia kwa
                      // kuandika `/settings` mwenyewe. Safu ya chini
                      // ilikuwa chini ya skrini. Sasa ni kadi ya kwanza.
                      Material(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: AppSpacing.borderRadiusMd,
                        child: InkWell(
                          borderRadius: AppSpacing.borderRadiusMd,
                          onTap: () =>
                              context.pushNamed(AppRoutes.settingsName),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.settings_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        context.localised(
                                          swahili: 'Mipangilio',
                                          english: 'Settings',
                                        ),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        context.localised(
                                          swahili:
                                              'Lugha, muonekano, faragha na data',
                                          english:
                                              'Language, appearance, privacy and data',
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ---- Safu ya mtoto — sasa inabofya ----
                      Material(
                        color: theme.colorScheme.surface,
                        borderRadius: AppSpacing.borderRadiusMd,
                        child: InkWell(
                          borderRadius: AppSpacing.borderRadiusMd,
                          onTap: () =>
                              context.pushNamed(AppRoutes.childProfileName),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              borderRadius: AppSpacing.borderRadiusMd,
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                const CircleAvatar(
                                  radius: AppSpacing.avatarSm,
                                  backgroundColor: AppColors.playfulYellow,
                                  backgroundImage: AssetImage(
                                    'assets/images/mascot_lion.png',
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        childName.isEmpty
                                            ? l10n.childProfile
                                            : childName,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        childName.isEmpty
                                            ? context.localised(
                                                swahili:
                                                    'Ongeza jina na umri wa mtoto',
                                                english:
                                                    "Add your child's name and age",
                                              )
                                            : context.localised(
                                                swahili: 'Gusa kubadilisha',
                                                english: 'Tap to edit',
                                              ),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ---- Usajili — kadi inabofya na ina maelezo ----
                      Material(
                        borderRadius: AppSpacing.borderRadiusMd,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () =>
                              context.pushNamed(AppRoutes.subscriptionName),
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  AppColors.safariGreen,
                                  AppColors.zanzibarTurquoise,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        l10n.subscribe,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  // **Hatuahidi kitu:** malipo
                                  // hayajasanidiwa. Tunaeleza kile
                                  // kinachopatikana sasa.
                                  context.localised(
                                    swahili: 'Angalia kinachokuja — malipo '
                                        'bado hayajawashwa',
                                    english: 'See what is planned — payments '
                                        'are not live yet',
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

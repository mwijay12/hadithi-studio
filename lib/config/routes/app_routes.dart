/// Njia za urambazaji za Hadithi Studio.
///
/// Faili hili ni **chanzo kimoja cha ukweli** kwa njia zote (paths) na
/// majina (names). Hakuna mahali pengine panapopaswa kuandika `'/home'`
/// kwa mkono — kila mwito huita [AppRoutes].
///
/// **Kwa nini `StatefulShellRoute.indexedStack`:** kila tabu ina
/// `Navigator` yake. Bila hii, kusukuma ukurasa wa hadithi ndani ya
/// Maktaba kungebadilisha tabu nzima na kupoteza scroll position na
/// back-stack ya tabu ile. Kwa `indexedStack`, kila tabu huhifadhi hali
/// yake — tabu nne zinaendelea kuwa hai hata mtumiaji akiwa tabu moja.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/create/presentation/pages/create_story_page.dart';
import '../../features/create/presentation/pages/my_stories_page.dart';
import '../../features/profile/presentation/pages/child_profile_page.dart';
import '../../features/profile/presentation/pages/subscription_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/stories/domain/entities/story.dart';
import '../../features/stories/domain/entities/story_shelf.dart';
import '../../features/stories/presentation/cubit/reader_cubit.dart';
import '../../features/stories/presentation/cubit/story_detail_cubit.dart';
import '../../features/stories/presentation/cubit/story_list_cubit.dart';
import '../../features/stories/presentation/pages/all_stories_page.dart';
import '../../features/stories/presentation/pages/shelf_page.dart';
import '../../features/songs/presentation/pages/songs_page.dart';
import '../../features/stories/presentation/pages/story_detail_page.dart';
import '../../features/stories/presentation/pages/story_reader_page.dart';
import '../../features/stories/presentation/stories_dependencies.dart';
import '../../navigation/app_shell.dart';

/// Njia na majina ya kurasa.
abstract final class AppRoutes {
  // ---------------------------------------------------------------------
  // Njia (paths)
  // ---------------------------------------------------------------------

  /// Skrini ya kuanza (splash).
  static const String splash = '/';

  /// Mtiririko wa kuwakaribisha watumiaji wapya.
  static const String onboarding = '/onboarding';

  /// Tabu 1 — Nyumbani.
  static const String home = '/home';

  /// Tabu 2 — Maktaba.
  static const String library = '/library';

  /// Tabu 3 — Tengeneza (kitovu cha app).
  static const String create = '/create';

  /// Tabu 4 — Rafu Yangu.
  static const String bookshelf = '/bookshelf';

  /// Tabu 5 — Wasifu.
  static const String profile = '/profile';

  /// Ukurasa wa maelezo ya hadithi moja — mfano `/story/safari-ya-simba`.
  static const String storyDetail = '/story/:id';

  /// **STORY READER** — kusoma/kusikiliza — mfano `/story/safari-ya-simba/read`.
  static const String reader = '/story/:id/read';

  /// Orodha ya hadithi za rafu moja — mfano `/category/safari`.
  static const String shelf = '/category/:id';

  /// Orodha ya hadithi **zote** (Maktaba kamili + utafutaji).
  static const String allStories = '/stories/all';

  /// **Mipangilio** — ikiwemo chaguo la lugha. Ngazi ya juu (haipo ndani
  /// ya tabu) ili `pushNamed` kutoka mahali popote itatuliwe.
  static const String settings = '/settings';

  /// **Sera ya Faragha** — huonyesha taarifa zilizohifadhiwa kifaa pekee.
  static const String privacyPolicy = '/settings/privacy';

  /// **Mipangilio ya Arifa** — huchagua arifa (huhifadhi kifaa).
  static const String notificationSettings = '/settings/notifications';

  /// **Mhariri wa hadithi** — mtoto/mzazi huandika hadithi yake.
  /// Nyimbo za watoto (katalogi ya nyimbo zilizowekwa kwenye assets).
  static const String songs = '/songs';

  static const String createStory = '/create/new';

  /// **Hadithi Zangu** — rasimu zilizohifadhiwa kwenye kifaa.
  static const String myStories = '/create/mine';

  /// **Wasifu wa mtoto** — jina na kundi la umri (kifaa pekee).
  static const String childProfile = '/profile/child';

  /// **Usajili** — hali ya malipo kwa uwazi (hakuna malipo bado).
  static const String subscription = '/profile/subscription';

  // ---------------------------------------------------------------------
  // Majina (names) — kwa `goNamed`/`pushNamed`
  // ---------------------------------------------------------------------

  static const String splashName = 'splash';
  static const String onboardingName = 'onboarding';
  static const String homeName = 'home';
  static const String libraryName = 'library';
  static const String createName = 'create';
  static const String bookshelfName = 'bookshelf';
  static const String profileName = 'profile';

  static const String storyDetailName = 'storyDetail';
  static const String readerName = 'reader';
  static const String shelfName = 'shelf';
  static const String allStoriesName = 'allStories';
  static const String settingsName = 'settings';
  static const String privacyPolicyName = 'privacyPolicy';
  static const String notificationSettingsName = 'notificationSettings';
  static const String songsName = 'songs';

  static const String createStoryName = 'createStory';
  static const String myStoriesName = 'myStories';
  static const String childProfileName = 'childProfile';
  static const String subscriptionName = 'subscription';

  /// Njia za tabu tano kwa mpangilio wa `AppShell`.
  ///
  /// Mpangilio huu **unapaswa** kuendana na orodha ya `AppShellTab` —
  /// kama utabadilisha mmoja, badilisha mwingine.
  static const List<String> tabLocations = <String>[
    home,
    library,
    create,
    bookshelf,
    profile,
  ];
}

/// Hujenga `GoRouter` mmoja kwa app.
abstract final class AppRouter {
  /// Huunda router.
  ///
  /// [initialLocation] huruhusu mwito kuamua pa kuanza: kawaida ni
  /// [AppRoutes.splash] (ambayo huamua mwenyewe pa kwenda), lakini
  /// kwenye preview ya web tunaweza kuanza moja kwa moja kwenye shell.
  static GoRouter router({String initialLocation = AppRoutes.splash}) {
    return GoRouter(
      initialLocation: initialLocation,
      debugLogDiagnostics: false,
      routes: <RouteBase>[
        // -----------------------------------------------------------------
        // 1. Splash
        // -----------------------------------------------------------------
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splashName,
          builder: (BuildContext context, GoRouterState state) =>
              const SplashPage(),
        ),

        // -----------------------------------------------------------------
        // 2. Onboarding
        // -----------------------------------------------------------------
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboardingName,
          builder: (BuildContext context, GoRouterState state) =>
              const OnboardingPage(),
        ),

        // -----------------------------------------------------------------
        // 3. Shell yenye tabu tano
        // -----------------------------------------------------------------
        StatefulShellRoute.indexedStack(
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) =>
              AppShell(navigationShell: navigationShell),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.home,
                  name: AppRoutes.homeName,
                  builder: (BuildContext context, GoRouterState state) =>
                      const HomeTabPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.library,
                  name: AppRoutes.libraryName,
                  builder: (BuildContext context, GoRouterState state) =>
                      const LibraryTabPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.create,
                  name: AppRoutes.createName,
                  builder: (BuildContext context, GoRouterState state) =>
                      const CreateTabPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.bookshelf,
                  name: AppRoutes.bookshelfName,
                  builder: (BuildContext context, GoRouterState state) =>
                      const BookshelfTabPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.profile,
                  name: AppRoutes.profileName,
                  builder: (BuildContext context, GoRouterState state) =>
                      const ProfileTabPage(),
                ),
              ],
            ),
          ],
        ),

        // -----------------------------------------------------------------
        // -----------------------------------------------------------------
        // 3b. Mipangilio — ngazi ya juu
        // -----------------------------------------------------------------
        GoRoute(
          path: AppRoutes.settings,
          name: AppRoutes.settingsName,
          builder: (BuildContext context, GoRouterState state) =>
              const SettingsPage(),
        ),

        // Sera ya faragha na arifa — ndani ya Settings.
        GoRoute(
          path: AppRoutes.privacyPolicy,
          name: AppRoutes.privacyPolicyName,
          builder: (BuildContext context, GoRouterState state) =>
              const PrivacyPolicyPage(),
        ),
        // Nyimbo — ukurasa wa katalogi (hali tupu kwa sasa, lakini
        // huamka yenyewe mara faili zikiwekwa kwenye `assets/audio/songs/`).
        GoRoute(
          path: AppRoutes.songs,
          name: AppRoutes.songsName,
          builder: (BuildContext context, GoRouterState state) =>
              const SongsPage(),
        ),
        GoRoute(
          path: AppRoutes.notificationSettings,
          name: AppRoutes.notificationSettingsName,
          builder: (BuildContext context, GoRouterState state) =>
              const NotificationSettingsPage(),
        ),

        // Tengeneza na Wasifu — ngazi ya juu kama `/settings`, ili kitufe
        // cha "Rudi" kirejee tabu ile ile iliyotumika.
        GoRoute(
          path: AppRoutes.createStory,
          name: AppRoutes.createStoryName,
          builder: (BuildContext context, GoRouterState state) =>
              const CreateStoryPage(),
        ),
        GoRoute(
          path: AppRoutes.myStories,
          name: AppRoutes.myStoriesName,
          builder: (BuildContext context, GoRouterState state) =>
              const MyStoriesPage(),
        ),
        GoRoute(
          path: AppRoutes.childProfile,
          name: AppRoutes.childProfileName,
          builder: (BuildContext context, GoRouterState state) =>
              const ChildProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.subscription,
          name: AppRoutes.subscriptionName,
          builder: (BuildContext context, GoRouterState state) =>
              const SubscriptionPage(),
        ),

        // 4. Kurasa za hadithi — **ngazi ya juu**, si ndani ya tabu
        // -----------------------------------------------------------------
        //
        // Hizi ni ndugu za `StatefulShellRoute`, si watoto wa branch yoyote.
        // Sababu: `go_router` hudai kila `name` iwe ya kipekee kwenye router
        // nzima. Kama tungeziweka ndani ya branch zote tano (kila tabu
        // inahitaji kuweza kufungua hadithi), tungekuwa na jina lile lile
        // `storyDetail` mara tano — na `go_router` **hutupa kosa wakati wa
        // runtime**. Kwa kuziweka ngazi ya juu, `pushNamed` kutoka tabu yoyote
        // inatatuliwa mahali pamoja.
        //
        // Kila builder husoma `state.pathParameters['id']` na `state.extra`
        // (`Story?`), kisha hujenga cubit yake na kuitia `BlocProvider` —
        // bila hivyo `BlocBuilder` wa ukurasa haungepata cubit.
        GoRoute(
          path: AppRoutes.storyDetail,
          name: AppRoutes.storyDetailName,
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id'] ?? '';
            final Story? story = state.extra as Story?;
            return BlocProvider<StoryDetailCubit>(
              create: (BuildContext context) => StoryDetailCubit(
                repository: resolveStoryRepository(),
                // `extra` hutupatia hadithi kamili kutoka kadi iliyoguswa:
                // ukurasa unaonekana **papo hapo**, bila spinner.
                initialStory: story,
              )..load(id),
              child: StoryDetailPage(storyId: id),
            );
          },
        ),

        GoRoute(
          path: AppRoutes.reader,
          name: AppRoutes.readerName,
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id'] ?? '';
            final Story? story = state.extra as Story?;
            // `auto=1` hutoka kwenye `openReader(autoPlay: true)` — "Sikiliza".
            final bool autoPlay = state.uri.queryParameters['auto'] == '1';
            return BlocProvider<ReaderCubit>(
              create: (BuildContext context) {
                final ReaderCubit cubit =
                    ReaderCubit(repository: resolveStoryRepository());
                if (story != null) {
                  // Tuna hadithi tayari — hatuhitaji ombi la `id`.
                  cubit.loadStory(story, autoPlay: autoPlay);
                } else {
                  // Kiungo kilichoshirikiwa — pakia kwa `id`.
                  cubit.loadById(id, autoPlay: autoPlay);
                }
                return cubit;
              },
              child: StoryReaderPage(storyId: id, autoPlay: autoPlay),
            );
          },
        ),

        GoRoute(
          path: AppRoutes.shelf,
          name: AppRoutes.shelfName,
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id'] ?? '';
            return BlocProvider<StoryListCubit>(
              create: (BuildContext context) {
                final StoryListCubit cubit =
                    StoryListCubit(repository: resolveStoryRepository());
                // `id` isiyojulikana haipakiwi — `ShelfPage` huonyesha hali
                // tupu kwa `StoryShelf.fromId(id) == null`.
                final StoryShelf? shelf = StoryShelf.fromId(id);
                if (shelf != null) cubit.loadShelf(shelf);
                return cubit;
              },
              child: ShelfPage(categoryId: id),
            );
          },
        ),

        GoRoute(
          path: AppRoutes.allStories,
          name: AppRoutes.allStoriesName,
          builder: (BuildContext context, GoRouterState state) {
            return BlocProvider<StoryListCubit>(
              create: (BuildContext context) => StoryListCubit(
                repository: resolveStoryRepository(),
              )..loadAll(),
              child: const AllStoriesPage(),
            );
          },
        ),
      ],
    );
  }
}

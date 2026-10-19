/// Kutatua `StoryRepository` bila kutegemea DI.
///
/// ## Kwa nini faili hili lipo
///
/// `main.dart` huita `di.init()` — ambayo husajili `ApiClient`, hifadhi na
/// cache — kabla ya `runApp`. Lakini `main_web_preview.dart` **hairudii** DI:
/// ni entrypoint ya preview ya web ambayo haina seva, haina Hive na haina
/// `flutter_secure_storage`. Kama kurasa zingeita `sl<StoryRepository>()`
/// moja kwa moja, preview ingeanguka kwa `GetIt` registration error kabla ya
/// kuchora kitu chochote.
///
/// Kwa hivyo kurasa huita [resolveStoryRepository] badala ya `sl<…>()`:
///
/// * Kwenye app kamili — DI imesajili implement (inaweza kuwa ya mtandao
///   baadaye), tunairudisha.
/// * Kwenye preview ya web — hakuna kilichosajiliwa, tunarudisha
///   [StoryRepositoryImpl] yenye data ya `StorySampleData`.
///
/// Hakuna tawi la `if (kIsWeb)` hapa, na hilo ni kwa makusudi: uamuzi hutegemea
/// **kilichosajiliwa**, si jukwaa. Preview hii itaendelea kufanya kazi hata
/// siku moja DI itakaposajiliwa kwenye web.
library;

import 'package:get_it/get_it.dart';

import '../data/repositories/story_repository_impl.dart';
import '../domain/repositories/story_repository.dart';

/// Hurudisha `StoryRepository` inayopatikana sasa.
///
/// Haitupi kamwe: kama hakuna iliyosajiliwa, hurudisha implement ya ndani
/// iliyojengwa juu ya data ya mfano. Hii inamaanisha kuwa kila ukurasa wa
/// hadithi unaweza kuonyesha maudhui hata bila mtandao — kinacholingana na
/// kanuni ya 7 (app ifanye kazi bila mtandao kwa neema).
StoryRepository resolveStoryRepository() {
  final GetIt sl = GetIt.instance;
  if (sl.isRegistered<StoryRepository>()) {
    return sl<StoryRepository>();
  }
  return StoryRepositoryImpl();
}

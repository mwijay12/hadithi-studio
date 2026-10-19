import '../app_config.dart';

/// Base URL, timeouts, headers na endpoints zote za backend.
///
/// Endpoints zimegawanywa kwa feature kama ilivyo kwenye spec §2.2.
/// Kila kundi ni `abstract final class` — hii inazuia kuundwa kwa
/// instance na kurithiwa, kwani hizi ni constants tu.
///
/// **Muhimu:** hakuna endpoint inayojengwa kwa mkono kwenye feature code.
/// Kila mahali panatumia constants hizi ili kubadilisha API iwe kitu kimoja.
abstract final class ApiConstants {
  // ─────────────────────────────────────────────────────────────
  // Base URL
  // ─────────────────────────────────────────────────────────────

  /// Base URL ya API inayotumika sasa (hutoka [AppConfig], hivyo
  /// hubadilika kwa mazingira: dev / staging / prod).
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// Prefix ya API: `/api/v1`.
  static const String apiPrefix = '/api/v1';

  /// Toleo la API.
  static const String apiVersion = 'v1';

  // ─────────────────────────────────────────────────────────────
  // Timeouts
  // ─────────────────────────────────────────────────────────────
  //
  // Tanzania ina mtandao wa 2G/3G sana, hivyo timeouts ni za ukarimu
  // kuliko app za kawaida. AI na TTS zinahitaji muda mrefu zaidi.

  /// Muda wa kuunganisha (connect).
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Muda wa kupokea jibu (receive).
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Muda wa kutuma data (send).
  static const Duration sendTimeout = Duration(seconds: 60);

  /// Kutengeneza hadithi kwa AI — hudumu hadi dakika 3.
  static const Duration aiGenerationTimeout = Duration(minutes: 3);

  /// Kutengeneza sauti (TTS) — hudumu hadi dakika 2.
  static const Duration ttsSynthesisTimeout = Duration(minutes: 2);

  /// Kupakia picha/ukurasa wa hadithi.
  static const Duration uploadTimeout = Duration(minutes: 5);

  /// Muda wa kusubiri malipo ya M-Pesa kuthibitishwa (polling).
  static const Duration paymentPollingInterval = Duration(seconds: 3);

  /// Muda mrefu wa kusubiri malipo kabla ya kukata tamaa.
  static const Duration paymentPollingTimeout = Duration(minutes: 3);

  /// Jaribio la kurudia (retry) kwa requests zilizoshindwa.
  static const int maxRetries = 3;

  // ─────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────

  /// Idadi ya hadithi kwa ukurasa mmoja (spec §6.4: 20 kwa ukurasa).
  static const int defaultPageSize = 20;

  /// Idadi ya reviews kwa ukurasa.
  static const int reviewsPageSize = 10;

  // ─────────────────────────────────────────────────────────────
  // Headers
  // ─────────────────────────────────────────────────────────────

  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAcceptLanguage = 'Accept-Language';
  static const String headerAppVersion = 'X-App-Version';
  static const String headerPlatform = 'X-Platform';
  static const String headerDeviceId = 'X-Device-Id';
  static const String headerClient = 'X-Client';

  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormUrlEncoded =
      'application/x-www-form-urlencoded';
  static const String contentTypeMultipart = 'multipart/form-data';

  /// Prefix ya token: `Bearer eyJhbGci...`
  static const String bearerPrefix = 'Bearer ';

  /// Luga inayotumwa kwa `Accept-Language` (Swahili ni ya msingi).
  static const String languageSwahili = 'sw';
  static const String languageEnglish = 'en';

  // ─────────────────────────────────────────────────────────────
  // HTTP status codes
  // ─────────────────────────────────────────────────────────────

  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusAccepted = 202;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusConflict = 409;
  static const int statusUnprocessableEntity = 422;
  static const int statusTooManyRequests = 429;
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;
}

/// AUTH — usajili, kuingia, uthibitisho wa namba ya simu (+255), OTP.
abstract final class AuthEndpoints {
  static const String register = '${ApiConstants.apiPrefix}/auth/register';
  static const String login = '${ApiConstants.apiPrefix}/auth/login';

  /// Uthibitisho wa namba ya simu ya Tanzania (+255).
  static const String phoneVerify = '${ApiConstants.apiPrefix}/auth/phone-verify';

  static const String sendOtp = '${ApiConstants.apiPrefix}/auth/otp/send';
  static const String verifyOtp = '${ApiConstants.apiPrefix}/auth/otp/verify';
  static const String refreshToken =
      '${ApiConstants.apiPrefix}/auth/refresh-token';
  static const String forgotPassword =
      '${ApiConstants.apiPrefix}/auth/forgot-password';

  /// Kufuta akaunti (mahitaji ya ulinzi wa data — §11).
  static const String deleteAccount = '${ApiConstants.apiPrefix}/auth/account';
}

/// STORIES — kusoma, kutafuta, makundi, featured, trending.
abstract final class StoryEndpoints {
  static const String stories = '${ApiConstants.apiPrefix}/stories';
  static const String featured = '${ApiConstants.apiPrefix}/stories/featured';
  static const String trending = '${ApiConstants.apiPrefix}/stories/trending';
  static const String categories = '${ApiConstants.apiPrefix}/stories/categories';
  static const String recommended =
      '${ApiConstants.apiPrefix}/stories/recommended';

  /// Maelezo ya hadithi moja: `/stories/:id`.
  static String detail(String storyId) =>
      '${ApiConstants.apiPrefix}/stories/$storyId';

  /// Kurasa zote za hadithi: `/stories/:id/pages`.
  static String pages(String storyId) =>
      '${ApiConstants.apiPrefix}/stories/$storyId/pages';

  /// Ukurasa mmoja: `/stories/:id/pages/:pageNum`.
  static String page(String storyId, int pageNumber) =>
      '${ApiConstants.apiPrefix}/stories/$storyId/pages/$pageNumber';

  /// Hadithi za kundi moja: `/stories/category/:slug`.
  static String byCategory(String slug) =>
      '${ApiConstants.apiPrefix}/stories/category/$slug';

  /// Alama ya kurasa (bookmark): `/stories/:id/bookmark`.
  static String bookmark(String storyId) =>
      '${ApiConstants.apiPrefix}/stories/$storyId/bookmark';

  /// Kumpenda (favorite): `/stories/:id/favorite`.
  static String favorite(String storyId) =>
      '${ApiConstants.apiPrefix}/stories/$storyId/favorite';

  /// Kuhifadhi maendeleo ya usomaji: `/stories/:id/progress`.
  static String progress(String storyId) =>
      '${ApiConstants.apiPrefix}/stories/$storyId/progress';
}

/// CREATOR — rasimu, AI text/image generation, kuchapisha.
abstract final class CreatorEndpoints {
  static const String drafts = '${ApiConstants.apiPrefix}/creator/drafts';

  /// Kutengeneza maandishi ya hadithi kwa AI (GPT-4/GPT-4o).
  static const String generateText =
      '${ApiConstants.apiPrefix}/creator/generate-text';

  /// Kutengeneza picha kwa AI (DALL-E 3 / SDXL).
  static const String generateIllustration =
      '${ApiConstants.apiPrefix}/creator/generate-illustration';

  /// Kutengeneza jalada (cover) kwa AI.
  static const String generateCover =
      '${ApiConstants.apiPrefix}/creator/generate-cover';

  static const String templates = '${ApiConstants.apiPrefix}/creator/templates';
  static const String publish = '${ApiConstants.apiPrefix}/creator/publish';
  static const String myStories = '${ApiConstants.apiPrefix}/creator/my-stories';
  static const String analytics = '${ApiConstants.apiPrefix}/creator/analytics';

  /// Rasimu moja: `/creator/drafts/:id`.
  static String draft(String draftId) =>
      '${ApiConstants.apiPrefix}/creator/drafts/$draftId';
}

/// TTS — kutengeneza sauti ya Kiswahili na muda wa maneno.
abstract final class TtsEndpoints {
  /// Kutengeneza sauti: `POST /tts/synthesize`.
  static const String synthesize = '${ApiConstants.apiPrefix}/tts/synthesize';

  /// Sauti zinazopatikana: `GET /tts/voices`.
  static const String voices = '${ApiConstants.apiPrefix}/tts/voices';

  /// Muda wa kila neno kwa word highlighting: `POST /tts/word-timings`.
  static const String wordTimings =
      '${ApiConstants.apiPrefix}/tts/word-timings';
}

/// PAYMENTS — M-Pesa, Tigo Pesa, Airtel Money, Halopesa, kadi.
abstract final class PaymentEndpoints {
  /// Vodacom M-Pesa (mtandao mkubwa Tanzania).
  static const String mpesaInitiate =
      '${ApiConstants.apiPrefix}/payments/mpesa/initiate';

  /// Tigo Pesa.
  static const String tigoPesaInitiate =
      '${ApiConstants.apiPrefix}/payments/tigopesa/initiate';

  /// Airtel Money.
  static const String airtelMoneyInitiate =
      '${ApiConstants.apiPrefix}/payments/airtelmoney/initiate';

  /// Halopesa.
  static const String halopesaInitiate =
      '${ApiConstants.apiPrefix}/payments/halopesa/initiate';

  /// Hali ya malipo: `/payments/status/:transactionId`.
  static String status(String transactionId) =>
      '${ApiConstants.apiPrefix}/payments/status/$transactionId';

  static const String subscriptionPlans =
      '${ApiConstants.apiPrefix}/payments/subscriptions/plans';
  static const String subscribe =
      '${ApiConstants.apiPrefix}/payments/subscriptions/subscribe';
  static const String cancelSubscription =
      '${ApiConstants.apiPrefix}/payments/subscriptions/cancel';

  static const String transactions =
      '${ApiConstants.apiPrefix}/payments/transactions';

  /// Mapato ya mwandishi (creator earnings).
  static const String earnings = '${ApiConstants.apiPrefix}/payments/earnings';

  /// Kutoa mapato kwa M-Pesa (minimum TZS 10,000).
  static const String withdrawEarnings =
      '${ApiConstants.apiPrefix}/payments/earnings/withdraw';
}

/// PROFILE — wasifu, takwimu, mafanikio, watoto, udhibiti wa mzazi.
abstract final class ProfileEndpoints {
  static const String profile = '${ApiConstants.apiPrefix}/profile';
  static const String stats = '${ApiConstants.apiPrefix}/profile/stats';
  static const String achievements =
      '${ApiConstants.apiPrefix}/profile/achievements';

  /// Wasifu wa watoto (hadi 5 kwa FAMILIA).
  static const String children = '${ApiConstants.apiPrefix}/profile/children';

  /// Udhibiti wa mzazi (PIN, muda wa skrini, filters).
  static const String parentalControls =
      '${ApiConstants.apiPrefix}/profile/parental-controls';

  /// Mtoto mmoja: `/profile/children/:id`.
  static String child(String childId) =>
      '${ApiConstants.apiPrefix}/profile/children/$childId';
}

/// COMMUNITY — maoni, waandishi, changamoto, leaderboard.
abstract final class CommunityEndpoints {
  /// Maoni ya hadithi: `/reviews/story/:id`.
  static String reviewsForStory(String storyId) =>
      '${ApiConstants.apiPrefix}/reviews/story/$storyId';

  static const String createReview = '${ApiConstants.apiPrefix}/reviews';

  /// Wasifu wa mwandishi: `/authors/:id`.
  static String author(String authorId) =>
      '${ApiConstants.apiPrefix}/authors/$authorId';

  static String followAuthor(String authorId) =>
      '${ApiConstants.apiPrefix}/authors/$authorId/follow';

  static const String challenges = '${ApiConstants.apiPrefix}/challenges';

  static String joinChallenge(String challengeId) =>
      '${ApiConstants.apiPrefix}/challenges/$challengeId/join';

  /// Leaderboard (kitaifa na kwa mkoa wa Tanzania).
  static const String leaderboard = '${ApiConstants.apiPrefix}/leaderboard';
}

/// NOTIFICATIONS — taarifa na mapendeleo yake.
abstract final class NotificationEndpoints {
  static const String notifications =
      '${ApiConstants.apiPrefix}/notifications';
  static const String preferences =
      '${ApiConstants.apiPrefix}/notifications/preferences';

  /// Kufunga taarifa moja kama imesomwa: `/notifications/:id/read`.
  static String markAsRead(String notificationId) =>
      '${ApiConstants.apiPrefix}/notifications/$notificationId/read';
}

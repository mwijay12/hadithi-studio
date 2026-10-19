import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('sw'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Hadithi Studio'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Read. Listen. Live the Story.'**
  String get tagline;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// Home screen greeting using the user's first name.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}!'**
  String greeting(String name);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @bookshelf.
  ///
  /// In en, this message translates to:
  /// **'My Shelf'**
  String get bookshelf;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search stories...'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title, author or category'**
  String get searchHint;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @splashGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hadithi Studio!'**
  String get splashGreeting;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Read. Listen. Live the Story.'**
  String get splashTagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your library...'**
  String get splashLoading;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Read Stories That Come Alive'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Beautifully illustrated stories that spark your child\'s imagination, in Swahili and English.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Listen in Swahili Voice'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Hear stories read aloud in clear Swahili while each word is highlighted as it is spoken.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Create Your Own Story'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Use AI to write and illustrate your own story, from a single idea to a finished book.'**
  String get onboardingBody3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get onboardingTitle4;

  /// No description provided for @onboardingBody4.
  ///
  /// In en, this message translates to:
  /// **'Pick Swahili, English or both. You can change this at any time.'**
  String get onboardingBody4;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The language you prefer to use in the app.'**
  String get chooseLanguageSubtitle;

  /// No description provided for @chooseAgeGroup.
  ///
  /// In en, this message translates to:
  /// **'Choose Age Group'**
  String get chooseAgeGroup;

  /// No description provided for @chooseAgeGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will recommend stories that suit this age.'**
  String get chooseAgeGroupSubtitle;

  /// No description provided for @chooseInterests.
  ///
  /// In en, this message translates to:
  /// **'Pick Your Favourite Categories'**
  String get chooseInterests;

  /// No description provided for @chooseInterestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select one or more. You can change these later.'**
  String get chooseInterestsSubtitle;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bilingual.
  ///
  /// In en, this message translates to:
  /// **'Both Languages'**
  String get bilingual;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured Stories'**
  String get featured;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @dailyStory.
  ///
  /// In en, this message translates to:
  /// **'Story of the Day'**
  String get dailyStory;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning!'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon!'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening!'**
  String get goodEvening;

  /// No description provided for @readNow.
  ///
  /// In en, this message translates to:
  /// **'Read Now'**
  String get readNow;

  /// No description provided for @listenNow.
  ///
  /// In en, this message translates to:
  /// **'Listen Now'**
  String get listenNow;

  /// No description provided for @createdInTanzania.
  ///
  /// In en, this message translates to:
  /// **'Created in Tanzania'**
  String get createdInTanzania;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendations;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @myDownloads.
  ///
  /// In en, this message translates to:
  /// **'My Downloads'**
  String get myDownloads;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @myStories.
  ///
  /// In en, this message translates to:
  /// **'My Stories'**
  String get myStories;

  /// No description provided for @drafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get drafts;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read Aloud'**
  String get readAloud;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @veryFast.
  ///
  /// In en, this message translates to:
  /// **'Very fast'**
  String get veryFast;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @readingTime.
  ///
  /// In en, this message translates to:
  /// **'Reading Time'**
  String get readingTime;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @publishDate.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publishDate;

  /// No description provided for @tapToInteract.
  ///
  /// In en, this message translates to:
  /// **'Tap to interact!'**
  String get tapToInteract;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// Page indicator, e.g. 'Page 3 of 10'.
  ///
  /// In en, this message translates to:
  /// **'of {total}'**
  String ofPages(int total);

  /// No description provided for @ttsVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get ttsVoice;

  /// No description provided for @voiceMama.
  ///
  /// In en, this message translates to:
  /// **'Mama'**
  String get voiceMama;

  /// No description provided for @voiceBaba.
  ///
  /// In en, this message translates to:
  /// **'Baba'**
  String get voiceBaba;

  /// No description provided for @voiceMtoto.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get voiceMtoto;

  /// No description provided for @autoPageTurn.
  ///
  /// In en, this message translates to:
  /// **'Auto Page Turn'**
  String get autoPageTurn;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get fontSize;

  /// No description provided for @nightMode.
  ///
  /// In en, this message translates to:
  /// **'Night Mode'**
  String get nightMode;

  /// No description provided for @createStory.
  ///
  /// In en, this message translates to:
  /// **'Create Story'**
  String get createStory;

  /// No description provided for @generateStory.
  ///
  /// In en, this message translates to:
  /// **'Generate Story with AI'**
  String get generateStory;

  /// No description provided for @generateIllustration.
  ///
  /// In en, this message translates to:
  /// **'Generate Illustration with AI'**
  String get generateIllustration;

  /// No description provided for @chooseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose Template'**
  String get chooseTemplate;

  /// No description provided for @storyTitle.
  ///
  /// In en, this message translates to:
  /// **'Story Title'**
  String get storyTitle;

  /// No description provided for @storyDescription.
  ///
  /// In en, this message translates to:
  /// **'Story Description'**
  String get storyDescription;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose Category'**
  String get chooseCategory;

  /// No description provided for @chooseArtStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose Art Style'**
  String get chooseArtStyle;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @aiGenerating.
  ///
  /// In en, this message translates to:
  /// **'AI is generating...'**
  String get aiGenerating;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Start from Scratch'**
  String get custom;

  /// No description provided for @pageCount.
  ///
  /// In en, this message translates to:
  /// **'Number of Pages'**
  String get pageCount;

  /// No description provided for @characterBuilder.
  ///
  /// In en, this message translates to:
  /// **'Character Builder'**
  String get characterBuilder;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get premium;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @planBure.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get planBure;

  /// No description provided for @planMsingi.
  ///
  /// In en, this message translates to:
  /// **'BASIC'**
  String get planMsingi;

  /// No description provided for @planVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get planVip;

  /// No description provided for @planFamilia.
  ///
  /// In en, this message translates to:
  /// **'FAMILY'**
  String get planFamilia;

  /// No description provided for @payWithMpesa.
  ///
  /// In en, this message translates to:
  /// **'Pay with M-Pesa'**
  String get payWithMpesa;

  /// No description provided for @payWithTigoPesa.
  ///
  /// In en, this message translates to:
  /// **'Pay with Tigo Pesa'**
  String get payWithTigoPesa;

  /// No description provided for @payWithAirtelMoney.
  ///
  /// In en, this message translates to:
  /// **'Pay with Airtel Money'**
  String get payWithAirtelMoney;

  /// No description provided for @payWithHalopesa.
  ///
  /// In en, this message translates to:
  /// **'Pay with Halopesa'**
  String get payWithHalopesa;

  /// No description provided for @payWithCard.
  ///
  /// In en, this message translates to:
  /// **'Pay with Card'**
  String get payWithCard;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @parentalControls.
  ///
  /// In en, this message translates to:
  /// **'Parental Controls'**
  String get parentalControls;

  /// No description provided for @screenTime.
  ///
  /// In en, this message translates to:
  /// **'Screen Time'**
  String get screenTime;

  /// No description provided for @childProfile.
  ///
  /// In en, this message translates to:
  /// **'Child Profile'**
  String get childProfile;

  /// No description provided for @childProfiles.
  ///
  /// In en, this message translates to:
  /// **'Child Profiles'**
  String get childProfiles;

  /// No description provided for @readingStats.
  ///
  /// In en, this message translates to:
  /// **'Reading Stats'**
  String get readingStats;

  /// No description provided for @readingLevel.
  ///
  /// In en, this message translates to:
  /// **'Reading Level'**
  String get readingLevel;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get ageGroup;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to your phone.'**
  String get otpSent;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet'**
  String get noInternet;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline — showing downloaded stories.'**
  String get offlineBanner;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network connection. Check your internet.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get errorServer;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @storageFull.
  ///
  /// In en, this message translates to:
  /// **'Storage is full. Delete some downloaded stories.'**
  String get storageFull;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage Used'**
  String get storageUsed;

  /// No description provided for @catAnimalStories.
  ///
  /// In en, this message translates to:
  /// **'Animal Stories'**
  String get catAnimalStories;

  /// No description provided for @catMoralsWisdom.
  ///
  /// In en, this message translates to:
  /// **'Morals & Wisdom'**
  String get catMoralsWisdom;

  /// No description provided for @catScience.
  ///
  /// In en, this message translates to:
  /// **'Science for Kids'**
  String get catScience;

  /// No description provided for @catCulture.
  ///
  /// In en, this message translates to:
  /// **'Tanzanian Culture'**
  String get catCulture;

  /// No description provided for @catPoemsSongs.
  ///
  /// In en, this message translates to:
  /// **'Poems & Songs'**
  String get catPoemsSongs;

  /// No description provided for @catSafari.
  ///
  /// In en, this message translates to:
  /// **'Safari & Adventure'**
  String get catSafari;

  /// No description provided for @storySafariYaSimba.
  ///
  /// In en, this message translates to:
  /// **'Simba\'s Safari'**
  String get storySafariYaSimba;

  /// No description provided for @storyMlimaKilimanjaro.
  ///
  /// In en, this message translates to:
  /// **'Mount Kilimanjaro'**
  String get storyMlimaKilimanjaro;

  /// No description provided for @storyNyotaZaUsiku.
  ///
  /// In en, this message translates to:
  /// **'Stars of the Night'**
  String get storyNyotaZaUsiku;

  /// No description provided for @storyNgomaYaFuraha.
  ///
  /// In en, this message translates to:
  /// **'The Happy Drum'**
  String get storyNgomaYaFuraha;

  /// Hint inside the immersive search bar on the All Stories page.
  ///
  /// In en, this message translates to:
  /// **'Search stories, authors, categories...'**
  String get searchPlaceholder;

  /// Page title for the complete library listing.
  ///
  /// In en, this message translates to:
  /// **'All Stories'**
  String get allStories;

  /// Reactive result count above a story grid, e.g. '24 stories found'.
  ///
  /// In en, this message translates to:
  /// **'{count} stories found'**
  String storiesFound(int count);

  /// Empty-state title when filters or a search return nothing.
  ///
  /// In en, this message translates to:
  /// **'No matching stories'**
  String get noStoriesFound;

  /// Empty-state hint suggesting the user widen the filter.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter'**
  String get tryDifferentFilter;

  /// Action that resets every active filter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// Label of the button that opens the filter bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Confirm button inside the filter bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// Header action inside the filter sheet that resets the selection.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Sort order: most recently published first.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// Sort order: most read first.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get sortPopular;

  /// Sort order: highest rating first.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get sortRating;

  /// Sort order: title alphabetical.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get sortName;

  /// Neutral chip meaning no filter is applied.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Short chip label for the newest-first sort. Not the same as sortNewest.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// Short chip label for the most-read sort.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// Chip that keeps only free stories.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeOnly;

  /// Footer shown while the next page of stories is loading.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get loadingMore;

  /// Hint shown while a pull-to-refresh gesture is in progress.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// Title of the settings panel that slides over the reader.
  ///
  /// In en, this message translates to:
  /// **'Reading Settings'**
  String get readingSettings;

  /// Label of the reading-mode selector in the reader settings panel.
  ///
  /// In en, this message translates to:
  /// **'Reading mode'**
  String get readingMode;

  /// Reading mode: text on screen plus audio reading it aloud (default).
  ///
  /// In en, this message translates to:
  /// **'Read and Listen'**
  String get readAndListen;

  /// Reading mode: audio only, for bedtime listening.
  ///
  /// In en, this message translates to:
  /// **'Listen Only'**
  String get listenOnly;

  /// Reading mode: no audio at all, silent reading.
  ///
  /// In en, this message translates to:
  /// **'Read Only'**
  String get readOnly;

  /// How long the reader waits before turning the page by itself.
  ///
  /// In en, this message translates to:
  /// **'Page turn delay'**
  String get turnDelay;

  /// Short label for the auto page-turn delay chips.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String delaySeconds(int seconds);

  /// Switch that adds soft music behind the narration (not wired yet).
  ///
  /// In en, this message translates to:
  /// **'Background music'**
  String get backgroundMusic;

  /// Slider label for the background-music volume.
  ///
  /// In en, this message translates to:
  /// **'Music volume'**
  String get musicVolume;

  /// Asked when the reader finds a saved position for this story.
  ///
  /// In en, this message translates to:
  /// **'Continue reading from page {page}?'**
  String continuePrompt(int page);

  /// Action that ignores the saved position and starts at page one.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// Heading of the dialog shown when the last page is finished.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Body of the completion dialog.
  ///
  /// In en, this message translates to:
  /// **'You have finished the story!'**
  String get storyComplete;

  /// Action in the completion dialog that returns to the shelf.
  ///
  /// In en, this message translates to:
  /// **'Read another story'**
  String get readAnother;

  /// Action in the completion dialog that opens the rating prompt.
  ///
  /// In en, this message translates to:
  /// **'Rate this story'**
  String get rateStory;

  /// Overflow action that reports a problem with the story.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportStory;

  /// Overflow action that shows story information.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get storyInfo;

  /// Tooltip of the overflow menu button in the reader.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// Hint that a single word can be tapped to be read aloud.
  ///
  /// In en, this message translates to:
  /// **'Tap a word to hear it'**
  String get tapToHear;

  /// Short confirmation after saving a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved'**
  String get bookmarkAdded;

  /// Short confirmation after removing a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get bookmarkRemoved;

  /// Speech speed chip between Slow and Normal.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get speedGentle;

  /// Speech speed chip between Normal and Fast.
  ///
  /// In en, this message translates to:
  /// **'A bit fast'**
  String get speedQuick;

  /// No description provided for @aboutTheStory.
  ///
  /// In en, this message translates to:
  /// **'About the Story'**
  String get aboutTheStory;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get readLess;

  /// No description provided for @writtenBy.
  ///
  /// In en, this message translates to:
  /// **'Written by {author}'**
  String writtenBy(String author);

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @readers.
  ///
  /// In en, this message translates to:
  /// **'{count} readers'**
  String readers(int count);

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviews(int count);

  /// No description provided for @pagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String pagesCount(int count);

  /// No description provided for @readingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String readingTimeLabel(int minutes);

  /// No description provided for @similarStories.
  ///
  /// In en, this message translates to:
  /// **'Similar Stories'**
  String get similarStories;

  /// No description provided for @userReviews.
  ///
  /// In en, this message translates to:
  /// **'Reader Reviews'**
  String get userReviews;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get errorOccurred;

  /// No description provided for @unlockFor.
  ///
  /// In en, this message translates to:
  /// **'Unlock for TZS {price}'**
  String unlockFor(String price);

  /// No description provided for @shareStoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Read \"{title}\" on Hadithi Studio!'**
  String shareStoryMessage(String title);

  /// No description provided for @crashTitle.
  ///
  /// In en, this message translates to:
  /// **'Sorry! Something went wrong 😔'**
  String get crashTitle;

  /// No description provided for @crashMessage.
  ///
  /// In en, this message translates to:
  /// **'We apologise. Something unexpected happened.'**
  String get crashMessage;

  /// No description provided for @restartApp.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartApp;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblem;

  /// No description provided for @reportProblemCopied.
  ///
  /// In en, this message translates to:
  /// **'Details copied. Send them to support.'**
  String get reportProblemCopied;

  /// No description provided for @errorDetails.
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get errorDetails;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @notAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get notAvailableYet;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

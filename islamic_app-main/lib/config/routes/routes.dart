enum Routes {
  splash,
  main,
  // v2
  // Bottom Navigation
  home,
  mosque,
  prayers,
  quran,
  more,
  
  // Auth
  login,
  signup,
  forgotPassword,
  
  /// Quran
  verseView,
  verseViewSettings,
  quranReadingMode,
  memorizationReport,
  // Mosque
  addMosque,
  favoriteMosques,
  // More
  qibla,
  hadith,
  hadithChapters,
  hadithList,
  hadithDetail,
  hadithSearch,
  zakat,
  aiChatbot,
  chatHistory,
  duaCollection,
  faq,
  prayerGuide,
  hajjGuide,
  wuduGuide,
  freeQuran,
  trivia,
  triviaSoloLobby,
  triviaSolo,
  triviaGroupLobby,
  triviaGroupGame,
  triviaLeaderboard,
  settings,
  
  // Legal
  aboutUs,
  termsConditions,
  privacyPolicy,
  contactUs,

  // Others
  mapsLocationPicker,
  locationPicker,
  
  // Subscription
  subscription,

  // end v2

  // onboard Settings
  chooseLanguageOnboard,
  getPrayerTimesOnboard,
  locationDetailsOnboard,

  // Prayers
  prayersCalendar,
  notificationSettings,
  prayerNotificationSettings,

  // Location
  searchLocation,
  // Settings
  calculationSettings,
  // Settings (not sub-routes)
  calculationMethodSettings(pathParameters: {'method'}),
  selectTimeZone,

  // Others
  ;

  const Routes({
    this.pathOverride,
    this.pathParameters,
  });
  final String? pathOverride;
  final Set<String>? pathParameters;

  String get path {
    final initialPath = pathOverride ?? '/$name';
    if (pathParameters != null) {
      return '$initialPath/:${pathParameters!.join('/:')}';
    } else {
      return initialPath;
    }
  }
}

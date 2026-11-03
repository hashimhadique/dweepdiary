class AppConstants {
  // App Branding
  static const String appName = 'Dweep Diary';
  static const String appTagline = 'Lakshadweep News Portal';
  static const String websiteUrl = 'https://dweepdiary.in';
  
  // WordPress REST API Endpoint for dweepdiary.in
  static const String apiBaseUrl = 'https://dweepdiary.in/index.php?rest_route=/wp/v2';
  static const String postsEndpoint = '$apiBaseUrl/posts';
  static const String categoriesEndpoint = '$apiBaseUrl/categories';

  // OneSignal Push Notification App ID
  static const String oneSignalAppId = '2e9f508d-8921-4b81-9e4a-a553ac2ce8b4';

  // ════════════════════════════════════════════════════════════
  // GOOGLE ADMOB CONFIGURATION (REVENUE & ADS)
  // ════════════════════════════════════════════════════════════
  // Set to 'false' to show REAL production ads and earn revenue
  static const bool useTestAds = false;

  // Google AdMob Official App ID
  static const String adMobAppIdAndroid = 'ca-app-pub-9969872629451816~3787335139';

  // Real Production AdMob Unit IDs (From your AdMob Dashboard)
  static const String adMobBannerIdAndroid = 'ca-app-pub-9969872629451816/5777792395';
  static const String adMobInterstitialIdAndroid = 'ca-app-pub-9969872629451816/5777792395';

  // Google Safe Test IDs (fallback for dev testing)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  // Dynamic getters based on useTestAds flag
  static String get activeBannerId => useTestAds ? _testBannerId : adMobBannerIdAndroid;
  static String get activeInterstitialId => useTestAds ? _testInterstitialId : adMobInterstitialIdAndroid;

  // Frequency of showing Interstitial ad (show on every 2nd article open)
  static const int interstitialAdInterval = 2;

  // Minimum interval between interstitial ads (e.g. at least 60 seconds)
  static const int minInterstitialIntervalSeconds = 60;

  // Local sponsored ad banner URL
  static const String defaultSponsoredAdUrl = 'https://dweepdiary.in/wp-content/uploads/2026/07/Dweep-diary-ads.webp';

  // ════════════════════════════════════════════════════════════
  // CONTACT & SERVICES
  // ════════════════════════════════════════════════════════════
  static const String contactEmail = 'contact@dweepdiary.in';
  
  // Official Dweep Diary WhatsApp Editorial Desk (Updated)
  static const String whatsAppEditorialNumber = '+918289883750';

  // IRCTC Lakshadweep Ship URLs
  static const String shipAlertsUrl = 'https://lakshadweep.irctc.co.in/alert-announcements';
  static const String shipBookingUrl = 'https://lakshadweep.irctc.co.in';

  static const String shareAppText = 'Get the latest news from Lakshadweep and Kerala. Download the Dweep Diary Mobile App: https://dweepdiary.in';
}

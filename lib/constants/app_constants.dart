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

  // Google AdMob Official App ID
  static const String adMobAppIdAndroid = 'ca-app-pub-9969872629451816~3787335139';
  
  // Google AdMob Unit IDs (Safe test IDs during development)
  static const String adMobBannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String adMobInterstitialIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String adMobNativeIdAndroid = 'ca-app-pub-3940256099942544/2247696110';

  // Real Play Store Banner ID: 'ca-app-pub-9969872629451816/5777792395'
  
  static const String adMobBannerIdIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String adMobInterstitialIdIos = 'ca-app-pub-3940256099942544/4411468910';

  // Frequency of showing Interstitial ad (every N article clicks)
  static const int interstitialAdInterval = 4;

  // Local sponsored ad banner URL
  static const String defaultSponsoredAdUrl = 'https://dweepdiary.in/wp-content/uploads/2026/07/Dweep-diary-ads.webp';

  // Contact & Social
  static const String contactEmail = 'contact@dweepdiary.in';
  static const String shareAppText = 'Get the latest news from Lakshadweep and Kerala. Download the Dweep Diary Mobile App: https://dweepdiary.in';
}

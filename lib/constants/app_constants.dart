class AppConstants {
  // App Branding
  static const String appName = 'Dweep Diary';
  static const String appTagline = 'ലക്ഷദ്വീപിന്റെ വാർത്താ ജാലകം';
  static const String websiteUrl = 'https://dweepdiary.in';
  
  // WordPress REST API Endpoint for dweepdiary.in
  static const String apiBaseUrl = 'https://dweepdiary.in/index.php?rest_route=/wp/v2';
  static const String postsEndpoint = '$apiBaseUrl/posts';
  static const String categoriesEndpoint = '$apiBaseUrl/categories';

  // OneSignal Push Notification App ID
  // Configured with Dweep Diary OneSignal App ID
  static const String oneSignalAppId = '2e9f508d-8921-4b81-9e4a-a553ac2ce8b4';

  // Google AdMob Official App ID
  static const String adMobAppIdAndroid = 'ca-app-pub-9969872629451816~3787335139';
  
  // Google AdMob Unit IDs
  // SAFE TESTING MODE: Google Official Test IDs are active during development/testing
  // to protect your AdMob account from policy violations / invalid traffic bans.
  static const String adMobBannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111'; // Safe Google Test Banner
  static const String adMobInterstitialIdAndroid = 'ca-app-pub-3940256099942544/1033173712'; // Safe Google Test Interstitial
  static const String adMobNativeIdAndroid = 'ca-app-pub-3940256099942544/2247696110'; // Safe Google Test Native

  // NOTE FOR PLAY STORE RELEASE:
  // When publishing to Google Play Store, swap the Banner ID above with your Real Ad Unit ID:
  // static const String adMobBannerIdAndroid = 'ca-app-pub-9969872629451816/5777792395'; // Your Real Banner Ad Unit
  
  static const String adMobBannerIdIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String adMobInterstitialIdIos = 'ca-app-pub-3940256099942544/4411468910';

  // Frequency of showing Interstitial ad (every N article clicks)
  static const int interstitialAdInterval = 4;

  // Local sponsored ad banner URL (can be customized from remote config or API)
  static const String defaultSponsoredAdUrl = 'https://dweepdiary.in/wp-content/uploads/2026/07/Dweep-diary-ads.webp';

  // Contact & Social
  static const String contactEmail = 'contact@dweepdiary.in';
  static const String shareAppText = 'ലക്ഷദ്വീപിലെയും കേരളത്തിലെയും ഏറ്റവും പുതിയ വാർത്തകൾ ഉടനടി അറിയാൻ Dweep Diary മൊബൈൽ ആപ്പ് ഡൗൺലോഡ് ചെയ്യുക: https://dweepdiary.in';
}

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  int _articleOpenCounter = 0;

  Map<String, dynamic>? _customSponsorAd;
  Map<String, dynamic>? get customSponsorAd => _customSponsorAd;

  Future<void> init() async {
    _loadInterstitialAd();
    _fetchCustomSponsorAd();
  }

  Future<void> _fetchCustomSponsorAd() async {
    try {
      final ad = await ApiService().fetchCustomSponsorAd();
      if (ad != null && ad['active'] == true) {
        _customSponsorAd = ad;
      }
    } catch (_) {}
  }

  void _loadInterstitialAd() {
    if (_isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: AppConstants.adMobInterstitialIdAndroid,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _setupInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _setupInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd(); // Preload next interstitial
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );
  }

  /// Call this whenever an article is opened
  void onArticleOpened() {
    _articleOpenCounter++;
    if (_articleOpenCounter % AppConstants.interstitialAdInterval == 0) {
      showInterstitialAd();
    }
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      _loadInterstitialAd();
    }
  }
}

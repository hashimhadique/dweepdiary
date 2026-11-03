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
  DateTime? _lastInterstitialShownTime;

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

    final unitId = AppConstants.activeInterstitialId;
    debugPrint('AdService: Loading Interstitial Ad unit $unitId...');

    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: InterstitialAd loaded successfully!');
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _setupInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('AdService: InterstitialAd failed to load: $error');
          // Retry after 15 seconds
          Future.delayed(const Duration(seconds: 15), () {
            if (_interstitialAd == null) _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void _setupInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _lastInterstitialShownTime = DateTime.now();
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

    // Check if cooldown elapsed
    final now = DateTime.now();
    final canShowByTime = _lastInterstitialShownTime == null ||
        now.difference(_lastInterstitialShownTime!).inSeconds >=
            AppConstants.minInterstitialIntervalSeconds;

    // Show if interval reached OR time elapsed
    if (_articleOpenCounter % AppConstants.interstitialAdInterval == 0 && canShowByTime) {
      showInterstitialAd();
    } else if (_interstitialAd == null) {
      _loadInterstitialAd();
    }
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _lastInterstitialShownTime = DateTime.now();
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      _loadInterstitialAd();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../services/ad_service.dart';

enum AdBannerType {
  adMob,
  customSponsor,
  auto,
}

class AdBannerWidget extends StatefulWidget {
  final AdBannerType type;
  final String? customImageUrl;
  final String? customRedirectUrl;

  const AdBannerWidget({
    super.key,
    this.type = AdBannerType.auto,
    this.customImageUrl,
    this.customRedirectUrl,
  });

  const AdBannerWidget.adMob({super.key})
      : type = AdBannerType.adMob,
        customImageUrl = null,
        customRedirectUrl = null;

  const AdBannerWidget.customSponsor({
    super.key,
    this.customImageUrl,
    this.customRedirectUrl,
  }) : type = AdBannerType.customSponsor;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdMobLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == AdBannerType.adMob || widget.type == AdBannerType.auto) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.adMobBannerIdAndroid,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdMobLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdMobLoaded = false;
            });
          }
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // If strictly custom sponsor or auto fallback when AdMob not loaded
    if (widget.type == AdBannerType.customSponsor ||
        (!_isAdMobLoaded && widget.type == AdBannerType.auto) ||
        widget.type == AdBannerType.customSponsor) {
      return _buildCustomSponsorBanner(isDark);
    }

    // Google AdMob Banner
    if (_isAdMobLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Default to Custom Sponsor Banner
    return _buildCustomSponsorBanner(isDark);
  }

  Widget _buildCustomSponsorBanner(bool isDark) {
    final remoteAd = AdService().customSponsorAd;
    final imageUrl = widget.customImageUrl ??
        remoteAd?['imageUrl'] ??
        AppConstants.defaultSponsoredAdUrl;
    final redirectUrl = widget.customRedirectUrl ??
        remoteAd?['redirectUrl'] ??
        AppConstants.websiteUrl;
    final sponsorLabel = remoteAd?['sponsoredText'] ?? 'SPONSORED';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(redirectUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  height: 68,
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : AppColors.primaryLight,
                  child: Center(
                    child: Text(
                      'ADVERTISEMENT',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white70 : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
              Positioned(
                top: 6,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    sponsorLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

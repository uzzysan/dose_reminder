import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // Test Ad Unit IDs (Google)
  final String _testAdUnitId = _getTestAdUnitId();

  // Production Ad Unit IDs
  final String _productionAdUnitId = 'ca-app-pub-3287491879097224/3529190931';

  // Use test ads for development, production for release
  String get _adUnitId => const bool.fromEnvironment('dart.vm.product')
      ? _productionAdUnitId
      : _testAdUnitId;

  static String _getTestAdUnitId() {
    if (kIsWeb) {
      return ''; // Web doesn't support AdMob banners
    }
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/9214589741' // Android test banner
        : 'ca-app-pub-3940256099942544/2435281174'; // iOS test banner
  }

  @override
  void initState() {
    super.initState();
    // Only load ads on mobile platforms
    if (!kIsWeb) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ads on web
    if (kIsWeb || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Function(bool isPlaying)? onStateChanged;

  Future<void> init() async {
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setPitch(1.0);

    // Try setting Malayalam voice or fallback to default
    try {
      final languages = await _flutterTts.getLanguages;
      if (languages.contains('ml-IN')) {
        await _flutterTts.setLanguage('ml-IN');
      } else {
        await _flutterTts.setLanguage('en-IN');
      }
    } catch (_) {}

    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      onStateChanged?.call(true);
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      onStateChanged?.call(false);
    });

    _flutterTts.setErrorHandler((msg) {
      _isPlaying = false;
      onStateChanged?.call(false);
    });
  }

  Future<void> speak(String text) async {
    if (_isPlaying) {
      await stop();
    }
    if (text.trim().isNotEmpty) {
      await _flutterTts.speak(text);
      _isPlaying = true;
      onStateChanged?.call(true);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
    onStateChanged?.call(false);
  }
}

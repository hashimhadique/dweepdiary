import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  List<String> _chunks = [];
  int _currentChunkIndex = 0;
  bool _isInitialized = false;

  Function(bool isPlaying)? onStateChanged;
  Function(int current, int total)? onProgressChanged;

  Future<void> init() async {
    if (_isInitialized) return;

    await _flutterTts.setSpeechRate(0.46);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    // Try setting Malayalam voice or fallback to Indian English/Default
    try {
      final languages = await _flutterTts.getLanguages;
      if (languages.contains('ml-IN')) {
        await _flutterTts.setLanguage('ml-IN');
      } else if (languages.contains('ml')) {
        await _flutterTts.setLanguage('ml');
      } else {
        await _flutterTts.setLanguage('en-IN');
      }
    } catch (_) {}

    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      onStateChanged?.call(true);
    });

    _flutterTts.setCompletionHandler(() {
      _onChunkCompleted();
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
      onStateChanged?.call(false);
    });

    _flutterTts.setErrorHandler((msg) {
      // If one chunk hits an error, try the next chunk or finish
      if (_currentChunkIndex + 1 < _chunks.length) {
        _currentChunkIndex++;
        _speakCurrentChunk();
      } else {
        _isPlaying = false;
        onStateChanged?.call(false);
      }
    });

    _isInitialized = true;
  }

  /// Split long article into manageable sentence chunks (<= 250 chars)
  List<String> _splitText(String fullText) {
    final clean = fullText.replaceAll('\r', '').trim();
    if (clean.isEmpty) return [];

    final List<String> result = [];
    final paragraphs = clean.split(RegExp(r'\n+'));

    for (var para in paragraphs) {
      final trimmedPara = para.trim();
      if (trimmedPara.isEmpty) continue;

      // Split by Malayalam sentence terminators: . ? ! |
      final sentences = trimmedPara.split(RegExp(r'(?<=[.?!।|])\s+'));
      for (var sentence in sentences) {
        final s = sentence.trim();
        if (s.isEmpty) continue;

        if (s.length <= 250) {
          result.add(s);
        } else {
          // Break very long sentence into comma/word fragments
          final fragments = s.split(RegExp(r'(?<=[,;])\s+'));
          String current = '';
          for (var frag in fragments) {
            if ((current + ' ' + frag).length > 250) {
              if (current.isNotEmpty) result.add(current.trim());
              current = frag;
            } else {
              current = current.isEmpty ? frag : '$current $frag';
            }
          }
          if (current.isNotEmpty) result.add(current.trim());
        }
      }
    }

    return result.isEmpty ? [clean] : result;
  }

  /// Start reading the complete article from beginning to end
  Future<void> speakFullArticle(String fullText) async {
    await stop();
    await init();

    _chunks = _splitText(fullText);
    _currentChunkIndex = 0;

    if (_chunks.isEmpty) return;

    _isPlaying = true;
    onStateChanged?.call(true);
    _speakCurrentChunk();
  }

  Future<void> _speakCurrentChunk() async {
    if (!_isPlaying || _currentChunkIndex >= _chunks.length) {
      _isPlaying = false;
      onStateChanged?.call(false);
      return;
    }

    onProgressChanged?.call(_currentChunkIndex + 1, _chunks.length);
    final text = _chunks[_currentChunkIndex];
    await _flutterTts.speak(text);
  }

  void _onChunkCompleted() {
    if (!_isPlaying) return;

    if (_currentChunkIndex + 1 < _chunks.length) {
      _currentChunkIndex++;
      _speakCurrentChunk();
    } else {
      // Entire article finished!
      _isPlaying = false;
      _chunks.clear();
      _currentChunkIndex = 0;
      onStateChanged?.call(false);
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    _chunks.clear();
    _currentChunkIndex = 0;
    try {
      await _flutterTts.stop();
    } catch (_) {}
    onStateChanged?.call(false);
  }
}

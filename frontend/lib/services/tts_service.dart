import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, {String language = 'en-US'}) async {
    await _tts.setLanguage(language);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<List<dynamic>> getAvailableLanguages() async {
    return await _tts.getLanguages;
  }

  Future<bool> isLanguageAvailable(String language) async {
    final languages = await getAvailableLanguages();
    return languages.contains(language);
  }
}
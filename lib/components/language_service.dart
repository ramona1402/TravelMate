import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:TravelMate/data/language.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  List<dynamic>? _ttsVoices;
  List<LocaleName>? _sttLocales;

  static String getTtsLocale(String languageCode) {
    return ttsLanguageMap[languageCode] ?? 'en-US';
  }

  static String getSttLocale(String languageCode) {
    return speechRecognitionLocales[languageCode] ?? 'en-US';
  }

  Future<void> initializeTtsCapabilities() async {
    try {
      final FlutterTts tts = FlutterTts();
      _ttsVoices = await tts.getVoices;
    } catch (e) {
      _ttsVoices = [];
    }
  }

  Future<void> initializeSttCapabilities() async {
    try {
      final SpeechToText stt = SpeechToText();
      bool available = await stt.initialize();
      if (available) {
        _sttLocales = await stt.locales();
      } else {
        _sttLocales = [];
      }
    } catch (e) {
      _sttLocales = [];
    }
  }

  Future<bool> isTtsLanguageSupported(String languageCode) async {
    if (_ttsVoices == null) {
      await initializeTtsCapabilities();
    }

    String targetLocale = getTtsLocale(languageCode);

    return _ttsVoices?.any((voice) {
          String voiceLocale = voice['locale']?.toString() ?? '';
          return voiceLocale == targetLocale ||
              voiceLocale.startsWith(languageCode) ||
              voiceLocale.toLowerCase() == targetLocale.toLowerCase();
        }) ??
        false;
  }

  Future<bool> isSttLanguageSupported(String languageCode) async {
    if (_sttLocales == null) {
      await initializeSttCapabilities();
    }

    String targetLocale = getSttLocale(languageCode);

    return _sttLocales?.any((locale) {
          return locale.localeId == targetLocale ||
              locale.localeId == targetLocale.replaceAll('-', '_') ||
              locale.localeId.startsWith(languageCode) ||
              locale.localeId.toLowerCase() == targetLocale.toLowerCase();
        }) ??
        false;
  }

  Future<String> getBestSttLocale(String languageCode) async {
    if (_sttLocales == null) {
      await initializeSttCapabilities();
    }

    String preferredLocale = getSttLocale(languageCode);

    if (_sttLocales?.any((l) => l.localeId == preferredLocale) ?? false) {
      return preferredLocale;
    }

    String underscoreFormat = preferredLocale.replaceAll('-', '_');
    if (_sttLocales?.any((l) => l.localeId == underscoreFormat) ?? false) {
      return underscoreFormat;
    }

    String baseLanguage = languageCode.split('-')[0];
    LocaleName? baseMatch = _sttLocales?.firstWhere(
      (l) => l.localeId.startsWith(baseLanguage),
      orElse: () => _sttLocales!.first,
    );

    if (baseMatch != null && baseMatch.localeId.startsWith(baseLanguage)) {
      return baseMatch.localeId;
    }

    return 'en-US';
  }

  Future<String> getBestTtsLocale(String languageCode) async {
    if (_ttsVoices == null) {
      await initializeTtsCapabilities();
    }

    String preferredLocale = getTtsLocale(languageCode);

    bool exactMatch =
        _ttsVoices?.any(
          (voice) => voice['locale']?.toString() == preferredLocale,
        ) ??
        false;

    if (exactMatch) {
      return preferredLocale;
    }

    String baseLanguage = languageCode.split('-')[0];
    var baseMatch = _ttsVoices?.firstWhere(
      (voice) => voice['locale']?.toString().startsWith(baseLanguage) ?? false,
      orElse: () => null,
    );

    if (baseMatch != null) {
      return baseMatch['locale'].toString();
    }

    return 'en-US';
  }

  static String getLanguageDisplayName(String languageCode) {
    return languageList[languageCode] ?? 'Unknown Language';
  }
}

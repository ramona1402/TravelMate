import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:TravelMate/components/language_service.dart';

class VoiceInputButton extends StatefulWidget {
  final ValueChanged<String> onResult;
  final String? languageCode;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.languageCode,
  });

  @override
  VoiceInputButtonState createState() => VoiceInputButtonState();
}

class VoiceInputButtonState extends State<VoiceInputButton> {
  late SpeechToText _speech;
  bool _speechEnabled = false;
  bool _isListening = false;
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          }
        },
      );

      await _languageService.initializeSttCapabilities();
    } catch (e) {
      _speechEnabled = false;
      debugPrint('Failed to initialize speech recognition: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _toggleRecording() async {
    if (!_speechEnabled) {
      debugPrint('Speech recognition not available');
      return;
    }

    if (!_isListening) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  void _startListening() async {
    try {
      String languageCode = widget.languageCode ?? 'en';

      String locale = await _languageService.getBestSttLocale(languageCode);

      await _speech.listen(
        onResult: _onSpeechResult,
        localeId: locale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: null,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      setState(() {
        _isListening = true;
      });
    } catch (e) {
      debugPrint('Failed to start listening: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _stopListening() async {
    try {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    } catch (e) {
      debugPrint('Failed to stop listening: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    widget.onResult(result.recognizedWords);

    if (result.finalResult) {
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 36,
      icon: Icon(
        _isListening ? Icons.mic : Icons.mic_off,
        color:
            _isListening
                ? Colors.red
                : (_speechEnabled ? Colors.black : Colors.grey),
      ),
      onPressed: _speechEnabled ? _toggleRecording : null,
      tooltip:
          _isListening
              ? 'Stop listening'
              : (_speechEnabled
                  ? 'Start listening'
                  : 'Speech recognition unavailable'),
    );
  }
}

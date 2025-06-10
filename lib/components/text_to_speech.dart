import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:TravelMate/data/language.dart';
import 'package:TravelMate/components/language_service.dart';

class TextToSpeechButton extends StatefulWidget {
  final String text;
  final String languageCode;
  final double? speechRate;
  final double? pitch;
  final double? volume;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;

  const TextToSpeechButton({
    super.key,
    required this.text,
    required this.languageCode,
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.icon = Icons.volume_up,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  TextToSpeechButtonState createState() => TextToSpeechButtonState();
}

class TextToSpeechButtonState extends State<TextToSpeechButton>
    with TickerProviderStateMixin {
  static final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setVolume(widget.volume ?? 1.0);
      await _flutterTts.setSpeechRate(widget.speechRate ?? 0.5);
      await _flutterTts.setPitch(widget.pitch ?? 1.0);
      await _flutterTts.setSharedInstance(true);

      _flutterTts.setStartHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = true;
          });
          _animationController.repeat(reverse: true);
        }
      });

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
          });
          _animationController.stop();
          _animationController.reset();
        }
      });

      _flutterTts.setCancelHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
          });
          _animationController.stop();
          _animationController.reset();
        }
      });

      _flutterTts.setErrorHandler((msg) {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
          });
          _animationController.stop();
          _animationController.reset();
          _showError('TTS Error: $msg');
        }
      });

      _isInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      _showError('Failed to initialize Text-to-Speech: $e');
    }
  }

  Future<void> _speak() async {
    if (!_isInitialized || widget.text.trim().isEmpty) {
      _showError('Nothing to speak or TTS not initialized');
      return;
    }

    try {
      await _flutterTts.stop();

      String ttsLocale = LanguageService.getTtsLocale(widget.languageCode);

      await _flutterTts.setLanguage(ttsLocale);
      await _flutterTts.speak(widget.text);
    } catch (e) {
      _showError('Failed to speak: $e');
      setState(() {
        _isSpeaking = false;
      });
      _animationController.stop();
      _animationController.reset();
    }
  }

  Future<void> _stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      _showError('Failed to stop speech: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSpeaking ? _pulseAnimation.value : 1.0,
          child: IconButton(
            icon: Icon(
              _isSpeaking ? Icons.stop : (widget.icon ?? Icons.volume_up),
              color:
                  _isSpeaking ? Colors.red : (widget.iconColor ?? Colors.black),
              size: widget.iconSize,
            ),
            onPressed: _isInitialized ? (_isSpeaking ? _stop : _speak) : null,
            tooltip:
                _isSpeaking
                    ? 'Stop speaking'
                    : 'Speak text in ${languageList[widget.languageCode] ?? widget.languageCode}',
          ),
        );
      },
    );
  }
}

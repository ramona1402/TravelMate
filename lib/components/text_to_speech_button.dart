import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  
  static List<String>? _availableLanguages;
  static Map<String, String>? _languageMapping;

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
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setVolume(widget.volume ?? 1.0);
      await _flutterTts.setSpeechRate(widget.speechRate ?? 0.5);
      await _flutterTts.setPitch(widget.pitch ?? 1.0);
      await _flutterTts.setSharedInstance(true);

      if (_availableLanguages == null) {
        await _initializeLanguageMapping();
      }

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
        }
      });

      _isInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to initialize Text-to-Speech: $e');
    }
  }

  Future<void> _initializeLanguageMapping() async {
    try {
      List<dynamic> languages = await _flutterTts.getLanguages;
      _availableLanguages = languages.map((lang) => lang.toString()).toList();
      
      _languageMapping = {};
      
      final Map<String, List<String>> languageVariants = {
        'en': ['eng-default', 'eng-x-lvariant-f00', 'eng-x-lvariant-l03'],
        'es': ['spa-default', 'spa-x-lvariant-f00'],
        'fr': ['fra-default', 'fra-x-lvariant-f00'],
        'de': ['deu-default', 'deu-x-lvariant-f00'],
        'it': ['ita-default', 'ita-x-lvariant-f00'],
        'pt': ['por-default', 'por-x-lvariant-f00'],
        'ru': ['rus-default', 'rus-x-lvariant-f00'],
        'pl': ['pol-default', 'pol-x-lvariant-f00'],
        'th': ['tha-default', 'tha-x-lvariant-f00'],
        'vi': ['vie-default', 'vie-x-lvariant-f00'],
        'hi': ['hin-default', 'hin-x-lvariant-f00'],
        'ro': ['ron-default', 'ron-x-lvariant-f00'], 
      };
      
      for (String langCode in languageVariants.keys) {
        for (String variant in languageVariants[langCode]!) {
          if (_availableLanguages!.contains(variant)) {
            _languageMapping![langCode] = variant;
            break;
          }
        }
      }
      
    } catch (e) {
      debugPrint('Failed to initialize language mapping: $e');
      _availableLanguages = [];
      _languageMapping = {};
    }
  }

  Future<void> _speak() async {
    if (!_isInitialized || widget.text.trim().isEmpty) {
      return; 
    }

    try {
      await _flutterTts.stop();

      String? mappedLanguage = _languageMapping?[widget.languageCode];
      
      if (mappedLanguage != null) {
        await _flutterTts.setLanguage(mappedLanguage);
        await _flutterTts.speak(widget.text);
      } else {
        String englishTts = _languageMapping?['en'] ?? 'eng-default';
        await _flutterTts.setLanguage(englishTts);
        await _flutterTts.speak(widget.text);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
        _animationController.stop();
        _animationController.reset();
      }
      debugPrint('Failed to speak: $e');
    }
  }

  Future<void> _stop() async {
    try {
      await _flutterTts.stop();
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
        _animationController.stop();
        _animationController.reset();
      }
    } catch (e) {
      debugPrint('Failed to stop speech: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLanguageSupported = _languageMapping?.containsKey(widget.languageCode) ?? false;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSpeaking ? _pulseAnimation.value : 1.0,
          child: IconButton(
            icon: Icon(
              _isSpeaking ? Icons.stop : (widget.icon ?? Icons.volume_up),
              color: _isSpeaking 
                  ? Colors.deepOrange
                  : (isLanguageSupported 
                      ? (widget.iconColor ?? Colors.black)
                      : Colors.grey),
              size: widget.iconSize,
            ),
            onPressed: _isInitialized
                ? (_isSpeaking ? _stop : _speak)
                : null,
          ),
        );
      },
    );
  }
}

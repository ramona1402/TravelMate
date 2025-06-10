import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart';
import 'package:TravelMate/data/language.dart';
import 'package:TravelMate/components/language_selector.dart';
import 'package:TravelMate/components/flag_helper.dart';
import 'package:TravelMate/components/speech_to_text.dart';
import 'package:TravelMate/components/text_to_speech_button.dart';
import 'package:TravelMate/components/language_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();
  final LanguageService _languageService = LanguageService();

  String _translatedText = "";
  bool _isTranslating = false;
  bool _hasInputText = false;
  String _fromLanguage = 'en';
  String _toLanguage = 'es';

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
    _initializeLanguageService();
  }

  void _onInputChanged() {
    final hasText = _inputController.text.trim().isNotEmpty;
    if (_hasInputText != hasText) {
      setState(() {
        _hasInputText = hasText;
      });
    }
  }

  Future<void> _initializeLanguageService() async {
    try {
      await Future.wait([
        _languageService.initializeTtsCapabilities(),
        _languageService.initializeSttCapabilities(),
      ]);
    } catch (e) {
      debugPrint('Language service initialization error: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to initialize language services');
      }
    }
  }

  Future<void> _translateText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _translatedText = "";
    });

    try {
      final translation = await _translator.translate(
        text,
        from: _fromLanguage,
        to: _toLanguage,
      );

      if (mounted) {
        setState(() {
          _translatedText = translation.text;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedText = "Translation failed. Please try again.";
          _isTranslating = false;
        });

        _showErrorSnackBar('Translation failed: ${_getErrorMessage(e)}');
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return 'Please check your internet connection';
    }
    return 'An unexpected error occurred';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _swapLanguages() {
    final temp = _fromLanguage;
    final inputText = _inputController.text.trim();

    setState(() {
      _fromLanguage = _toLanguage;
      _toLanguage = temp;

      if (inputText.isNotEmpty && _translatedText.isNotEmpty) {
        _inputController.text = _translatedText;
        _translatedText = "";
      } else {
        _translatedText = "";
      }
    });

    if (_inputController.text.trim().isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), _translateText);
    }
  }

  void _clearInput() {
    setState(() {
      _inputController.clear();
      _translatedText = "";
    });
  }

  void _showLanguageSelector(bool isFromLanguage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LanguageSelectorPopup(
          currentLanguageCode: isFromLanguage ? _fromLanguage : _toLanguage,
          onLanguageSelected: (languageCode) {
            setState(() {
              if (isFromLanguage) {
                _fromLanguage = languageCode;
              } else {
                _toLanguage = languageCode;
              }
            });
            if (_inputController.text.trim().isNotEmpty) {
              _translateText();
            }
          },
          title:
              isFromLanguage
                  ? "Select Source Language"
                  : "Select Target Language",
        );
      },
    );
  }

  void _handleVoiceInput(String transcribedText) {
    _inputController.text = transcribedText;
    _translateText();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _translatedText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFd6defa),
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // ascunde tastatura
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildLanguageSelector(),
                _buildInputSection(),
                const SizedBox(height: 16),
                if (_translatedText.isNotEmpty || _isTranslating)
                  _buildOutputSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text(
        "Translator",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLanguageButton(_fromLanguage, true),
          IconButton(
            icon: const Icon(Icons.swap_horiz, size: 28),
            onPressed: _swapLanguages,
            tooltip: 'Swap languages',
          ),
          _buildLanguageButton(_toLanguage, false),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String languageCode, bool isFromLanguage) {
    return Expanded(
      child: InkWell(
        onTap: () => _showLanguageSelector(isFromLanguage),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment:
                isFromLanguage
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
            children: [
              if (!isFromLanguage) ...[
                Expanded(
                  child: Text(
                    languageList[languageCode] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(
                  FlagHelper.getFlagAsset(languageCode),
                ),
              ),
              if (isFromLanguage) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    languageList[languageCode] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageList[_fromLanguage] ?? 'From',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF003366),
                ),
              ),
              Row(
                children: [
                  if (_hasInputText)
                    TextToSpeechButton(
                      text: _inputController.text,
                      languageCode: _fromLanguage,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearInput,
                    tooltip: 'Clear text',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inputController,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration.collapsed(
              hintText: "Enter text to translate...",
            ),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _isTranslating ? null : _translateText,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isTranslating ? Colors.grey : Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child:
                    _isTranslating
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          "Translate",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              VoiceInputButton(
                languageCode: _fromLanguage,
                onResult: _handleVoiceInput,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageList[_toLanguage] ?? 'To',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF003366),
                ),
              ),
              if (_translatedText.isNotEmpty && !_isTranslating)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFF003366)),
                      onPressed: _copyToClipboard,
                      tooltip: 'Copy translation',
                    ),
                    TextToSpeechButton(
                      text: _translatedText,
                      languageCode: _toLanguage,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          _isTranslating
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        'Translating...',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
              : SelectableText(
                _translatedText,
                style: const TextStyle(fontSize: 16),
              ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:TravelMate/data/language.dart';
import 'package:TravelMate/components/flag_helper.dart';

class LanguageSelectorPopup extends StatefulWidget {
  final String currentLanguageCode;
  final Function(String) onLanguageSelected;
  final String title;

  const LanguageSelectorPopup({
    Key? key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
    required this.title,
  }) : super(key: key);

  @override
  State<LanguageSelectorPopup> createState() => _LanguageSelectorPopupState();
}

class _LanguageSelectorPopupState extends State<LanguageSelectorPopup> {
  late TextEditingController _searchController;
  late List<MapEntry<String, String>> _filteredLanguages;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredLanguages = languageList.entries.toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedLanguage();
    });
  }

  void _filterLanguages(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = languageList.entries.toList();
      } else {
        _filteredLanguages =
            languageList.entries
                .where(
                  (entry) =>
                      entry.value.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  void _scrollToSelectedLanguage() {
    final int selectedIndex = _filteredLanguages.indexWhere(
      (entry) => entry.key == widget.currentLanguageCode,
    );

    if (selectedIndex != -1) {
      _scrollController.animateTo(
        selectedIndex * 56.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search language',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _filterLanguages,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _filteredLanguages.length,
                itemBuilder: (context, index) {
                  final entry = _filteredLanguages[index];
                  final isSelected = entry.key == widget.currentLanguageCode;

                  return ListTile(
                    leading: FlagHelper.flagAvatar(entry.key, radius: 12),
                    title: Text(entry.value),
                    tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                    trailing:
                        isSelected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                    onTap: () {
                      widget.onLanguageSelected(entry.key);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

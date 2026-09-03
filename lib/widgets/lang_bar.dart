import 'package:flutter/material.dart';

class LangBar extends StatelessWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;

  const LangBar({
    Key? key,
    required this.currentLang,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // एपमा सपोर्ट गर्ने ५ भाषाहरू
    final List<String> languages = ['Nepali', 'English', 'Hindi', 'Newari', 'Bhojpuri'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButton<String>(
        value: currentLang,
        dropdownColor: Colors.blue[900],
        icon: const Icon(Icons.language, color: Colors.white),
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        items: languages.map((String lang) {
          return DropdownMenuItem<String>(
            value: lang,
            child: Text(
              lang,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onLanguageChanged(newValue);
          }
        },
      ),
    );
  }
}

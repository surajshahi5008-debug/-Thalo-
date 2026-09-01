import 'package:flutter/material.dart';

class LanguageBar extends StatelessWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;
  final Function(String) onNotificationTap;

  const LanguageBar({
    Key? key,
    required this.currentLang,
    required this.onLanguageChanged,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: currentLang,
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ne', child: Text('नेपाली')),
              DropdownMenuItem(value: 'new', child: Text('नेपाल भाषा')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
              DropdownMenuItem(value: 'ur', child: Text('اردو')),
            ],
            onChanged: (val) {
              if (val != null) {
                onLanguageChanged(val);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.deepPurple),
            onPressed: () {
              onNotificationTap(currentLang);
            },
          ),
        ],
      ),
    );
  }
}

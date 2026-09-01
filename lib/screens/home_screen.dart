import 'package:flutter/material.dart';
import '../widgets/lang_bar.dart';
import '../widgets/calendar_picker.dart';

class HomeScreen extends StatelessWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;
  final Function(String) onNotificationTap;
  final String selectedDate;
  final VoidCallback onCalendarTap;
  final VoidCallback onLogout;

  const HomeScreen({
    Key? key,
    required this.currentLang,
    required this.onLanguageChanged,
    required this.onNotificationTap,
    required this.selectedDate,
    required this.onCalendarTap,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LanguageBar(
              currentLang: currentLang,
              onLanguageChanged: onLanguageChanged,
              onNotificationTap: onNotificationTap,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'गृह पृष्ठ (Home)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  CalendarPickerWidget(
                    selectedDate: selectedDate,
                    onCalendarTap: onCalendarTap,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'स्वागत छ!',
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('लगआउट गर्नुहोस्'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

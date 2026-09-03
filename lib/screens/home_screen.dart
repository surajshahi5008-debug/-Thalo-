import 'package:flutter/material.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Thalo - Home', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'स्वागत छ! तपाईं सफलतापूर्वक लगइन हुनुभएको छ।',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'चयन गरिएको भाषा: $currentLang',
              style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
              onPressed: onLogout,
              child: const Text('लगआउट गर्नुहोस्', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

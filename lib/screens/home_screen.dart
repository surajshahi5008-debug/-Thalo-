import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;
  final Function(bool) onNotificationTap;
  final String selectedDate;
  final VoidCallback onCalendarTap;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.currentLang,
    required this.onLanguageChanged,
    required this.onNotificationTap,
    required this.selectedDate,
    required this.onCalendarTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('थलो - गृहपृष्ठ ($currentLang)', style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'स्वागत छ! (Welcome to Thalo Home)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'हालको भाषा (Current Language): $currentLang',
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
              ),
              const SizedBox(height: 8),
              Text(
                'मिति (Selected Date): $selectedDate',
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                  ),
                  onPressed: onLogout,
                  child: const Text(
                    'लगआउट गर्नुहोस् (Logout)',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

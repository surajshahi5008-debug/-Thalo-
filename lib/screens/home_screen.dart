import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onLanguageChanged;
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

  String _getText(String key) {
    return AppStrings.localizedValues[currentLang]?[key] ?? 
           AppStrings.localizedValues['नेपाली']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(_getText('appName'), style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_rounded, size: 80, color: AppColors.primaryBlue),
              const SizedBox(height: 20),
              Text(
                _getText('loginTitle'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'सफलतापूर्वक लगइन वा साइन अप हुनुभएको छ!',
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: onLogout,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                label: const Text('लगआउट गर्नुहोस् (Logout)', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

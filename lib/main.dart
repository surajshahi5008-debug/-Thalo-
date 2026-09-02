import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ThaloApp());
}

class ThaloApp extends StatelessWidget {
  const ThaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.backgroundLight,
      ),
      home: const AuthWrapper(),
    );
  }
}

// यो विजेटले लगइन भएको छ कि छैन भनेर छुट्याउँछ र सही स्क्रिन देखाउँछ
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // 0: Login, 1: Register, 2: Home
  int _currentIndex = 0;
  String _currentLang = 'ne';
  final String _selectedDate = 'आज';

  @override
  Widget build(BuildContext context) {
    // यदि लगइन वा रजिस्टर छैन भने तिनै देखाउने, भएन भने होम पेज देखाउने
    if (_currentIndex == 0) {
      return LoginScreen(
        currentLang: _currentLang,
        onLanguageChanged: (lang) {
          setState(() {
            _currentLang = lang;
          });
        },
        onNotificationTap: (val) {},
        onLoginSuccess: () {
          setState(() {
            _currentIndex = 2; // लगइन भएपछि Home मा जाने
          });
        },
        goToRegister: () {
          setState(() {
            _currentIndex = 1; // Register मा जाने
          });
        },
      );
    } else if (_currentIndex == 1) {
      return RegisterScreen(
        currentLang: _currentLang,
        onLanguageChanged: (lang) {
          setState(() {
            _currentLang = lang;
          });
        },
        onNotificationTap: (val) {},
        onRegisterSuccess: () {
          setState(() {
            _currentIndex = 2; // रजिस्टर भएपछि Home मा जाने
          });
        },
        goToLogin: () {
          setState(() {
            _currentIndex = 0; // Login मा फर्कने
          });
        },
      );
    } else {
      return HomeScreen(
        currentLang: _currentLang,
        onLanguageChanged: (lang) {
          setState(() {
            _currentLang = lang;
          });
        },
        onNotificationTap: (val) {},
        selectedDate: _selectedDate,
        onCalendarTap: () {},
        onLogout: () {
          setState(() {
            _currentIndex = 0; // लगर आउट गरेर फेरि Login मा पठाउने
          });
        },
      );
    }
  }
}

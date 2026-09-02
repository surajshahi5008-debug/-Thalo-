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

class ThaloApp extends StatefulWidget {
  const ThaloApp({Key? key}) : super(key: key);

  @override
  State<ThaloApp> createState() => _ThaloAppState();
}

class _ThaloAppState extends State<ThaloApp> {
  String currentLang = 'ne';
  String selectedDate = '२०८३/०५/१६';

  void _handleNotificationTap(String? payload) {
    debugPrint("Notification tapped with payload: $payload");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(
              currentLang: currentLang,
              onLanguageChanged: (lang) {
                setState(() {
                  currentLang = lang;
                  if (lang == 'en') {
                    selectedDate = '2026/09/02';
                  } else {
                    selectedDate = '२०८३/०५/१६';
                  }
                });
              },
              onNotificationTap: _handleNotificationTap,
              onLoginSuccess: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              goToRegister: () {
                Navigator.pushNamed(context, '/register');
              },
            ),
        '/register': (context) => RegisterScreen(
              currentLang: currentLang,
              onLanguageChanged: (lang) {
                setState(() {
                  currentLang = lang;
                  if (lang == 'en') {
                    selectedDate = '2026/09/02';
                  } else {
                    selectedDate = '२०८३/०५/१६';
                  }
                });
              },
              onNotificationTap: _handleNotificationTap,
              onRegisterSuccess: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              goToLogin: () {
                Navigator.pop(context);
              },
            ),
        '/home': (context) => HomeScreen(
              currentLang: currentLang,
              onLanguageChanged: (lang) {
                setState(() {
                  currentLang = lang;
                });
              },
              onNotificationTap: _handleNotificationTap,
              selectedDate: selectedDate,
              onCalendarTap: () {
                // क्यालेन्डर खोल्ने लजिक
              },
              onLogout: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
      },
    );
  }
}

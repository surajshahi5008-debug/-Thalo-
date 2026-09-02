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
  // भाषा र क्यालेन्डरको स्टेट
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
                  // भाषा अनुसार क्यालेन्डर वा मिति ढाँचा मिलाउने
                  if (lang == 'en') {
                    selectedDate = '2026/09/02';
                  } else {
                    selectedDate = '२०८३/०५/१६';
                  }
                });
              },
              onNotificationTap: _handleNotificationTap,
              onLoginSuccess: () {},
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
              onRegisterSuccess: () {},
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
                // क्यालेन्डर खोल्ने वा मितի छान्ने लजिक यहाँ बस्छ
              },
              onLogout: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
      },
    );
  }
}

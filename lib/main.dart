import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:thalo/screens/login_screen.dart';
import 'package:thalo/screens/register_screen.dart';

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
  // हालको भाषा सेट गर्ने भेरिएबल
  String currentLang = 'ne';

  void _handleNotificationTap(String? payload) {
    debugPrint("Notification tapped with payload: $payload");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thalo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(
              currentLang: currentLang,
              onLanguageChanged: (lang) {
                setState(() {
                  currentLang = lang;
                });
              },
              onNotificationTap: _handleNotificationTap,
            ),
        '/register': (context) => RegisterScreen(
              currentLang: currentLang,
              onLanguageChanged: (lang) {
                setState(() {
                  currentLang = lang;
                });
              },
              onNotificationTap: _handleNotificationTap,
            ),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thalo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainRouter(),
    );
  }
}

class MainRouter extends StatefulWidget {
  const MainRouter({Key? key}) : super(key: key);

  @override
  State<MainRouter> createState() => _MainRouterState();
}

class _MainRouterState extends State<MainRouter> {
  String _currentLang = 'English';
  int _currentIndex = 0; // 0: Login, 1: Register, 2: Home
  String _selectedDate = '';
  final AuthService _authService = AuthService();

  void _handleLanguageChanged(String newLang) {
    setState(() {
      _currentLang = newLang;
    });
  }

  void _handleNotificationTap(String lang) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification tapped in $lang')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 0) {
      return LoginScreen(
        currentLang: _currentLang,
        onLanguageChanged: _handleLanguageChanged,
        onNotificationTap: _handleNotificationTap,
        onLoginSuccess: () {
          setState(() {
            _currentIndex = 2; // होम स्क्रिनमा जाने
          });
        },
        goToRegister: () {
          setState(() {
            _currentIndex = 1; // रजिस्टर स्क्रिनमा जाने
          });
        },
      );
    } else if (_currentIndex == 1) {
      return RegisterScreen(
        currentLang: _currentLang,
        onLanguageChanged: _handleLanguageChanged,
        onNotificationTap: _handleNotificationTap,
        onRegisterSuccess: () {
          setState(() {
            _currentIndex = 2; // रजिस्टर भएपछि होममा जाने
          });
        },
        goToLogin: () {
          setState(() {
            _currentIndex = 0; // लगइनमा फर्कने
          });
        },
      );
    } else {
      return HomeScreen(
        currentLang: _currentLang,
        onLanguageChanged: _handleLanguageChanged,
        onNotificationTap: _handleNotificationTap,
        selectedDate: _selectedDate,
        onCalendarTap: () {
          // यहाँ क्यालेन्डर डायलग कल गर्न सकिन्छ
          setState(() {
            _selectedDate = '2080-11-15 (वि.सं.)';
          });
        },
        onLogout: () {
          setState(() {
            _currentIndex = 0; // लगआउट गरेर लगइनमा फर्कने
          });
        },
      );
    }
  }
}

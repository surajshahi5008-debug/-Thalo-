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
      home: const MainRouter(),
    );
  }
}

class MainRouter extends StatefulWidget {
  const MainRouter({super.key});

  @override
  State<MainRouter> createState() => _MainRouterState();
}

class _MainRouterState extends State<MainRouter> {
  int _currentIndex = 0;
  String currentLang = 'ne';
  String selectedDate = '२०८३/०५/१६';

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        currentLang: currentLang,
        onLanguageChanged: (lang) {
          setState(() {
            currentLang = lang;
          });
        },
        onNotificationTap: (notif) {},
        selectedDate: selectedDate,
        onCalendarTap: () {},
        onLogout: () {},
      ),
      LoginScreen(
        currentLang: currentLang,
        onLanguageChanged: (lang) {
          setState(() {
            currentLang = lang;
          });
        },
      ),
      RegisterScreen(
        currentLang: currentLang,
        onLanguageChanged: (lang) {
          setState(() {
            currentLang = lang;
          });
        },
      ),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textDark.withOpacity(0.6),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Register',
          ),
        ],
      ),
    );
  }
}

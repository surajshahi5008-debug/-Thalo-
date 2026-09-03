import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ThaloApp());
}

class ThaloApp extends StatefulWidget {
  const ThaloApp({Key? key}) : super(key: key);

  @override
  State<ThaloApp> createState() => _ThaloAppState();
}

class _ThaloAppState extends State<ThaloApp> {
  // एपको वर्तमान स्थिति (State Management)
  String _currentLang = 'Nepali';
  String _currentScreen = 'login'; // 'login', 'register', 'home'
  
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  
  String _errorMessage = '';
  
  // Calendar & Date states
  String _selectedCalendar = 'AD';
  int _selectedYear = 2000;
  int _selectedMonth = 1;
  int _selectedDay = 1;
  String _ageResultText = '';
  String _birthdayWishText = '';
  bool _showBirthdayWish = false;

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  void _changeLanguage(String lang) {
    setState(() {
      _currentLang = lang;
    });
  }

  void _handleNotificationTap(String lang) {
    // नटिफिकेसन वा अतिरिक्त लजिक यहाँ राख्न सकिन्छ
  }

  void _handleLogin() {
    setState(() {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _errorMessage = _currentLang == 'Nepali' ? 'कृपया इमेल र पासवर्ड भर्नुहोस्।' : 'Please fill in email and password.';
      } else {
        _errorMessage = '';
        _currentScreen = 'home';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thalo App',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 'register':
        return RegisterScreen(
          currentLang: _currentLang,
          onLanguageChanged: _changeLanguage,
          onNotificationTap: _handleNotificationTap,
          onBackToLogin: () => setState(() => _currentScreen = 'login'),
          onProceedToNextStep: () => setState(() => _currentScreen = 'home'),
          firstNameController: _firstNameController,
          middleNameController: _middleNameController,
          lastNameController: _lastNameController,
          selectedCalendar: _selectedCalendar,
          selectedYear: _selectedYear,
          selectedMonth: _selectedMonth,
          selectedDay: _selectedDay,
          ageResultText: _ageResultText,
          birthdayWishText: _birthdayWishText,
          showBirthdayWish: _showBirthdayWish,
          onDatePickerTap: () {
            // क्यालेन्डर डायलग वा लजिक यहाँ राख्न सकिन्छ
          },
          formatNumber: _formatNumber,
        );
      
      case 'home':
        return HomeScreen(
          currentLang: _currentLang,
          onLanguageChanged: _changeLanguage,
          onNotificationTap: _handleNotificationTap,
          selectedDate: '$_selectedYear-$_selectedMonth-$_selectedDay',
          onCalendarTap: () {},
          onLogout: () => setState(() {
            _currentScreen = 'login';
            _emailController.clear();
            _passwordController.clear();
          }),
        );
        
      case 'login':
      default:
        return LoginScreen(
          currentLang: _currentLang,
          onLanguageChanged: _changeLanguage,
          onNotificationTap: _handleNotificationTap,
          onLoginSuccess: () => setState(() => _currentScreen = 'home'),
          goToRegister: () => setState(() => _currentScreen = 'register'),
          emailController: _emailController,
          passwordController: _passwordController,
          errorMessage: _errorMessage,
          onLoginPressed: _handleLogin,
          onForgotPressed: () {
            // फर्गेट पासवर्ड लजिक
          },
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../utils/localization_helper.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  int _currentIndex = 0; 
  String _currentLang = 'नेपाली';
  final String _selectedDate = 'आज';

  String? _selectedGender;
  bool _acceptTerms = false;

  String _selectedCalendar = 'वि.सं.'; 
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  String _ageResultText = '';
  String _birthdayWishText = '';
  bool _showBirthdayWish = false;

  String _selectedCountryCode = '+91';
  bool _isLoading = false;
  String _verificationId = '';

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  final TextEditingController _regFirstNameController = TextEditingController();
  final TextEditingController _regMiddleNameController = TextEditingController();
  final TextEditingController _regLastNameController = TextEditingController();
  final TextEditingController _regPhoneEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _phoneOtpController = TextEditingController();
  
  String _loginErrorMessage = '';
  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;

  @override
  void initState() {
    super.initState();
    _setCurrentDate();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regFirstNameController.dispose();
    _regMiddleNameController.dispose();
    _regLastNameController.dispose();
    _regPhoneEmailController.dispose();
    _regPasswordController.dispose();
    _phoneOtpController.dispose();
    super.dispose();
  }

  void _setCurrentDate() {
    DateTime now = DateTime.now();
    if (_currentLang == 'English' || _selectedCalendar == 'AD') {
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedCalendar = 'AD';
    } else {
      _selectedYear = now.year + 57; 
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedCalendar = 'वि.सं.';
    }
  }

  String _getText(String key) => LocalizationHelper.getText(_currentLang, key);

  void _handleLogin() {
    String input = _loginEmailController.text.trim();
    String password = _loginPasswordController.text;

    setState(() {
      if (input.isEmpty) {
        _loginErrorMessage = _getText('errEmailNotRegistered');
        return;
      }

      if (input != 'test@thalo.com' && input != '9800000000') {
        _loginErrorMessage = _getText('errEmailNotRegistered');
      } else if (password != '123456') {
        _loginErrorMessage = _getText('errIncorrectPassword');
      } else {
        _loginErrorMessage = '';
        _currentIndex = 2; // Home Screen मा जाने
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 2) {
      return const HomeScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? _getText('loginAppBar') : _getText('registerAppBar')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_currentIndex == 0 ? _getText('loginTitle') : _getText('registerTitle'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _loginEmailController,
                decoration: InputDecoration(labelText: _getText('emailLabel')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _loginPasswordController,
                obscureText: _obscureLoginPassword,
                decoration: InputDecoration(labelText: _getText('passwordLabel')),
              ),
              if (_loginErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_loginErrorMessage, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                child: Text(_getText('loginButton')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

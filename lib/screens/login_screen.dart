import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class LoginScreen extends StatefulWidget {
  final String currentLang;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onLoginSuccess;
  final VoidCallback onRegisterTap;

  const LoginScreen({
    super.key,
    required this.currentLang,
    required this.onLanguageChanged,
    required this.onLoginSuccess,
    required this.onRegisterTap,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  bool _obscureLoginPassword = true;
  String _loginErrorMessage = '';

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  String _getText(String key) {
    return AppStrings.localizedValues[widget.currentLang]?[key] ?? 
           AppStrings.localizedValues['नेपाली']![key]!;
  }

  void _handleLogin() {
    String input = _loginEmailController.text.trim();
    String password = _loginPasswordController.text;

    setState(() {
      if (input.isEmpty) {
        _loginErrorMessage = _getText('errEmailNotRegistered');
        return;
      }

      bool isEmail = input.contains('@');
      
      if (isEmail && input != 'test@thalo.com') {
        _loginErrorMessage = _getText('errEmailNotRegistered');
      } else if (!isEmail && input != '9800000000') {
        _loginErrorMessage = _getText('errPhoneNotRegistered');
      } else if (password != '123456') {
        _loginErrorMessage = _getText('errIncorrectPassword');
      } else {
        _loginErrorMessage = '';
        widget.onLoginSuccess();
      }
    });
  }

  Widget _buildLanguageSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['English', 'नेपाली', 'नेपाल भाषा', 'हिन्दी', 'اردو'].map((lang) {
          final isSelected = widget.currentLang == lang;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () => widget.onLanguageChanged(lang),
              child: Text(
                lang,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(_getText('loginAppBar'), style: const TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getText('loginTitle'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _loginEmailController,
                decoration: InputDecoration(
                  labelText: _getText('emailLabel'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _loginPasswordController,
                obscureText: _obscureLoginPassword,
                decoration: InputDecoration(
                  labelText: _getText('passwordLabel'),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureLoginPassword = !_obscureLoginPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_getText('forgotPassword'))),
                    );
                  },
                  child: Text(
                    _getText('forgotPassword'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                ),
              ),
              if (_loginErrorMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  _loginErrorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[50],
                    elevation: 0,
                  ),
                  onPressed: _handleLogin,
                  child: Text(_getText('loginButton'), style: const TextStyle(color: Colors.purple, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onRegisterTap,
                child: Text(_getText('noAccount'), style: const TextStyle(color: Colors.purple, fontSize: 14)),
              ),
              const SizedBox(height: 30),
              _buildLanguageSelector(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../widgets/lang_bar.dart';

class LoginScreen extends StatefulWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;
  final Function(String) onNotificationTap;
  final VoidCallback onLoginSuccess;
  final VoidCallback goToRegister;
  
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String errorMessage;
  final VoidCallback onLoginPressed;
  final VoidCallback onForgotPressed;

  const LoginScreen({
    Key? key,
    required this.currentLang,
    required this.onLanguageChanged,
    required this.onNotificationTap,
    required this.onLoginSuccess,
    required this.goToRegister,
    required this.emailController,
    required this.passwordController,
    required this.errorMessage,
    required this.onLoginPressed,
    required this.onForgotPressed,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(AppStrings.get('loginAppBar', widget.currentLang), style: const TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LanguageBar(
              currentLang: widget.currentLang,
              onLanguageChanged: widget.onLanguageChanged,
              onNotificationTap: widget.onNotificationTap,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.get('loginTitle', widget.currentLang),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: widget.emailController,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('emailLabel', widget.currentLang),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: widget.passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('passwordLabel', widget.currentLang),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: widget.onForgotPressed,
                        child: Text(
                          AppStrings.get('forgotPassword', widget.currentLang),
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                    if (widget.errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        widget.errorMessage,
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
                        onPressed: widget.onLoginPressed,
                        child: Text(
                          AppStrings.get('loginButton', widget.currentLang),
                          style: const TextStyle(color: Colors.purple, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: widget.goToRegister,
                      child: Text(
                        AppStrings.get('noAccount', widget.currentLang),
                        style: const TextStyle(color: Colors.purple, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

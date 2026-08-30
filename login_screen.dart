import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/lang_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _selectedLang = 'English';
  bool _isLoading = false;
  String _errorMessage = '';

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // सफल भएपछि गरिने कामहरू (पछिल्लो चरणमा थप्नेछौं)
    } catch (e) {
      setState(() {
        _errorMessage = getLocalizedError(e.toString(), _selectedLang);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedLang == 'English' ? 'Login' : 'लगइन'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildLang_bar(_selectedLang, (lang) {
              setState(() {
                _selectedLang = lang;
              });
            }),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: _selectedLang == 'English' ? 'Email' : 'इमेल',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: _selectedLang == 'English' ? 'Password' : 'पासवर्ड',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text(_selectedLang == 'English' ? 'Login' : 'लगइन गर्नुहोस्'),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ThaloApp());
}

class ThaloApp extends StatelessWidget {
  const ThaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thalo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController _regPhoneEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _selectedCountryCode = '+977';
  String _verificationId = '';
  String _selectedLanguage = 'en';

  // Multi-language support (English, Nepali, Nepal Bhasa, Hindi, Urdu)
  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'title': 'Thalo - Login/Signup',
      'input_hint': 'Enter email or phone number',
      'password_hint': 'Enter password',
      'continue_btn': 'Continue',
    },
    'ne': {
      'title': 'थलो - लगइन/साइनअप',
      'input_hint': 'इमेल वा फोन नम्बर राख्नुहोस्',
      'password_hint': 'पासवर्ड राख्नुहोस्',
      'continue_btn': 'अगाडि बढाउनुहोस्',
    },
    'new': {
      'title': 'थलो - क्वथँ/धार्मिक',
      'input_hint': 'इमेल वा फोन नम्बर च्वयादिसँ',
      'password_hint': 'पासवर्ड च्वयादिसँ',
      'continue_btn': 'न्ह्याःच्वनेगु',
    },
    'hi': {
      'title': 'थलो - लॉगिन/साइनअप',
      'input_hint': 'ईमेल या फोन नंबर दर्ज करें',
      'password_hint': 'पासवर्ड दर्ज करें',
      'continue_btn': 'आगे बढ़ें',
    },
    'ur': {
      'title': 'تھالو - لاگ ان/سائن اپ',
      'input_hint': 'ای میل یا فون نمبر درج کریں',
      'password_hint': 'پاسورڈ درج کریں',
      'continue_btn': 'آگے بڑھیں',
    },
  };

  String _getLocalizedText(String key) {
    return _localizedStrings[_selectedLanguage]?[key] ?? _localizedStrings['en']![key]!;
  }

  // Registration & Phone/Email Verification Handler
  Future<void> _startRegistrationAndVerification() async {
    String input = _regPhoneEmailController.text.trim();
    String password = _regPasswordController.text;

    if (input.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      if (input.contains('@')) {
        await _authService.signUpWithEmail(input, password);
        setState(() {
          _isLoading = false;
          _currentIndex = 12;
        });
      } else {
        String cleanPhone = input.replaceAll(RegExp(r'\D'), '');
        String formattedPhone = '$_selectedCountryCode$cleanPhone';

        await _authService.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          onCodeSent: (verificationId) {
            setState(() {
              _verificationId = verificationId;
              _isLoading = false;
              _currentIndex = 12;
            });
          },
          onVerificationFailed: (e) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? 'त्रुटि देखियो')),
            );
          },
          onVerificationCompleted: (credential) async {
            setState(() => _isLoading = false);
          },
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('त्रुटि देखियो: $e')),
      );
    }
  }

  Future<void> _verifyOtpCode() async {
    String smsCode = _otpController.text.trim();
    if (smsCode.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithPhoneCredential(_verificationId, smsCode);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('गलत ओटिपी कोड: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedText('title')),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ne', child: Text('नेपाली')),
              DropdownMenuItem(value: 'new', child: Text('नेपाल भाषा')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
              DropdownMenuItem(value: 'ur', child: Text('اردو')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedLanguage = val);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _regPhoneEmailController,
                    decoration: InputDecoration(
                      labelText: _getLocalizedText('input_hint'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _regPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _getLocalizedText('password_hint'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _startRegistrationAndVerification,
                    child: Text(_getLocalizedText('continue_btn')),
                  ),
                ],
              ),
      ),
    );
  }
}

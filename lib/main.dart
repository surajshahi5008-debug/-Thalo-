import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialisation लाई try-catch मा राख्नाले Crash हुन पाउँदैन
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const MaterialApp(
    home: ThaloRegisterScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'यो इमेल पहिले नै प्रयोगमा छ।';
      case 'invalid-email':
        return 'मान्य इमेल ठेगाना हाल्नुहोस्।';
      case 'weak-password':
        return 'पासवर्ड धेरै कमजोर छ।';
      case 'user-not-found':
        return 'यो इमेलसँग कुनै खाता फेला परेन।';
      case 'wrong-password':
      case 'invalid-credential':
        return 'इमेल वा पासवर्ड मिलेन।';
      case 'too-many-requests':
        return 'धेरै प्रयास भयो। केही समयपछि फेरि प्रयास गर्नुहोस्।';
      case 'network-request-failed':
        return 'इन्टरनेट जडान जाँच गर्नुहोस्।';
      default:
        return 'इमेल वा पासवर्ड मिलेन।';
    }
  }
}

class ThaloRegisterScreen extends StatefulWidget {
  const ThaloRegisterScreen({super.key});

  @override
  State<ThaloRegisterScreen> createState() => _ThaloRegisterScreenState();
}

class _ThaloRegisterScreenState extends State<ThaloRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedLang = 'नेपाली';

  final List<String> _languages = ['नेपाली', 'हिन्दी', 'English', 'Urdu'];

  Map<String, String> _getRegisterLabels(String lang) {
    switch (lang) {
      case 'हिन्दी':
        return {
          'title': 'थलो अकाउंट बनाएं',
          'name': 'पूरा नाम',
          'email': 'ईमेल पता',
          'pass': 'पासवर्ड',
          'btn': 'साइन अप करें',
          'haveAccount': 'पहले से खाता है?',
          'loginLink': 'लॉगिन करें'
        };
      case 'English':
        return {
          'title': 'Create Thalo Account',
          'name': 'Full Name',
          'email': 'Email Address',
          'pass': 'Password',
          'btn': 'Sign Up',
          'haveAccount': 'Already have an account?',
          'loginLink': 'Log In'
        };
      case 'Urdu':
        return {
          'title': 'تھلو اکاؤنٹ بنائیں',
          'name': 'پورا نام',
          'email': 'ای میل کا پتہ',
          'pass': 'پاس ورڈ',
          'btn': 'سائن اپ کریں',
          'haveAccount': 'پہلے سے اکاؤنٹ ہے؟',
          'loginLink': 'لاگ ان کریں'
        };
      default:
        return {
          'title': 'थलो खाता बनाउनुहोस्',
          'name': 'पूरा नाम',
          'email': 'इमेल ठेगाना',
          'pass': 'पासवर्ड',
          'btn': 'साइन अप गर्नुहोस्',
          'haveAccount': 'पहिले नै खाता छ?',
          'loginLink': 'लगइन गर्नुहोस्'
        };
    }
  }

  TextDirection _getDirection(String lang) =>
      lang == 'Urdu' ? TextDirection.rtl : TextDirection.ltr;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.registerWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThaloNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = _getRegisterLabels(_selectedLang);
    final dir = _getDirection(_selectedLang);

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Thalo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text(labels['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: _nameController,
                    textDirection: dir,
                    decoration: InputDecoration(
                        hintText: labels['name']!,
                        filled: true,
                        fillColor: const Color(0xfff5f6f8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.person_outline,
                            color: Colors.grey)),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'कृपया नाम हाल्नुहोस्'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    textDirection: dir,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        hintText: labels['email']!,
                        filled: true,
                        fillColor: const Color(0xfff5f6f8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.mail_outline,
                            color: Colors.grey)),
                    validator: (value) =>
                        (value == null || !value.contains('@'))
                            ? 'मान्य इमेल हाल्नुहोस्'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    textDirection: dir,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: labels['pass']!,
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => (value == null || value.length < 6)
                        ? 'पासवर्ड ६ वर्ण भन्दा बढी हुनुपर्छ'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(labels['btn']!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(labels['haveAccount']!,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ThaloLoginScreen()),
                        ),
                        child: Text(labels['loginLink']!,
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedLang,
                        underline: const SizedBox(),
                        items: _languages.map((String lang) {
                          return DropdownMenuItem<String>(
                            value: lang,
                            child: Text(lang,
                                style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (String? newLang) {
                          if (newLang != null) {
                            setState(() => _selectedLang = newLang);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// navigation screen setup
class ThaloNavigationScreen extends StatelessWidget {
  const ThaloNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thalo Main App')),
      body: const Center(child: Text('Welcome to Thalo App!')),
    );
  }
}

// login screen setup
class ThaloLoginScreen extends StatelessWidget {
  const ThaloLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thalo Login')),
      body: const Center(child: Text('Login Page')),
    );
  }
}

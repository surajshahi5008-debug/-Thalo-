import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const MaterialApp(
    home: ThaloLoginScreen(),
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

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'यो इमेलसँग कुनै खाता फेला परेन।';
      case 'wrong-password':
      case 'invalid-credential':
        return 'इमेल वा पासवर्ड मिलेन।';
      case 'email-already-in-use':
        return 'यो इमेल पहिले नै प्रयोगमा छ।';
      case 'invalid-email':
        return 'मान्य इमेल ठेगाना हाल्नुहोस्।';
      case 'weak-password':
        return 'पासवर्ड धेरै कमजोर छ।';
      default:
        return 'इमेल वा पासवर्ड मिलेन।';
    }
  }
}

// ================= १. लगइन स्क्रिन (मुख्य सुरुवाती स्क्रिन) =================
class ThaloLoginScreen extends StatefulWidget {
  const ThaloLoginScreen({super.key});

  @override
  State<ThaloLoginScreen> createState() => _ThaloLoginScreenState();
}

class _ThaloLoginScreenState extends State<ThaloLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedLang = 'नेपाली';

  final List<String> _languages = ['नेपाली', 'हिन्दी', 'English', 'Urdu'];

  Map<String, String> _getLoginLabels(String lang) {
    switch (lang) {
      case 'हिन्दी':
        return {
          'title': 'अपने खाते में लॉगिन करें',
          'email': 'ईमेल पता',
          'pass': 'पासवर्ड',
          'btn': 'लॉगिन करें',
          'noAccount': 'खाता नहीं है?',
          'signUpLink': 'साइन अप करें'
        };
      case 'English':
        return {
          'title': 'Log in to your account',
          'email': 'Email Address',
          'pass': 'Password',
          'btn': 'Log In',
          'noAccount': "Don't have an account?",
          'signUpLink': 'Sign Up'
        };
      case 'Urdu':
        return {
          'title': 'اپنے اکاؤنٹ میں لاگ ان کریں',
          'email': 'ای میل کا پتہ',
          'pass': 'پاس ورڈ',
          'btn': 'لاگ ان کریں',
          'noAccount': 'اکاؤنٹ نہیں ہے؟',
          'signUpLink': 'سائن اپ کریں'
        };
      default:
        return {
          'title': 'आफ्नो खातामा लगइन गर्नुहोस्',
          'email': 'इमेल ठेगाना',
          'pass': 'पासवर्ड',
          'btn': 'लगइन गर्नुहोस्',
          'noAccount': 'खाता छैन?',
          'signUpLink': 'साइन अप गर्नुहोस्'
        };
    }
  }

  TextDirection _getDirection(String lang) =>
      lang == 'Urdu' ? TextDirection.rtl : TextDirection.ltr;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.loginWithEmail(
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = _getLoginLabels(_selectedLang);
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
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'पासवर्ड हाल्नुहोस्'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                      Text(labels['noAccount']!,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ThaloRegisterScreen()),
                        ),
                        child: Text(labels['signUpLink']!,
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

// ================= २. रजिस्टर (साइन अप) स्क्रिन =================
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
  final _dobController = TextEditingController();
  
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedLang = 'नेपाली';
  String? _selectedGender;
  String? _calculatedAgeText;

  final List<String> _languages = ['नेपाली', 'हिन्दी', 'English', 'Urdu'];
  final List<String> _genders = ['पुरुष (Male)', 'महिला (Female)', 'अन्य (Other)'];

  Map<String, String> _getRegisterLabels(String lang) {
    switch (lang) {
      case 'हिन्दी':
        return {
          'title': 'थलो अकाउंट बनाएं',
          'name': 'पूरा नाम',
          'dob': 'जन्म तिथि (DOB)',
          'gender': 'लिंग चुनें',
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
          'dob': 'Date of Birth',
          'gender': 'Select Gender',
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
          'dob': 'تاریخ پیدائش',
          'gender': 'جنس منتخب کریں',
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
          'dob': 'जन्ममिति (DOB)',
          'gender': 'लिङ्ग छान्नुहोस्',
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

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        
        int years = now.year - picked.year;
        DateTime lastBirthday = DateTime(now.year, picked.month, picked.day);

        if (now.isBefore(lastBirthday)) {
          years--;
          lastBirthday = DateTime(now.year - 1, picked.month, picked.day);
        }

        int days = now.difference(lastBirthday).inDays;
        _calculatedAgeText = "उमेर: $years वर्ष, $days दिन";
      });
    }
  }

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
    _dobController.dispose();
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
                  
                  // १. पूरा नाम
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

                  // २. जन्ममिति (Date of Birth)
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDateOfBirth(context),
                    decoration: InputDecoration(
                      hintText: labels['dob']!,
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.calendar_today_outlined,
                          color: Colors.grey),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'जन्ममिति छान्नुहोस्'
                        : null,
                  ),

                  if (_calculatedAgeText != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        _calculatedAgeText!,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ३. लिङ्ग (Gender Dropdown)
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      hintText: labels['gender']!,
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.wc, color: Colors.grey),
                    ),
                    items: _genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState

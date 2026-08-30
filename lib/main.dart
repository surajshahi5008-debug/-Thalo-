import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ================= १. AuthService (अथेन्टिकेसन र डाटाबेज लजिक) =================
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> loginWithEmail({required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<User?> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String dob,
    String gender = 'अन्य',
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email.trim(),
          'dob': dob,
          'gender': gender,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> sendPhoneOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'प्रमाणीकरण असफल भयो');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<User?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw e.toString();
    }
  }
}

// ================= २. ThaloLoginScreen (लगइन स्क्रिन) =================
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
      String msg = e.toString().contains('invalid-credential') ||
              e.toString().contains('wrong-password') ||
              e.toString().contains('user-not-found')
          ? 'इमेल वा पासवर्ड मिलेन।'
          : 'लगइन गर्न सकिएन। फेरि प्रयास गर्नुहोस्।';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
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
                      hintText: labels['email'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'मान्य इमेल हाल्नुहोस्';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    textDirection: dir,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: labels['pass'],
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

// ================= ३. ThaloRegisterScreen (रजिस्टर स्क्रिन) =================
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
  String? _calculatedAgeText;

  final List<String> _languages = ['नेपाली', 'हिन्दी', 'English', 'Urdu'];

  Map<String, String> _getRegisterLabels(String lang) {
    switch (lang) {
      case 'हिन्दी':
        return {
          'title': 'थलो अकाउंट बनाएं',
          'name': 'पूरा नाम',
          'dob': 'जन्म तिथि (DOB)',
          'email': 'ईमेल पता',
          'pass': 'पासवर्ड बनाएं',
          'btn': 'साइन अप करें',
          'haveAccount': 'पहले से खाता है?',
          'loginLink': 'लॉगिन करें'
        };
      case 'English':
        return {
          'title': 'Create Thalo Account',
          'name': 'Full Name',
          'dob': 'Date of Birth',
          'email': 'Email Address',
          'pass': 'Create Password',
          'btn': 'Sign Up',
          'haveAccount': 'Already have an account?',
          'loginLink': 'Log In'
        };
      case 'Urdu':
        return {
          'title': 'تھلو اکاؤنٹ بنائیں',
          'name': 'پورا نام',
          'dob': 'تاریخ پیدائش',
          'email': 'ای میل کا پتہ',
          'pass': 'پاس ورڈ بنائیں',
          'btn': 'سائن اپ کریں',
          'haveAccount': 'پہلے سے اکاؤنٹ ہے؟',
          'loginLink': 'لاگ ان کریں'
        };
      default:
        return {
          'title': 'थलो खाता बनाउनुहोस्',
          'name': 'पूरा नाम',
          'dob': 'जन्ममिति (DOB)',
          'email': 'इमेल ठेगाना',
          'pass': 'पासवर्ड राख्नुहोस्',
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
        }
        _calculatedAgeText = "उमेर: $years वर्ष";
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
        dob: _dobController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThaloNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString().contains('email-already-in-use')
          ? 'यो इमेल पहिले नै प्रयोगमा छ।'
          : e.toString().contains('weak-password')
              ? 'पासवर्ड धेरै कमजोर छ।'
              : 'खाता बनाउन सकिएन। फेरि प्रयास गर्नुहोस्।';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
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
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    textDirection: dir,
                    decoration: InputDecoration(
                      hintText: labels['name'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'कृपया नाम हाल्नुहोस्'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDateOfBirth(context),
                    decoration: InputDecoration(
                      hintText: labels['dob'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.cake_outlined, color: Colors.grey),
                      helperText: _calculatedAgeText,
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'जन्ममिति छान्नुहोस्'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    textDirection: dir,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: labels['email'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
                    ),
                    validator: (value) => (value == null || !value.contains('@'))
                        ? 'मान्य इमेल हाल्नुहोस्'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    textDirection: dir,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: labels['pass'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
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
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
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
                            child: Text(lang, style: const TextStyle(fontSize: 14)),
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

// ================= ४. ThaloNavigationScreen (गृहपृष्ठ / नेभिगेसन) =================
class ThaloNavigationScreen extends StatefulWidget {
  const ThaloNavigationScreen({super.key});

  @override
  State<ThaloNavigationScreen> createState() => _ThaloNavigationScreenState();
}

class _ThaloNavigationScreenState extends State<ThaloNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('🏠 Thalo Home Screen', style: TextStyle(color: Colors.grey, fontSize: 16))),
    const Center(child: Text('🔍 Search Screen', style: TextStyle(color: Colors.grey, fontSize: 16))),
    const Center(child: Text('📊 Analytics Screen', style: TextStyle(color: Colors.grey, fontSize: 16))),
    const Center(child: Text('👤 Profile Screen', style: TextStyle(color: Colors.grey, fontSize: 16))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        shape: const CircleBorder(),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat Room Button Clicked!')),
          );
        },
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () => setState(() => _currentIndex = 0)),
            IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _currentIndex = 1)),
            const SizedBox(width: 40),
            IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => setState(() => _currentIndex = 2)),
            IconButton(icon: const Icon(Icons.person), onPressed: () => setState(() => _currentIndex = 3)),
          ],
        ),
      ),
    );
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // यदि तपाईंले Firebase Initialize गर्नुभएको छैन भने यो लाइन राख्नुपर्छ:
  // await Firebase.initializeApp(); 
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
      ),
      // एप खुल्दा सबैभन्दा पहिले कुन स्क्रिन देखाउने (यहाँ Login देखाउने बनाइएको छ)
      home: const ThaloLoginScreen(), 
    );
  }
}

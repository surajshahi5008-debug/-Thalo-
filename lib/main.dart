import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thalo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.white),
      home: const ThaloLoginScreen(),
    );
  }
}

// ================= AuthService =================
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login({required String email, required String password}) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  Future<User?> register({required String name, required String email, required String password, required String dob}) async {
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
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }
}

// ================= Language Helper Widget =================
Widget buildLangBar(String currentLang, Function(String) onSelected) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: ['English', 'नेपाली', 'हिन्दी', 'Urdu'].map((lang) {
      bool isSel = currentLang == lang;
      return GestureDetector(
        onTap: () => onSelected(lang),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            lang == 'English' ? lang : ' • $lang',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              color: isSel ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      );
    }).toList(),
  );
}

// ================= ThaloLoginScreen =================
class ThaloLoginScreen extends StatefulWidget {
  const ThaloLoginScreen({super.key});

  @override
  State<ThaloLoginScreen> createState() => _ThaloLoginScreenState();
}

class _ThaloLoginScreenState extends State<ThaloLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _lang = 'English'; // Default English

  final Map<String, Map<String, String>> _texts = {
    'English': {'title': 'Log in to your account', 'email': 'Email Address', 'pass': 'Password', 'btn': 'Log In', 'noAcc': "Don't have an account?", 'link': 'Sign Up'},
    'नेपाली': {'title': 'आफ्नो खातामा लगइन गर्नुहोस्', 'email': 'इमेल ठेगाना', 'pass': 'पासवर्ड', 'btn': 'लगइन गर्नुहोस्', 'noAcc': 'खाता छैन?', 'link': 'साइन अप गर्नुहोस्'},
    'हिन्दी': {'title': 'अपने खाते में लॉगिन करें', 'email': 'ईमेल पता', 'pass': 'पासवर्ड', 'btn': 'लॉगिन करें', 'noAcc': 'खाता नहीं है?', 'link': 'साइन अप करें'},
    'Urdu': {'title': 'اپنے اکاؤنٹ میں لاگ ان کریں', 'email': 'ای میل کا پتہ', 'pass': 'پاس ورڈ', 'btn': 'لاگ ان کریں', 'noAcc': 'اکاؤنٹ نہیں ہے؟', 'link': 'سائن اپ کریں'},
  };

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().login(email: _emailController.text, password: _passwordController.text);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ThaloNavigationScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _texts[_lang]!;
    return Directionality(
      textDirection: _lang == 'Urdu' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Thalo', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(t['title']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: t['email'], filled: true, fillColor: const Color(0xfff5f6f8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: t['pass'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(t['btn']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t['noAcc']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThaloRegisterScreen())), child: Text(t['link']!, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildLangBar(_lang, (l) => setState(() => _lang = l)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= ThaloRegisterScreen =================
class ThaloRegisterScreen extends StatefulWidget {
  const ThaloRegisterScreen({super.key});

  @override
  State<ThaloRegisterScreen> createState() => _ThaloRegisterScreenState();
}

class _ThaloRegisterScreenState extends State<ThaloRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _dobC = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _lang = 'English'; // Default English

  final Map<String, Map<String, String>> _texts = {
    'English': {'title': 'Create Thalo Account', 'name': 'Full Name', 'dob': 'Date of Birth', 'email': 'Email Address', 'pass': 'Password', 'btn': 'Sign Up', 'hasAcc': 'Already have an account?', 'link': 'Log In'},
    'नेपाली': {'title': 'थलो खाता बनाउनुहोस्', 'name': 'पूरा नाम', 'dob': 'जन्ममिति', 'email': 'इमेल ठेगाना', 'pass': 'पासवर्ड', 'btn': 'साइन अप गर्नुहोस्', 'hasAcc': 'पहिले नै खाता छ?', 'link': 'लगइन गर्नुहोस्'},
    'हिन्दी': {'title': 'थलो अकाउंट बनाएं', 'name': 'पूरा नाम', 'dob': 'जन्म तिथि', 'email': 'ईमेल पता', 'pass': 'पासवर्ड', 'btn': 'साइन अप करें', 'hasAcc': 'पहले से खाता है?', 'link': 'लॉगिन करें'},
    'Urdu': {'title': 'تھلو اکاؤنٹ بنائیں', 'name': 'پورا نام', 'dob': 'تاریخ پیدائش', 'email': 'ای میل کا پتہ', 'pass': 'پاس ورڈ', 'btn': 'سائن اپ کریں', 'hasAcc': 'پہلے سے اکاؤنٹ ہے؟', 'link': 'لاگ ان کریں'},
  };

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().register(name: _nameC.text, email: _emailC.text, password: _passC.text, dob: _dobC.text);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ThaloNavigationScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _texts[_lang]!;
    return Directionality(
      textDirection: _lang == 'Urdu' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t['title']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _nameC,
                    decoration: InputDecoration(hintText: t['name'], filled: true, fillColor: const Color(0xfff5f6f8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.person_outline, color: Colors.grey)),
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobC,
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1940), lastDate: DateTime.now());
                      if (picked != null) setState(() => _dobC.text = "${picked.year}-${picked.month}-${picked.day}");
                    },
                    decoration: InputDecoration(hintText: t['dob'], filled: true, fillColor: const Color(0xfff5f6f8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.cake_outlined, color: Colors.grey)),
                    validator: (v) => (v == null || v.isEmpty) ? 'Select DOB' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailC,
                    decoration: InputDecoration(hintText: t['email'], filled: true, fillColor: const Color(0xfff5f6f8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passC,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: t['pass'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(t['btn']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t['hasAcc']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      TextButton(onPressed: () => Navigator.pop(context), child: Text(t['link']!, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildLangBar(_lang, (l) => setState(() => _lang = l)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= ThaloNavigationScreen =================
class ThaloNavigationScreen extends StatefulWidget {
  const ThaloNavigationScreen({super.key});

  @override
  State<ThaloNavigationScreen> createState() => _ThaloNavigationScreenState();
}

class _ThaloNavigationScreenState extends State<ThaloNavigationScreen> {
  String _lang = 'English'; // Default English
  final Map<String, String> _texts = {
    'English': 'Welcome to Thalo Home Screen!',
    'नेपाली': 'थलो होम स्क्रिनमा स्वागत छ!',
    'हिन्दी': 'थलो होम स्क्रीन में आपका स्वागत है!',
    'Urdu': 'تھلو ہوم اسکرین میں خوش آمدید!',
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _lang == 'Urdu' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_texts[_lang]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              buildLangBar(_lang, (l) => setState(() => _lang = l)),
            ],
          ),
        ),
      ),
    );
  }
}

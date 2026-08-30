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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ThaloLoginScreen(),
    );
  }
}

// ================= AuthService =================
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login({required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw 'unknown';
    }
  }

  Future<User?> register({
    required String firstName,
    required String middleName,
    required String lastName,
    required String gender,
    required String dob,
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      String finalEmail = emailOrPhone.trim();
      if (!finalEmail.contains('@')) {
        finalEmail = '$finalEmail@thalo.app';
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: finalEmail,
        password: password,
      );
      User? user = credential.user;
      if (user != null) {
        String fullName = '$firstName ${middleName.isNotEmpty ? '$middleName ' : ''}$lastName';
        await user.updateDisplayName(fullName.trim());
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': firstName.trim(),
          'middleName': middleName.trim(),
          'lastName': lastName.trim(),
          'fullName': fullName.trim(),
          'gender': gender,
          'dob': dob,
          'emailOrPhone': emailOrPhone.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw 'unknown';
    }
  }
}

// ================= Language Helper & Error Translator =================
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

String getLocalizedError(String errorCode, String lang) {
  Map<String, Map<String, String>> errorMessages = {
    'wrong-password': {
      'English': 'Incorrect password. Please try again.',
      'नेपाली': 'गलत पासवर्ड। कृपया फेरि प्रयास गर्नुहोस्।',
      'हिन्दी': 'गलत पासवर्ड। कृपया पुनः प्रयास करें।',
      'Urdu': 'गलत پاس ورڈ۔ براہ کرم دوبارہ کوشش کریں۔',
    },
    'user-not-found': {
      'English': 'No user found with this email/phone.',
      'नेपाली': 'यो इमेल वा फोन नम्बरसँग सम्बन्धित कुनै खाता फेला परेन।',
      'हिन्दी': 'इस ईमेल या फोन से कोई उपयोगकर्ता नहीं मिला।',
      'Urdu': 'اس ای میل یا فون کے ساتھ کوئی صارف نہیں ملا।',
    },
    'invalid-credential': {
      'English': 'Invalid email/phone or password.',
      'नेपाली': 'इमेल/फोन वा पासवर्ड मिलेन।',
      'हिन्दी': 'अमान्य ईमेल/फोन या पासवर्ड।',
      'Urdu': 'غلط ای میل/فون یا پاس ورڈ۔',
    },
    'email-already-in-use': {
      'English': 'This email or phone is already registered.',
      'नेपाली': 'यो इमेल वा फोन नम्बर पहिल्यै दर्ता भइसकेको छ।',
      'हिन्दी': 'यह ईमेल या फोन पहले से पंजीकृत है।',
      'Urdu': 'یہ ای میل یا فون پہلے سے رجسٹرڈ ہے۔',
    },
    'weak-password': {
      'English': 'The password is too weak.',
      'नेपाली': 'पासवर्ड धेरै कमजोर भयो। कम्तीमा ६ अक्षर हुनुपर्छ।',
      'हिन्दी': 'पासवर्ड बहुत कमज़ोर है।',
      'Urdu': 'پاس ورڈ بہت کمزور ہے۔',
    },
  };

  if (errorMessages.containsKey(errorCode) && errorMessages[errorCode]!.containsKey(lang)) {
    return errorMessages[errorCode]![lang]!;
  }

  switch (lang) {
    case 'नेपाली':
      return 'केही त्रुटि भयो। कृपया फेरि प्रयास गर्नुहोस्।';
    case 'हिन्दी':
      return 'कुछ त्रुटि हुई। कृपया पुनः प्रयास करें।';
    case 'Urdu':
      return 'کچھ غلط ہو گیا۔ براہ مہربانی دوبارہ کوشش کریں۔';
    default:
      return 'An error occurred. Please try again.';
  }
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
  String _lang = 'English';

  final Map<String, Map<String, String>> _texts = {
    'English': {
      'title': 'Log in to your account',
      'email': 'Email or Phone Number',
      'pass': 'Password',
      'btn': 'Log In',
      'noAcc': "Don't have an account?",
      'link': 'Sign Up'
    },
    'नेपाली': {
      'title': 'आफ्नो खातामा लगइन गर्नुहोस्',
      'email': 'इमेल वा फोन नम्बर',
      'pass': 'पासवर्ड',
      'btn': 'लगइन गर्नुहोस्',
      'noAcc': 'खाता छैन?',
      'link': 'साइन अप गर्नुहोस्'
    },
    'हिन्दी': {
      'title': 'अपने खाते में लॉगिन करें',
      'email': 'ईमेल या फोन नंबर',
      'pass': 'पासवर्ड',
      'btn': 'लॉगिन करें',
      'noAcc': 'खाता नहीं है?',
      'link': 'साइन अप करें'
    },
    'Urdu': {
      'title': 'اپنے اکاؤنٹ میں لاگ ان کریں',
      'email': 'ای میل یا فون نمبر',
      'pass': 'پاس ورڈ',
      'btn': 'لاگ ان کریں',
      'noAcc': 'اکاؤنٹ نہیں ہے؟',
      'link': 'سائن اپ کریں'
    },
  };

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      String loginInput = _emailController.text.trim();
      if (!loginInput.contains('@')) {
        loginInput = '$loginInput@thalo.app';
      }
      await AuthService().login(
        email: loginInput,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ThaloNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      String message = getLocalizedError(e.toString(), _lang);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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
                  const Text(
                    'Thalo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    t['title']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: t['email'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: t['pass'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(t['btn']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t['noAcc']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ThaloRegisterScreen()),
                        ),
                        child: Text(
                          t['link']!,
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
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

// ================= ThaloRegisterScreen (Multi-step) =================
class ThaloRegisterScreen extends StatefulWidget {
  const ThaloRegisterScreen({super.key});

  @override
  State<ThaloRegisterScreen> createState() => _ThaloRegisterScreenState();
}

class _ThaloRegisterScreenState extends State<ThaloRegisterScreen> {
  int _currentStep = 1;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final _firstNameC = TextEditingController();
  final _middleNameC = TextEditingController();
  final _lastNameC = TextEditingController();
  final _emailOrPhoneC = TextEditingController();
  final _passC = TextEditingController();
  final _dobC = TextEditingController();

  String? _selectedGender;
  String _ageString = '';
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _lang = 'English';

  final Map<String, Map<String, String>> _texts = {
    'English': {
      'title1': 'Personal Details (Step 1)',
      'title2': 'Account Security (Step 2)',
      'fName': 'First Name',
      'mName': 'Middle Name (Optional)',
      'lName': 'Last Name',
      'gender': 'Select Gender',
      'dob': 'Date of Birth',
      'email': 'Email or Phone Number',
      'pass': 'Create Password',
      'next': 'Next',
      'btn': 'Sign Up',
      'hasAcc': 'Already have an account?',
      'link': 'Log In',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
    },
    'नेपाली': {
      'title1': 'व्यक्तिगत विवरण (चरण १)',
      'title2': 'खाता सुरक्षा (चरण २)',
      'fName': 'पहिलो नाम',
      'mName': 'बीचको नाम (ऐच्छिक)',
      'lName': 'थर',
      'gender': 'लिङ्ग छान्नुहोस्',
      'dob': 'जन्म मिति',
      'email': 'इमेल वा फोन नम्बर',
      'pass': 'पासवर्ड सिर्जना गर्नुहोस्',
      'next': 'अर्को',
      'btn': 'साइन अप गर्नुहोस्',
      'hasAcc': 'पहिले नै खाता छ?',
      'link': 'लगइन गर्नुहोस्',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'अन्य',
    },
    'हिन्दी': {
      'title1': 'व्यक्तिगत विवरण (चरण १)',
      'title2': 'खाता सुरक्षा (चरण २)',
      'fName': 'पहला नाम',
      'mName': 'बीच का नाम (वैकल्पिक)',
      'lName': 'उपनाम',
      'gender': 'लिंग चुनें',
      'dob': 'जन्म तिथि',
      'email': 'ईमेल या फोन नंबर',
      'pass': 'पासवर्ड बनाएं',
      'next': 'अगला',
      'btn': 'साइन अप करें',
      'hasAcc': 'पहले से खाता है?',
      'link': 'लॉगिन करें',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'अन्य',
    },
    'Urdu': {
      'title1': 'ذاتی تفصیلات (مرحلہ 1)',
      'title2': 'اکاؤنٹ سیکیورٹی (مرحلہ 2)',
      'fName': 'پہلا نام',
      'mName': 'درمیانی نام',
      'lName': 'آخری نام',
      'gender': 'صنف منتخب کریں',
      'dob': 'تاریخ پیدائش',
      'email': 'ای میل یا فون نمبر',
      'pass': 'پاس ورڈ بنائیں',
      'next': 'اگلا',
      'btn': 'سائن اپ کریں',
      'hasAcc': 'پہلے سے اکاؤنٹ ہے؟',
      'link': 'لاگ ان کریں',
      'male': 'مرد',
      'female': 'عورت',
      'other': 'دیگر',
    },
  };

  void _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int years = today.year - dob.year;
    int months = today.month - dob.month;
    int days = today.day - dob.day;

    if (days < 0) {
      months--;
      days += DateTime(today.year, today.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    setState(() {
      switch (_lang) {
        case 'नेपाली':
          _ageString = 'उमेर: $years वर्ष, $months महिना, $days दिन';
          break;
        case 'हिन्दी':
          _ageString = 'आयु: $years वर्ष, $months महीने, $days दिन';
          break;
        case 'Urdu':
          _ageString = 'عمر: $years سال، $months ماہ، $days دن';
          break;
        default:
          _ageString = 'Age: $years years, $months months, $days days';
      }
    });
  }

  void _goToStep2() {
    if (_formKey1.currentState!.validate() && _selectedGender != null) {
      setState(() => _currentStep = 2);
    } else if (_selectedGender == null) {
      String msg = 'Please select gender';
      if (_lang == 'नेपाली') msg = 'कृपया लिङ्ग छान्नुहोस्';
      if (_lang == 'हिन्दी') msg = 'कृपया लिंग चुनें';
      if (_lang == 'Urdu') msg = 'براہ کرم صنف منتخب کریں';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _submit() async {
    if (!_formKey2.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().register(
        firstName: _firstNameC.text,
        middleName: _middleNameC.text,
        lastName: _lastNameC.text,
        gender: _selectedGender ?? '',
        dob: _dobC.text,
        emailOrPhone: _emailOrPhoneC.text,
        password: _passC.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ThaloNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      String message = getLocalizedError(e.toString(), _lang);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: _currentStep == 2
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _currentStep = 1),
                )
              : null,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _currentStep == 1
                ? Form(
                    key: _formKey1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t['title1']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: _firstNameC,
                          decoration: InputDecoration(
                            hintText: t['fName'],
                            filled: true,
                            fillColor: const Color(0xfff5f6f8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _middleNameC,
                          decoration: InputDecoration(
                            hintText: t['mName'],
                            filled: true,
                            fillColor: const Color(0xfff5f6f8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                          ),
                        ),
                    

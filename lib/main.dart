import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

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

  String _formatEmail(String input) {
    String cleaned = input.trim();
    if (!cleaned.contains('@')) {
      return '$cleaned@thalo.app';
    }
    return cleaned;
  }

  String _securePassword(String rawPassword) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(rawPassword);
    return 'Thalo_$encoded';
  }

  Future<User?> login({required String email, required String password}) async {
    try {
      String finalEmail = _formatEmail(email);
      String finalPassword = _securePassword(password);
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: finalEmail,
        password: finalPassword,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw e.toString();
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
      String finalEmail = _formatEmail(emailOrPhone);
      String finalPassword = _securePassword(password);

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: finalEmail,
        password: finalPassword,
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
      throw e.toString();
    }
  }
}

// ================= Language Bar & Localization =================
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
      'English': 'The password is too weak (Min 6 characters).',
      'नेपाली': 'पासवर्ड धेरै कमजोर भयो (कम्तीमा ६ अक्षर आवश्यक छ)।',
      'हिन्दी': 'पासवर्ड बहुत कमज़ोर है (न्यूनतम 6 अक्षर)।',
      'Urdu': 'پاس ورڈ بہت کمزور ہے (کم از کم 6 حروف)۔',
    },
    'invalid-email': {
      'English': 'The format of the email or phone is invalid.',
      'नेपाली': 'इमेल वा फोन नम्बरको ढाँचा मिलेन।',
      'हिन्दी': 'ईमेल या फोन नंबर का प्रारूप अमान्य है।',
      'Urdu': 'ای میل یا فون نمبر کا فارمیٹ غلط ہے۔',
    },
    'network-request-failed': {
      'English': 'Network error. Please check your internet connection.',
      'नेपाली': 'इन्टरनेट जडान असफल भयो। कृपया आफ्नो नेट जाँच गर्नुहोस्।',
      'हिन्दी': 'नेटवर्क त्रुटि। कृपया अपना इंटरनेट कनेक्शन जांचें।',
      'Urdu': 'نیٹ ورک کی خرابی۔ براہ کرم اپنا انٹرنیٹ چیک کریں۔',
    },
  };

  if (errorMessages.containsKey(errorCode) && errorMessages[errorCode]!.containsKey(lang)) {
    return errorMessages[errorCode]![lang]!;
  }
  return 'Error: $errorCode';
}

// ================= Dynamic Calendar Picker Dialog =================
class DynamicCalendarPickerDialog extends StatefulWidget {
  final String appLanguage;
  final Function(String formattedDate) onConfirm;

  const DynamicCalendarPickerDialog({
    super.key,
    required this.appLanguage,
    required this.onConfirm,
  });

  @override
  State<DynamicCalendarPickerDialog> createState() => _DynamicCalendarPickerDialogState();
}

class _DynamicCalendarPickerDialogState extends State<DynamicCalendarPickerDialog> {
  late String primaryCalendarName;
  late String activeCalendarType;

  int selectedYear = 2080;
  int selectedMonth = 1;
  int selectedDay = 1;

  @override
  void initState() {
    super.initState();
    // भाषा अनुसार स्थानीय क्यालेन्डर नाम छुट्याउने
    if (widget.appLanguage == 'नेपाली') {
      primaryCalendarName = 'BS';
    } else if (widget.appLanguage == 'Urdu') {
      primaryCalendarName = 'Hijri';
    } else if (widget.appLanguage == 'हिन्दी') {
      primaryCalendarName = 'VS';
    } else {
      primaryCalendarName = 'Local';
    }

    activeCalendarType = primaryCalendarName;
    _setToday();
  }

  void _setToday() {
    DateTime now = DateTime.now();
    if (activeCalendarType == primaryCalendarName) {
      selectedYear = now.year + (widget.appLanguage == 'नेपाली' ? 57 : 0);
      selectedMonth = now.month;
      selectedDay = now.day;
    } else {
      selectedYear = now.year;
      selectedMonth = now.month;
      selectedDay = now.day;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> years = activeCalendarType == primaryCalendarName
        ? List.generate(85, (index) => 2000 + index)
        : List.generate(80, (index) => 1950 + index);

    List<int> months = List.generate(12, (index) => index + 1);
    List<int> days = List.generate(32, (index) => index + 1);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // माथिल्लो भागमा भाषा अनुसारको क्यालेन्डर टगल र Today बटन
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          activeCalendarType = primaryCalendarName;
                          selectedYear = 2080;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: activeCalendarType == primaryCalendarName ? Colors.black87 : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          primaryCalendarName,
                          style: TextStyle(
                            color: activeCalendarType == primaryCalendarName ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          activeCalendarType = 'AD';
                          selectedYear = 2000;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: activeCalendarType == 'AD' ? Colors.black87 : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'AD',
                          style: TextStyle(
                            color: activeCalendarType == 'AD' ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _setToday,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // साल, महिना र दिन छान्ने ड्रपडाउन बक्सहरू (तस्बिरको ढाँचा अनुसार)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedYear,
                        isExpanded: true,
                        items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                        onChanged: (val) => setState(() => selectedYear = val!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        isExpanded: true,
                        items: months.map((m) => DropdownMenuItem(value: m, child: Text('$m'))).toList(),
                        onChanged: (val) => setState(() => selectedMonth = val!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedDay,
                        isExpanded: true,
                        items: days.map((d) => DropdownMenuItem(value: d, child: Text('$d'))).toList(),
                        onChanged: (val) => setState(() => selectedDay = val!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  String formatted = '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')} ($activeCalendarType)';
                  widget.onConfirm(formatted);
                  Navigator.pop(context);
                },
                child: const Text('OK / Confirm', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
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
      await AuthService().login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ThaloNavigationScreen(lang: _lang)),
      );
    } catch (e) {
      if (!mounted) return;
      String message = getLocalizedError(e.toString().replaceAll('1', '').trim(), _lang);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
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
                  const Text('Thalo', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(t['title']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: t['email'],
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(t['btn']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t['noAcc']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThaloRegisterScreen())),
                        child: Text(t['link']!, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
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

// ================= ThaloRegisterScreen =================
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

  void _openDynamicCalendarPicker() {
    showDialog(
      context: context,
      builder: (context) => DynamicCalendarPickerDialog(
        appLanguage: _lang,
        onConfirm: (formattedDate) {
          setState(() {
            _dobC.text = formattedDate;
            try {
              String clean = formattedDate.split(' ')[0];
              int year = int.parse(clean.split('-')[0]);
              if (formattedDate.contains('BS') || formattedDate.contains('Hijri')) {
                year -= (_lang == 'नेपाली' ? 57 : 0);
              }
              int month = int.parse(clean.split('-')[1]);
              int day = int.parse(clean.split('-')[2]);
              DateTime parsed = DateTime(year, month, day);
              
              DateTime today = DateTime.now();
              int ageY = today.year - parsed.year;
              _ageString = 'उमेर / Age: लगभग $ageY वर्ष';
            } catch (_) {
              _ageString = '';
            }
          });
        },
      ),
    );
  }

  void _goToStep2() {
    if (_formKey1.currentState!.validate() && _selectedGender != null) {
      setState(() => _currentStep = 2);
    } else if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया लिङ्ग छान्नुहोस्'), backgroundColor: Colors.orange));
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ThaloNavigationScreen(lang: _lang)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getLocalizedError(e.toString(), _lang)), backgroundColor: Colors.red));
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
          leading: _currentStep == 2 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentStep = 1)) : null,
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
                        Text(t['title1']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: _firstNameC,
                          decoration: InputDecoration(
                            hintText: t['fName'],
                            filled: true,
                            fillColor: const Color(0xfff5f6f8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameC,
                          decoration: InputDecoration(
                            hintText: t['lName'],
                            filled: true,
                            fillColor: const Color(0xfff5f6f8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            hintText: t['gender'],
                            filled: true,
                            fillColor: const Color(0xfff5f6f8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.transgender, color: Colors.grey),
                          ),
                          items: [
                            DropdownMenuItem(value: 'Male', child: Text(t['male']!)),
                            DropdownMenuItem(value: 'Female', child: Text(t['female']!)),
                            DropdownMenuItem(value: 'Other', child: Text(t['other']!)),
                          ],
                          onChanged: (val) => setState(() => _selectedGender = val),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dobC,
                          readOnly: true,
                          onTap: _openDynamicCalendarPicker,
                          decoration: InputDecoration(
                            hintText: t['dob'],
                            filled: true,
                            fillColor: const Color(0xfff5f6f8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Select DOB' : null,
                        ),
                        if (_ageString.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(_ageString, textAlign: TextAlign.center, style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                        ],
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: _goToStep2,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(t['next']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(t['hasAcc']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(t['link']!, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        buildLangBar(_lang, (l) => setState(() => _lang = l)),
                      ],
                    ),
                  )
                : Form(
                    key: _formKey2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(t['title2']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: _emailOrPhoneC,
                          decoration: InputDecoration(
                            hintText: t['email'],
                            filled: true,
                            fillColor: const Color(0xfff5f6f8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.perm_identity, color: Colors.grey),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(t['btn']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(t['hasAcc']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(t['link']!, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
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

// ================= ThaloNavigationScreen =================
class ThaloNavigationScreen extends StatefulWidget {
  final String lang;
  const ThaloNavigationScreen({super.key, required this.lang});

  @override
  State<ThaloNavigationScreen> createState() => _ThaloNavigationScreenState();
}

class _ThaloNavigationScreenState extends State<ThaloNavigationScreen> {
  late String _lang;

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
  }

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

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

// ================= Language Bar & Localization =================
Widget buildLangBar(String currentLang, Function(String) onSelected) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: ['English', 'नेपाली', 'नेपाल भाषा', 'हिन्दी', 'Urdu'].map((lang) {
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
  String? primaryCalendarName;
  late String activeCalendarType;
  int selectedYear = 2080;
  int selectedMonth = 1;
  int selectedDay = 1;

  @override
  void initState() {
    super.initState();
    if (widget.appLanguage == 'नेपाली') {
      primaryCalendarName = 'वि.सं.';
    } else if (widget.appLanguage == 'नेपाल भाषा') {
      primaryCalendarName = 'ने.सं.';
    } else if (widget.appLanguage == 'Urdu') {
      primaryCalendarName = 'هجری';
    } else {
      primaryCalendarName = null; 
    }
    activeCalendarType = primaryCalendarName ?? 'AD';
    _setToday();
  }

  void _setToday() {
    DateTime now = DateTime.now();
    if (primaryCalendarName != null && activeCalendarType == primaryCalendarName) {
      if (widget.appLanguage == 'नेपाली') {
        selectedYear = now.year + 57;
      } else if (widget.appLanguage == 'नेपाल भाषा') {
        selectedYear = now.year + 923;
      } else {
        selectedYear = now.year;
      }
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
    int currentBaseYear = DateTime.now().year;
    List<int> years = List.generate(201, (index) => (currentBaseYear - 100) + index);
    List<int> months = List.generate(12, (index) => index + 1);
    List<int> days = List.generate(32, (index) => index + 1);
    bool hasToggle = primaryCalendarName != null;

    // भाषा अनुसारको शुद्ध शब्द ('पुष्टि गर्नुहोस्')
    String confirmText = 'Confirm';
    if (widget.appLanguage == 'नेपाली') {
      confirmText = 'पुष्टि गर्नुहोस्';
    } else if (widget.appLanguage == 'नेपाल भाषा') {
      confirmText = 'निश्चित यानादिसँ';
    } else if (widget.appLanguage == 'हिन्दी') {
      confirmText = 'पुष्टि करें';
    } else if (widget.appLanguage == 'Urdu') {
      confirmText = 'تصدیق کریں';
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (hasToggle) ...[
                      GestureDetector(
                        onTap: () => setState(() {
                          activeCalendarType = primaryCalendarName!;
                          selectedYear = currentBaseYear + 57;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: activeCalendarType == primaryCalendarName ? Colors.black87 : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            primaryCalendarName!,
                            style: TextStyle(
                              color: activeCalendarType == primaryCalendarName ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GestureDetector(
                      onTap: () => setState(() {
                        activeCalendarType = 'AD';
                        selectedYear = currentBaseYear;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: activeCalendarType == 'AD' ? Colors.black87 : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _setToday,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Today', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: years.contains(selectedYear) ? selectedYear : currentBaseYear,
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
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
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
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
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
                child: Text(confirmText, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Verification Notice Screen (Email Link or Phone OTP) =================
class ThaloVerificationNoticeScreen extends StatelessWidget {
  final String contactInfo;
  final String lang;
  const ThaloVerificationNoticeScreen({super.key, required this.contactInfo, required this.lang});

  @override
  Widget build(BuildContext context) {
    bool isEmail = contactInfo.contains('@');

    final Map<String, Map<String, String>> texts = {
      'English': {
        'title': isEmail ? 'Verify Your Email' : 'Verify Your Phone',
        'desc': isEmail 
            ? 'We have sent a verification link to your email. Please check your inbox and click the link to verify.' 
            : 'We have sent a 6-digit OTP to your phone number via SMS.',
        'btn': 'Go to Home',
      },
      'नेपाली': {
        'title': isEmail ? 'तपाईंको इमेल पुष्टि गर्नुहोस्' : 'तपाईंको फोन नम्बर पुष्टि गर्नुहोस्',
        'desc': isEmail 
            ? 'हामीले तपाईंको इमेलमा भेरिफिकेसन लिङ्क पठाएका छौं। कृपया इमेल खोलेर लिङ्कमा क्लिक गर्नुहोस्।' 
            : 'हामीले तपाईंको फोन नम्बरमा SMS मार्फत ६ अंकको OTP पठाएका छौं।',
        'btn': 'गृह पृष्ठमा जानुहोस्',
      },
      'हिन्दी': {
        'title': isEmail ? 'अपना ईमेल सत्यापित करें' : 'अपना फोन सत्यापित करें',
        'desc': isEmail 
            ? 'हमने आपके ईमेल पर एक सत्यापन लिंक भेजा है। कृपया अपना इनबॉक्स जांचें।' 
            : 'हमने आपके फोन पर 6-अंक का OTP भेजा है।',
        'btn': 'होम स्क्रीन पर जाएं',
      },
      'Urdu': {
        'title': isEmail ? 'اپنا ای میل تصدیق کریں' : 'اپنا فون تصدیق کریں',
        'desc': isEmail 
            ? 'ہم نے آپ کے ای میل پر تصدیقی لنک بھیج دیا ہے۔' 
            : 'ہم نے آپ کے فون پر 6 ہندسوں کا OTP بھیج دیا ہے۔',
        'btn': 'ہوم سکرین پر جائیں',
      }
    };

    final t = texts[lang] ?? texts['English']!;

    return Directionality(
      textDirection: lang == 'Urdu' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(isEmail ? Icons.mark_email_unread_outlined : Icons.sms_outlined, size: 64, color: Colors.black87),
              const SizedBox(height: 20),
              Text(t['title']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(t['desc']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ThaloNavigationScreen(lang: lang)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(t['btn']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
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
    'नेपाल भाषा': {
      'title': 'जिगु खाताय् लगइन यानादिसँ',
      'email': 'इमेल वा फोन नम्बर',
      'pass': 'पासवर्ड',
      'btn': 'लगइन यानादिसँ',
      'noAcc': 'खाता मदु ला?',
      'link': 'साइन अप यायेगु'
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ThaloNavigationScreen(lang: _lang)),
    );
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(t['btn']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
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
      'btn': 'Verify & Sign Up',
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
      'btn': 'पुष्टि गरी साइन अप गर्नुहोस्',
      'hasAcc': 'पहिले नै खाता छ?',
      'link': 'लगइन गर्नुहोस्',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'अन्य',
    },
    'नेपाल भाषा': {
      'title1': 'व्यक्तिगत विवरण (चरण १)',
      'title2': 'खाता सुरक्षा (चरण २)',
      'fName': 'न्हापांग्गु नां',
      'mName': 'दथुया नां (छ्यायेफु)',
      'lName': 'थ्वः/थर',
      'gender': 'लिङ्ग ल्ययादिसँ',
      'dob': 'बुगु मिति',
      'email': 'इमेल वा फोन नम्बर',
      'pass': 'पासवर्ड तयार यानादिसँ',
      'next': 'लिपांग्गु',
      'btn': 'निश्चित कयाः साइन अप यानादिसँ',
      'hasAcc': 'न्हापां नं खाता दु ला?',
      'link': 'लगइन यायेगु',
      'male': 'मिजं',
      'female': 'मिसा',
      'other': 'गुगुं नं मेगु',
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
      'btn': 'सत्यापित करें और साइन अप करें',
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
      'btn': 'تصدیق کریں اور سائن اپ کریں',
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
              if (formattedDate.contains('वि.सं.')) year -= 57;
              else if (formattedDate.contains('ने.सं.')) year -= 923;

              int month = int.parse(clean.split('-')[1]);
              int day = int.parse(clean.split('-')[2]);
              DateTime parsed = DateTime(year, month, day);
              DateTime today = DateTime.now();
              Duration difference = today.difference(parsed);
              int ageYears = difference.inDays ~/ 365;
              int ageDays = difference.inDays % 365;

              if (_lang == 'नेपाली') {
                _ageString = 'उमेर: $ageYears वर्ष र $ageDays दिन';
              } else if (_lang == 'नेपाल भाषा') {
                _ageString = 'उमेर: $ageYears दँ व $ageDays दिं';
              } else if (_lang == 'हिन्दी') {
                _ageString = 'आयु: $ageYears वर्ष और $ageDays दिन';
              } else if (_lang == 'Urdu') {
                _ageString = 'عمر: $ageYears سال اور $ageDays دن';
              } else {
                _ageString = 'Age: $ageYears years and $ageDays days';
              }
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

  void _submit() {
    if (!_formKey2.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThaloVerificationNoticeScreen(contactInfo: _emailOrPhoneC.text, lang: _lang),
      ),
    );
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
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(t['btn']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
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
    'नेपाल भाषा': 'थलो होम स्क्रिनय् सुस्वागतम्!',
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

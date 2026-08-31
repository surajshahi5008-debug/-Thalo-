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

// ================= Number Localizer (अंकहरू भाषाअनुसार बदल्ने) =================
String _localizeNumber(String input, String lang) {
  if (lang != 'नेपाली' && lang != 'नेपाल भाषा' && lang != 'हिन्दी' && lang != 'Urdu') {
    return input;
  }
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const localized = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
  
  String result = input;
  for (int i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], localized[i]);
  }
  return result;
}

// ================= Helper: Localized Month Names =================
List<String> getLocalizedMonths(String langCode, String calendarType) {
  if (calendarType == 'वि.सं.') {
    return ['वैशाख', 'जेठ', 'आषाढ', 'श्रावण', 'भाद्र', 'आश्विन', 'कार्तिक', 'मार्गशीर्ष', 'पौष', 'माघ', 'फाल्गुन', 'चैत्र'];
  } else if (calendarType == 'ने.सं.') {
    return ['छलागा', 'चौला', 'बछला', 'तछला', 'दिल्ला', 'गुंला', 'ञला', 'कला', 'थिला', 'प्वंला', 'अछला', 'तियाँ'];
  }
  
  switch (langCode) {
    case 'हिन्दी':
      return ['जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];
    case 'नेपाली':
    case 'नेपाल भाषा':
    case 'Urdu':
    case 'English':
    default:
      return ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  }
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

    List<String> localizedMonthNames = getLocalizedMonths(widget.appLanguage, activeCalendarType);

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
                          selectedYear = widget.appLanguage == 'नेपाल भाषा' ? currentBaseYear + 923 : currentBaseYear + 57;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: activeCalendarType == primaryCalendarName ? Colors.black87 : Colors.grey[300],
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
                          color: activeCalendarType == 'AD' ? Colors.black87 : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'AD',
                          style: TextStyle(
                            color: activeCalendarType == 'AD' ? Colors.white : Colors.black87,
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
                        items: years.map((y) => DropdownMenuItem(
                          value: y, 
                          child: Text(_localizeNumber('$y', widget.appLanguage)),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedYear = val!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        isExpanded: true,
                        items: months.map((m) => DropdownMenuItem(
                          value: m, 
                          child: Text(localizedMonthNames[m - 1], overflow: TextOverflow.ellipsis),
                        )).toList(),
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
                        items: days.map((d) => DropdownMenuItem(
                          value: d, 
                          child: Text(_localizeNumber('$d', widget.appLanguage)),
                        )).toList(),
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

// ================= Verification Notice Screen =================
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
      'नेपाल भाषा': {
        'title': isEmail ? 'जिगु इमेल निश्चित यानादिसँ' : 'जिगु फोन नम्बर निश्चित यानादिसँ',
        'desc': isEmail 
            ? 'जिपिं जिगु इमेलय् भेरिफिकेसन लिंक छ्वयाबियागु दु। छगु इमेल स्वयाः भेरिफाइ यानादिसँ।' 
            : 'जिपिं जिगु फोन नम्बरय् SMS पाखें ६ अंकया OTP छ्वयाबियागु दु।',
        'btn': 'छेँय् वनेगु',
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
  String _birthdayMessage = '';
  String _birthdayWish = '';
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

              int ageYears = today.year - parsed.year;
              int ageMonths = today.month - parsed.month;
              int ageDays = today.day - parsed.day;

              if (ageDays < 0) {
                ageMonths -= 1;
                DateTime prevMonth = DateTime(today.year, today.month, 0);
                ageDays += prevMonth.day;
              }

              if (ageMonths < 0) {
                ageYears -= 1;
                ageMonths += 12;
              }

              String yStr = _localizeNumber('$ageYears', _lang);
              String mStr = _localizeNumber('$ageMonths', _lang);
              String dStr = _localizeNumber('$ageDays', _lang);

              if (_lang == 'नेपाली') {
                _ageString = 'उमेर: $yStr वर्ष, $mStr महिना र $dStr दिन';
              } else if (_lang == 'नेपाल भाषा') {
                _ageString = 'उमेर: $yStr दँ, $mStr महिना व $dStr दिं';
              } else if (_lang == 'हिन्दी') {
                _ageString = 'आयु: $yStr वर्ष, $mStr महीने और $dStr दिन';
              } else if (_lang == 'Urdu') {
                _ageString = 'عمر: $yStr سال، $mStr مہینے اور $dStr دن';
              } else {
                _ageString = 'Age: $yStr years, $mStr months and $dStr days';
              }

              DateTime nextBday = DateTime(today.year, parsed.month, parsed.day);
              if (nextBday.isBefore(today) || nextBday.isAtSameMomentAs(today)) {
                if (!(nextBday.month == today.month && nextBday.day == today.day)) {
                  nextBday = DateTime(today.year + 1, parsed.month, parsed.day);
                }
              }

              int diffDays = nextBday.difference(today).inDays;
              
              if (parsed.month == today.month && parsed.day == today.day) {
                int celebratingAge = today.year - parsed.year;
                String cAgeStr = _localizeNumber('$celebratingAge', _lang);
                
                if (_lang == 'नेपाली') {
                  _birthdayMessage = 'तपाईंको आज $cAgeStr औं जन्मदिन रहेको छ।';
                  _birthdayWish = '🎉 थलोको तर्फबाट तपाईंलाई जन्मदिनको हार्दिक मंगलमय शुभकामना! 🎉';
                } else if (_lang == 'नेपाल भाषा') {
                  _birthdayMessage = 'जिगु थौं $cAgeStr औं बुगुन्हि जुयाच्वंगु दु।';
                  _birthdayWish = '🎉 थलो पाखें जिगु बुगुन्हिया भिंतुना! 🎉';
                } else if (_lang == 'हिन्दी') {
                  _birthdayMessage = 'आपका आज $cAgeStr वां जन्मदिन है।';
                  _birthdayWish = '🎉 थलो की ओर से आपको जन्मदिन की हार्दिक शुभकामनाएं! 🎉';
                } else if (_lang == 'Urdu') {
                  _birthdayMessage = 'آج آپ کی سالگرہ ہے۔';
                  _birthdayWish = '🎉 تھلو کی طرف سے آپ کو سالگرہ بہت مبارک ہو! 🎉';
                } else {
                  _birthdayMessage = 'Today is your $cAgeStr-th birthday.';
                  _birthdayWish = '🎉 Happy Birthday! Wishing you a wonderful birthday from Thalo! 🎉';
                }
              } else {
                _birthdayWish = ''; 
                int nthAge = ageYears + 1;
                String diffStr = _localizeNumber('$diffDays', _lang);
                String nthStr = _localizeNumber('$nthAge', _lang);
                
                if (_lang == 'नेपाली') {
                  _birthdayMessage = 'तपाईंको $nthStr जन्मदिन $diffStr दिनपछि आउँदैछ।';
                } else if (_lang == 'नेपाल भाषा') {
                  _birthdayMessage = 'जिगु $nthStr गुगु बुगुन्हि $diffStr दिं लिपा वयाच्वंगु दु।';
                } else if (_lang == 'हिन्दी') {
                  _birthdayMessage = 'आपका $nthStr जन्मदिन $diffStr दिन बाद आ रहा है।';
                } else if (_lang == 'Urdu') {
                  _birthdayMessage = 'آپ کی اگلی سالگرہ $diffStr دن کے بعد آ رہی ہے۔';
                } else {
                  _birthdayMessage = 'Your $nthStr birthday is coming up in $diffStr days.';
                }
              }

            } catch (e) {
              _ageString = '';
              _birthdayMessage = '';
              _birthdayWish = '';
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
                        if (_birthdayMessage.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(_birthdayMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13)),
                        ],
                        if (_birthdayWish.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(_birthdayWish, textAlign: TextAlign.center, style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 13)),
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
    'English': 'Connect, Create and Be Happy',
    'नेपाली': 'जोडिनुहोस्, सिर्जना गर्नुहोस् र खुसी रहनुहोस्',
    'नेपाल भाषा': 'स्वापू तयादिसँ, सिर्जना यानादिसँ व तनाः च्वनादिसँ',
    'हिन्दी': 'जुड़ें, बनाएं और खुश रहें',
    'Urdu': 'جڑیں، تخلیق کریں اور خوش رہیں',
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _lang == 'Urdu' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thalo Home'),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const ThaloLoginScreen()),
                  (route) => false,
                );
              },
            )
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              _texts[_lang] ?? _texts['English']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ThaloApp());
}

class ThaloApp extends StatelessWidget {
  const ThaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // 0: Login, 1: Register Step 1, 11: Register Step 2, 2: Home
  int _currentIndex = 0;
  String _currentLang = 'नेपाली';
  final String _selectedDate = 'आज';

  // साइन अप स्टेप २ का लागि भेरिएबलहरू
  String? _selectedGender;
  bool _acceptTerms = false;

  // जन्म मिति र क्यालेन्डर स्विचका लागि भेरिएबलहरू
  String _selectedCalendar = 'वि.सं.'; 
  int _selectedYear = 2080;
  int _selectedMonth = 8;
  int _selectedDay = 31;

  // भाषा अनुसार शुद्ध शब्दहरू र क्यालेन्डर सर्टकटहरू
  Map<String, Map<String, String>> get _localizedValues => {
        'English': {
          'loginAppBar': 'Thalo - Login',
          'loginTitle': 'Welcome Back to Thalo',
          'emailLabel': 'Email',
          'passwordLabel': 'Password',
          'loginButton': 'Login',
          'noAccount': "Don't have an account? Sign Up here",
          'registerAppBar': 'Thalo - Sign Up',
          'registerTitle': 'Create New Account',
          'firstName': 'First Name',
          'middleName': 'Middle Name (Optional)',
          'lastName': 'Last Name',
          'dob': 'Date of Birth',
          'nextButton': 'Next',
          'gender': 'Select Gender',
          'male': 'Male',
          'female': 'Female',
          'other': 'Other',
          'phoneOrEmail': 'Email or Phone Number',
          'terms': 'I accept the Terms & Conditions',
          'registerButton': 'Sign Up',
          'hasAccount': 'Already have an account? Login here',
          'calToggle': '', // अङ्ग्रेजीमा पनि सर्टकट देखाइने छैन
        },
        'नेपाली': {
          'loginAppBar': 'थलो - लगइन',
          'loginTitle': 'थलोमा स्वागत छ',
          'emailLabel': 'इमेल',
          'passwordLabel': 'पासवर्ड',
          'loginButton': 'लगइन',
          'noAccount': 'खाता छैन? यहाँ रजिस्टर गर्नुहोस्',
          'registerAppBar': 'थलो - साइन अप',
          'registerTitle': 'नयाँ खाता खोल्नुहोस्',
          'firstName': 'पहिलो नाम',
          'middleName': 'बीचको नाम (ऐच्छिक)',
          'lastName': 'थर',
          'dob': 'जन्म मिति',
          'nextButton': 'अर्को',
          'gender': 'लिङ्ग छान्नुहोस्',
          'male': 'पुरुष',
          'female': 'महिला',
          'other': 'अन्य',
          'phoneOrEmail': 'इमेल वा फोन नम्बर',
          'terms': 'म सर्त तथा नियमहरू (Terms & Conditions) स्वीकार गर्दछु',
          'registerButton': 'साइन अप',
          'hasAccount': 'पहिले नै खाता छ? यहाँ लगइन गर्नुहोस्',
          'calToggle': 'वि.सं./AD',
        },
        'नेपाल भाषा': {
          'loginAppBar': 'थलो - लगइन',
          'loginTitle': 'थलोस स्वागत जुइच्वन',
          'emailLabel': 'इमेल',
          'passwordLabel': 'पासवर्ड',
          'loginButton': 'लगइन',
          'noAccount': 'खाता मदुगु? थन रजिस्टर यानादिसँ',
          'registerAppBar': 'थलो - साइन अप',
          'registerTitle': 'न्हूगु खाता तयेगु',
          'firstName': 'पुलां नामं',
          'middleName': 'दथुया नामं',
          'lastName': 'थथर',
          'dob': 'बुगु मिति',
          'nextButton': 'लिउ',
          'gender': 'लिङ्ग ल्ययादिसँ',
          'male': 'पुरुष',
          'female': 'महिला',
          'other': 'मेगु',
          'phoneOrEmail': 'इमेल वा फोन नम्बर',
          'terms': 'शर्त स्वीकार यानाच्वना',
          'registerButton': 'साइन अप',
          'hasAccount': 'न्हापां नं खाता दुसा? थन लगइन यानादिसँ',
          'calToggle': 'ने.सं./AD',
        },
        'हिन्दी': {
          'loginAppBar': 'थलो - लॉगिन',
          'loginTitle': 'थलो में आपका स्वागत है',
          'emailLabel': 'ईमेल',
          'passwordLabel': 'पासवर्ड',
          'loginButton': 'लॉग इन',
          'noAccount': 'खाता नहीं है? यहाँ रजिस्टर करें',
          'registerAppBar': 'थलो - साइन अप',
          'registerTitle': 'नया खाता बनाएं',
          'firstName': 'पहला नाम',
          'middleName': 'बीच का नाम (वैकल्पिक)',
          'lastName': 'उपनाम',
          'dob': 'जन्म तिथि',
          'nextButton': 'अगला',
          'gender': 'लिंग चुनें',
          'male': 'पुरुष',
          'female': 'महिला',
          'other': 'अन्य',
          'phoneOrEmail': 'ईमेल या फोन नंबर',
          'terms': 'मैं नियम और शर्तें स्वीकार करता हूँ',
          'registerButton': 'साइन अप',
          'hasAccount': 'पहले से खाता है? यहाँ लॉगिन करें',
          'calToggle': '', // हिन्दीमा क्यालेन्डर सर्टकट देखाइने छैन
        },
        'اردو': {
          'loginAppBar': 'تھلو - لاگ ان',
          'loginTitle': 'تھلو میں خوش آمدید',
          'emailLabel': 'ای میل',
          'passwordLabel': 'پاس ورڈ',
          'loginButton': 'لاگ ان',
          'noAccount': 'اکاؤنٹ نہیں ہے؟ یہاں رجسٹر کریں',
          'registerAppBar': 'تھلو - سائن اپ',
          'registerTitle': 'نیا اکاؤنٹ بنائیں',
          'firstName': 'पहला نام',
          'middleName': 'درمیانی نام',
          'lastName': 'آخری نام',
          'dob': 'تاریخ پیدائش',
          'nextButton': 'اگلا',
          'gender': 'جنس منتخب کریں',
          'male': 'مرد',
          'female': 'عورت',
          'other': 'دیگر',
          'phoneOrEmail': 'ای میل یا فون نمبر',
          'terms': 'میں شرائط و ضوابط قبول کرتا ہوں',
          'registerButton': 'سائن اپ',
          'hasAccount': 'پہلے سے اکاؤنٹ ہے؟ یہاں لاگ ان کریں',
          'calToggle': 'هجری/AD',
        },
      };

  String _getText(String key) {
    return _localizedValues[_currentLang]?[key] ?? _localizedValues['नेपाली']![key]!;
  }

  // भाषा छान्ने तेर्सो (Horizontal) विजेट
  Widget _buildLanguageSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['English', 'नेपाली', 'नेपाल भाषा', 'हिन्दी', 'اردو'].map((lang) {
          final isSelected = _currentLang == lang;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentLang = lang;
                  if (lang == 'नेपाल भाषा') {
                    _selectedCalendar = 'ने.सं.';
                  } else if (lang == 'اردو') {
                    _selectedCalendar = 'هجری';
                  } else {
                    _selectedCalendar = 'वि.सं.';
                  }
                });
              },
              child: Text(
                lang,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.grey[700],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // जन्म मिति छान्ने पपअप डायलॉग (असीमित वर्ष र छनोट गरिएका भाषामा मात्र क्यालेन्डर स्विच सहित)
  void _showDatePickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_getText('dob'), style: const TextStyle(fontSize: 16)),
                  // हिन्दी र अंग्रेजी बाहेक अन्य भाषामा मात्र क्यालेन्डर स्विच बटन देखाउने
                  if (_currentLang != 'हिन्दी' && _currentLang != 'English')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          if (_currentLang == 'नेपाली') {
                            _selectedCalendar = (_selectedCalendar == 'वि.सं.') ? 'AD' : 'वि.सं.';
                          } else if (_currentLang == 'नेपाल भाषा') {
                            _selectedCalendar = (_selectedCalendar == 'ने.सं.') ? 'AD' : 'ने.सं.';
                          } else if (_currentLang == 'اردو') {
                            _selectedCalendar = (_selectedCalendar == 'هجری') ? 'AD' : 'هجری';
                          }
                        });
                      },
                      child: Text(_selectedCalendar, style: const TextStyle(color: Colors.blue, fontSize: 11)),
                    ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // वर्ष (Year) - पूर्ण रूपमा असीमित दायरा
                        Expanded(
                          flex: 2,
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedYear,
                            items: List.generate(2001, (index) => 1000 + index)
                                .map((year) => DropdownMenuItem(value: year, child: Text('$year', style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => _selectedYear = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // महिना (Month)
                        Expanded(
                          flex: 2,
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedMonth,
                            items: List.generate(12, (index) => index + 1).map((month) {
                              String monthName = '$month';
                              if (_currentLang == 'हिन्दी' || _currentLang == 'English' || _currentLang == 'اردو') {
                                const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                                monthName = months[month - 1];
                              } else if (_currentLang == 'नेपाली' || _currentLang == 'नेपाल भाषा') {
                                const nepMonths = ['बैशाख', 'जेठ', 'आषाढ', 'श्रावण', 'भाद्र', 'आश्विन', 'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फागुन', 'चैत'];
                                monthName = nepMonths[month - 1];
                              }
                              return DropdownMenuItem(value: month, child: Text(monthName, style: const TextStyle(fontSize: 12)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => _selectedMonth = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // गते/दिन (Day)
                        Expanded(
                          flex: 1,
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedDay,
                            items: List.generate(32, (index) => index + 1)
                                .map((day) => DropdownMenuItem(value: day, child: Text('$day', style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => _selectedDay = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('रद्द गर्नुहोस्'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('ठीक छ (OK)', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 0) {
      // ----------------- LOGIN SCREEN -----------------
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(_getText('loginAppBar'), style: const TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getText('loginTitle'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 30),
                TextField(
                  decoration: InputDecoration(
                    labelText: _getText('emailLabel'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _getText('passwordLabel'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[50],
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 2; // Home
                      });
                    },
                    child: Text(_getText('loginButton'), style: const TextStyle(color: Colors.purple, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1; // Register Step 1
                    });
                  },
                  child: Text(_getText('noAccount'), style: const TextStyle(color: Colors.purple, fontSize: 14)),
                ),
                const SizedBox(height: 30),
                _buildLanguageSelector(),
              ],
            ),
          ),
        ),
      );
    } else if (_currentIndex == 1) {
      // ----------------- REGISTER STEP 1 (Name & DOB) -----------------
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _currentIndex = 0; // Back to Login
              });
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  _getText('registerTitle'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 25),
                TextField(
                  decoration: InputDecoration(
                    labelText: _getText('firstName'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: _getText('middleName'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: _getText('lastName'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showDatePickerDialog,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: (_currentLang == 'हिन्दी' || _currentLang == 'English')
                            ? '${_getText('dob')} : $_selectedYear-$_selectedMonth-$_selectedDay'
                            : '${_getText('dob')} ($_selectedCalendar) : $_selectedYear-$_selectedMonth-$_selectedDay',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 11; // Go to Register Step 2
                      });
                    },
                    child: Text(_getText('nextButton'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                  child: Text(_getText('hasAccount'), style: const TextStyle(color: Colors.purple, fontSize: 14)),
                ),
                const SizedBox(height: 20),
                _buildLanguageSelector(),
              ],
            ),
          ),
        ),
      );
    } else if (_currentIndex == 11) {
      // ----------------- REGISTER STEP 2 (Gender - 3 Options, Contact, Terms) -----------------
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _currentIndex = 1; // Back to Step 1
              });
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    _getText('registerTitle'),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 25),
                Text(_getText('gender'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(_getText('male'), style: const TextStyle(fontSize: 12)),
                        value: 'Male',
                        groupValue: _selectedGender,
                        onChanged: (val) => setState(() => _selectedGender = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(_getText('female'), style: const TextStyle(fontSize: 12)),
                        value: 'Female',
                        groupValue: _selectedGender,
                        onChanged: (val) => setState(() => _selectedGender = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(_getText('other'), style: const TextStyle(fontSize: 12)),
                        value: 'Other',
                        groupValue: _selectedGender,
                        onChanged: (val) => setState(() => _selectedGender = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: _getText('phoneOrEmail'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _getText('passwordLabel'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                      ),
                      Expanded(
                        child: Text(
                          _getText('terms'),
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _acceptTerms
                        ? () {
                            setState(() {
                              _currentIndex = 2; // Home
                            });
                          }
                        : null,
                    child: Text(_getText('registerButton'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: _buildLanguageSelector()),
              ],
            ),
          ),
        ),
      );
    } else {
      // ----------------- HOME SCREEN -----------------
      return HomeScreen(
        currentLang: _currentLang,
        onLanguageChanged: (lang) {
          setState(() {
            _currentLang = lang;
          });
        },
        onNotificationTap: (val) {},
        selectedDate: _selectedDate,
        onCalendarTap: () {},
        onLogout: () {
          setState(() {
            _currentIndex = 0; // Logout to Login
          });
        },
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
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
  // 0: Login, 1: Register, 2: Home
  int _currentIndex = 0;
  String _currentLang = 'नेपाली';
  final String _selectedDate = 'आज';

  // ५ वटै भाषाका लागि लोकलाइजेसन म्याप
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
          'registerButton': 'Sign Up',
          'hasAccount': 'Already have an account? Login here',
          'homeTitle': 'Home Page',
          'placeholder': "What's on your mind...",
          'postBtn': 'Post',
        },
        'नेपाली': {
          'loginAppBar': 'थलो - लगइन',
          'loginTitle': 'थलोमा स्वागत छ',
          'emailLabel': 'इमेल (Email)',
          'passwordLabel': 'पासवर्ड (Password)',
          'loginButton': 'लगइन',
          'noAccount': 'खाता छैन? यहाँ रजिस्टर गर्नुहोस्',
          'registerAppBar': 'थलो - साइन अप',
          'registerTitle': 'नयाँ खाता खोल्नुहोस्',
          'registerButton': 'साइन अप',
          'hasAccount': 'पहिले नै खाता छ? यहाँ लगइन गर्नुहोस्',
          'homeTitle': 'गृह पृष्ठ (Home)',
          'placeholder': 'तपाईको मनमा के छ लेख्नुहोस्...',
          'postBtn': 'पोस्ट',
        },
        'नेपाल भाषा': {
          'loginAppBar': 'थलो - लगइन',
          'loginTitle': 'थलोस स्वागत जुइच्वन',
          'emailLabel': 'इमेल (Email)',
          'passwordLabel': 'पासवर्ड (Password)',
          'loginButton': 'लगइन',
          'noAccount': 'खाता मदुगु? थन रजिस्टर यानादिसँ',
          'registerAppBar': 'थलो - साइन अप',
          'registerTitle': 'न्हूगु खाता तयेगु',
          'registerButton': 'साइन अप',
          'hasAccount': 'न्हापां नं खाता दुसा? थन लगइन यानादिसँ',
          'homeTitle': 'छेँ पौ (Home)',
          'placeholder': 'जिगः मतिइ छु दु च्वयादिसँ...',
          'postBtn': 'पोस्ट',
        },
        'हिन्दी': {
          'loginAppBar': 'थलो - लॉगिन',
          'loginTitle': 'थलो में आपका स्वागत है',
          'emailLabel': 'ईमेल (Email)',
          'passwordLabel': 'पासवर्ड (Password)',
          'loginButton': 'लॉग इन',
          'noAccount': 'खाता नहीं है? यहाँ रजिस्टर करें',
          'registerAppBar': 'थलो - साइन अप',
          'registerTitle': 'नया खाता बनाएं',
          'registerButton': 'साइन अप',
          'hasAccount': 'पहले से खाता है? यहाँ लॉगिन करें',
          'homeTitle': 'होम पेज (Home)',
          'placeholder': 'आपके मन में क्या है लिखें...',
          'postBtn': 'पोस्ट',
        },
        'اردو': {
          'loginAppBar': 'تھلو - لاگ ان',
          'loginTitle': 'تھلو میں خوش آمدید',
          'emailLabel': 'ای میل (Email)',
          'passwordLabel': 'پاس ورڈ (Password)',
          'loginButton': 'لاگ ان',
          'noAccount': 'اکاؤنٹ نہیں ہے؟ یہاں رجسٹر کریں',
          'registerAppBar': 'تھلو - سائن اپ',
          'registerTitle': 'نیا اکاؤنٹ بنائیں',
          'registerButton': 'سائن اپ',
          'hasAccount': 'پہلے سے اکاؤنٹ ہے؟ یہاں لاگ ان کریں',
          'homeTitle': 'ہوم پیج (Home)',
          'placeholder': 'آپ کے ذہن میں کیا ہے...',
          'postBtn': 'پوسٹ',
        },
      };

  String _getText(String key) {
    return _localizedValues[_currentLang]?[key] ?? _localizedValues['नेपाली']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 0) {
      // Login Screen (नीलो एप बार र नीलो शीर्षक)
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
                        _currentIndex = 2; // होम पेजमा जाने
                      });
                    },
                    child: Text(_getText('loginButton'), style: const TextStyle(color: Colors.purple, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1; // रजिस्टर पेजमा जाने
                    });
                  },
                  child: Text(_getText('noAccount'), style: const TextStyle(color: Colors.purple, fontSize: 14)),
                ),
                const SizedBox(height: 30),
                // तल तेर्सो (Horizontal) रूपमा सानो अक्षरमा भाषा छान्ने सेक्सन
                SingleChildScrollView(
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
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_currentIndex == 1) {
      // Register/Sign Up Screen (नीलो एप बार, हरियो शीर्षक र हरियो बटन)
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getText('registerTitle'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
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
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 2; // होम पेजमा जाने
                      });
                    },
                    child: Text(_getText('registerButton'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0; // लगइन पेजमा फर्कने
                    });
                  },
                  child: Text(_getText('hasAccount'), style: const TextStyle(color: Colors.purple, fontSize: 14)),
                ),
                const SizedBox(height: 30),
                // तल तेर्सो (Horizontal) रूपमा सानो अक्षरमा भाषा छान्ने सेक्सन
                SingleChildScrollView(
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
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Home Screen (लगइन पछि मात्र खुल्ने र नोटिफिकेसन आइकन देखाउने)
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
            _currentIndex = 0; // लगआउट गरेर फेरि Login मा पठाउने
          });
        },
      );
    }
  }
}

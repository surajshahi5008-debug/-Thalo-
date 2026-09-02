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
  int _currentIndex = 0; // 0: Login, 1: Reg Step 1, 11: Reg Step 2, 12: OTP/Link Verification, 2: Home
  String _currentLang = 'नेपाली';
  final String _selectedDate = 'आज';

  String? _selectedGender;
  bool _acceptTerms = false;

  String _selectedCalendar = 'वि.सं.'; 
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  String _ageResultText = '';
  String _birthdayWishText = '';
  bool _showBirthdayWish = false;

  // Controllers and Error States
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  // Registration Controllers
  final TextEditingController _regFirstNameController = TextEditingController();
  final TextEditingController _regMiddleNameController = TextEditingController();
  final TextEditingController _regLastNameController = TextEditingController();
  final TextEditingController _regPhoneEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _phoneOtpController = TextEditingController();
  
  String _loginErrorMessage = '';
  
  // Password Visibility Toggles
  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;

  // Auto-saved credentials mockup variables
  String _savedEmailOrPhone = '';
  String _savedPassword = '';

  @override
  void initState() {
    super.initState();
    _setCurrentDate();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regFirstNameController.dispose();
    _regMiddleNameController.dispose();
    _regLastNameController.dispose();
    _regPhoneEmailController.dispose();
    _regPasswordController.dispose();
    _phoneOtpController.dispose();
    super.dispose();
  }

  void _setCurrentDate() {
    DateTime now = DateTime.now();
    if (_currentLang == 'English' || _selectedCalendar == 'AD') {
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedCalendar = 'AD';
    } else if (_currentLang == 'नेपाली') {
      _selectedYear = now.year + 57; 
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedCalendar = 'वि.सं.';
    } else if (_currentLang == 'नेपाल भाषा') {
      _selectedYear = now.year + 1120; 
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedCalendar = 'ने.सं.';
    } else if (_currentLang == 'اردو') {
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedCalendar = 'هجری';
    } else {
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
    }
  }

  Map<String, Map<String, String>> get _localizedValues => {
        'English': {
          'loginAppBar': 'Thalo - Login',
          'loginTitle': 'Welcome Back to Thalo',
          'emailLabel': 'Email or Phone Number',
          'passwordLabel': 'Password',
          'loginButton': 'Login',
          'noAccount': "Don't have an account? Sign Up here",
          'forgotPassword': 'Forgot Password / Username?',
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
          'registerButton': 'Sign Up & Send Verification',
          'hasAccount': 'Already have an account? Login here',
          'okButton': 'OK',
          'cancelButton': 'Cancel',
          'verificationTitle': 'Account Verification',
          'verificationSubtitle': 'Email link sent to your email & SMS OTP sent to your phone.',
          'verifyButton': 'Verify & Complete',
          'smsOtpLabel': 'Enter Phone SMS OTP (6-digit)',
          'emailLinkNotice': 'Please also check your inbox and click the Email Verification Link.',
          'errEmailNotRegistered': 'This email is not registered in Thalo.',
          'errPhoneNotRegistered': 'This phone number is not registered in Thalo.',
          'errIncorrectPassword': 'Password is incorrect.',
        },
        'नेपाली': {
          'loginAppBar': 'थलो - लगइन',
          'loginTitle': 'थलोमा स्वागत छ',
          'emailLabel': 'इमेल वा फोन नम्बर',
          'passwordLabel': 'पासवर्ड',
          'loginButton': 'लगइन',
          'noAccount': 'खाता छैन? यहाँ रजिस्टर गर्नुहोस्',
          'forgotPassword': 'पासवर्ड वा युजरनेम बिर्सनुभयो?',
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
          'terms': 'म सर्त तथा नियमहरू स्वीकार गर्दछु',
          'registerButton': 'साइन अप र भेरिफिकेसन पठाउनुहोस्',
          'hasAccount': 'पहिले नै खाता छ? यहाँ लगइन गर्नुहोस्',
          'okButton': 'ठीक छ',
          'cancelButton': 'रद्द गर्नुहोस्',
          'verificationTitle': 'खाता प्रमाणीकरण',
          'verificationSubtitle': 'तपाईको इमेलमा लिङ्क पठाइएको छ र फोनमा SMS OTP पठाइएको छ।',
          'verifyButton': 'प्रमाणित गरी पूरा गर्नुहोस्',
          'smsOtpLabel': 'फोनको SMS OTP कोड हाल्नुहोस् (६-अङ्क)',
          'emailLinkNotice': 'कृपया इमेल बक्स खोलेर इमेल भेरिफिकेसन लिङ्कमा पनि क्लिक गर्नुहोस्।',
          'errEmailNotRegistered': 'यो इमेल थलोमा दर्ता भएको छैन।',
          'errPhoneNotRegistered': 'यो फोन नम्बर थलोमा दर्ता भएको छैन।',
          'errIncorrectPassword': 'पासवर्ड मिलेन।',
        },
        'नेपाल भाषा': {
          'loginAppBar': 'थलो - लगइन',
          'loginTitle': 'थलोस स्वागत जुइच्वन',
          'emailLabel': 'इमेल वा फोन नम्बर',
          'passwordLabel': 'पासवर्ड',
          'loginButton': 'लगइन',
          'noAccount': 'खाता मदुगु? थन रजिस्टर यानादिसँ',
          'forgotPassword': 'पासवर्ड वा युजरनेम मंकाःगु ला?',
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
          'registerButton': 'साइन अप व प्रमाणीकरण छ्वयादिसँ',
          'hasAccount': 'न्हापां नं खाता दुसा? थन लगइन यानादिसँ',
          'okButton': 'थुगु',
          'cancelButton': 'मखु',
          'verificationTitle': 'खाता प्रमाणीकरण',
          'verificationSubtitle': 'इमेलय् लिङ्क व फोनय् SMS OTP छ्वया तःगु दु।',
          'verifyButton': 'रुजु याना क्वचायेकेगु',
          'smsOtpLabel': 'फोनया SMS OTP कोड तयादिसँ',
          'emailLinkNotice': 'इमेल स्वयाः भेरिफिकेसन लिङ्कय् नं क्लिक यानादिसँ।',
          'errEmailNotRegistered': 'थ्व इमेल थलोस दर्ता मजू।',
          'errPhoneNotRegistered': 'थ्व फोन नम्बर थलोस दर्ता मजू।',
          'errIncorrectPassword': 'पासवर्ड मिले मजू।',
        },
        'हिन्दी': {
          'loginAppBar': 'थलो - लॉगिन',
          'loginTitle': 'थलो में आपका स्वागत है',
          'emailLabel': 'ईमेल या फोन नंबर',
          'passwordLabel': 'पासवर्ड',
          'loginButton': 'लॉग इन',
          'noAccount': 'खाता नहीं है? यहाँ रजिस्टर करें',
          'forgotPassword': 'पासवर्ड या यूजरनेम भूल गए?',
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
          'registerButton': 'साइन अप और सत्यापन भेजें',
          'hasAccount': 'पहले से खाता है? यहाँ लॉगिन करें',
          'okButton': 'ठीक है',
          'cancelButton': 'रद्द करें',
          'verificationTitle': 'खाता सत्यापन',
          'verificationSubtitle': 'आपके ईमेल पर लिंक और फोन पर SMS OTP भेजा गया है।',
          'verifyButton': 'सत्यापित करें और पूर्ण करें',
          'smsOtpLabel': 'फोन का SMS OTP कोड दर्ज करें (6-अंक)',
          'emailLinkNotice': 'कृपया अपना ईमेल खोलकर सत्यापन लिंक पर भी क्लिक करें।',
          'errEmailNotRegistered': 'यह ईमेल थलो में पंजीकृत नहीं है।',
          'errPhoneNotRegistered': 'यह फोन नंबर थलो में पंजीकृत नहीं है।',
          'errIncorrectPassword': 'पासवर्ड गलत है।',
        },
        'اردو': {
          'loginAppBar': 'تھلو - لاگ ان',
          'loginTitle': 'تھلو میں خوش آمدید',
          'emailLabel': 'ای میل یا فون نمبر',
          'passwordLabel': 'پاس ورڈ',
          'loginButton': 'لاگ ان',
          'noAccount': 'اکاؤنٹ نہیں ہے؟ یہاں رجسٹر کریں',
          'forgotPassword': 'پاس ورڈ یا یوزر نیم بھول گئے؟',
          'registerAppBar': 'تھلو - سائن اپ',
          'registerTitle': 'نیا اکاؤنٹ بنائیں',
          'firstName': 'پہلا نام',
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
          'registerButton': 'سائن اپ اور تصدیق بھیجیں',
          'hasAccount': 'پہلے سے اکاؤنٹ ہے؟ یہاں لاگ ان کریں',
          'okButton': 'ٹھیک ہے',
          'cancelButton': 'منسوخ کریں',
          'verificationTitle': 'اکاؤنٹ کی تصدیق',
          'verificationSubtitle': 'آپ کی ای میل پر لنک اور فون پر SMS OTP بھیج دیا گیا ہے۔',
          'verifyButton': 'تصدیق کریں اور مکمل کریں',
          'smsOtpLabel': 'فون کا SMS OTP کوڈ درج کریں',
          'emailLinkNotice': 'براہ کرم ای میل کھول کر تصدیقی لنک پر بھی کلک کریں۔',
          'errEmailNotRegistered': 'یہ ای میل تھلو میں رجسٹرڈ نہیں ہے۔',
          'errPhoneNotRegistered': 'یہ فون نمبر تھلو میں رجسٹرڈ نہیں ہے۔',
          'errIncorrectPassword': 'پاس ورڈ درست نہیں ہے۔',
        },
      };

  String _getText(String key) {
    return _localizedValues[_currentLang]?[key] ?? _localizedValues['नेपाली']![key]!;
  }

  String _formatNumber(int number) {
    if (_selectedCalendar == 'AD' || _currentLang == 'English') {
      return number.toString();
    }
    String numStr = number.toString();
    if (_currentLang == 'नेपाली' || _currentLang == 'नेपाल भाषा') {
      const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const nepaliDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
      for (int i = 0; i < 10; i++) {
        numStr = numStr.replaceAll(englishDigits[i], nepaliDigits[i]);
      }
    } else if (_currentLang == 'हिन्दी') {
      const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const hindiDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
      for (int i = 0; i < 10; i++) {
        numStr = numStr.replaceAll(englishDigits[i], hindiDigits[i]);
      }
    } else if (_currentLang == 'اردو') {
      const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const urduDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
      for (int i = 0; i < 10; i++) {
        numStr = numStr.replaceAll(englishDigits[i], urduDigits[i]);
      }
    }
    return numStr;
  }

  void _calculateAgeAndBirthday() {
    DateTime now = DateTime.now();
    int currentY = (_selectedCalendar == 'AD') ? now.year : now.year + (_selectedCalendar == 'वि.सं.' ? 57 : (_selectedCalendar == 'ने.सं.' ? 1120 : 0));
    int currentM = now.month;
    int currentD = now.day;

    int years = currentY - _selectedYear;
    int months = currentM - _selectedMonth;
    int days = currentD - _selectedDay;

    if (days < 0) {
      months--;
      days += 30;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years < 0) years = 0;
    if (months < 0) months = 0;
    if (days < 0) days = 0;

    String yStr = _formatNumber(years);
    String mStr = _formatNumber(months);
    String dStr = _formatNumber(days);
    
    int nextBirthdayAge = years + 1;
    String nextAgeOrdinalStr = _formatNumber(nextBirthdayAge);

    if (_currentLang == 'नेपाली') {
      _ageResultText = 'तपाईंको उमेर: $yStr वर्ष, $mStr महिना, र $dStr दिन भयो।';
    } else if (_currentLang == 'नेपाल भाषा') {
      _ageResultText = 'छगु उमेर: $yStr दँ, $mStr महिना, व $dStr न्हिं जूगु दु।';
    } else if (_currentLang == 'हिन्दी') {
      _ageResultText = 'आपकी आयु: $yStr वर्ष, $mStr महीने, और $dStr दिन हो गई है।';
    } else if (_currentLang == 'اردو') {
      _ageResultText = 'آپ کی عمر: $yStr سال، $mStr مہینے، اور $dStr دن ہے۔';
    } else {
      _ageResultText = 'Age: $yStr years, $mStr months, and $dStr days old.';
    }

    if (_selectedMonth == currentM && _selectedDay == currentD) {
      setState(() {
        if (_currentLang == 'नेपाली') {
          _birthdayWishText = 'आज तपाईंको $nextAgeOrdinalStr औं जन्मदिन हो! 🎂';
        } else if (_currentLang == 'नेपाल भाषा') {
          _birthdayWishText = 'थौं छगु $nextAgeOrdinalStr गूगु बुगुन्हि खः! 🎂';
        } else if (_currentLang == 'हिन्दी') {
          _birthdayWishText = 'आज आपका $nextAgeOrdinalStr वाँ जन्मदिन है! 🎂';
        } else if (_currentLang == 'اردو') {
          _birthdayWishText = 'آج آپ کی $nextAgeOrdinalStr ویں سالگرہ ہے! 🎂';
        } else {
          _birthdayWishText = 'Today is your $nextAgeOrdinalStr birthday! 🎂';
        }
        _showBirthdayWish = true;
      });
    } else {
      int remainingDays = ((_selectedMonth - currentM) * 30) + (_selectedDay - currentD);
      if (remainingDays < 0) remainingDays += 365;
      String remStr = _formatNumber(remainingDays);

      setState(() {
        _showBirthdayWish = false;
        if (_currentLang == 'नेपाली') {
          _birthdayWishText = 'तपाईंको $nextAgeOrdinalStr औं जन्मदिन आउन $remStr दिन बाँकी छ।';
        } else if (_currentLang == 'नेपाल भाषा') {
          _birthdayWishText = 'छगु $nextAgeOrdinalStr गूगु बुगुन्हि वयेत $remStr न्हिं ल्यं दु।';
        } else if (_currentLang == 'हिन्दी') {
          _birthdayWishText = 'आपका $nextAgeOrdinalStr वाँ जन्मदिन आने में $remStr दिन बाकी हैं।';
        } else if (_currentLang == 'اردو') {
          _birthdayWishText = 'آپ کی $nextAgeOrdinalStr ویں سالگرہ میں $remStr دن باقی ہیں۔';
        } else {
          _birthdayWishText = '$remStr days remaining for your $nextAgeOrdinalStr birthday.';
        }
      });
    }
  }

  // Handle Login Validation Logic & Auto-Save Credentials
  void _handleLogin() {
    String input = _loginEmailController.text.trim();
    String password = _loginPasswordController.text;

    setState(() {
      if (input.isEmpty) {
        _loginErrorMessage = _getText('errEmailNotRegistered');
        return;
      }

      bool isEmail = input.contains('@');
      
      if (isEmail && input != 'test@thalo.com') {
        _loginErrorMessage = _getText('errEmailNotRegistered');
      } else if (!isEmail && input != '9800000000') {
        _loginErrorMessage = _getText('errPhoneNotRegistered');
      } else if (password != '123456') {
        _loginErrorMessage = _getText('errIncorrectPassword');
      } else {
        _loginErrorMessage = '';
        // Auto-save credentials for user convenience
        _savedEmailOrPhone = input;
        _savedPassword = password;
        _currentIndex = 2; // Success -> Go to Home
      }
    });
  }

  void _handleSuccessfulRegistration() {
    // Auto-save registration credentials
    _savedEmailOrPhone = _regPhoneEmailController.text.trim();
    _savedPassword = _regPasswordController.text;
    
    // Automatically populate login field for smooth transition
    _loginEmailController.text = _savedEmailOrPhone;
    _loginPasswordController.text = _savedPassword;

    setState(() {
      _currentIndex = 2; // Go to Home
    });
  }

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
                  } else if (lang == 'English') {
                    _selectedCalendar = 'AD';
                  } else {
                    _selectedCalendar = 'वि.सं.';
                  }
                  _setCurrentDate();
                  if (_ageResultText.isNotEmpty) {
                    _calculateAgeAndBirthday();
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
                  if (_currentLang != 'हिन्दी' && _currentLang != 'English')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          DateTime now = DateTime.now();
                          if (_currentLang == 'नेपाली') {
                            if (_selectedCalendar == 'वि.सं.') {
                              _selectedCalendar = 'AD';
                              _selectedYear = now.year;
                            } else {
                              _selectedCalendar = 'वि.सं.';
                              _selectedYear = now.year + 57;
                            }
                          } else if (_currentLang == 'नेपाल भाषा') {
                            if (_selectedCalendar == 'ने.सं.') {
                              _selectedCalendar = 'AD';
                              _selectedYear = now.year;
                            } else {
                              _selectedCalendar = 'ने.सं.';
                              _selectedYear = now.year + 1120;
                            }
                          } else if (_currentLang == 'اردو') {
                            if (_selectedCalendar == 'هجری') {
                              _selectedCalendar = 'AD';
                              _selectedYear = now.year;
                            } else {
                              _selectedCalendar = 'هجری';
                              _selectedYear = now.year;
                            }
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCalendar,
                            style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const Text(' | ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(
                            _selectedCalendar == 'AD' ? 'लोकल' : 'AD',
                            style: const TextStyle(color: Colors.blueGrey, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedYear,
                        menuMaxHeight: 200,
                        items: List.generate(2001, (index) => 1000 + index)
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(_formatNumber(year), style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => _selectedYear = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedMonth,
                        menuMaxHeight: 200,
                        items: List.generate(12, (index) => index + 1).map((month) {
                          String monthName = _formatNumber(month);
                          if (_selectedCalendar == 'AD' || _currentLang == 'English' || _currentLang == 'हिन्दी' || _currentLang == 'اردو') {
                            const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                            monthName = months[month - 1];
                          } else if (_selectedCalendar == 'ने.सं.' && _currentLang == 'नेपाल भाषा') {
                            const nepalBhasaMonths = ['चिल्ला', 'दिल्ला', 'गुंला', 'ञला', 'चौला', 'बछला', 'तंला', 'देवा', 'कछला', 'इला', 'थिल्ला', 'प्वंला'];
                            monthName = nepalBhasaMonths[month - 1];
                          } else if (_selectedCalendar == 'वि.सं.' && _currentLang == 'नेपाली') {
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
                    Expanded(
                      flex: 1,
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedDay,
                        menuMaxHeight: 200,
                        items: List.generate(32, (index) => index + 1)
                            .map((day) => DropdownMenuItem(
                                  value: day,
                                  child: Text(_formatNumber(day), style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => _selectedDay = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_getText('cancelButton')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    setState(() {
                      _calculateAgeAndBirthday();
                    });
                    Navigator.pop(context);
                  },
                  child: Text(_getText('okButton'), style: const TextStyle(color: Colors.white)),
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
    // 0: Login Screen
    if (_currentIndex == 0) {
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
                  controller: _loginEmailController,
                  decoration: InputDecoration(
                    labelText: _getText('emailLabel'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _loginPasswordController,
                  obscureText: _obscureLoginPassword,
                  decoration: InputDecoration(
                    labelText: _getText('passwordLabel'),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureLoginPassword = !_obscureLoginPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot password option prompt or navigation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_getText('forgotPassword'))),
                      );
                    },
                    child: Text(
                      _getText('forgotPassword'),
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ),
                ),
                if (_loginErrorMessage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _loginErrorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[50],
                      elevation: 0,
                    ),
                    onPressed: _handleLogin,
                    child: Text(_getText('loginButton'), style: const TextStyle(color: Colors.purple, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _loginErrorMessage = '';
                      _currentIndex = 1;
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
    } 
    // 1: Register Step 1 (Name & DOB)
    else if (_currentIndex == 1) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _currentIndex = 0;
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
                TextField(
                  controller: _regFirstNameController,
                  decoration: InputDecoration(labelText: _getText('firstName'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _regMiddleNameController,
                  decoration: InputDecoration(labelText: _getText('middleName'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _regLastNameController,
                  decoration: InputDecoration(labelText: _getText('lastName'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showDatePickerDialog,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: (_selectedCalendar == 'AD' || _currentLang == 'English')
                            ? '${_getText('dob')} (AD) : ${_formatNumber(_selectedYear)}-${_formatNumber(_selectedMonth)}-${_formatNumber(_selectedDay)}'
                            : '${_getText('dob')} ($_selectedCalendar) : ${_formatNumber(_selectedYear)}-${_formatNumber(_selectedMonth)}-${_formatNumber(_selectedDay)}',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                if (_ageResultText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_ageResultText, style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                ],
                if (_birthdayWishText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(_birthdayWishText, style: TextStyle(fontSize: 13, color: _showBirthdayWish ? Colors.pink[700] : Colors.green[700], fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 11;
                      });
                    },
                    child: Text(_getText('nextButton'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _currentIndex = 0),
                    child: Text(_getText('hasAccount'), style: const TextStyle(color: Colors.purple, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: _buildLanguageSelector()),
              ],
            ),
          ),
        ),
      );
    } 
    // 11: Register Step 2 (Gender, Email/Phone, Password & Terms)
    else if (_currentIndex == 11) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _currentIndex = 1),
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
                  controller: _regPhoneEmailController,
                  decoration: InputDecoration(
                    labelText: _getText('phoneOrEmail'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _regPasswordController,
                  obscureText: _obscureRegPassword,
                  decoration: InputDecoration(
                    labelText: _getText('passwordLabel'),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureRegPassword = !_obscureRegPassword;
                        });
                      },
                    ),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _acceptTerms
                        ? () {
                            // Proceed to separated verification screen
                            setState(() {
                              _currentIndex = 12;
                            });
                          }
                        : null,
                    child: Text(_getText('registerButton'), style: const TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: _buildLanguageSelector()),
              ],
            ),
          ),
        ),
      );
    } 
    // 12: Verification Screen (Email Link + SMS OTP)
    else if (_currentIndex == 12) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(_getText('verificationTitle'), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _currentIndex = 11),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, size: 60, color: Colors.green),
                const SizedBox(height: 20),
                Text(
                  _getText('verificationTitle'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 10),
                Text(
                  _getText('verificationSubtitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    border: Border.all(color: Colors.amber.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_read, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _getText('emailLinkNotice'),
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _phoneOtpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: _getText('smsOtpLabel'),
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                  style: const TextStyle(fontSize: 18, letterSpacing: 6),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _handleSuccessfulRegistration,
                    child: Text(_getText('verifyButton'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 30),
                _buildLanguageSelector(),
              ],
            ),
          ),
        ),
      );
    } 
    // Home Screen
    else {
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
            // Keep or clear auto-saved depending on user choice, clearing password for security on explicit logout
            _loginPasswordController.clear();
            _loginErrorMessage = '';
            _currentIndex = 0;
          });
        },
      );
    }
  }
}

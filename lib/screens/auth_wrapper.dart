import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import 'home_screen.dart';

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

  // Timer and Unique Wish Variables
  Timer? _birthdayTimer;
  bool _showThaloUniqueWish = false;

  // Country Code Variable
  String _selectedCountryCode = '+91';
  bool _isLoading = false;
  String _verificationId = '';

  // AuthService instance
  final AuthService _authService = AuthService();

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

  @override
  void initState() {
    super.initState();
    _setCurrentDate();
  }

  @override
  void dispose() {
    _birthdayTimer?.cancel();
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
    if (_currentLang == 'English' || _currentLang == 'हिन्दी' || _selectedCalendar == 'AD') {
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

  String _getText(String key) {
    return AppLocalizations.localizedValues[_currentLang]?[key] ?? AppLocalizations.localizedValues['नेपाली']![key]!;
  }

  String _formatNumber(int number) {
    return AppLocalizations.formatNumber(number, _currentLang, _selectedCalendar);
  }

  // Language-based Ordinal Converter for 1 to 10 and standard format above 10
  String _getOrdinalWord(int age, String lang) {
    if (lang == 'नेपाली') {
      switch (age) {
        case 1: return 'पहिलो';
        case 2: return 'दोस्रो';
        case 3: return 'तेस्रो';
        case 4: return 'चौँथो';
        case 5: return 'पाँचौं';
        case 6: return 'छैटौं';
        case 7: return 'सातौं';
        case 8: return 'आठौं';
        case 9: return 'नवौं';
        case 10: return 'दशौं';
        default: return '${_formatNumber(age)} औँ';
      }
    } else if (lang == 'हिन्दी') {
      switch (age) {
        case 1: return 'पहला';
        case 2: return 'दूसरा';
        case 3: return 'तीसरा';
        case 4: return 'चौथा';
        case 5: return 'पाँचवाँ';
        case 6: return 'छठा';
        case 7: return 'सातवाँ';
        case 8: return 'आठवाँ';
        case 9: return 'नौवाँ';
        case 10: return 'दसवाँ';
        default: return '$age वाँ';
      }
    } else if (lang == 'English') {
      switch (age) {
        case 1: return 'first';
        case 2: return 'second';
        case 3: return 'third';
        case 4: return 'fourth';
        case 5: return 'fifth';
        case 6: return 'sixth';
        case 7: return 'seventh';
        case 8: return 'eighth';
        case 9: return 'ninth';
        case 10: return 'tenth';
        default:
          if (age % 100 >= 11 && age % 100 <= 13) return '${age}th';
          switch (age % 10) {
            case 1: return '${age}st';
            case 2: return '${age}nd';
            case 3: return '${age}rd';
            default: return '${age}th';
          }
      }
    } else if (lang == 'नेपाल भाषा') {
      switch (age) {
        case 1: return 'न्हापांगु';
        case 2: return 'लिपांगु';
        case 3: return 'स्वंगूगु';
        case 4: return 'प्यंगूगु';
        case 5: return 'न्यागूगु';
        case 6: return 'खुगूगु';
        case 7: return 'न्हेगूगु';
        case 8: return 'च्यागूगु';
        case 9: return 'गुंगूगु';
        case 10: return 'न्हेगूगु';
        default: return '${_formatNumber(age)} गूगु';
      }
    } else if (lang == 'اردو') {
      switch (age) {
        case 1: return 'پہلی';
        case 2: return 'دوسری';
        case 3: return 'تیسری';
        case 4: return 'چوتھی';
        case 5: return 'پانچویں';
        case 6: return 'چھٹی';
        case 7: return 'ساتویں';
        case 8: return 'آٹھویں';
        case 9: return 'نویں';
        case 10: return 'دسویں';
        default: return '$age ویں';
      }
    }
    return '${_formatNumber(age)} औँ';
  }

  void _startBirthdayTimer() {
    _birthdayTimer?.cancel();
    setState(() {
      _showThaloUniqueWish = false;
    });

    _birthdayTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showThaloUniqueWish = true;
        });
      }
    });
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
    String ordinalAgeStr = _getOrdinalWord(nextBirthdayAge, _currentLang);

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
          _birthdayWishText = 'आज तपाईंको $ordinalAgeStr जन्मदिन हो! 🎂';
        } else if (_currentLang == 'नेपाल भाषा') {
          _birthdayWishText = 'थौं छगु $ordinalAgeStr बुगुन्हि खः! 🎂';
        } else if (_currentLang == 'हिन्दी') {
          _birthdayWishText = 'आज आपका $ordinalAgeStr जन्मदिन है! 🎂';
        } else if (_currentLang == 'اردو') {
          _birthdayWishText = 'آج آپ کی $ordinalAgeStr سالگرہ ہے! 🎂';
        } else {
          _birthdayWishText = 'Today is your $ordinalAgeStr birthday! 🎂';
        }
        _showBirthdayWish = true;
      });
      _startBirthdayTimer();
    } else {
      int remainingDays = ((_selectedMonth - currentM) * 30) + (_selectedDay - currentD);
      if (remainingDays < 0) remainingDays += 365;
      String remStr = _formatNumber(remainingDays);

      _birthdayTimer?.cancel();
      setState(() {
        _showBirthdayWish = false;
        _showThaloUniqueWish = false;
        if (_currentLang == 'नेपाली') {
          _birthdayWishText = 'तपाईंको $ordinalAgeStr जन्मदिन आउन $remStr दिन बाँकी छ।';
        } else if (_currentLang == 'नेपाल भाषा') {
          _birthdayWishText = 'छगु $ordinalAgeStr बुगुन्हि वयेत $remStr न्हिं ल्यं दु।';
        } else if (_currentLang == 'हिन्दी') {
          _birthdayWishText = 'आपका $ordinalAgeStr जन्मदिन आने में $remStr दिन बाकी हैं।';
        } else if (_currentLang == 'اردو') {
          _birthdayWishText = 'آپ کی $ordinalAgeStr سالگرہ میں $remStr دن باقی ہیں۔';
        } else {
          _birthdayWishText = '$remStr days remaining for your $ordinalAgeStr birthday.';
        }
      });
    }
  }

  String _getThaloUniqueWishText() {
    if (_currentLang == 'नेपाली') {
      return 'थलो परिवारतर्फबाट यहाँलाई जीवनको यो नयाँ वर्ष सफलता, सुस्वास्थ्य र समृद्धिमय रहोस् हार्दिक मंगलमय शुभकामना! ✨';
    } else if (_currentLang == 'हिन्दी') {
      return 'थलो परिवार की ओर से आपके जीवन का यह नया वर्ष सफलता, अच्छे स्वास्थ्य और समृद्धि से भरा रहे, हार्दिक शुभकामनाएं! ✨';
    } else if (_currentLang == 'English') {
      return 'Warmest wishes from the Thalo family! May this new year of your life bring immense success, good health, and prosperity. ✨';
    } else if (_currentLang == 'नेपाल भाषा') {
      return 'थलो परिवारया तर्फबाट छयात सफलाता, यलया व सुख समृद्धिया तःधंगु भिंतुना! ✨';
    } else if (_currentLang == 'اردو') {
      return 'تھلو فیملی کی طرف سے آپ کو سالگرہ کی بہت بہت مبارکباد! آپ کی زندگی کا یہ نیا سال کامیابی اور خوشیوں سے بھرپور ہو۔ ✨';
    }
    return 'थलो परिवारतर्फबाट यहाँलाई हार्दिक मंगलमय शुभकामना! ✨';
  }

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
        _currentIndex = 2; 
      }
    });
  }

  Future<void> _startRegistrationAndVerification() async {
    String input = _regPhoneEmailController.text.trim();
    String password = _regPasswordController.text;

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सबै विवरण भर्नुहोस्।')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (input.contains('@')) {
        await _authService.signUpWithEmail(input, password);
        
        setState(() {
          _isLoading = false;
          _currentIndex = 12; 
        });
        return;
      }

      String cleanPhone = input.replaceAll(RegExp(r'\D'), '');
      
      if (cleanPhone.length != 10) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('कृपया सही १० अंकको मोबाइल नम्बर हाल्नुहोस्।')),
        );
        return;
      }

      String formattedPhone = '$_selectedCountryCode$cleanPhone';

      await _authService.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          await _authService.signInWithCredential(credential);
          _handleSuccessfulRegistration();
        },
        onVerificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          
          String errorMessage = e.code == 'invalid-phone-number' 
              ? 'अमान्य फोन नम्बर। कृपया सहि नम्बर हाल्नुहोस्।' 
              : (e.message ?? 'त्रुटि देखियो');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: const TextStyle(fontSize: 13)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        },
        onCodeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
            _currentIndex = 12; 
          });
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = _getText('errEmailAlreadyInUse');
      } else if (e.code == 'phone-number-already-exists' || e.code == 'credential-already-in-use') {
        message = _getText('errPhoneAlreadyInUse');
      } else {
        message = e.message ?? 'त्रुटि देखियो: ${e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 13, height: 1.3)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('त्रुटि देखियो: $e', style: const TextStyle(fontSize: 13)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _verifyOtpAndComplete(String smsCode) async {
    if (smsCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया ६ अंकको सही OTP हाल्नुहोस्।')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      try {
        await _authService.signInWithPhoneCredential(_verificationId, smsCode);
        _handleSuccessfulRegistration();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' || e.code == 'provider-already-linked') {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText('errPhoneAlreadyInUse'), style: const TextStyle(fontSize: 13)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
          return;
        }
        rethrow;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP मिलेन: $e', style: const TextStyle(fontSize: 13)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleSuccessfulRegistration() {
    String savedEmailOrPhone = _regPhoneEmailController.text.trim();
    String savedPassword = _regPasswordController.text;
    
    _loginEmailController.text = savedEmailOrPhone;
    _loginPasswordController.text = savedPassword;

    setState(() {
      _isLoading = false;
      _currentIndex = 2; 
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
                  } else if (lang == 'English' || lang == 'हिन्दी') {
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
                  if (_currentLang != 'English' && _currentLang != 'हिन्दी')
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
    // 1: Register Step 1
    else if (_currentIndex == 1) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _currentIndex = 0),
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
                        labelText: (_selectedCalendar == 'AD' || _currentLang == 'English' || _currentLang == 'हिन्दी')
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _showThaloUniqueWish ? _getThaloUniqueWishText() : _birthdayWishText,
                      key: ValueKey<bool>(_showThaloUniqueWish),
                      style: TextStyle(
                        fontSize: 13, 
                        color: _showThaloUniqueWish ? Colors.purple[700] : (_showBirthdayWish ? Colors.pink[700] : Colors.green[700]), 
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => setState(() => _currentIndex = 11),
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
    // 11: Register Step 2
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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: _getText('phoneOrEmail'),
                    border: const OutlineInputBorder(),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          items: const [
                            DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: '+977', child: Text('🇳🇵 +977', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCountryCode = val);
                          },
                        ),
                      ),
                    ),
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
                      onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
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
                    onPressed: _acceptTerms ? _startRegistrationAndVerification : null,
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
    // 12: Verification Screen
    else if (_currentIndex == 12) {
      bool isEmail = _regPhoneEmailController.text.contains('@');

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
                
                if (isEmail) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      border: Border.all(color: Colors.amber.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.mark_email_read, color: Colors.orange, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          _getText('emailLinkNotice'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: _handleSuccessfulRegistration,
                      child: const Text('मैले इमेल रुजु गरें (Home जाने)', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                  ),
                ] else ...[
                  Text(
                    _getText('verificationSubtitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
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
                      onPressed: () => _verifyOtpAndComplete(_phoneOtpController.text.trim()),
                      child: Text(_getText('verifyButton'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
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
          setState(() => _currentLang = lang);
        },
        onNotificationTap: (val) {},
        selectedDate: _selectedDate,
        onCalendarTap: () {},
        onLogout: () {
          setState(() {
            _loginPasswordController.clear();
            _loginErrorMessage = '';
            _currentIndex = 0;
          });
        },
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class RegisterScreen extends StatefulWidget {
  final String currentLang;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onLoginTap;
  final Function(String emailOrPhone, String password) onRegistrationSuccess;

  const RegisterScreen({
    super.key,
    required this.currentLang,
    required this.onLanguageChanged,
    required this.onLoginTap,
    required this.onRegistrationSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 1; // 1: Name & DOB, 2: Gender, Phone/Email, Password & Terms, 3: OTP/Verification
  
  String _selectedCalendar = 'वि.सं.'; 
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  String _ageResultText = '';
  String _birthdayWishText = '';
  bool _showBirthdayWish = false;

  String? _selectedGender;
  bool _acceptTerms = false;
  String _selectedCountryCode = '+91';
  bool _isLoading = false;
  String _verificationId = '';

  // Controllers
  final TextEditingController _regFirstNameController = TextEditingController();
  final TextEditingController _regMiddleNameController = TextEditingController();
  final TextEditingController _regLastNameController = TextEditingController();
  final TextEditingController _regPhoneEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _phoneOtpController = TextEditingController();

  bool _obscureRegPassword = true;

  @override
  void initState() {
    super.initState();
    _setCurrentDate();
  }

  @override
  void dispose() {
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
    if (widget.currentLang == 'English' || _selectedCalendar == 'AD') {
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedCalendar = 'AD';
    } else if (widget.currentLang == 'नेपाली') {
      _selectedYear = now.year + 57; 
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedCalendar = 'वि.सं.';
    } else if (widget.currentLang == 'नेपाल भाषा') {
      _selectedYear = now.year + 1120; 
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedCalendar = 'ने.सं.';
    } else if (widget.currentLang == 'اردو') {
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
    return AppStrings.localizedValues[widget.currentLang]?[key] ?? 
           AppStrings.localizedValues['नेपाली']![key]!;
  }

  String _formatNumber(int number) {
    if (_selectedCalendar == 'AD' || widget.currentLang == 'English') {
      return number.toString();
    }
    String numStr = number.toString();
    if (widget.currentLang == 'नेपाली' || widget.currentLang == 'नेपाल भाषा') {
      const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const nepaliDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
      for (int i = 0; i < 10; i++) {
        numStr = numStr.replaceAll(englishDigits[i], nepaliDigits[i]);
      }
    } else if (widget.currentLang == 'हिन्दी') {
      const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const hindiDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
      for (int i = 0; i < 10; i++) {
        numStr = numStr.replaceAll(englishDigits[i], hindiDigits[i]);
      }
    } else if (widget.currentLang == 'اردو') {
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

    if (widget.currentLang == 'नेपाली') {
      _ageResultText = 'तपाईंको उमेर: $yStr वर्ष, $mStr महिना, र $dStr दिन भयो।';
    } else if (widget.currentLang == 'नेपाल भाषा') {
      _ageResultText = 'छगु उमेर: $yStr दँ, $mStr महिना, व $dStr न्हिं जूगु दु।';
    } else if (widget.currentLang == 'हिन्दी') {
      _ageResultText = 'आपकी आयु: $yStr वर्ष, $mStr महीने, और $dStr दिन हो गई है।';
    } else if (widget.currentLang == 'اردو') {
      _ageResultText = 'آپ کی عمر: $yStr سال، $mStr مہینے، اور $dStr دن ہے۔';
    } else {
      _ageResultText = 'Age: $yStr years, $mStr months, and $dStr days old.';
    }

    if (_selectedMonth == currentM && _selectedDay == currentD) {
      setState(() {
        if (widget.currentLang == 'नेपाली') {
          _birthdayWishText = 'आज तपाईंको $nextAgeOrdinalStr औं जन्मदिन हो! 🎂';
        } else if (widget.currentLang == 'नेपाल भाषा') {
          _birthdayWishText = 'थौं छगु $nextAgeOrdinalStr गूगु बुगुन्हि खः! 🎂';
        } else if (widget.currentLang == 'हिन्दी') {
          _birthdayWishText = 'आज आपका $nextAgeOrdinalStr वाँ जन्मदिन है! 🎂';
        } else if (widget.currentLang == 'اردو') {
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
        if (widget.currentLang == 'नेपाली') {
          _birthdayWishText = 'तपाईंको $nextAgeOrdinalStr औं जन्मदिन आउन $remStr दिन बाँकी छ।';
        } else if (widget.currentLang == 'नेपाल भाषा') {
          _birthdayWishText = 'छगु $nextAgeOrdinalStr गूगु बुगुन्हि वयेत $remStr न्हिं ल्यं दु।';
        } else if (widget.currentLang == 'हिन्दी') {
          _birthdayWishText = 'आपका $nextAgeOrdinalStr वाँ जन्मदिन आने में $remStr दिन बाकी हैं।';
        } else if (widget.currentLang == 'اردو') {
          _birthdayWishText = 'آپ کی $nextAgeOrdinalStr ویں سالگرہ میں $remStr دن باقی ہیں۔';
        } else {
          _birthdayWishText = '$remStr days remaining for your $nextAgeOrdinalStr birthday.';
        }
      });
    }
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
                  if (widget.currentLang != 'हिन्दी' && widget.currentLang != 'English')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          DateTime now = DateTime.now();
                          if (widget.currentLang == 'नेपाली') {
                            if (_selectedCalendar == 'वि.सं.') {
                              _selectedCalendar = 'AD';
                              _selectedYear = now.year;
                            } else {
                              _selectedCalendar = 'वि.सं.';
                              _selectedYear = now.year + 57;
                            }
                          } else if (widget.currentLang == 'नेपाल भाषा') {
                            if (_selectedCalendar == 'ने.सं.') {
                              _selectedCalendar = 'AD';
                              _selectedYear = now.year;
                            } else {
                              _selectedCalendar = 'ने.सं.';
                              _selectedYear = now.year + 1120;
                            }
                          } else if (widget.currentLang == 'اردو') {
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
                          if (_selectedCalendar == 'AD' || widget.currentLang == 'English' || widget.currentLang == 'हिन्दी' || widget.currentLang == 'اردو') {
                            const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                            monthName = months[month - 1];
                          } else if (_selectedCalendar == 'ने.सं.' && widget.currentLang == 'नेपाल भाषा') {
                            const nepalBhasaMonths = ['चिल्ला', 'दिल्ला', 'गुंला', 'ञला', 'चौला', 'बछला', 'तंला', 'देवा', 'कछला', 'इला', 'थिल्ला', 'प्वंला'];
                            monthName = nepalBhasaMonths[month - 1];
                          } else if (_selectedCalendar == 'वि.सं.' && widget.currentLang == 'नेपाली') {
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
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: input,
          password: password,
        );
        await userCredential.user?.sendEmailVerification();
        setState(() {
          _isLoading = false;
          _step = 3; 
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

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          widget.onRegistrationSuccess(_regPhoneEmailController.text.trim(), _regPasswordController.text);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          String errorMessage = e.code == 'invalid-phone-number' 
              ? 'अमान्य फोन नम्बर। कृपया सहि नम्बर हाल्नुहोस्।' 
              : (e.message ?? 'त्रुटि देखियो');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: const TextStyle(fontSize: 13)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
            _step = 3; 
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
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
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      try {
        await FirebaseAuth.instance.signInWithCredential(credential);
        widget.onRegistrationSuccess(_regPhoneEmailController.text.trim(), _regPasswordController.text);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' || e.code == 'provider-already-linked') {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText('errPhoneAlreadyInUse'), style: const TextStyle(fontSize: 13)),
              behavior: SnackBarBehavior.floating,
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

  Widget _buildLanguageSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['English', 'नेपाली', 'नेपाल भाषा', 'हिन्दी', 'اردو'].map((lang) {
          final isSelected = widget.currentLang == lang;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () {
                widget.onLanguageChanged(lang);
                setState(() {
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
                  color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Step 1: Name & DOB
    if (_step == 1) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onLoginTap,
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
                        labelText: (_selectedCalendar == 'AD' || widget.currentLang == 'English')
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
                  Text(_ageResultText, style: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
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
                    onPressed: () => setState(() => _step = 2),
                    child: Text(_getText('nextButton'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: widget.onLoginTap,
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
    // Step 2: Gender, Phone/Email, Password & Terms
    else if (_step == 2) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _step = 1),
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
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
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
    // Step 3: Verification Screen (Email Link Notice + SMS OTP Box)
    else {
      bool isEmail = _regPhoneEmailController.text.contains('@');

      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text(_getText('verificationTitle'), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _step = 2),
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                      onPressed: () => widget.onRegistrationSuccess(
                        _regPhoneEmailController.text.trim(), 
                        _regPasswordController.text,
                      ),
                      child: const Text('मैले इमेल रुजु गरें (Home जाने)', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                  ),
                ] else ...[
                  Text(
                    _getText('verificationSubtitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
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
  }
}

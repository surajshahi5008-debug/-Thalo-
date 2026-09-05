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
  int _currentIndex = 0;
  String _currentLang = 'नेपाली';
  final String _selectedDate = 'आज';
  String? _selectedGender;
  bool _acceptTerms = false;
  
  String _selectedCalendar = 'वि.सं.';
  late int _selectedYear, _selectedMonth, _selectedDay;

  String _ageResultText = '';
  String _birthdayWishText = '';
  bool _showBirthdayWish = false, _showThaloUniqueWish = false;
  Timer? _birthdayTimer;
  String _selectedCountryCode = '+91';
  bool _isLoading = false;
  String _verificationId = '', _loginErrorMessage = '';
  bool _obscureLoginPassword = true, _obscureRegPassword = true;

  final AuthService _authService = AuthService();
  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPassCtrl = TextEditingController();
  final TextEditingController _regFirstCtrl = TextEditingController();
  final TextEditingController _regMidCtrl = TextEditingController();
  final TextEditingController _regLastCtrl = TextEditingController();
  final TextEditingController _regPhoneEmailCtrl = TextEditingController();
  final TextEditingController _regPassCtrl = TextEditingController();
  final TextEditingController _phoneOtpCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setCurrentDateForLanguage(_currentLang);
  }

  @override
  void dispose() {
    _birthdayTimer?.cancel();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regFirstCtrl.dispose();
    _regMidCtrl.dispose();
    _regLastCtrl.dispose();
    _regPhoneEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _phoneOtpCtrl.dispose();
    super.dispose();
  }

  void _setCurrentDateForLanguage(String lang) {
    final now = DateTime.now();
    if (lang == 'नेपाली') {
      _selectedCalendar = 'वि.सं.';
      _selectedYear = 2083;
      _selectedMonth = 5;
      _selectedDay = 20;
    } else if (lang == 'नेपाल भाषा') {
      _selectedCalendar = 'ने.सं.';
      _selectedYear = 1146;
      _selectedMonth = 3;
      _selectedDay = 15;
    } else if (lang == 'اردو') {
      _selectedCalendar = 'هجری';
      _selectedYear = 1448;
      _selectedMonth = 3;
      _selectedDay = 23;
    } else {
      _selectedCalendar = 'AD';
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
    }
    _calculateAgeAndBirthday();
  }

  String _getText(String k) {
    if (k == 'dob') {
      if (_currentLang == 'नेपाली') return 'जन्म मिति';
      if (_currentLang == 'नेपाल भाषा') return 'बुगु मिति';
      if (_currentLang == 'हिन्दी') return 'जन्म तिथि';
      if (_currentLang == 'اردو') return 'تاریخ پیدائش';
      return 'Date of Birth';
    }
    return AppLocalizations.localizedValues[_currentLang]?[k] ?? AppLocalizations.localizedValues['नेपाली']![k]!;
  }

  String _fmtNum(int n) {
    if (_selectedCalendar == 'هجری' && (_currentLang == 'اردو')) {
      const arabicDigits = ['٠', '١', '٢', '۳', '۴', '۵', '۶', '۷', '۸', '٩'];
      return n.toString().split('').map((char) {
        int? digit = int.tryParse(char);
        return digit != null ? arabicDigits[digit] : char;
      }).join('');
    }
    return AppLocalizations.formatNumber(n, _currentLang, _selectedCalendar);
  }

  String _getNumberOrWord(int n, String lang) {
    if (n <= 10) {
      if (lang == 'नेपाली') {
        const map = {0: 'शून्य', 1: 'एक', 2: 'दुई', 3: 'तीन', 4: 'चार', 5: 'पाँच', 6: 'छ', 7: 'सात', 8: 'आठ', 9: 'नौ', 10: 'दश'};
        return map[n] ?? _fmtNum(n);
      } else if (lang == 'English') {
        const map = {0: 'zero', 1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five', 6: 'six', 7: 'seven', 8: 'eight', 9: 'nine', 10: 'ten'};
        return map[n] ?? n.toString();
      } else if (lang == 'हिन्दी') {
        const map = {0: 'शून्य', 1: 'एक', 2: 'दो', 3: 'तीन', 4: 'चार', 5: 'पाँच', 6: 'छः', 7: 'सात', 8: 'आठ', 9: 'नौ', 10: 'दस'};
        return map[n] ?? _fmtNum(n);
      }
    }
    return _fmtNum(n);
  }

  String _getMonthName(int m) {
    if (_selectedCalendar == 'वि.सं.') {
      return ['बैशाख', 'जेठ', 'आषाढ', 'श्रावण', 'भाद्र', 'आश्विन', 'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फागुन', 'चैत'][m - 1];
    } else if (_selectedCalendar == 'ने.सं.') {
      return ['चिल्ला', 'दिल्ला', 'गुंला', 'ञला', 'चौला', 'बछला', 'तंला', 'देवा', 'कछला', 'इला', 'थिल्ला', 'प्वंला'][m - 1];
    } else if (_selectedCalendar == 'AD') {
      if (_currentLang == 'हिन्दी') {
        return ['जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'][m - 1];
      } else {
        return ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m - 1];
      }
    } else if (_selectedCalendar == 'هجری') {
      return ['محرم', 'صفر', 'ربیع الاول', 'ربیع الثانی', 'جمادی الاول', 'جمادی الثانی', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذوالقعدہ', 'ذوالحجہ'][m - 1];
    }
    return _fmtNum(m);
  }

  void _calculateAgeAndBirthday() {
    final now = DateTime.now();
    int adYear = _selectedYear;
    int adMonth = _selectedMonth;
    int adDay = _selectedDay;

    if (_selectedCalendar == 'वि.सं.') {
      adYear = _selectedYear - 57;
      adMonth = _selectedMonth > 4 ? _selectedMonth - 4 : _selectedMonth + 8;
      if (_selectedMonth <= 4) adYear--;
      adDay = _selectedDay; 
    } else if (_selectedCalendar == 'ने.सं.') {
      adYear = _selectedYear + 879;
      adMonth = _selectedMonth;
      adDay = _selectedDay;
    } else if (_selectedCalendar == 'هجری') {
      adYear = (_selectedYear * 0.97).toInt() + 622;
      adMonth = _selectedMonth;
      adDay = _selectedDay;
    }

    DateTime birthDate;
    try {
      birthDate = DateTime(_selectedCalendar == 'AD' ? _selectedYear : adYear, adMonth, adDay);
    } catch (_) {
      birthDate = DateTime(now.year, now.month, now.day);
    }

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      DateTime prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years < 0) years = 0;
    if (months < 0) months = 0;
    if (days < 0) days = 0;

    String yStr = _fmtNum(years), mStr = _fmtNum(months), dStr = _fmtNum(days);
    int currentAgeYears = years;
    String formattedAgeNum = _getNumberOrWord(currentAgeYears, _currentLang);

    if (_currentLang == 'नेपाली') {
      _ageResultText = 'तपाईंको उमेर: $yStr वर्ष, $mStr महिना, र $dStr दिन भयो।';
    } else if (_currentLang == 'नेपाल भाषा') {
      _ageResultText = 'छगु उमेर: $yStr दँ, $mStr महिना, व $dStr न्हिं जूगु दु।';
    } else if (_currentLang == 'हिन्दी') {
      _ageResultText = 'आपकी आयु: $yStr वर्ष, $mStr महीने, और $dStr दिन हो गई है।';
    } else if (_currentLang == 'اردو') {
      _ageResultText = 'آپ کی عمر: $yStr سال، $مہینے، اور $dStr دن ہے۔';
    } else {
      _ageResultText = 'Age: $yStr years, $mStr months, and $dStr days old.';
    }

    DateTime nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      if (!(nextBirthday.month == now.month && nextBirthday.day == now.day)) {
        nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
      }
    }

    int remDays = nextBirthday.difference(now).inDays;

    if (birthDate.month == now.month && birthDate.day == now.day) {
      setState(() {
        _showBirthdayWish = true;
        int exactAge = now.year - birthDate.year;
        String exactAgeNum = _getNumberOrWord(exactAge, _currentLang);
        if (_currentLang == 'नेपाली') {
          _birthdayWishText = 'थलो परिवारको तर्फबाट तपाईंलाई $exactAgeNum औँ जन्मदिनको हार्दिक मंगलमय शुभकामना! 🎂';
        } else if (_currentLang == 'नेपाल भाषा') {
          _birthdayWishText = 'थलो परिवारया तर्फबाट छयात $exactAgeNum गःगु बुगुन्हिया तःधंगु भिंतुना! 🎂';
        } else if (_currentLang == 'हिन्दी') {
          _birthdayWishText = 'थलो परिवार की ओर से आपको आपके $exactAgeNum वाँ जन्मदिन की हार्दिक शुभकामनाएं! 🎂';
        } else if (_currentLang == 'اردو') {
          _birthdayWishText = 'تھلو فیملی کی طرف سے آپ کو $exactAgeNum ویں سالگرہ کی مبارکباد! 🎂';
        } else {
          _birthdayWishText = 'Warmest wishes from the Thalo family on your $exactAge${_getEnglishSuffix(exactAge)} birthday! 🎂';
        }
      });
      _birthdayTimer?.cancel();
    } else {
      String dayNumStr = _getNumberOrWord(remDays, _currentLang);
      _birthdayTimer?.cancel();
      setState(() {
        _showBirthdayWish = false;
        _showThaloUniqueWish = false;
        int upcomingAge = currentAgeYears + 1;
        String upcomingAgeStr = _getNumberOrWord(upcomingAge, _currentLang);
        if (_currentLang == 'नेपाली') {
          _birthdayWishText = 'तपाईंको $upcomingAgeStr औँ जन्मदिन आउन $dayNumStr ${remDays == 1 ? 'दिन बाँकी छ' : 'दिन बाँकी छन्'}।';
        } else if (_currentLang == 'नेपाल भाषा') {
          _birthdayWishText = 'छगु $upcomingAgeStr गःगु बुगुन्हि वयेत $dayNumStr न्हिं ल्यं दु।';
        } else if (_currentLang == 'हिन्दी') {
          _birthdayWishText = 'आपका $upcomingAgeStr वाँ जन्मदिन आने में $dayNumStr ${remDays == 1 ? 'दिन बाकी है' : 'दिन बाकी हैं'}।';
        } else if (_currentLang == 'اردو') {
          _birthdayWishText = 'آپ کی $upcomingAgeStr ویں سالگرہ میں $dayNumStr دن باقی ہیں۔';
        } else {
          _birthdayWishText = '$dayNumStr ${remDays == 1 ? 'day' : 'days'} remaining for your $upcomingAge${_getEnglishSuffix(upcomingAge)} birthday.';
        }
      });
    }
  }

  String _getEnglishSuffix(int age) {
    if (age % 100 >= 11 && age % 100 <= 13) return 'th';
    switch (age % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  void _handleLogin() {
    String input = _loginEmailCtrl.text.trim(), pass = _loginPassCtrl.text;
    setState(() {
      if (input.isEmpty || (input.contains('@') && input != 'test@thalo.com') || (!input.contains('@') && input != '9800000000')) {
        _loginErrorMessage = input.contains('@') ? _getText('errEmailNotRegistered') : _getText('errPhoneNotRegistered');
      } else if (pass != '123456') {
        _loginErrorMessage = _getText('errIncorrectPassword');
      } else {
        _loginErrorMessage = '';
        _currentIndex = 2;
      }
    });
  }

  Future<void> _startRegistration() async {
    String input = _regPhoneEmailCtrl.text.trim(), pass = _regPassCtrl.text;
    if (input.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया सबै विवरण भर्नुहोस्।')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (input.contains('@')) {
        await _authService.signUpWithEmail(input, pass);
        setState(() { _isLoading = false; _currentIndex = 12; });
        return;
      }
      String cleanPhone = input.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length != 10) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया सही १० अंकको मोबाइल नम्बर हाल्नुहोस्।')));
        return;
      }
      await _authService.verifyPhoneNumber(
        phoneNumber: '$_selectedCountryCode$cleanPhone',
        onVerificationCompleted: (cred) async {
          await _authService.signInWithCredential(cred);
          _completeReg();
        },
        onVerificationFailed: (e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'त्रुटि देखियो')));
        },
        onCodeSent: (id, token) {
          setState(() { _verificationId = id; _isLoading = false; _currentIndex = 12; });
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('त्रुटि देखियो: $e')));
    }
  }

  Future<void> _verifyOtp(String smsCode) async {
    if (smsCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया ६ अंकको सही OTP हाल्नुहोस्।')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithPhoneCredential(_verificationId, smsCode);
      _completeReg();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP मिलेन: $e')));
    }
  }

  void _completeReg() {
    _loginEmailCtrl.text = _regPhoneEmailCtrl.text.trim();
    _loginPassCtrl.text = _regPassCtrl.text;
    setState(() { _isLoading = false; _currentIndex = 2; });
  }

  Widget _buildLangSelector() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['English', 'नेपाली', 'नेपाल भाषा', 'हिन्दी', 'اردو'].map((lang) {
        bool isSel = _currentLang == lang;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => setState(() {
              _currentLang = lang;
              _setCurrentDateForLanguage(lang);
            }),
            child: Text(lang, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.blue : Colors.grey[700])),
          ),
        );
      }).toList(),
    ),
  );

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) {
          int baseYear = _selectedCalendar == 'AD' ? 2026 : (_selectedCalendar == 'वि.सं.' ? 2083 : (_selectedCalendar == 'ने.सं.' ? 1146 : 1448));
          int startYear = baseYear - 110;
          int endYear = baseYear + 150;
          List<int> years = List.generate(endYear - startYear + 1, (i) => startYear + i);

          String altCalendar = 'वि.सं.';
          if (_currentLang == 'नेपाली') altCalendar = 'वि.सं.';
          else if (_currentLang == 'नेपाल भाषा') altCalendar = 'ने.सं.';
          else if (_currentLang == 'اردو') altCalendar = 'هجری';

          bool hasSwitch = _currentLang == 'नेपाली' || _currentLang == 'नेपाल भाषा' || _currentLang == 'اردو';

          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_getText('dob'), style: const TextStyle(fontSize: 15)),
                hasSwitch
                    ? GestureDetector(
                        onTap: () {
                          setDlgState(() {
                            if (_selectedCalendar == 'AD') {
                              _selectedCalendar = altCalendar;
                              if (altCalendar == 'वि.सं.') { _selectedYear = 2083; _selectedMonth = 5; _selectedDay = 20; }
                              else if (altCalendar == 'ने.सं.') { _selectedYear = 1146; _selectedMonth = 3; _selectedDay = 15; }
                              else if (altCalendar == 'هجری') { _selectedYear = 1448; _selectedMonth = 3; _selectedDay = 23; }
                            } else {
                              _selectedCalendar = 'AD';
                              _selectedYear = 2026; _selectedMonth = 9; _selectedDay = 5;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.shade200)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_selectedCalendar, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                              const SizedBox(width: 4),
                              const Icon(Icons.swap_horiz, size: 14, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(_selectedCalendar == 'AD' ? altCalendar : 'AD', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButton<int>(
                      isExpanded: true, value: _selectedYear, menuMaxHeight: 200,
                      items: years.map((y) => DropdownMenuItem(value: y, child: Text(_fmtNum(y), style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) => v != null ? setDlgState(() => _selectedYear = v) : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: DropdownButton<int>(
                      isExpanded: true, value: _selectedMonth, menuMaxHeight: 200,
                      items: List.generate(12, (i) => i + 1).map((m) {
                        return DropdownMenuItem(value: m, child: Text(_getMonthName(m), style: const TextStyle(fontSize: 11, overflow: TextOverflow.ellipsis)));
                      }).toList(),
                      onChanged: (v) => v != null ? setDlgState(() => _selectedMonth = v) : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 1,
                    child: DropdownButton<int>(
                      isExpanded: true, value: _selectedDay, menuMaxHeight: 200,
                      items: List.generate(31, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text(_fmtNum(d), style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) => v != null ? setDlgState(() => _selectedDay = v) : null,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(_getText('cancelButton'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () { setState(() => _calculateAgeAndBirthday()); Navigator.pop(context); },
                child: Text(_getText('okButton'), style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_currentIndex == 0) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue, title: Text(_getText('loginAppBar'), style: const TextStyle(color: Colors.white)), automaticallyImplyLeading: false),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_getText('loginTitle'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 30),
                TextField(controller: _loginEmailCtrl, decoration: InputDecoration(labelText: _getText('emailLabel'), border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(
                  controller: _loginPassCtrl, obscureText: _obscureLoginPassword,
                  decoration: InputDecoration(
                    labelText: _getText('passwordLabel'), border: const OutlineInputBorder(),
                    suffixIcon: IconButton(icon: Icon(_obscureLoginPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword)),
                  ),
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: Text(_getText('forgotPassword'), style: const TextStyle(fontSize: 12)))),
                if (_loginErrorMessage.isNotEmpty) ...[const SizedBox(height: 10), Text(_loginErrorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))],
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[50], elevation: 0), onPressed: _handleLogin, child: Text(_getText('loginButton'), style: const TextStyle(color: Colors.purple)))),
                const SizedBox(height: 16),
                TextButton(onPressed: () => setState(() { _loginErrorMessage = ''; _currentIndex = 1; }), child: Text(_getText('noAccount'))),
                const SizedBox(height: 30),
                _buildLangSelector(),
              ],
            ),
          ),
        ),
      );
    }

    if (_currentIndex == 1) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue, title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentIndex = 0))),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text(_getText('registerTitle'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green))),
                const SizedBox(height: 25),
                TextField(controller: _regFirstCtrl, decoration: InputDecoration(labelText: _getText('firstName'), border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _regMidCtrl, decoration: InputDecoration(labelText: _getText('middleName'), border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _regLastCtrl, decoration: InputDecoration(labelText: _getText('lastName'), border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                
                GestureDetector(
                  onTap: _showDatePicker,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: '${_getText('dob')} : ${_fmtNum(_selectedYear)} ${_getMonthName(_selectedMonth)} ${_fmtNum(_selectedDay)} ($_selectedCalendar)',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_ageResultText.isEmpty ? 'Age: 0 years, 0 months, and 0 days old.' : _ageResultText, style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _birthdayWishText.isEmpty ? '365 days remaining for your birthday.' : _birthdayWishText,
                    key: ValueKey<String>(_birthdayWishText),
                    style: TextStyle(fontSize: 13, color: _showBirthdayWish ? Colors.purple[700] : Colors.green[700], fontWeight: FontWeight.bold, height: 1.3),
                  ),
                ),
                
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => setState(() => _currentIndex = 11), child: Text(_getText('nextButton'), style: const TextStyle(color: Colors.white)))),
                const SizedBox(height: 16),
                Center(child: TextButton(onPressed: () => setState(() => _currentIndex = 0), child: Text(_getText('hasAccount')))),
                const SizedBox(height: 20),
                Center(child: _buildLangSelector()),
              ],
            ),
          ),
        ),
      );
    }

    if (_currentIndex == 11) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue, title: Text(_getText('registerAppBar'), style: const TextStyle(color: Colors.white)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentIndex = 1))),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text(_getText('registerTitle'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green))),
                const SizedBox(height: 25),
                Text(_getText('gender'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Row(
                  children: ['Male', 'Female', 'Other'].map((g) => Expanded(child: RadioListTile<String>(title: Text(_getText(g.toLowerCase()), style: const TextStyle(fontSize: 12)), value: g, groupValue: _selectedGender, onChanged: (v) => setState(() => _selectedGender = v), contentPadding: EdgeInsets.zero))).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _regPhoneEmailCtrl, keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: _getText('phoneOrEmail'), border: const OutlineInputBorder(),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          items: const [DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91', style: TextStyle(fontSize: 13))), DropdownMenuItem(value: '+977', child: Text('🇳🇵 +977', style: TextStyle(fontSize: 13)))],
                          onChanged: (v) => v != null ? setState(() => _selectedCountryCode = v) : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _regPassCtrl, obscureText: _obscureRegPassword,
                  decoration: InputDecoration(
                    labelText: _getText('passwordLabel'), border: const OutlineInputBorder(),
                    suffixIcon: IconButton(icon: Icon(_obscureRegPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword)),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50], border: Border.all(color: Colors.blue.shade200), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [Checkbox(value: _acceptTerms, onChanged: (v) => setState(() => _acceptTerms = v ?? false)), Expanded(child: Text(_getText('terms'), style: const TextStyle(fontSize: 12)))]),
                ),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: _acceptTerms ? _startRegistration : null, child: Text(_getText('registerButton'), style: const TextStyle(color: Colors.white)))),
                const SizedBox(height: 20),
                Center(child: _buildLangSelector()),
              ],
            ),
          ),
        ),
      );
    }

    if (_currentIndex == 12) {
      bool isEmail = _regPhoneEmailCtrl.text.contains('@');
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue, title: Text(_getText('verificationTitle'), style: const TextStyle(color: Colors.white)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentIndex = 11))),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, size: 60, color: Colors.green),
                const SizedBox(height: 20),
                Text(_getText('verificationTitle'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 10),
                isEmail ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.amber[50], border: Border.all(color: Colors.amber.shade300), borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [const Icon(Icons.mark_email_read, color: Colors.orange, size: 40), const SizedBox(height: 10), Text(_getText('emailLinkNotice'), textAlign: TextAlign.center)]),
                ) : Column(children: [
                  Text(_getText('verificationSubtitle'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                  const SizedBox(height: 20),
                  TextField(controller: _phoneOtpCtrl, keyboardType: TextInputType.number, maxLength: 6, decoration: InputDecoration(labelText: _getText('smsOtpLabel'), border: const OutlineInputBorder(), counterText: ''), style: const TextStyle(fontSize: 18, letterSpacing: 6)),
                ]),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: isEmail ? Colors.blue : Colors.green), onPressed: () => isEmail ? _completeReg() : _verifyOtp(_phoneOtpCtrl.text.trim()), child: Text(isEmail ? 'मैले इमेल रुजु गरें (Home जाने)' : _getText('verifyButton'), style: const TextStyle(color: Colors.white)))),
                const SizedBox(height: 30),
                _buildLangSelector(),
              ],
            ),
          ),
        ),
      );
    }

    return HomeScreen(
      currentLang: _currentLang,
      onLanguageChanged: (lang) => setState(() => _currentLang = lang),
      onNotificationTap: (v) {},
      selectedDate: _selectedDate,
      onCalendarTap: () {},
      onLogout: () => setState(() { _loginPassCtrl.clear(); _loginErrorMessage = ''; _currentIndex = 0; }),
    );
  }
}

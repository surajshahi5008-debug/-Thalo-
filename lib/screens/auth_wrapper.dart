import 'dart:async';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  int _currentIndex = 1; // 0: Login, 1: Register Step 1, 11: Register Step 2
  String _currentLang = 'नेपाली';
  String _selectedCalendar = 'वि.सं.';
  
  late int _selectedYear, _selectedMonth, _selectedDay;
  String _ageResultText = '';
  String _birthdayWishText = '';
  bool _showBirthdayWish = false, _showThaloUniqueWish = false;
  Timer? _birthdayTimer;

  final _firstCtrl = TextEditingController();
  final _midCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setCurrentDate();
  }

  @override
  void dispose() {
    _birthdayTimer?.cancel();
    _firstCtrl.dispose();
    _midCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  // १. प्रयोगकर्ताले जुन दिन खोल्छ, त्यही दिनको डाइनमिक मिति (DateTime.now())
  void _setCurrentDate() {
    final now = DateTime.now();
    if (_currentLang == 'नेपाली' || _currentLang == 'हिन्दी') {
      _selectedCalendar = 'वि.सं.';
      _selectedYear = now.year + 57;
    } else if (_currentLang == 'नेपाल भाषा') {
      _selectedCalendar = 'ने.सं.';
      _selectedYear = now.year + 1120; // नेपाल संवत् वर्ष
    } else if (_currentLang == 'اردو') {
      _selectedCalendar = 'هجری';
      _selectedYear = now.year - 579; // हिजरी रूपान्तरण
    } else {
      _selectedCalendar = 'AD';
      _selectedYear = now.year;
    }
    _selectedMonth = now.month;
    _selectedDay = now.day;
  }

  // २. भाषा र क्यालेन्डर अनुसार अङ्क तथा शब्द रूपान्तरण (१० सम्म शब्दमा, माथि अङ्कमा)
  String _formatNum(int n) {
    const devDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    const urduDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    if (_currentLang == 'English') return n.toString();

    String numStr = n.toString();
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < numStr.length; i++) {
      int digit = int.parse(numStr[i]);
      sb.write(_currentLang == 'اردو' ? urduDigits[digit] : devDigits[digit]);
    }
    return sb.toString();
  }

  String _formatNumberOrWord(int n) {
    if (n <= 10) {
      final wordsMap = {
        'नेपाली': {1:'एक', 2:'दुई', 3:'तीन', 4:'चार', 5:'पाँच', 6:'छ', 7:'सात', 8:'आठ', 9:'नौ', 10:'दश'},
        'हिन्दी': {1:'एक', 2:'दो', 3:'तीन', 4:'चार', 5:'पाँच', 6:'छह', 7:'सात', 8:'आठ', 9:'नौ', 10:'दस'},
        'English': {1:'one', 2:'two', 3:'three', 4:'four', 5:'five', 6:'six', 7:'seven', 8:'eight', 9:'nine', 10:'ten'},
        'नेपाल भाषा': {1:'छगू', 2:'निगू', 3:'स्वंगू', 4:'प्यंगू', 5:'न्यागू', 6:'खुगू', 7:'म्ह्यागू', 8:'च्यागू', 9:'गुंइगु', 10:'झ्यागू'},
        'اردو': {1:'ایک', 2:'دو', 3:'تین', 4:'چار', 5:'پانچ', 6:'چھ', 7:'سات', 8:'آٹھ', 9:'نو', 10:'دس'},
      };
      return wordsMap[_currentLang]?[n] ?? _formatNum(n);
    }
    return _formatNum(n);
  }

  // ३. उमेर र जन्मदिनको सटीक क्याल्कुलेशन (सम्बन्धित भाषा, व्याकरण र एकवचन/बहुवचन)
  void _calculateAgeAndBirthday() {
    final now = DateTime.now();
    int currentY = _selectedCalendar == 'AD' ? now.year : 
                  (_selectedCalendar == 'वि.सं.' ? now.year + 57 : 
                  (_selectedCalendar == 'ने.सं.' ? now.year + 1120 : now.year - 579));
    
    int years = currentY - _selectedYear;
    int months = now.month - _selectedMonth;
    int days = now.day - _selectedDay;

    if (days < 0) { months--; days += 30; }
    if (months < 0) { years--; months += 12; }
    if (years < 0) years = 0;

    String yStr = _formatNumberOrWord(years);
    String mStr = _formatNumberOrWord(months);
    String dStr = _formatNumberOrWord(days);

    // उमेर प्रदर्शन
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

    // आज जन्मदिन परेमा वा नपरेमा
    if (_selectedMonth == now.month && _selectedDay == now.day) {
      String ageOrd = _getOrdinal(years);
      setState(() {
        _showBirthdayWish = true;
        if (_currentLang == 'नेपाली') _birthdayWishText = 'आज तपाईंको $ageOrd जन्मदिन हो! 🎂';
        else if (_currentLang == 'नेपाल भाषा') _birthdayWishText = 'थौं छगु $ageOrd बुगुन्हि खः! 🎂';
        else if (_currentLang == 'हिन्दी') _birthdayWishText = 'आज आपका $ageOrd जन्मदिन है! 🎂';
        else if (_currentLang == 'اردو') _birthdayWishText = 'آج آپ کی $ageOrd سالگرہ ہے! 🎂';
        else _birthdayWishText = 'Today is your $ageOrd birthday! 🎂';
      });

      _birthdayTimer?.cancel();
      _showThaloUniqueWish = false;
      _birthdayTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) setState(() => _showThaloUniqueWish = true);
      });
    } else {
      int remDays = (_selectedMonth - now.month) * 30 + (_selectedDay - now.day);
      if (remDays < 0) remDays += 365;
      String dayFormatted = _formatNumberOrWord(remDays);
      String nextAgeOrd = _getOrdinal(years + 1);

      _birthdayTimer?.cancel();
      setState(() {
        _showBirthdayWish = false;
        _showThaloUniqueWish = false;
        
        if (_currentLang == 'नेपाली') {
          _birthdayWishText = 'तपाईंको $nextAgeOrd जन्मदिन आउन $dayFormatted ${remDays == 1 ? 'दिन बाँकी छ' : 'दिन बाँकी छन्'}।';
        } else if (_currentLang == 'नेपाल भाषा') {
          _birthdayWishText = 'छगु $nextAgeOrd बुगुन्हि वयेत $dayFormatted न्हिं ल्यं दु।';
        } else if (_currentLang == 'हिन्दी') {
          _birthdayWishText = 'आपका $nextAgeOrd जन्मदिन आने में $dayFormatted ${remDays == 1 ? 'दिन बाकी है' : 'दिन बाकी हैं'}।';
        } else if (_currentLang == 'اردو') {
          _birthdayWishText = 'آپ کی $nextAgeOrd سالگرہ میں $dayFormatted ${remDays == 1 ? 'دن باقی ہے' : 'دن باقی ہیں'}।';
        } else {
          _birthdayWishText = '$dayFormatted ${remDays == 1 ? 'day' : 'days'} remaining for your $nextAgeOrd birthday.';
        }
      });
    }
  }

  String _getOrdinal(int num) {
    String formatted = _formatNumberOrWord(num);
    if (_currentLang == 'नेपाली') return '$formatted औँ';
    if (_currentLang == 'हिन्दी') return '$formatted वाँ';
    if (_currentLang == 'नेपाल भाषा') return '$formatted गःगु';
    if (_currentLang == 'اردو') return '$formatted ویں';
    
    // English Suffix
    if (num % 100 >= 11 && num % 100 <= 13) return '${num}th';
    switch (num % 10) {
      case 1: return '${num}st';
      case 2: return '${num}nd';
      case 3: return '${num}rd';
      default: return '${num}th';
    }
  }

  String _getThaloUniqueWishText() {
    final now = DateTime.now();
    int currentY = _selectedCalendar == 'AD' ? now.year : 
                  (_selectedCalendar == 'वि.सं.' ? now.year + 57 : 
                  (_selectedCalendar == 'ने.सं.' ? now.year + 1120 : now.year - 579));
    int age = currentY - _selectedYear;
    String ageOrd = _getOrdinal(age);

    if (_currentLang == 'नेपाली') return 'थलो परिवारतर्फबाट यहाँलाई $ageOrd जन्मदिनको हार्दिक मंगलमय शुभकामना! ✨';
    if (_currentLang == 'हिन्दी') return 'थलो परिवार की ओर से आपको आपके $ageOrd जन्मदिन की हार्दिक शुभकामनाएं! ✨';
    if (_currentLang == 'नेपाल भाषा') return 'थलो परिवारया तर्फबाट छयात $ageOrd बुगुन्हिया तःधंगु भिंतुना! ✨';
    if (_currentLang == 'اردو') return 'تھلو فیملی کی طرف سے آپ کو $ageOrd سالگرہ کی مبارکباد! ✨';
    return 'Warmest wishes from the Thalo family on your $ageOrd birthday! ✨';
  }

  // ४. भाषा अनुसार लेबलहरू (अनावश्यक (AD) नराखी)
  String _getDobLabel() {
    if (_currentLang == 'नेपाली') return 'जन्म मिति';
    if (_currentLang == 'नेपाल भाषा') return 'बुगु मिति';
    if (_currentLang == 'हिन्दी') return 'जन्म तिथि';
    if (_currentLang == 'اردو') return 'تاریخ پیدائش';
    return 'Date of Birth';
  }

  // ५. क्यालेन्डर संवाद (Calendar Dialog with Local & AD switch)
  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_getDobLabel(), style: const TextStyle(fontSize: 16)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50], elevation: 0),
                onPressed: () => setDlgState(() {
                  final now = DateTime.now();
                  if (_selectedCalendar == 'AD') {
                    _selectedCalendar = _currentLang == 'नेपाल भाषा' ? 'ने.सं.' : (_currentLang == 'اردو' ? 'هجری' : 'वि.सं.');
                    _selectedYear = _selectedCalendar == 'वि.सं.' ? now.year + 57 : (_selectedCalendar == 'ने.सं.' ? now.year + 1120 : now.year - 579);
                  } else {
                    _selectedCalendar = 'AD';
                    _selectedYear = now.year;
                  }
                }),
                child: Text('$_selectedCalendar | ${_selectedCalendar == 'AD' ? 'Local' : 'AD'}', style: const TextStyle(color: Colors.blue, fontSize: 11)),
              ),
            ],
          ),
          content: Row(
            children: [
              // Year
              Expanded(
                flex: 2,
                child: DropdownButton<int>(
                  isExpanded: true, value: _selectedYear, menuMaxHeight: 200,
                  items: List.generate(2001, (i) => 1000 + i).map((y) => DropdownMenuItem(value: y, child: Text(_formatNum(y), style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => v != null ? setDlgState(() => _selectedYear = v) : null,
                ),
              ),
              const SizedBox(width: 6),
              // Month
              Expanded(
                flex: 2,
                child: DropdownButton<int>(
                  isExpanded: true, value: _selectedMonth, menuMaxHeight: 200,
                  items: List.generate(12, (i) => i + 1).map((m) {
                    String monthName = _formatNum(m);
                    if (_selectedCalendar == 'AD') {
                      monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m - 1];
                      if (_currentLang == 'हिन्दी') monthName = ['जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'][m - 1];
                      if (_currentLang == 'اردو') monthName = ['جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون', 'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر'][m - 1];
                    } else if (_selectedCalendar == 'ने.सं.') {
                      monthName = ['चिल्ला', 'दिल्ला', 'गुंला', 'ञला', 'चौला', 'बछला', 'तंला', 'देवा', 'कछला', 'इला', 'थिल्ला', 'प्वंला'][m - 1];
                    } else if (_selectedCalendar == 'वि.सं.') {
                      monthName = ['बैशाख', 'जेठ', 'आषाढ', 'श्रावण', 'भाद्र', 'आश्विन', 'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फागुन', 'चैत'][m - 1];
                    } else if (_selectedCalendar == 'هجری') {
                      monthName = ['محرم', 'صفر', 'ربیع الاول', 'ربیع الثانی', 'جمادی الاول', 'جمادی الثانی', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذی القعدہ', 'ذی الحجہ'][m - 1];
                    }
                    return DropdownMenuItem(value: m, child: Text(monthName, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (v) => v != null ? setDlgState(() => _selectedMonth = v) : null,
                ),
              ),
              const SizedBox(width: 6),
              // Day
              Expanded(
                flex: 1,
                child: DropdownButton<int>(
                  isExpanded: true, value: _selectedDay, menuMaxHeight: 200,
                  items: List.generate(32, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text(_formatNum(d), style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => v != null ? setDlgState(() => _selectedDay = v) : null,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () { setState(() => _calculateAgeAndBirthday()); Navigator.pop(context); },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  // ६. भाषा चयन बार (Language Selector)
  Widget _buildLangSelector() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: ['English', 'नेपाली', 'नेपाल भाषा', 'हिन्दी', 'اردو'].map((lang) {
      bool isSel = _currentLang == lang;
      return GestureDetector(
        onTap: () => setState(() {
          _currentLang = lang;
          _setCurrentDate();
          _calculateAgeAndBirthday();
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(lang, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.blue : Colors.grey[700])),
        ),
      );
    }).toList(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('थलो - साइन अप'), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('नयाँ खाता खोल्नुहोस्', style: TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            TextField(controller: _firstCtrl, decoration: const InputDecoration(labelText: 'पहिलो नाम', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _midCtrl, decoration: const InputDecoration(labelText: 'बीचको नाम (ऐच्छिक)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _lastCtrl, decoration: const InputDecoration(labelText: 'थर', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            
            // Birthday Selector Field
            GestureDetector(
              onTap: _showDatePicker,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '${_getDobLabel()} (${_selectedCalendar}) : ${_formatNum(_selectedYear)}-${_formatNum(_selectedMonth)}-${_formatNum(_selectedDay)}',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Age & Wishes Display Area
            Text(_ageResultText, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _showThaloUniqueWish ? _getThaloUniqueWishText() : _birthdayWishText,
                key: ValueKey<bool>(_showThaloUniqueWish),
                style: TextStyle(
                  fontSize: 12, 
                  color: _showThaloUniqueWish ? Colors.purple[800] : (_showBirthdayWish ? Colors.pink[800] : Colors.green[800]), 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            _buildLangSelector(),
          ],
        ),
      ),
    );
  }
}

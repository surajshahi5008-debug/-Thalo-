import 'dart:async';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  int _currentIndex = 1; // साइन अप पृष्ठ देखाउन
  String _currentLang = 'नेपाली';
  String _selectedCalendar = 'वि.सं.';
  
  // आजको वास्तविक वर्तमान मिति (DateTime.now()) मा आधारित सुरुको मिति
  late int _selectedYear, _selectedMonth, _selectedDay;

  String _ageResultText = '';
  String _birthdayWishText = '';

  final TextEditingController _regFirstCtrl = TextEditingController();
  final TextEditingController _regMidCtrl = TextEditingController();
  final TextEditingController _regLastCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setTodayBirthDate();
  }

  @override
  void dispose() {
    _regFirstCtrl.dispose();
    _regMidCtrl.dispose();
    _regLastCtrl.dispose();
    super.dispose();
  }

  // एप खुल्दा वा भाषा बदल्दा आजकै वास्तविक मिति सेट गर्ने
  void _setTodayBirthDate() {
    final now = DateTime.now();
    if (_currentLang == 'नेपाली') {
      _selectedCalendar = 'वि.सं.';
      _selectedYear = now.year + 57; // अंग्रेजी सालमा ५७ जोडेर वि.सं.
    } else {
      _selectedCalendar = 'AD';
      _selectedYear = now.year;
    }
    _selectedMonth = now.month;
    _selectedDay = now.day;
    _calculateAgeAndBirthday();
  }

  String _fmtNum(int n) {
    if (_currentLang == 'नेपाली') {
      const eng = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const nep = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
      return n.toString().split('').map((char) {
        int index = eng.indexOf(char);
        return index != -1 ? nep[index] : char;
      }).join('');
    }
    return n.toString();
  }

  // १० सम्म शब्दमा र त्यसभन्दा माथि अंकमा राख्ने नियम
  String _getNumberOrWord(int n) {
    if (_currentLang == 'नेपाली') {
      if (n <= 10) {
        const map = {
          0: 'शून्य', 1: 'पहिलो', 2: 'दोस्रो', 3: 'तेस्रो', 4: 'चौथो', 
          5: 'पाँचौँ', 6: 'छैटौँ', 7: 'सातौँ', 8: 'आठौँ', 9: 'नवौँ', 10: 'दशौँ'
        };
        return map[n] ?? _fmtNum(n);
      }
      return '${_fmtNum(n)}औँ';
    } else {
      if (n <= 10) {
        const map = {
          0: 'zero', 1: 'first', 2: 'second', 3: 'third', 4: 'fourth', 
          5: 'fifth', 6: 'sixth', 7: 'seventh', 8: 'eighth', 9: 'ninth', 10: 'tenth'
        };
        return map[n] ?? n.toString();
      }
      return '${n}th';
    }
  }

  // नेपाली महिनाका नामहरू शब्दमा
  String _getMonthName(int m) {
    if (_selectedCalendar == 'वि.सं.') {
      const months = [
        'बैशाख', 'जेठ', 'आषाढ', 'श्रावण', 'भाद्र', 'आश्विन', 
        'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फागुन', 'चैत'
      ];
      if (m >= 1 && m <= 12) return months[m - 1];
    }
    return _fmtNum(m);
  }

  void _calculateAgeAndBirthday() {
    final now = DateTime.now();
    int currentY = _selectedCalendar == 'AD' ? now.year : now.year + 57;
    int years = currentY - _selectedYear;
    int months = now.month - _selectedMonth;
    int days = now.day - _selectedDay;

    if (days < 0) { months--; days += 30; }
    if (months < 0) { years--; months += 12; }
    if (years < 0) years = 0;
    if (months < 0) months = 0;
    if (days < 0) days = 0;

    String yStr = _fmtNum(years), mStr = _fmtNum(months), dStr = _fmtNum(days);
    
    if (_currentLang == 'नेपाली') {
      _ageResultText = 'तपाईंको उमेर: $yStr वर्ष, $mStr महिना, र $dStr दिन भयो।';
    } else {
      _ageResultText = 'Age: $yStr years, $mStr months, and $dStr days old.';
    }

    // जन्मदिनको छोटो र मीठो शुभकामना सन्देश
    if (_selectedMonth == now.month && _selectedDay == now.day) {
      String ageWord = _getNumberOrWord(years);
      if (_currentLang == 'नेपाली') {
        _birthdayWishText = 'थलोको तर्फबाट तपाईंलाई $ageWord जन्मदिनको शुभकामना! 🎂';
      } else {
        _birthdayWishText = 'Happy $ageWord birthday from Thalo! 🎂';
      }
    } else {
      int upcomingAge = years + 1;
      String upcomingAgeStr = _getNumberOrWord(upcomingAge);
      int remDays = (_selectedMonth - now.month) * 30 + (_selectedDay - now.day);
      if (remDays < 0) remDays += 365;
      String dayNumStr = _fmtNum(remDays);

      if (_currentLang == 'नेपाली') {
        _birthdayWishText = 'तपाईंको $upcomingAgeStr जन्मदिन आउन $dayNumStr दिन बाँकी छ।';
      } else {
        _birthdayWishText = '$dayNumStr days remaining for your $upcomingAgeStr birthday.';
      }
    }
    setState(() {});
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(_currentLang == 'नेपाली' ? 'जन्म मिति छाान्नुहोस्' : 'Select Date of Birth', style: const TextStyle(fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            child: Row(
              children: [
                // वर्ष चयन
                Expanded(
                  flex: 2,
                  child: DropdownButton<int>(
                    isExpanded: true, value: _selectedYear, menuMaxHeight: 200,
                    items: List.generate(100, (i) => DateTime.now().year + 57 - i).map((y) => DropdownMenuItem(value: y, child: Text(_fmtNum(y), style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => v != null ? setDlgState(() => _selectedYear = v) : null,
                  ),
                ),
                const SizedBox(width: 8),
                // महिना (शब्दमा) चयन
                Expanded(
                  flex: 2,
                  child: DropdownButton<int>(
                    isExpanded: true, value: _selectedMonth, menuMaxHeight: 200,
                    items: List.generate(12, (i) => i + 1).map((m) {
                      return DropdownMenuItem(value: m, child: Text(_getMonthName(m), style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (v) => v != null ? setDlgState(() => _selectedMonth = v) : null,
                  ),
                ),
                const SizedBox(width: 8),
                // गते चयन
                Expanded(
                  flex: 1,
                  child: DropdownButton<int>(
                    isExpanded: true, value: _selectedDay, menuMaxHeight: 200,
                    items: List.generate(32, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text(_fmtNum(d), style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => v != null ? setDlgState(() => _selectedDay = v) : null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(_currentLang == 'नेपाली' ? 'रद्द गर्नुहोस्' : 'Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () { _calculateAgeAndBirthday(); Navigator.pop(context); },
              child: Text(_currentLang == 'नेपाली' ? 'ठीक छ' : 'OK', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangSelector() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: ['नेपाली', 'English'].map((lang) {
      bool isSel = _currentLang == lang;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GestureDetector(
          onTap: () => setState(() {
            _currentLang = lang;
            _setTodayBirthDate();
          }),
          child: Text(lang, style: TextStyle(fontSize: 13, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.blue : Colors.grey[700])),
        ),
      );
    }).toList(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, 
        title: Text(_currentLang == 'नेपाली' ? 'थलो - साइन अप' : 'Thalo - Sign Up', style: const TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  _currentLang == 'नेपाली' ? 'नयाँ खाता खोल्नुहोस्' : 'Create a New Account', 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)
                ),
              ),
              const SizedBox(height: 25),
              TextField(controller: _regFirstCtrl, decoration: InputDecoration(labelText: _currentLang == 'नेपाली' ? 'पहिलो नाम' : 'First Name', border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _regMidCtrl, decoration: InputDecoration(labelText: _currentLang == 'नेपाली' ? 'बीचको नाम (ऐच्छिक)' : 'Middle Name (Optional)', border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _regLastCtrl, decoration: InputDecoration(labelText: _currentLang == 'नेपाली' ? 'थर' : 'Last Name', border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              
              // जन्म मिति फिल्ड (वर्ष + महिना शब्दमा + गते)
              GestureDetector(
                onTap: _showDatePicker,
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: _currentLang == 'नेपाली' 
                          ? 'जन्म मिति : ${_fmtNum(_selectedYear)} ${_getMonthName(_selectedMonth)} ${_fmtNum(_selectedDay)}'
                          : 'Date of Birth : $_selectedYear-$_selectedMonth-$_selectedDay',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(_ageResultText, style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              
              // छोटो र मीठो शुभकामना सन्देश
              Text(
                _birthdayWishText, 
                style: TextStyle(fontSize: 13, color: Colors.purple[700], fontWeight: FontWeight.bold, height: 1.3),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, 
                height: 48, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green), 
                  onPressed: () {}, 
                  child: Text(_currentLang == 'नेपाली' ? 'अर्को' : 'Next', style: const TextStyle(color: Colors.white, fontSize: 16))
                ),
              ),
              const SizedBox(height: 20),
              Center(child: _buildLangSelector()),
            ],
          ),
        ),
      ),
    );
  }
}

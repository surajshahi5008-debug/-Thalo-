import 'package:flutter/material.dart';
import '../widgets/lang_bar.dart';
import '../widgets/calendar_picker.dart';
import '../calendar_helper.dart';

class RegisterScreen extends StatefulWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;
  final Function(String) onNotificationTap;
  final VoidCallback onRegisterSuccess;
  final VoidCallback goTologin;

  const RegisterScreen({
    Key? key,
    required this.currentLang,
    required this.onLanguageChanged,
    required this.onNotificationTap,
    required this.onRegisterSuccess,
    required this.goTologin,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedCalendar = 'वि.सं.';
  int _selectedYear = 2083;
  int _selectedMonth = 5; 
  int _selectedDay = 23;   

  @override
  void initState() {
    super.initState();
    _resetToToday();
  }

  void _resetToToday() {
    if (_selectedCalendar == 'هجری') {
      _selectedYear = 1448;
      _selectedMonth = 3;
      _selectedDay = 26;
    } else if (_selectedCalendar == 'ने.सं.') {
      _selectedYear = 1146;
      _selectedMonth = 9;
      _selectedDay = 2;
    } else {
      _selectedYear = 2083;
      _selectedMonth = 5;
      _selectedDay = 23;
    }
  }

  void _showCalendarPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 400,
              child: Column(
                children: [
                  // यदि भाषा अंग्रेजी वा हिन्दी छ भने क्यालेन्डर विकल्प नदेखाउने वा AD मात्र राख्ने
                  if (widget.currentLang != 'en' && widget.currentLang != 'hi')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['वि.सं.', 'ने.सं.', 'هجری'].map((cal) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ChoiceChip(
                            label: Text(cal),
                            selected: _selectedCalendar == cal,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() {
                                  _selectedCalendar = cal;
                                  if (cal == 'هجری') {
                                    _selectedYear = 1448;
                                    _selectedMonth = 3;
                                    _selectedDay = 26;
                                  } else if (cal == 'ने.सं.') {
                                    _selectedYear = 1146;
                                    _selectedMonth = 9;
                                    _selectedDay = 2;
                                  } else {
                                    _selectedYear = 2083;
                                    _selectedMonth = 5;
                                    _selectedDay = 23;
                                  }
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: CalendarHelper.getYearRange(_selectedCalendar == 'هجری' ? 1448 : (_selectedCalendar == 'ने.सं.' ? 1146 : 2083)).length,
                            itemBuilder: (context, index) {
                              int baseY = _selectedCalendar == 'هجری' ? 1448 : (_selectedCalendar == 'ने.सं.' ? 1146 : 2083);
                              int year = CalendarHelper.getYearRange(baseY)[index];
                              return ListTile(
                                title: Text(year.toString(), textAlign: TextAlign.center),
                                selected: _selectedYear == year,
                                onTap: () {
                                  setModalState(() {
                                    _selectedYear = year;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 12,
                            itemBuilder: (context, index) {
                              int month = index + 1;
                              String monthName = CalendarHelper.getMonthName(month, widget.currentLang, calendarType: _selectedCalendar);
                              return ListTile(
                                title: Text(monthName.isEmpty ? '$month' : monthName, textAlign: TextAlign.center),
                                selected: _selectedMonth == month,
                                onTap: () {
                                  setModalState(() {
                                    _selectedMonth = month;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 31,
                            itemBuilder: (context, index) {
                              int day = index + 1;
                              return ListTile(
                                title: Text(day.toString(), textAlign: TextAlign.center),
                                selected: _selectedDay == day,
                                onTap: () {
                                  setModalState(() {
                                    _selectedDay = day;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('मिति छान्नुहोस्'),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String monthName = CalendarHelper.getMonthName(_selectedMonth, widget.currentLang, calendarType: _selectedCalendar);
    String selectedDateStr = '$_selectedYear-${monthName.isEmpty ? _selectedMonth : monthName}-$_selectedDay (${widget.currentLang == 'en' || widget.currentLang == 'hi' ? 'AD' : _selectedCalendar})';

    // भाषा कोड (currentLang) पास गरिएको छ ताकि अंग्रेजी/हिन्दीमा स्वतः AD मात्र गणना होस्
    Map<String, dynamic> ageData = CalendarHelper.calculateAgeAndCountdown(
      year: _selectedYear,
      month: _selectedMonth,
      day: _selectedDay,
      calendarType: _selectedCalendar,
      languageCode: widget.currentLang,
    );

    DateTime adConverted = CalendarHelper.convertToAD(_selectedYear, _selectedMonth, _selectedDay, _selectedCalendar, languageCode: widget.currentLang);

    String adBaseText = CalendarHelper.getLocalizedText('ad_base', widget.currentLang);
    String ageLabel = CalendarHelper.getLocalizedText('age_text', widget.currentLang);
    String yearUnit = CalendarHelper.getLocalizedText('years', widget.currentLang);
    String monthUnit = CalendarHelper.getLocalizedText('months', widget.currentLang);
    String dayUnit = CalendarHelper.getLocalizedText('days', widget.currentLang);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LanguageBar(
              currentLang: widget.currentLang,
              onLanguageChanged: widget.onLanguageChanged,
              onNotificationTap: widget.onNotificationTap,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    const Text(
                      'نیاں खाता खोल्नुहोस् (Register)',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'इमेल (Email)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'पासवर्ड (Password)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CalendarPickerWidget(
                      selectedDate: selectedDateStr,
                      onCalendarTap: () => _showCalendarPickerModal(context),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$adBaseText: ${adConverted.year}-${adConverted.month}-${adConverted.day} (AD)',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$ageLabel: ${ageData['years']} $yearUnit, ${ageData['months']} $monthUnit, ${ageData['days']} $dayUnit.',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ageData['isBirthdayToday'] 
                          ? CalendarHelper.getLocalizedText('birthday_today', widget.currentLang)
                          : '${CalendarHelper.getLocalizedText('birthday_countdown', widget.currentLang)} ${ageData['remainingDays']} ${CalendarHelper.getLocalizedText('days', widget.currentLang)}',
                      style: const TextStyle(fontSize: 14, color: Colors.purple),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: widget.onRegisterSuccess,
                      child: const Text('दर्ता गर्नुहोस्'),
                    ),
                    TextButton(
                      onPressed: widget.goTologin,
                      child: const Text('पहिले नै खाता छ? लगईन गर्नुहोस्'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

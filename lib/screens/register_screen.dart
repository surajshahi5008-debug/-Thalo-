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
  int _selectedDay = 25;   

  @override
  void initState() {
    super.initState();
    _updateCalendarBasedOnLanguage(widget.currentLang);
    _resetToToday();
  }

  @override
  void didUpdateWidget(covariant RegisterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLang != widget.currentLang) {
      _updateCalendarBasedOnLanguage(widget.currentLang);
    }
  }

  void _updateCalendarBasedOnLanguage(String lang) {
    setState(() {
      if (lang == 'en' || lang == 'hi') {
        _selectedCalendar = 'AD';
        _selectedYear = 2026;
        _selectedMonth = 9;
        _selectedDay = 10;
      } else {
        if (_selectedCalendar == 'AD') {
          _selectedCalendar = 'वि.सं.';
        }
        _resetToToday();
      }
    });
  }

  void _resetToToday() {
    if (widget.currentLang == 'en' || widget.currentLang == 'hi') {
      _selectedYear = 2026;
      _selectedMonth = 9;
      _selectedDay = 10;
    } else if (_selectedCalendar == 'هجری') {
      _selectedYear = 1448;
      _selectedMonth = 3;
      _selectedDay = 27;
    } else if (_selectedCalendar == 'ने.सं.') {
      _selectedYear = 1146;
      _selectedMonth = 10;
      _selectedDay = 1;
    } else {
      _selectedYear = 2083;
      _selectedMonth = 5;
      _selectedDay = 25;
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
                                    _selectedDay = 27;
                                  } else if (cal == 'ने.सं.') {
                                    _selectedYear = 1146;
                                    _selectedMonth = 10;
                                    _selectedDay = 1;
                                  } else {
                                    _selectedYear = 2083;
                                    _selectedMonth = 5;
                                    _selectedDay = 25;
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
                            itemCount: CalendarHelper.getYearRange(
                              widget.currentLang == 'en' || widget.currentLang == 'hi' 
                                  ? 2026 
                                  : (_selectedCalendar == 'هجری' ? 1448 : (_selectedCalendar == 'ने.सं.' ? 1146 : 2083))
                            ).length,
                            itemBuilder: (context, index) {
                              int baseY = widget.currentLang == 'en' || widget.currentLang == 'hi'
                                  ? 2026
                                  : (_selectedCalendar == 'هجری' ? 1448 : (_selectedCalendar == 'ने.सं.' ? 1146 : 2083));
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
                              String monthName = CalendarHelper.getMonthName(
                                month, 
                                widget.currentLang, 
                                calendarType: widget.currentLang == 'en' || widget.currentLang == 'hi' ? 'AD' : _selectedCalendar,
                                shortForm: true,
                              );
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
    String activeCalType = (widget.currentLang == 'en' || widget.currentLang == 'hi') ? 'AD' : _selectedCalendar;
    String monthName = CalendarHelper.getMonthName(_selectedMonth, widget.currentLang, calendarType: activeCalType, shortForm: true);
    
    String selectedDateStr = '$_selectedYear-$monthName-$_selectedDay ($activeCalType)';

    Map<String, dynamic> ageData = CalendarHelper.calculateAgeAndCountdown(
      year: _selectedYear,
      month: _selectedMonth,
      day: _selectedDay,
      calendarType: activeCalType,
      languageCode: widget.currentLang,
    );

    DateTime adConverted = CalendarHelper.convertToAD(_selectedYear, _selectedMonth, _selectedDay, activeCalType, languageCode: widget.currentLang);

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
              onLanguageChanged: (newLang) {
                widget.onLanguageChanged(newLang);
                _updateCalendarBasedOnLanguage(newLang);
              },
              onNotificationTap: widget.onNotificationTap,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    const Text(
                      'नयाँ खाता खोल्नुहोस् (Register)',
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
                          : '${CalendarHelper.getLocalizedText('birthday_countdown', widget.currentLang)} ${ageData['remainingDays']} $dayUnit',
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

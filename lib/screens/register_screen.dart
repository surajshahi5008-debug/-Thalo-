import 'package:flutter/material.dart' hide TextDirection;
import '../widgets/lang_bar.dart';
import '../widgets/calendar_picker.dart';
import '../calendar_helper.dart';
import '../calendar_enums.dart';
import '../date_converters.dart';

AppLanguage _mapLang(String code) {
  switch (code) {
    case 'hi':
      return AppLanguage.hindi;
    case 'ne':
      return AppLanguage.nepali;
    case 'new':
      return AppLanguage.newari;
    case 'ur':
      return AppLanguage.urdu;
    case 'en':
    default:
      return AppLanguage.english;
  }
}

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

  late CalendarSystem _selectedSystem;
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  AppLanguage get _appLang => _mapLang(widget.currentLang);

  @override
  void initState() {
    super.initState();
    _selectedSystem = CalendarHelper.defaultTabFor(_appLang);
    _resetToToday();
  }

  @override
  void didUpdateWidget(covariant RegisterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLang != widget.currentLang) {
      setState(() {
        final tabs = CalendarHelper.tabsFor(_appLang);
        if (!tabs.contains(_selectedSystem)) {
          _selectedSystem = CalendarHelper.defaultTabFor(_appLang);
        }
        _resetToToday();
      });
    }
  }

  void _resetToToday() {
    final now = DateTime.now();
    final todayAd = AdDate(now.year, now.month, now.day);
    final today = CalendarHelper.fromAd(_selectedSystem, todayAd);
    _selectedYear = today.year;
    _selectedMonth = today.month;
    _selectedDay = today.day;
  }

  List<int> _yearRange(int centerYear) =>
      List.generate(161, (i) => centerYear - 80 + i);

  void _showCalendarPickerModal(BuildContext context) {
    final tabs = CalendarHelper.tabsFor(_appLang);

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
                  if (tabs.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: tabs.map((sys) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ChoiceChip(
                            label: Text(CalendarHelper.calendarLabel(sys)),
                            selected: _selectedSystem == sys,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() {
                                  _selectedSystem = sys;
                                  _resetToToday();
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
                            itemCount: _yearRange(_selectedYear).length,
                            itemBuilder: (context, index) {
                              final year = _yearRange(_selectedYear)[index];
                              return ListTile(
                                title: Text(
                                  CalendarHelper.formatNumber(
                                    number: year,
                                    system: _selectedSystem,
                                    language: _appLang,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                              final month = index + 1;
                              final name = CalendarHelper.monthName(
                                system: _selectedSystem,
                                month: month,
                                language: _appLang,
                              );
                              return ListTile(
                                title: Text(name, textAlign: TextAlign.center),
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
                            itemCount: 32,
                            itemBuilder: (context, index) {
                              final day = index + 1;
                              return ListTile(
                                title: Text(
                                  CalendarHelper.formatNumber(
                                    number: day,
                                    system: _selectedSystem,
                                    language: _appLang,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                    child: Text(CalendarHelper.uiLabel('choose_date', _appLang)),
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
    final monthName = CalendarHelper.monthName(
      system: _selectedSystem,
      month: _selectedMonth,
      language: _appLang,
    );

    final selectedDateStr =
        '${CalendarHelper.formatNumber(number: _selectedYear, system: _selectedSystem, language: _appLang)}-$monthName-${CalendarHelper.formatNumber(number: _selectedDay, system: _selectedSystem, language: _appLang)} (${CalendarHelper.calendarLabel(_selectedSystem)})';

    final adConverted = CalendarHelper.toAd(
      system: _selectedSystem,
      year: _selectedYear,
      month: _selectedMonth,
      day: _selectedDay,
    );

    final ageData = CalendarHelper.calculateAgeAndCountdown(adConverted);

    // en/hi मा एउटै (AD) क्यालेन्डर मात्र हुने भएकाले conversion लाइन देखाउनु पर्दैन।
    final tabs = CalendarHelper.tabsFor(_appLang);
    final showConversionLine = tabs.length > 1;

    String? conversionText;
    if (showConversionLine) {
      if (_selectedSystem == CalendarSystem.ad) {
        final nativeSystem = tabs.firstWhere((s) => s != CalendarSystem.ad);
        final nativeDate = CalendarHelper.fromAd(nativeSystem, adConverted);
        final nativeMonthName = CalendarHelper.monthName(
          system: nativeSystem,
          month: nativeDate.month,
          language: _appLang,
        );
        conversionText =
            '${CalendarHelper.formatNumber(number: nativeDate.year, system: nativeSystem, language: _appLang)}-$nativeMonthName-${CalendarHelper.formatNumber(number: nativeDate.day, system: nativeSystem, language: _appLang)} (${CalendarHelper.calendarLabel(nativeSystem)})';
      } else {
        conversionText =
            '${adConverted.year}-${adConverted.month}-${adConverted.day} (AD)';
      }
    }

    final adBaseText = CalendarHelper.uiLabel('ad_base', _appLang);
    final ageLabel = CalendarHelper.uiLabel('age_text', _appLang);
    final yearUnit = CalendarHelper.uiLabel('years', _appLang);
    final monthUnit = CalendarHelper.uiLabel('months', _appLang);
    final dayUnit = CalendarHelper.uiLabel('days', _appLang);

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
                    if (showConversionLine && conversionText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        '$adBaseText: $conversionText',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      '$ageLabel: ${ageData['years']} $yearUnit, ${ageData['months']} $monthUnit, ${ageData['days']} $dayUnit.',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ageData['isBirthdayToday']
                          ? CalendarHelper.uiLabel('birthday_today', _appLang)
                          : '${CalendarHelper.uiLabel('birthday_countdown', _appLang)} ${ageData['remainingDays']} $dayUnit',
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

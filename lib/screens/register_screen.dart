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
  String _selectedDateStr = '';
  int _selectedYear = 2083;
  int _selectedMonth = 1;
  int _selectedDay = 1;

  @override
  void initState() {
    super.initState();
    // प्रणालीको वास्तविक करेन्ट डेट (Current Date) लिने
    DateTime now = DateTime.now();
    _selectedYear = now.year + 57; // आवश्यकता अनुसार वर्ष मिलाउन सकिन्छ
    _selectedMonth = now.month;
    _selectedDay = now.day;

    String monthName = CalendarHelper.getMonthName(_selectedMonth, widget.currentLang);
    _selectedDateStr = '$_selectedYear-${monthName.isEmpty ? _selectedMonth : monthName}-$_selectedDay ($_selectedCalendar)';
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
                            itemCount: CalendarHelper.getYearRange(2083).length,
                            itemBuilder: (context, index) {
                              int year = CalendarHelper.getYearRange(2083)[index];
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
                              String monthName = CalendarHelper.getMonthName(month, widget.currentLang);
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
                            itemCount: 32,
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
                      String monthName = CalendarHelper.getMonthName(_selectedMonth, widget.currentLang);
                      setState(() {
                        _selectedDateStr = '$_selectedYear-${monthName.isEmpty ? _selectedMonth : monthName}-$_selectedDay ($_selectedCalendar)';
                      });
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'नयाँ खाता खोल्नुहोस् (Register)',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      selectedDate: _selectedDateStr,
                      onCalendarTap: () => _showCalendarPickerModal(context),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: widget.onRegisterSuccess,
                      child: const Text('दर्ता गर्नुहोस्'),
                    ),
                    TextButton(
                      onPressed: widget.goTologin,
                      child: const Text('पहिले नै खाता छ? लगईन गर्नुहोहोस्'),
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

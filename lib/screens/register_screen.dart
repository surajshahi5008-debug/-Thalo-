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
  int _selectedMonth = 5; // भदौ (प्रमाणित आधार मिति अनुसार)
  int _selectedDay = 22;   // २२ गते

  @override
  void initState() {
    super.initState();
    // प्रमाणित आधार मिति (७ सेप्टेम्बर २०२६ = वि.सं. २०८३ भदौ २२) लाई डिफल्ट सेट गर्ने
    _selectedYear = 2083;
    _selectedMonth = 5;
    _selectedDay = 22;
  }

  void _showCalendarPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0,),
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
                                // क्यालेन्डर फेर्दा त्यसको प्रमाणित आधार वर्ष/महिना/गते सेट गर्ने
                                if (cal == 'هجری') {
                                  _selectedYear = 1448;
                                  _selectedMonth = 3; // Rabi' I
                                  _selectedDay = 25;
                                } else if (cal == 'ने.सं.') {
                                  _selectedYear = 1146;
                                  _selectedMonth = 9; // गुंला
                                  _selectedDay = 1;
                                } else {
                                  _selectedYear = 2083;
                                  _selectedMonth = 5; // भदौ
                                  _selectedDay = 22;
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
    String selectedDateStr = '$_selectedYear-${monthName.isEmpty ? _selectedMonth : monthName}-$_selectedDay ($_selectedCalendar)';

    // उमेर र AD मिति सही रूपमा क्याल्कुलेट गर्ने
    Map<String, dynamic> ageData = CalendarHelper.calculateAgeAndCountdown(
      year: _selectedYear,
      month: _selectedMonth,
      day: _selectedDay,
      calendarType: _selectedCalendar,
    );

    DateTime adConverted = CalendarHelper.convertToAD(_selectedYear, _selectedMonth, _selectedDay, _selectedCalendar);

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
                    const SizedBox(height: 10),
                    Text(
                      'AD आधारमा: ${adConverted.year}-${adConverted.month}-${adConverted.day} (AD)',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'उमेर: ${ageData['years']} वर्ष, ${ageData['months']} महिना, र ${ageData['days']} दिन भयो।',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ageData['isBirthdayToday'] 
                          ? 'तपाईंलाई जन्मदिनको शुभकामना! 🎂' 
                          : 'तपाईंको ${ageData['targetAge']} औं जन्मदिन आउन ${ageData['remainingDays']} दिन बाँकी छ।',
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

import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../widgets/lang_bar.dart';

class RegisterScreen extends StatefulWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;
  final Function(String) onNotificationTap;
  final VoidCallback onBackToLogin;
  final VoidCallback onProceedToNextStep;

  // Controllers
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;
  
  // Date selection states
  final String selectedCalendar;
  final int selectedYear;
  final int selectedMonth;
  final int selectedDay;
  final String ageResultText;
  final String birthdayWishText;
  final bool showBirthdayWish;
  final VoidCallback onDatePickerTap;
  final Function(int) formatNumber;

  const RegisterScreen({
    Key? key,
    required this.currentLang,
    required this.onLanguageChanged,
    required this.onNotificationTap,
    required this.onBackToLogin,
    required this.onProceedToNextStep,
    required this.firstNameController,
    required this.middleNameController,
    required this.lastNameController,
    required this.selectedCalendar,
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedDay,
    required this.ageResultText,
    required this.birthdayWishText,
    required this.showBirthdayWish,
    required this.onDatePickerTap,
    required this.formatNumber,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(AppStrings.get('registerAppBar', widget.currentLang), style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToLogin,
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
                  AppStrings.get('registerTitle', widget.currentLang),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: widget.firstNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('firstName', widget.currentLang),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.middleNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('middleName', widget.currentLang),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.lastNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('lastName', widget.currentLang),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: widget.onDatePickerTap,
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: (widget.selectedCalendar == 'AD' || widget.currentLang == 'English')
                          ? '${AppStrings.get('dob', widget.currentLang)} (AD) : ${widget.formatNumber(widget.selectedYear)}-${widget.formatNumber(widget.selectedMonth)}-${widget.formatNumber(widget.selectedDay)}'
                          : '${AppStrings.get('dob', widget.currentLang)} (${widget.selectedCalendar}) : ${widget.formatNumber(widget.selectedYear)}-${widget.formatNumber(widget.selectedMonth)}-${widget.formatNumber(widget.selectedDay)}',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              if (widget.ageResultText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.ageResultText,
                  style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                ),
              ],
              if (widget.birthdayWishText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.birthdayWishText,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.showBirthdayWish ? Colors.pink[700] : Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: widget.onProceedToNextStep,
                  child: Text(
                    AppStrings.get('nextButton', widget.currentLang),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: widget.onBackToLogin,
                  child: Text(
                    AppStrings.get('hasAccount', widget.currentLang),
                    style: const TextStyle(color: Colors.purple, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: LanguageBar(
                  currentLang: widget.currentLang,
                  onLanguageChanged: widget.onLanguageChanged,
                  onNotificationTap: widget.onNotificationTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// पात्रो वा मिति छनौट गर्ने साझा विजेट
class CalendarPickerWidget extends StatelessWidget {
  final String selectedDate;
  final VoidCallback onCalendarTap;

  const CalendarPickerWidget({
    Key? key,
    required this.selectedDate,
    required this.onCalendarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCalendarTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              selectedDate.isEmpty ? 'मिति छान्नुहोस्' : selectedDate,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

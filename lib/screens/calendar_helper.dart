import 'package:intl/intl.dart';

class CalendarHelper {
  // हालको AD (अंग्रेजी) मिति प्राप्त गर्ने
  static DateTime getTodayAD() {
    return DateTime.now();
  }

  // विभिन्न क्यालेन्डर (वि.सं., ने.सं., हिजरी, AD) लाई AD मा रूपान्तरण गर्ने सामान्य लजिक
  static DateTime convertToAD(int year, int month, int day, String calendarType) {
    if (calendarType == 'वि.सं.') {
      // अनुमानित वि.सं. देखि AD रूपान्तरण (करिब ५६ वर्ष ७ महिनाको भिन्नता हुन्छ)
      // उदाहरणको लागि: २०८३ बैशाख १ लाई আনুমানিক रूपमा कन्भर्ट गर्न सकिन्छ
      int adYear = year - 57;
      int adMonth = month - 3 <= 0 ? month + 9 : month - 3;
      if (month <= 3) adYear--;
      try {
        return DateTime(adYear, adMonth, day);
      } catch (_) {
        return DateTime.now();
      }
    } else if (calendarType == 'ने.सं.') {
      int adYear = year + 879;
      try {
        return DateTime(adYear, month, day);
      } catch (_) {
        return DateTime.now();
      }
    } else if (calendarType == 'هجری') {
      // इस्लामिक क्यालेन्डर अनुमानित रूपमा AD मा म्याप गर्ने
      int adYear = (year * 0.97) ~/ 1 + 622;
      try {
        return DateTime(adYear, month, day);
      } catch (_) {
        return DateTime.now();
      }
    }
    // यदि AD नै हो भने
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  // उमेर र जन्मदिनको काउन्टडाउन निकाल्ने मुख्य फंक्सन
  static Map<String, dynamic> calculateAgeAndCountdown({
    required int year,
    required int month,
    required int day,
    required String calendarType,
  }) {
    DateTime birthAD = convertToAD(year, month, day, calendarType);
    DateTime todayAD = DateTime.now();

    int ageYears = todayAD.year - birthAD.year;
    int ageMonths = todayAD.month - birthAD.month;
    int ageDays = todayAD.day - birthAD.day;

    if (ageDays < 0) {
      ageMonths--;
      // अघिल्लो महिनाको दिनहरू जोड्ने
      final prevMonth = DateTime(todayAD.year, todayAD.month, 0);
      ageDays += prevMonth.day;
    }

    if (ageMonths < 0) {
      ageYears--;
      ageMonths += 12;
    }

    if (ageYears < 0) {
      ageYears = 0;
      ageMonths = 0;
      ageDays = 0;
    }

    // अर्को जन्मदिन कहिले पर्छ हिसाब गर्ने
    DateTime nextBirthday = DateTime(todayAD.year, birthAD.month, birthAD.day);
    if (nextBirthday.isBefore(todayAD) || nextBirthday.isAtSameMomentAs(todayAD)) {
      if (nextBirthday.day == todayAD.day && nextBirthday.month == todayAD.month) {
        // आज नै जन्मदिन हो भने
        return {
          'years': ageYears,
          'months': ageMonths,
          'days': ageDays,
          'targetAge': ageYears,
          'remainingDays': 0,
          'isBirthdayToday': true,
        };
      }
      nextBirthday = DateTime(todayAD.year + 1, birthAD.month, birthAD.day);
    }

    int remainingDays = nextBirthday.difference(todayAD).inDays;
    int targetAge = ageYears + (nextBirthday.year > todayAD.year ? 1 : 0);

    return {
      'years': ageYears,
      'months': ageMonths,
      'days': ageDays,
      'targetAge': targetAge,
      'remainingDays': remainingDays,
      'isBirthdayToday': false,
    };
  }
}

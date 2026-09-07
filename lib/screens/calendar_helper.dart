import 'package:flutter/material.dart';

class CalendarHelper {
  static DateTime getTodayAD() => DateTime.now();

  static const Map<int, List<int>> _bsMonthDays = {
    2080: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2081: [31, 31, 32, 31, 31, 30, 30, 29, 30, 29, 30, 30],
    2082: [31, 31, 32, 31, 31, 30, 30, 30, 29, 29, 30, 30],
    2083: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2084: [30, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2085: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
  };

  static final DateTime _bsEpochAD = DateTime(2024, 4, 13);
  static final int _bsEpochYear = 2081;

  static List<int> getYearRange(int currentYear) {
    int startYear = currentYear - 50;
    int endYear = currentYear + 50;
    return List.generate(endYear - startYear + 1, (index) => startYear + index);
  }

  static DateTime convertBS_To_AD(int bsYear, int bsMonth, int bsDay) {
    int totalDays = 0;
    if (bsYear >= _bsEpochYear) {
      for (int y = _bsEpochYear; y < bsYear; y++) {
        List<int>? months = _bsMonthDays[y];
        if (months != null) {
          for (int m = 0; m < 12; m++) totalDays += months[m];
        }
      }
      List<int>? currentMonths = _bsMonthDays[bsYear];
      if (currentMonths != null) {
        for (int m = 0; m < bsMonth - 1; m++) totalDays += currentMonths[m];
      }
      totalDays += (bsDay - 1);
      return _bsEpochAD.add(Duration(days: totalDays));
    } else {
      for (int y = bsYear; y < _bsEpochYear; y++) {
        List<int>? months = _bsMonthDays[y];
        if (months != null) {
          for (int m = 0; m < 12; m++) totalDays += months[m];
        }
      }
      List<int>? currentMonths = _bsMonthDays[bsYear];
      if (currentMonths != null) {
        for (int m = 0; m < bsMonth - 1; m++) totalDays += currentMonths[m];
      }
      totalDays += (bsDay - 1);
      return _bsEpochAD.subtract(Duration(days: totalDays));
    }
  }

  // नेपाल संवत् (चन्द्रमामा आधारित सही लजिक - औसत २९.५३ दिन प्रति महिना)
  static DateTime convertNS_To_AD(int nsYear, int nsMonth, int nsDay) {
    int baseNsYear = 1146;
    DateTime baseAdDate = DateTime(2026, 9, 7); // ७ सेप्टेम्बर २०२६ (ने.सं. ११४६)
    
    int yearDiff = nsYear - baseNsYear;
    // ने.सं. वर्षमा करिब ३५४ दिन र महिनामा २९.५३ दिन हुन्छ
    double totalDaysOffset = (yearDiff * 354.37) + ((nsMonth - 9) * 29.53) + (nsDay - 1);
    return baseAdDate.add(Duration(days: totalDaysOffset.round()));
  }

  // हिजरी संवत् (उम्मुल कुरा / इस्लामिक चन्द्र क्यालेन्डर सही लजिक)
  static DateTime convertHijri_To_AD(int hijriYear, int hijriMonth, int hijriDay) {
    int baseHijriYear = 1448;
    int baseHijriMonth = 3; // Rabi' I
    int baseHijriDay = 25;
    DateTime baseAdDate = DateTime(2026, 9, 7); // ७ सेप्टेम्बर २०२६ = २५ रबी अल-अव्वल १४४८
    
    int yearDiff = hijriYear - baseHijriYear;
    int monthDiff = hijriMonth - baseHijriMonth;
    int dayDiff = hijriDay - baseHijriDay;
    
    // इस्लामिक वर्ष ३५४ वा ३५५ दिनको हुन्छ, महिना २९.५३ दिनको
    double totalDaysOffset = (yearDiff * 354.36) + (monthDiff * 29.53) + dayDiff;
    return baseAdDate.add(Duration(days: totalDaysOffset.round()));
  }

  static DateTime convertToAD(int year, int month, int day, String calendarType) {
    try {
      if (calendarType.contains('वि.सं.') || calendarType == 'वि.सं.') {
        return convertBS_To_AD(year, month, day);
      }
      if (calendarType.contains('ने.सं.') || calendarType == 'ने.सं.') {
        return convertNS_To_AD(year, month, day);
      }
      if (calendarType.contains('هجری') || calendarType == 'هجری') {
        return convertHijri_To_AD(year, month, day);
      }
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

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
      ageDays += DateTime(todayAD.year, todayAD.month, 0).day;
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

    DateTime nextBirthday = DateTime(todayAD.year, birthAD.month, birthAD.day);
    if (nextBirthday.isBefore(todayAD) || nextBirthday.isAtSameMomentAs(todayAD)) {
      if (nextBirthday.day == todayAD.day && nextBirthday.month == todayAD.month) {
        return {'years': ageYears, 'months': ageMonths, 'days': ageDays, 'targetAge': ageYears, 'remainingDays': 0, 'isBirthdayToday': true};
      }
      nextBirthday = DateTime(todayAD.year + 1, birthAD.month, birthAD.day);
    }

    return {
      'years': ageYears,
      'months': ageMonths,
      'days': ageDays,
      'targetAge': ageYears + (nextBirthday.year > todayAD.year ? 1 : 0),
      'remainingDays': nextBirthday.difference(todayAD).inDays,
      'isBirthdayToday': false,
    };
  }

  static String getMonthName(int month, String languageCode, {String calendarType = 'वि.सं.'}) {
    if (calendarType.contains('ने.सं.') || calendarType == 'ने.सं.') {
      const newMonths = ['कछला', 'थिला', 'पोथिला', 'सिल्ला', 'चला', 'बछला', 'तछला', 'दिल्ला', 'गुंला', 'ञला', 'चौला', 'अछला'];
      if (month >= 1 && month <= 12) return newMonths[month - 1];
    } else if (calendarType.contains('هجری') || calendarType == 'هجری') {
      const hijriMonths = ['محرم', 'صفر', 'ربیع الاول', 'ربیع الثانی', 'جمادی الاول', 'جمادی الثانی', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذوالقعدہ', 'ذوالحجہ'];
      if (month >= 1 && month <= 12) return hijriMonths[month - 1];
    }

    const monthsMap = {
      'en': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      'hi': ['जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'],
      'ne': ['बैशाख', 'जेठ', 'असार', 'साउन', 'भदौ', 'असोज', 'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फागुन', 'चैत'],
      'new': ['कछला', 'थिला', 'पोथिला', 'सिल्ला', 'चला', 'बछला', 'तछला', 'दिल्ला', 'गुंला', 'ञला', 'चौला', 'अछला'],
      'ur': ['محرم', 'صفر', 'ربیع الاول', 'ربیع الثانی', 'جمادی الاول', 'جمادی الثانی', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذوالقعدہ', 'ذوالحجہ'],
    };
    return monthsMap[languageCode]?[month - 1] ?? '';
  }
}

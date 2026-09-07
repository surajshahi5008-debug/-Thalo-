import 'package:flutter/material.dart';

class CalendarHelper {
  static DateTime getTodayAD() => DateTime.now();

  static const Map<int, List<int>> _bsMonthDays = {
    2028: [31, 31, 32, 31, 31, 30, 30, 29, 30, 29, 30, 30],
    2029: [31, 31, 32, 31, 31, 30, 30, 30, 29, 29, 30, 30],
    2030: [31, 31, 32, 31, 31, 30, 30, 30, 29, 29, 30, 30],
    2031: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2032: [30, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2033: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2034: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2035: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2036: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2037: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2038: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2039: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2040: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2041: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2042: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2043: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2044: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2045: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2046: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2047: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2048: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2049: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2050: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2051: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2052: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2053: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2054: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2055: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2056: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2057: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2058: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2059: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2060: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2061: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2062: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2063: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2064: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2065: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2066: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2067: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2068: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2069: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2070: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2071: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2072: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2073: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2074: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2075: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2076: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2077: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2078: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2079: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2080: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2081: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2082: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2083: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2084: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2085: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2086: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2087: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2088: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
    2089: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 29, 31],
    2090: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 29, 31],
  };

  static final DateTime _bsEpochAD = DateTime(2024, 4, 13);
  static final int _bsEpochYear = 2081;

  static List<int> getYearRange(int currentYear) {
    int startYear = currentYear - 110;
    int endYear = currentYear + 150;
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

  static DateTime convertNS_To_AD(int nsYear, int nsMonth, int nsDay) {
    int baseNsYear = 1144;
    DateTime baseAdDate = DateTime(2024, 11, 2);
    int yearDiff = nsYear - baseNsYear;
    int totalDaysOffset = (yearDiff * 365) + ((nsMonth - 1) * 30) + (nsDay - 1);
    return baseAdDate.add(Duration(days: totalDaysOffset));
  }

  static DateTime convertHijri_To_AD(int hijriYear, int hijriMonth, int hijriDay) {
    int jd = ((11 * hijriYear + 3) ~/ 30) + (354 * hijriYear) + (30 * hijriMonth) - 
             ((hijriMonth - 1) ~/ 2) + hijriDay + 1948440 - 385;
    int l = jd + 68569;
    int n = (4 * l) ~/ 146097;
    l = l - ((146097 * n + 3) ~/ 4);
    int i = (4000 * (l + 1)) ~/ 1461001;
    l = l - ((1461 * i) ~/ 4) + 31;
    int j = (80 * l) ~/ 2447;
    int d = l - ((2447 * j) ~/ 80);
    l = j ~/ 11;
    int m = j + 2 - (12 * l);
    int y = 100 * (n - 49) + i + l;
    return DateTime(y, m, d);
  }

  static DateTime convertToAD(int year, int month, int day, String calendarType) {
    try {
      if (calendarType == 'वि.सं.') return convertBS_To_AD(year, month, day);
      if (calendarType == 'ने.सं.') return convertNS_To_AD(year, month, day);
      if (calendarType == 'هجری') return convertHijri_To_AD(year, month, day);
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

  static String getMonthName(int month, String languageCode) {
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

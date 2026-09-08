import 'package:flutter/material.dart';

class CalendarHelper {
  static DateTime getTodayAD() => DateTime.now();

  static List<int> getYearRange(int currentYear) {
    int startYear = currentYear - 50;
    int endYear = currentYear + 50;
    return List.generate(endYear - startYear + 1, (index) => startYear + index);
  }

  // विक्रम संवत् लाई AD मा बदल्ने सही लजिक (आधार: ८ सेप्टेम्बर २०२६ = २०८३ भदौ २३)
  static DateTime convertBS_To_AD(int bsYear, int bsMonth, int bsDay) {
    DateTime baseAd = DateTime(2026, 9, 8);
    int baseBsYear = 2083;
    int baseBsMonth = 5; // भदौ
    int baseBsDay = 23;

    int yearDiff = bsYear - baseBsYear;
    int monthDiff = bsMonth - baseBsMonth;
    int dayDiff = bsDay - baseBsDay;

    int totalDaysOffset = (yearDiff * 365) + (monthDiff * 30) + dayDiff;
    return baseAd.add(Duration(days: totalDaysOffset));
  }

  // नेपाल संवत् लाई AD मा बदल्ने सही लजिक (आधार: ८ सेप्टेम्बर २०२६ = ११४६ गुंला २)
  static DateTime convertNS_To_AD(int nsYear, int nsMonth, int nsDay) {
    DateTime baseAd = DateTime(2026, 9, 8);
    int baseNsYear = 1146;
    int baseNsMonth = 9; // गुंला
    int baseNsDay = 2;

    int yearDiff = nsYear - baseNsYear;
    int monthDiff = nsMonth - baseNsMonth;
    int dayDiff = nsDay - baseNsDay;

    double totalDaysOffset = (yearDiff * 354.37) + (monthDiff * 29.53) + dayDiff;
    return baseAd.add(Duration(days: totalDaysOffset.round()));
  }

  // हिजरी संवत् लाई AD मा बदल्ने सही लजिक (आधार: ८ सेप्टेम्बर २०२६ = १४४८ रबी अल-अव्वल २६)
  static DateTime convertHijri_To_AD(int hijriYear, int hijriMonth, int hijriDay) {
    DateTime baseAd = DateTime(2026, 9, 8);
    int baseHijriYear = 1448;
    int baseHijriMonth = 3; // Rabi' I
    int baseHijriDay = 26;

    int yearDiff = hijriYear - baseHijriYear;
    int monthDiff = hijriMonth - baseHijriMonth;
    int dayDiff = hijriDay - baseHijriDay;

    double totalDaysOffset = (yearDiff * 354.36) + (monthDiff * 29.53) + dayDiff;
    return baseAd.add(Duration(days: totalDaysOffset.round()));
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

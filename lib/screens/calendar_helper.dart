import 'package:flutter/material.dart';

class EnglishCalendar {
  static const List<String> shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> fullMonthsHindi = [
    'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 
    'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
  ];

  static String getMonthName(int month, String languageCode) {
    if (month < 1 || month > 12) return '';
    if (languageCode == 'hi') {
      return fullMonthsHindi[month - 1];
    }
    return shortMonths[month - 1];
  }

  static DateTime toAD(int year, int month, int day) {
    return DateTime(year, month, day);
  }
}

class CalendarHelper {
  static DateTime getTodayAD() => DateTime.now();

  static List<int> getYearRange(int currentYear) {
    int startYear = currentYear - 50;
    int endYear = currentYear + 50;
    return List.generate(endYear - startYear + 1, (index) => startYear + index);
  }

  static DateTime convertBS_To_AD(int bsYear, int bsMonth, int bsDay) {
    DateTime baseAd = DateTime(2026, 9, 8);
    int baseBsYear = 2083;
    int baseBsMonth = 5; 
    int baseBsDay = 23;

    int yearDiff = bsYear - baseBsYear;
    int monthDiff = bsMonth - baseBsMonth;
    int dayDiff = bsDay - baseBsDay;

    int totalDaysOffset = (yearDiff * 365) + (monthDiff * 30) + dayDiff;
    return baseAd.add(Duration(days: totalDaysOffset));
  }

  static DateTime convertNS_To_AD(int nsYear, int nsMonth, int nsDay) {
    DateTime baseAd = DateTime(2026, 9, 8);
    int baseNsYear = 1146;
    int baseNsMonth = 9; 
    int baseNsDay = 2;

    int yearDiff = nsYear - baseNsYear;
    int monthDiff = nsMonth - baseNsMonth;
    int dayDiff = nsDay - baseNsDay;

    double totalDaysOffset = (yearDiff * 354.37) + (monthDiff * 29.53) + dayDiff;
    return baseAd.add(Duration(days: totalDaysOffset.round()));
  }

  static DateTime convertHijri_To_AD(int hijriYear, int hijriMonth, int hijriDay) {
    DateTime baseAd = DateTime(2026, 9, 8);
    int baseHijriYear = 1448;
    int baseHijriMonth = 3; 
    int baseHijriDay = 26;

    int yearDiff = hijriYear - baseHijriYear;
    int monthDiff = hijriMonth - baseHijriMonth;
    int dayDiff = hijriDay - baseHijriDay;

    double totalDaysOffset = (yearDiff * 354.36) + (monthDiff * 29.53) + dayDiff;
    return baseAd.add(Duration(days: totalDaysOffset.round()));
  }

  static DateTime convertToAD(int year, int month, int day, String calendarType, {String languageCode = 'ne'}) {
    try {
      // अंग्रेजी वा हिन्दी भाषा छ भने सधैं AD मात्र प्रयोग हुने (अनिवार्य नियम)
      if (languageCode == 'en' || languageCode == 'hi') {
        return EnglishCalendar.toAD(year, month, day);
      }

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
    String languageCode = 'ne',
  }) {
    DateTime birthAD = convertToAD(year, month, day, calendarType, languageCode: languageCode);
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
    if (languageCode == 'en' || languageCode == 'hi') {
      return EnglishCalendar.getMonthName(month, languageCode);
    }

    if (calendarType.contains('ने.सं.') || calendarType == 'ने.सं.') {
      const newMonths = ['कछला', 'थिला', 'पोथिला', 'सिल्ला', 'चला', 'bछला', 'तछला', 'दिल्ला', 'गुंला', 'ञला', 'चौला', 'अछला'];
      if (month >= 1 && month <= 12) return newMonths[month - 1];
    } else if (calendarType.contains('هجری') || calendarType == 'هجری') {
      const hijriMonths = ['محرم', 'صفر', 'ربیع الاول', 'ربیع الثانی', 'جمادی الاول', 'جمادی الثانی', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذوالقعدہ', 'ذوالحجہ'];
      if (month >= 1 && month <= 12) return hijriMonths[month - 1];
    } else if (calendarType.contains('वि.सं.') || calendarType == 'वि.सं.') {
      const bsMonths = ['बैशाख', 'जेठ', 'असार', 'साउन', 'भदौ', 'असोज', 'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फागुन', 'चैत'];
      if (month >= 1 && month <= 12) return bsMonths[month - 1];
    }

    const monthsMap = {
      'ne': ['बैशाख', 'जेठ', 'असार', 'साउन', 'भदौ', 'असोज', 'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फागुन', 'चैत'],
      'new': ['कछला', 'थिला', 'पोथिला', 'सिल्ला', 'चला', 'बछला', 'तछला', 'दिल्ला', 'गुंला', 'ञला', 'चौला', 'अछला'],
      'ur': ['محرم', 'صفر', 'ربیع الاول', 'ربیع الثانی', 'جمادی الاول', 'جمادی الثانی', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذوالقعدہ', 'ذوالحجہ'],
    };
    return monthsMap[languageCode]?[month - 1] ?? '';
  }

  // भाषा अनुसार UI का टेक्स्टहरू अनुवाद गर्ने फङ्सन
  static String getLocalizedText(String key, String lang) {
    final Map<String, Map<String, String>> localizedTexts = {
      'ad_base': {
        'ne': 'AD आधारमा',
        'hi': 'AD आधार पर',
        'en': 'Based on AD',
        'ur': 'بنیاد پر AD',
      },
      'age_text': {
        'ne': 'उमेर',
        'hi': 'आयु',
        'en': 'Age',
        'ur': 'عمر',
      },
      'years': {
        'ne': 'वर्ष',
        'hi': 'वर्ष',
        'en': 'years',
        'en_unit': 'years',
        'ur': 'سال',
      },
      'months': {
        'ne': 'महिना',
        'hi': 'महीने',
        'en': 'months',
        'ur': 'مہینے',
      },
      'days': {
        'ne': 'दिन',
        'hi': 'दिन',
        'en': 'days',
        'ur': 'دن',
      },
      'birthday_today': {
        'ne': 'तपाईंलाई जन्मदिनको शुभकामना! 🎂',
        'hi': 'आपको जन्मदिन की शुभकामनाएँ! 🎂',
        'en': 'Happy Birthday! 🎂',
        'ur': 'سالگرہ مبارک ہو! 🎂',
      },
      'birthday_countdown': {
        'ne': 'तपाईंको जन्मदिन आउन बाँकी दिन',
        'hi': 'आपके जन्मदिन में बाकी दिन',
        'en': 'Days remaining for your birthday',
        'ur': 'آپ کی سالگرہ میں باقی دن',
      },
    };

    return localizedTexts[key]?[lang] ?? localizedTexts[key]?['ne'] ?? '';
  }
}

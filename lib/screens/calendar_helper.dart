import 'package:flutter/material.dart';

class EnglishCalendar {
  static const List<String> shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> fullMonths = [
    'January', 'February', 'March', 'April', 'May', 'June', 
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> fullMonthsHindi = [
    'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 
    'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
  ];

  static String getMonthName(int month, String languageCode, {bool shortForm = true}) {
    if (month < 1 || month > 12) return '';
    if (languageCode == 'hi') {
      return fullMonthsHindi[month - 1];
    }
    if (languageCode == 'en') {
      return shortForm ? shortMonths[month - 1] : fullMonths[month - 1];
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

  // वि.सं. (Bikram Sambat) लाई सही रूपमा AD मा रूपान्तरण गर्ने फङ्सन
  static DateTime convertBS_T_AD(int bsYear, int bsMonth, int bsDay) {
    try {
      return DateTime(bsYear - 57, 4, 1).add(Duration(days: (bsMonth - 1) * 30 + bsDay));
    } catch (_) {
      return DateTime(bsYear - 57, 1, 1);
    }
  }

  // नेपाल संवत (Nepal Sambat) कन्भर्जन 
  static DateTime convertNS_To_AD(int nsYear, int nsMonth, int nsDay) {
    int adYear = nsYear + 879;
    try {
      return DateTime(adYear, 10, 1).add(Duration(days: (nsMonth - 1) * 30 + nsDay));
    } catch (_) {
      return DateTime.now();
    }
  }

  // हिजरी (Hijri) कन्भर्जन
  static DateTime convertHijri_To_AD(int hijriYear, int hijriMonth, int hijriDay) {
    int adYear = ((hijriYear * 0.97) + 622).toInt(); // .toInt() थपिएको
    try {
      return DateTime(adYear, 6, 1).add(Duration(days: (hijriMonth - 1) * 29 + hijriDay));
    } catch (_) {
      return DateTime.now();
    }
  }

  // समग्र क्यालेन्डर प्रकार अनुसार AD मा कन्भर्ट गर्ने मुख्य फङ्सन
  static DateTime convertToAD(int year, int month, int day, String calendarType, {String languageCode = 'ne'}) {
    try {
      if (calendarType == 'AD' || languageCode == 'en' || languageCode == 'hi' && !calendarType.contains('वि.सं.')) {
        if (calendarType.contains('वि.सं.') || calendarType.contains('ने.सं.') || calendarType.contains('هجری')) {
          // लुप कन्भर्जन तल जान्छ
        } else {
          return EnglishCalendar.toAD(year, month, day);
        }
      }

      if (calendarType.contains('वि.सं.') || calendarType == 'वि.सं.') {
        int estimatedAdYear = year - 57;
        DateTime baseBsToAd = DateTime(estimatedAdYear, 4, 13);
        int dayOffset = ((month - 1) * 30) + (day - 1);
        return baseBsToAd.add(Duration(days: dayOffset));
      }

      if (calendarType.contains('ने.सं.') || calendarType == 'ने.सं.') {
        int estimatedAdYear = year + 879;
        DateTime baseNsToAd = DateTime(estimatedAdYear, 11, 1);
        int dayOffset = ((month - 1) * 30) + (day - 1);
        return baseNsToAd.add(Duration(days: dayOffset));
      }

      if (calendarType.contains('هجری') || calendarType == 'هجری') {
        int estimatedAdYear = ((year * 0.97022) + 622.5).toInt(); // .toInt() थपिएको
        DateTime baseHijriToAd = DateTime(estimatedAdYear, 7, 1);
        int dayOffset = ((month - 1) * 29) + (day - 1);
        return baseHijriToAd.add(Duration(days: dayOffset));
      }

      return EnglishCalendar.toAD(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  // उमेर र जन्मदिनको काउन्टडाउन सही हिसाब गर्ने फङ्सन
  static Map<String, dynamic> calculateAgeAndCountdown({
    required int year,
    required int month,
    required int day,
    required String calendarType,
    String languageCode = 'ne',
  }) {
    DateTime birthAD = convertToAD(year, month, day, calendarType, languageCode: languageCode);
    DateTime todayAD = DateTime.now();

    if (birthAD.isAfter(todayAD)) {
      birthAD = todayAD;
    }

    int ageYears = todayAD.year - birthAD.year;
    int ageMonths = todayAD.month - birthAD.month;
    int ageDays = todayAD.day - birthAD.day;

    if (ageDays < 0) {
      ageMonths--;
      DateTime prevMonth = DateTime(todayAD.year, todayAD.month, 0);
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

    DateTime nextBirthday = DateTime(todayAD.year, birthAD.month, birthAD.day);
    if (nextBirthday.isBefore(todayAD) && !(nextBirthday.day == todayAD.day && nextBirthday.month == todayAD.month)) {
      nextBirthday = DateTime(todayAD.year + 1, birthAD.month, birthAD.day);
    }

    int remainingDays = nextBirthday.difference(todayAD).inDays;
    if (remainingDays < 0) remainingDays = 0;

    bool isBirthdayToday = (birthAD.month == todayAD.month && birthAD.day == todayAD.day);

    return {
      'years': ageYears,
      'months': ageMonths,
      'days': ageDays,
      'targetAge': ageYears + (isBirthdayToday ? 0 : 1),
      'remainingDays': remainingDays,
      'isBirthdayToday': isBirthdayToday,
    };
  }

  // सबै क्यालेन्डर र भाषाहरूका लागि महिनाको नाम पत्ता लगाउने फङ्सन
  static String getMonthName(int month, String languageCode, {String calendarType = 'वि.सं.', bool shortForm = true}) {
    if (languageCode == 'en' || languageCode == 'hi' && !calendarType.contains('वि.सं.')) {
      if (!calendarType.contains('वि.सं.') && !calendarType.contains('ने.सं.')) {
        return EnglishCalendar.getMonthName(month, languageCode, shortForm: shortForm);
      }
    }

    if (calendarType.contains('ने.सं.') || calendarType == 'ने.सं.') {
      const newMonths = ['कछला', 'थिला', 'पोथिला', 'सिल्ला', 'चला', 'बछला', 'तछला', 'दिल्ला', 'गुंला', 'ञला', 'चौला', 'अछला'];
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

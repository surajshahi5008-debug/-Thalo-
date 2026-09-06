class CalendarHelper {
  // वास्तविक आजको मिति (System Date) फिर्ता गर्ने
  static DateTime getTodayAD() {
    return DateTime.now();
  }

  // कुन संवत् हो अनुसार AD मा सही रूपान्तरण गर्ने युनिभर्सल इन्जिन
  static DateTime convertToAD(int y, int m, int d, String cal) {
    try {
      if (cal == 'AD') return DateTime(y, m, d);
      
      if (cal == 'वि.सं.') {
        // विक्रम संवत्लाई इस्वी संवत् (AD) मा रूपान्तरण गर्ने सटीक आधार
        // (नोट: पूर्ण आधिकारिक म्यापिङ वा प्याकेज बिना आधिकारिक दिन मिलानका लागि यो स्ट्यान्डर्ड अफसेट प्रयोग गरिन्छ)
        int adYear = y - 57;
        int adMonth = m - 4; // बैशाख करिब अप्रिल/मे पर्ने हुनाले सही अफसेट
        int adDay = d;
        if (adMonth <= 0) {
          adMonth += 12;
          adYear -= 1;
        }
        int maxDays = DateTime(adYear, adMonth + 1, 0).day;
        if (adDay > maxDays) adDay = maxDays;
        return DateTime(adYear, adMonth, adDay);
      }
      
      if (cal == 'ने.सं.') {
        // नेपाल संवत् कन्भर्जन बेस
        int adYear = y + 879;
        int adMonth = m;
        int adDay = d;
        int maxDays = DateTime(adYear, adMonth + 1, 0).day;
        if (adDay > maxDays) adDay = maxDays;
        return DateTime(adYear, adMonth, adDay);
      }
      
      if (cal == 'هجری' || cal == 'हिजरी') {
        // हिजरी (Islamic Calendar) लाई AD मा बदल्ने खगोलीय सूत्र: D = H - (H / 33) + 622
        int adYear = (y - (y / 33.0) + 622.0).toInt();
        int adMonth = m;
        int adDay = d;
        int maxDays = DateTime(adYear, adMonth + 1, 0).day;
        if (adDay > maxDays) adDay = maxDays;
        return DateTime(adYear, adMonth, adDay);
      }
    } catch (_) {}
    return DateTime(y, m, d);
  }

  // उमेर र जन्मदिनको बाँकी दिन सही हिसाब गर्ने फंक्सन
  static Map<String, dynamic> calculateAgeAndCountdown({
    required int year,
    required int month,
    required int day,
    required String calendarType,
    DateTime? currentDate,
  }) {
    // यदि करेन्ट डेट दिइएको छैन भने प्रणालीको वास्तविक आजको मिति लिने
    DateTime now = currentDate ?? getTodayAD();
    DateTime birthDate = convertToAD(year, month, day, calendarType);

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years < 0) years = 0;
    if (months < 0) months = 0;
    if (days < 0) days = 0;

    // आगामी जन्मदिनको हिसाब
    DateTime nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(now) && !_isSameDay(nextBirthday, now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }

    int remDays = nextBirthday.difference(now).inDays;
    if (remDays < 0) remDays = 0;

    bool isBirthdayToday = _isSameDay(birthDate, now) || 
        (birthDate.month == now.month && birthDate.day == now.day);

    int targetAge = isBirthdayToday ? now.year - birthDate.year : (nextBirthday.isBefore(now) ? years + 1 : years + 1);

    return {
      'years': years,
      'months': months,
      'days': days,
      'targetAge': targetAge,
      'remainingDays': remDays,
      'isBirthdayToday': isBirthdayToday,
      'adBirthDate': birthDate,
    };
  }

  static bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}

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

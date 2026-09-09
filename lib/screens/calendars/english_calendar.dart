class EnglishCalendar {
  // अङ्ग्रेजी भाषाका लागि महिनाको नाम (संक्षिप्त रूप / Short form)
  static const List<String> shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  // हिन्दी भाषाका लागि महिनाको नाम (पूर्ण रूप / Full form)
  static const List<String> fullMonthsHindi = [
    'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 
    'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
  ];

  // भाषा अनुसार महिनाको नाम फिर्ता गर्ने फङ्सन
  static String getMonthName(int month, String languageCode) {
    if (month < 1 || month > 12) return '';
    if (languageCode == 'hi') {
      return fullMonthsHindi[month - 1];
    }
    // पूर्वनिर्धारित अङ्ग्रेजीका लागि संक्षिप्त नाम
    return shortMonths[month - 1];
  }

  // AD मिति ह्यान्डलिङ
  static DateTime toAD(int year, int month, int day) {
    return DateTime(year, month, day);
  }
}

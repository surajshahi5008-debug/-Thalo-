import 'calendar_enums.dart';

/// भाषा र क्यालेन्डर प्रणालीसँग सम्बन्धित सबै localization डेटा।
class CalendarLocalization {
  CalendarLocalization._();

  static const Map<AppLanguage, List<CalendarSystem>> availableCalendars = {
    AppLanguage.english: [CalendarSystem.ad],
    AppLanguage.hindi: [CalendarSystem.ad],
    AppLanguage.nepali: [CalendarSystem.bs, CalendarSystem.ad],
    AppLanguage.newari: [CalendarSystem.ns, CalendarSystem.ad],
    AppLanguage.urdu: [CalendarSystem.hijri, CalendarSystem.ad],
  };

  static const Map<AppLanguage, CalendarSystem> defaultCalendar = {
    AppLanguage.english: CalendarSystem.ad,
    AppLanguage.hindi: CalendarSystem.ad,
    AppLanguage.nepali: CalendarSystem.bs,
    AppLanguage.newari: CalendarSystem.ns,
    AppLanguage.urdu: CalendarSystem.hijri,
  };

  static const Map<AppLanguage, TextDirection> textDirectionFor = {
    AppLanguage.english: TextDirection.ltr,
    AppLanguage.hindi: TextDirection.ltr,
    AppLanguage.nepali: TextDirection.ltr,
    AppLanguage.newari: TextDirection.ltr,
    AppLanguage.urdu: TextDirection.rtl,
  };

  static const Map<CalendarSystem, String> calendarLabel = {
    CalendarSystem.ad: 'AD',
    CalendarSystem.bs: 'वि.सं.',
    CalendarSystem.ns: 'ने.सं.',
    CalendarSystem.hijri: 'ہجری',
  };

  static const List<String> _adShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _hindiFull = [
    'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
    'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर',
  ];

  static const List<String> _bsMonths = [
    'बैशाख', 'जेठ', 'असार', 'साउन', 'भदौ', 'असोज',
    'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फागुन', 'चैत',
  ];

  static const List<String> _nsMonths = [
    'कछला', 'थिंला', 'पोहेला', 'सिल्ला', 'चिल्ला', 'चौला',
    'बछला', 'तछला', 'दिल्ला', 'गुंला', 'ञला', 'कौला',
  ];

  static const List<String> _hijriMonths = [
    'محرم', 'صفر', 'ربیع الاول', 'ربیع الثانی', 'جمادی الاول', 'جمادی الثانی',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذوالقعدہ', 'ذوالحجہ',
  ];

  static String monthName({
    required CalendarSystem system,
    required int month,
    required AppLanguage language,
  }) {
    if (month < 1 || month > 12) return '';
    switch (system) {
      case CalendarSystem.ad:
        return language == AppLanguage.hindi ? _hindiFull[month - 1] : _adShort[month - 1];
      case CalendarSystem.bs:
        return _bsMonths[month - 1];
      case CalendarSystem.ns:
        return _nsMonths[month - 1];
      case CalendarSystem.hijri:
        return _hijriMonths[month - 1];
    }
  }

  static const Map<String, Map<AppLanguage, String>> _labels = {
    'age': {
      AppLanguage.nepali: 'उमेर',
      AppLanguage.hindi: 'आयु',
      AppLanguage.english: 'Age',
      AppLanguage.urdu: 'عمر',
      AppLanguage.newari: 'उमेर',
    },
    'age_text': {
      AppLanguage.nepali: 'उमेर',
      AppLanguage.hindi: 'आयु',
      AppLanguage.english: 'Age',
      AppLanguage.urdu: 'عمر',
      AppLanguage.newari: 'उमेर',
    },
    'years': {
      AppLanguage.nepali: 'वर्ष',
      AppLanguage.hindi: 'वर्ष',
      AppLanguage.english: 'years',
      AppLanguage.urdu: 'سال',
      AppLanguage.newari: 'दँ',
    },
    'months': {
      AppLanguage.nepali: 'महिना',
      AppLanguage.hindi: 'महीने',
      AppLanguage.english: 'months',
      AppLanguage.urdu: 'مہینے',
      AppLanguage.newari: 'ला',
    },
    'days': {
      AppLanguage.nepali: 'दिन',
      AppLanguage.hindi: 'दिन',
      AppLanguage.english: 'days',
      AppLanguage.urdu: 'دن',
      AppLanguage.newari: 'न्ह्य',
    },
    'ad_base': {
      AppLanguage.nepali: 'AD आधारमा',
      AppLanguage.hindi: 'AD आधार पर',
      AppLanguage.english: 'Based on AD',
      AppLanguage.urdu: 'AD کی بنیاد پر',
      AppLanguage.newari: 'AD आधारमा',
    },
    'birthday_today': {
      AppLanguage.nepali: 'आज तपाईंको जन्मदिन हो!',
      AppLanguage.hindi: 'आज आपका जन्मदिन है!',
      AppLanguage.english: 'It\'s your birthday today!',
      AppLanguage.urdu: 'آج آپ کی سالگرہ ہے!',
      AppLanguage.newari: 'थ्व न्हिं छिगु जन्मदिन खः!',
    },
    'birthday_countdown': {
      AppLanguage.nepali: 'जन्मदिन बाँकी:',
      AppLanguage.hindi: 'जन्मदिन शेष:',
      AppLanguage.english: 'Days until birthday:',
      AppLanguage.urdu: 'سالگرہ تک باقی دن:',
      AppLanguage.newari: 'जन्मदिन बाँकी:',
    },
    'choose_date': {
      AppLanguage.nepali: 'मिति छान्नुहोस्',
      AppLanguage.hindi: 'तारीख़ चुनें',
      AppLanguage.english: 'Choose Date',
      AppLanguage.urdu: 'تاریخ منتخب کریں',
      AppLanguage.newari: 'मिति छान्नुहोस्',
    },
  };

  static String label(String key, AppLanguage language) {
    return _labels[key]?[language] ?? _labels[key]?[AppLanguage.english] ?? '';
  }
}

import 'calendar_enums.dart';

/// साधारण अंग्रेजी (Latin) अंकलाई अन्य लिपिका अंकमा बदल्ने युटिलिटी।
///
/// नोट (Newa अंकको बारेमा): Newa (Prachalit) डिजिटहरू Unicode ब्लक
/// U+11450–U+11459 मा वास्तविक रूपमा अवस्थित छन्, तर हालसम्म धेरैजसो
/// डिभाइस/फन्टले यसलाई सपोर्ट गर्दैनन् (मुख्यतः Noto Sans Newa फन्टले मात्र
/// राम्ररी देखाउँछ)। एपमा यो फन्ट बन्डल नगरे यी अंकहरू खाली बाकस (tofu)
/// देखिन सक्छ। प्रयोग गर्नुअघि फन्ट टेस्ट गर्नुहोस्।
class NumeralConverter {
  NumeralConverter._();

  static const Map<NumeralScript, List<String>> _digitMaps = {
    NumeralScript.latin: [
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ],
    NumeralScript.devanagari: [
      '०', '१', '२', '३', '४', '५', '६', '७', '८', '९',
    ],
    NumeralScript.newa: [
      '𑑐', '𑑑', '𑑒', '𑑓', '𑑔', '𑑕', '𑑖', '𑑗', '𑑘', '𑑙',
    ],
    NumeralScript.easternArabicIndic: [
      '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹',
    ],
  };

  static String convert(int number, NumeralScript script) {
    final digits = _digitMaps[script]!;
    final isNegative = number < 0;
    final str = number.abs().toString();
    final converted = str.split('').map((ch) {
      final d = int.tryParse(ch);
      return d == null ? ch : digits[d];
    }).join();
    return isNegative ? '-$converted' : converted;
  }

  static NumeralScript scriptFor(CalendarSystem system, AppLanguage language) {
    if (system == CalendarSystem.ad) return NumeralScript.latin;
    switch (language) {
      case AppLanguage.nepali:
        return NumeralScript.devanagari;
      case AppLanguage.newari:
        return NumeralScript.newa;
      case AppLanguage.urdu:
        return NumeralScript.easternArabicIndic;
      case AppLanguage.english:
      case AppLanguage.hindi:
        return NumeralScript.latin;
    }
  }
}

import '../calendar_enums.dart';
import '../calendar_localization.dart';
import '../numeral_converter.dart';
import '../date_converters.dart';

/// UI (जन्ममिति पिकर) ले प्रयोग गर्ने मुख्य facade।
class CalendarHelper {
  CalendarHelper._();

  static List<CalendarSystem> tabsFor(AppLanguage language) =>
      CalendarLocalization.availableCalendars[language]!;

  static CalendarSystem defaultTabFor(AppLanguage language) =>
      CalendarLocalization.defaultCalendar[language]!;

  static TextDirection textDirectionFor(AppLanguage language) =>
      CalendarLocalization.textDirectionFor[language]!;

  static String calendarLabel(CalendarSystem system) =>
      CalendarLocalization.calendarLabel[system]!;

  static String monthName({
    required CalendarSystem system,
    required int month,
    required AppLanguage language,
  }) =>
      CalendarLocalization.monthName(system: system, month: month, language: language);

  static String formatNumber({
    required int number,
    required CalendarSystem system,
    required AppLanguage language,
  }) {
    final script = NumeralConverter.scriptFor(system, language);
    return NumeralConverter.convert(number, script);
  }

  static String uiLabel(String key, AppLanguage language) =>
      CalendarLocalization.label(key, language);

  /// छानिएको मिति (जुनसुकै क्यालेन्डरमा भए पनि) लाई AD मा बदल्ने।
  static AdDate toAd({
    required CalendarSystem system,
    required int year,
    required int month,
    required int day,
  }) {
    switch (system) {
      case CalendarSystem.ad:
        return AdDate(year, month, day);
      case CalendarSystem.bs:
        return DateConverters.bsToAd(year, month, day);
      case CalendarSystem.ns:
        return DateConverters.nsToAd(year, month, day);
      case CalendarSystem.hijri:
        return DateConverters.hijriToAd(year, month, day);
    }
  }

  /// AD मितिलाई तोकिएको क्यालेन्डर प्रणालीमा बदल्ने (उल्टो दिशा)।
  static CalendarDate fromAd(CalendarSystem system, AdDate ad) {
    final adDateTime = ad.toDateTime();
    switch (system) {
      case CalendarSystem.ad:
        return CalendarDate(ad.year, ad.month, ad.day);
      case CalendarSystem.bs:
        return DateConverters.adToBs(adDateTime);
      case CalendarSystem.ns:
        return DateConverters.adToNs(adDateTime);
      case CalendarSystem.hijri:
        return DateConverters.adToHijri(adDateTime);
    }
  }

  /// उमेर र जन्मदिन काउन्टडाउन।
  static Map<String, dynamic> calculateAgeAndCountdown(AdDate birth) {
    final birthAD = birth.toDateTime();

    // समय (घण्टा/मिनेट) हटाएर शुद्ध मिति (midnight) मा ल्याइयो —
    // नत्र दिनको जुन बेला app खोलियो सोही अनुसार countdown १ दिनले तलमाथि हुन्थ्यो।
    final now = DateTime.now();
    final todayAD = DateTime(now.year, now.month, now.day);

    final effectiveBirth = birthAD.isAfter(todayAD) ? todayAD : birthAD;

    int ageYears = todayAD.year - effectiveBirth.year;
    int ageMonths = todayAD.month - effectiveBirth.month;
    int ageDays = todayAD.day - effectiveBirth.day;

    if (ageDays < 0) {
      ageMonths--;
      final prevMonth = DateTime(todayAD.year, todayAD.month, 0);
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

    DateTime nextBirthday = DateTime(todayAD.year, effectiveBirth.month, effectiveBirth.day);
    final isBirthdayToday =
        effectiveBirth.month == todayAD.month && effectiveBirth.day == todayAD.day;
    if (nextBirthday.isBefore(todayAD) && !isBirthdayToday) {
      nextBirthday = DateTime(todayAD.year + 1, effectiveBirth.month, effectiveBirth.day);
    }

    final remainingDays = nextBirthday.difference(todayAD).inDays.clamp(0, 1 << 30);

    return {
      'years': ageYears,
      'months': ageMonths,
      'days': ageDays,
      'targetAge': ageYears + (isBirthdayToday ? 0 : 1),
      'remainingDays': remainingDays,
      'isBirthdayToday': isBirthdayToday,
    };
  }
}

import 'package:nepali_utils/nepali_utils.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:tithi_engine/tithi_engine.dart';
import 'package:tithi_engine/data/all.dart';

/// AD मितिलाई साधारण रूपमा बोक्ने structure।
class AdDate {
  final int year;
  final int month;
  final int day;
  const AdDate(this.year, this.month, this.day);

  DateTime toDateTime() => DateTime(year, month, day);

  @override
  String toString() => '$year-$month-$day';
}

/// कुनै पनि क्यालेन्डरको वर्ष/महिना/गते बोक्ने साधारण structure।
class CalendarDate {
  final int year;
  final int month;
  final int day;
  const CalendarDate(this.year, this.month, this.day);
}

class DateConverters {
  DateConverters._();

  // -----------------------------------------------------------------
  // विक्रम सम्वत (BS) ⇄ AD — nepali_utils प्रयोग गरेर
  // -----------------------------------------------------------------
  static AdDate bsToAd(int bsYear, int bsMonth, int bsDay) {
    final nepaliDate = NepaliDateTime(bsYear, bsMonth, bsDay);
    final ad = nepaliDate.toDateTime();
    return AdDate(ad.year, ad.month, ad.day);
  }

  static CalendarDate adToBs(DateTime adDate) {
    final nd = adDate.toNepaliDateTime();
    return CalendarDate(nd.year, nd.month, nd.day);
  }

  // -----------------------------------------------------------------
  // हिजरी ⇄ AD — hijri प्याकेज प्रयोग गरेर
  // -----------------------------------------------------------------
  static AdDate hijriToAd(int hYear, int hMonth, int hDay) {
    final hijri = HijriCalendar();
    final ad = hijri.hijriToGregorian(hYear, hMonth, hDay);
    return AdDate(ad.year, ad.month, ad.day);
  }

  static CalendarDate adToHijri(DateTime adDate) {
    final hijri = HijriCalendar.fromDate(adDate);
    return CalendarDate(hijri.hYear, hijri.hMonth, hijri.hDay);
  }

  // -----------------------------------------------------------------
  // नेपाल सम्वत (NS) ⇄ AD — tithi_engine (खगोलीय पञ्चाङ्ग) प्रयोग गरेर
  // -----------------------------------------------------------------
  static final Panchang _panchang = Panchang(
    [registerAllCities],
    system: MonthSystem.amant,
  );

  static const List<String> _nsToHinduMonthName = [
    'Kartika', // १ कछला
    'Margashira', // २ थिंला
    'Pausha', // ३ पोहेला
    'Magha', // ४ सिल्ला
    'Phalguna', // ५ चिल्ला
    'Chaitra', // ६ चौला
    'Vaishakha', // ७ बछला
    'Jyeshtha', // ८ तछला
    'Ashadha', // ९ दिल्ला
    'Shravana', // १० गुंला
    'Bhadrapada', // ११ ञला
    'Ashwina', // १२ कौला
  ];

  static AdDate nsToAd(int nsYear, int nsMonth, int nsDay) {
    if (nsMonth < 1 || nsMonth > 12) {
      throw ArgumentError('nsMonth 1-12 को बीचमा हुनुपर्छ');
    }
    if (nsDay < 1 || nsDay > 30) {
      throw ArgumentError('nsDay 1-30 को बीचमा हुनुपर्छ');
    }

    final adYearForLookup = (nsMonth <= 2) ? nsYear + 879 : nsYear + 880;

    final monthName = _nsToHinduMonthName[nsMonth - 1];
    final lunarMonth = LunarMonth.values.firstWhere(
      (m) => m.displayName.toLowerCase() == monthName.toLowerCase(),
      orElse: () => throw StateError(
        'LunarMonth "$monthName" भेटिएन — tithi_engine को exact naming जाँच्नुपर्छ',
      ),
    );

    final tithi = nsDay <= 15 ? Tithi.shukla(nsDay) : Tithi.krishna(nsDay - 15);

    final foundDate = _panchang.findDate(
      lunarMonth,
      tithi,
      adYearForLookup,
      City.of('Kathmandu'),
    );

    if (foundDate == null) {
      throw StateError(
        'यो NS मितिको लागि AD मिति भेटिएन (अधिक महिना वा सीमा-बाहिरको वर्ष हुन सक्छ)',
      );
    }
    return AdDate(foundDate.year, foundDate.month, foundDate.day);
  }

  /// AD मितिबाट NS वर्ष/महिना/गते निकाल्ने (उल्टो दिशा)।
  static CalendarDate adToNs(DateTime adDate) {
    final info = _panchang.tithiOnDate(adDate, City.of('Kathmandu'));

    final hinduMonthName = info.month.displayName;
    final nsMonth = _nsToHinduMonthName.indexWhere(
          (name) => name.toLowerCase() == hinduMonthName.toLowerCase(),
        ) +
        1;
    if (nsMonth == 0) {
      throw StateError('हिन्दू महिना "$hinduMonthName" को NS म्यापिङ भेटिएन');
    }

    final nsDay = info.paksha == Paksha.shukla
        ? info.tithiInPaksha
        : info.tithiInPaksha + 15;

    // AD वर्षबाट NS वर्ष निकाल्ने (nsToAd को ठीक उल्टो सूत्र)
    final nsYear = (nsMonth <= 2) ? adDate.year - 879 : adDate.year - 880;

    return CalendarDate(nsYear, nsMonth, nsDay);
  }
}

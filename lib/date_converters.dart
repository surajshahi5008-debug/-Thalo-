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

  static NepaliDateTime adToBs(DateTime adDate) {
    return adDate.toNepaliDateTime();
  }

  // -----------------------------------------------------------------
  // हिजरी ⇄ AD — hijri प्याकेज प्रयोग गरेर
  // -----------------------------------------------------------------
  static AdDate hijriToAd(int hYear, int hMonth, int hDay) {
    final hijri = HijriCalendar();
    final ad = hijri.hijriToGregorian(hYear, hMonth, hDay);
    return AdDate(ad.year, ad.month, ad.day);
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
}

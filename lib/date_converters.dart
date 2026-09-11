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
  // नेपाल सम्वत (NS) ⇄ AD — tithi_engine प्रयोग गरेर (क्रमैसँग महिना गन्ने तरिका)
  // -----------------------------------------------------------------
  static final Panchang _panchang = Panchang(
    [registerAllCities],
    system: MonthSystem.amant,
  );

  static City get _kathmandu => City.of('Kathmandu');

  /// कुनै मितिपछिको सबैभन्दा नजिकको लुनार महिना सुरुवात मिति पत्ता लगाउने।
  ///
  /// सामान्यतया यो "शुक्ल प्रतिपदा" (tithiInPaksha == 1) भएको दिन हो। तर कहिलेकाहीं
  /// प्रतिपदा "क्षय तिथि" हुन्छ — अर्थात् त्यो तिथि कुनै पनि पूरा सौर्य दिनमा नपरी
  /// हराउँछ (अमावस्यापछिको भोलिपल्ट सिधै द्वितीया देखिन्छ)। त्यस्तो अवस्थामा
  /// कृष्ण पक्षबाट सिधै शुक्ल पक्षमा फड्केको दिनलाई नै महिनाको पहिलो दिन मानिन्छ,
  /// तिथिको नम्बर जे भए पनि।
  static DateTime _nextShuklaPratipada(DateTime after) {
    final debugLines = <String>[];
    TithiInfo? prevInfo;
    for (int i = 1; i <= 35; i++) {
      final candidate = after.add(Duration(days: i));
      final info = _panchang.tithiOnDate(candidate, _kathmandu);
      debugLines.add('${candidate.toIso8601String().substring(0, 10)}: $info');

      final isPratipada = info.paksha == Paksha.shukla && info.tithiInPaksha == 1;
      final isKshayaPratipada = info.paksha == Paksha.shukla &&
          prevInfo != null &&
          prevInfo.paksha == Paksha.krishna;

      if (isPratipada || isKshayaPratipada) {
        return DateTime(candidate.year, candidate.month, candidate.day);
      }
      prevInfo = info;
    }
    throw StateError(
      'शुक्ल प्रतिपदा भेटिएन (३५ दिनभित्र) — वास्तविक डेटा:\n${debugLines.join('\n')}',
    );
  }

  /// तोकिएको NS वर्षको नयाँ वर्ष (कार्तिक शुक्ल प्रतिपदा) को AD मिति।
  static DateTime _nsNewYearDate(int nsYear) {
    final adYear = nsYear + 879;
    final date = _panchang.findDate(
      LunarMonth.values.firstWhere(
        (m) => m.displayName.toLowerCase() == 'kartika',
      ),
      Tithi.shukla(1),
      adYear,
      _kathmandu,
    );
    if (date == null) {
      throw StateError('NS $nsYear को नयाँ वर्ष भेटिएन');
    }
    return DateTime(date.year, date.month, date.day);
  }

  /// नयाँ वर्षको मितिबाट क्रमैसँग गनेर n औं लुनार महिनाको सुरुवात मिति पत्ता लगाउने।
  static DateTime _nthLunarMonthStart(DateTime newYearDate, int n) {
    var current = newYearDate;
    for (int i = 1; i < n; i++) {
      current = _nextShuklaPratipada(current);
    }
    return current;
  }

  /// NS वर्ष/महिना/गते बाट AD मिति निकाल्ने।
  static AdDate nsToAd(int nsYear, int nsMonth, int nsDay) {
    if (nsMonth < 1 || nsMonth > 13) {
      throw ArgumentError('nsMonth 1-13 को बीचमा हुनुपर्छ (अधिक-महिना सहित)');
    }
    if (nsDay < 1 || nsDay > 30) {
      throw ArgumentError('nsDay 1-30 को बीचमा हुनुपर्छ');
    }

    final newYearDate = _nsNewYearDate(nsYear);
    final monthStart = _nthLunarMonthStart(newYearDate, nsMonth);

    // day 1 चाहिँ monthStart आफैं हो — तिथि खोजेर पत्ता लगाउनु पर्दैन।
    // (प्रतिपदा क्षय भएको महिनामा tithiInPaksha==1 कुनै दिनमा नै नआउन सक्छ)
    if (nsDay == 1) {
      return AdDate(monthStart.year, monthStart.month, monthStart.day);
    }

    final wantPaksha = nsDay <= 15 ? Paksha.shukla : Paksha.krishna;
    final wantTithi = nsDay <= 15 ? nsDay : nsDay - 15;

    for (int i = 1; i <= 32; i++) {
      final candidate = monthStart.add(Duration(days: i));
      final info = _panchang.tithiOnDate(candidate, _kathmandu);
      if (info.paksha == wantPaksha && info.tithiInPaksha == wantTithi) {
        return AdDate(candidate.year, candidate.month, candidate.day);
      }
    }
    throw StateError('यो NS मितिको लागि AD मिति भेटिएन');
  }

  /// AD मितिबाट NS वर्ष/महिना/गते निकाल्ने (उल्टो दिशा)।
  static CalendarDate adToNs(DateTime adDate) {
    final candidateOlder = adDate.year - 880;
    final candidateNewer = adDate.year - 879;

    final newYearNewer = _nsNewYearDate(candidateNewer);
    final int nsYear;
    final DateTime newYearDate;
    if (!adDate.isBefore(newYearNewer)) {
      nsYear = candidateNewer;
      newYearDate = newYearNewer;
    } else {
      nsYear = candidateOlder;
      newYearDate = _nsNewYearDate(candidateOlder);
    }

    int monthCount = 1;
    var monthStart = newYearDate;
    while (true) {
      final nextMonthStart = _nextShuklaPratipada(monthStart);
      if (!adDate.isBefore(nextMonthStart)) {
        monthStart = nextMonthStart;
        monthCount++;
        if (monthCount > 13) {
          throw StateError('NS महिना गन्तीमा त्रुटि (१३ भन्दा बढी भयो)');
        }
      } else {
        break;
      }
    }

    // adDate आफैं महिनाको पहिलो दिन (monthStart) हो भने nsDay सिधै 1 हो —
    // तिथि नम्बर जे भए पनि (क्षय प्रतिपदाको अवस्था ह्यान्डल गर्न)।
    if (adDate.year == monthStart.year &&
        adDate.month == monthStart.month &&
        adDate.day == monthStart.day) {
      return CalendarDate(nsYear, monthCount, 1);
    }

    final info = _panchang.tithiOnDate(adDate, _kathmandu);
    final nsDay =
        info.paksha == Paksha.shukla ? info.tithiInPaksha : info.tithiInPaksha + 15;

    return CalendarDate(nsYear, monthCount, nsDay);
  }
}

import 'package:nepali_utils/nepali_utils.dart';
import 'package:hijri/hijri_calendar.dart';

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
  // विक्रम सम्वत (BS) ⇄ AD — nepali_utils प्रयोग गरेर (सही, lookup-table आधारित)
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
  // हिजरी ⇄ AD — hijri प्याकेज प्रयोग गरेर (Umm al-Qura आधारित)
  // -----------------------------------------------------------------
  static AdDate hijriToAd(int hYear, int hMonth, int hDay) {
    final hijri = HijriCalendar();
    final ad = hijri.hijriToGregorian(hYear, hMonth, hDay);
    return AdDate(ad.year, ad.month, ad.day);
  }

  // -----------------------------------------------------------------
  // नेपाल सम्वत (NS) ⇄ AD — ⚠️ अझै समाधान नभएको भाग
  // -----------------------------------------------------------------
  // Nepal Sambat चन्द्र (lunar) क्यालेन्डर हो, र यसको लागि भरपर्दो
  // Dart/Flutter प्याकेज भेटिएन। अहिलेलाई error दिने राखिएको छ, ताकि
  // गलत मिति देखाइहालोस् भन्दा प्रयोगकर्तालाई थाहा होस्।
  static AdDate nsToAd(int nsYear, int nsMonth, int nsDay) {
    throw UnimplementedError(
      'NS→AD conversion अझै टुङ्गिएको छैन — पछि छुट्टै छलफल गरौंला।',
    );
  }
}

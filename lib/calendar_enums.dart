/// भाषाहरू जुन एपले सपोर्ट गर्छ।
enum AppLanguage { english, hindi, nepali, newari, urdu }

/// क्यालेन्डर प्रणालीहरू।
enum CalendarSystem { ad, bs, ns, hijri }

/// अंक लेख्ने लिपि (script)। यो क्यालेन्डर प्रणालीसँग सिधै बाँधिएको हुँदैन —
/// AD सधैं latin मा देखिन्छ, चाहे जुनसुकै भाषाको सेक्सनमा भए पनि।
enum NumeralScript { latin, devanagari, newa, easternArabicIndic }

/// पाठ बग्ने दिशा।
enum TextDirection { ltr, rtl }

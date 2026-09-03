class AppStrings {
  static const Map<string, map<string, string>> localizedValues = {
    'Nepali': {
      'appName': 'थलो',
      'login': 'लगइन गर्नुहोस्',
      'register': 'नयाँ खाता बनाउनुहोस्',
      'email': 'इमेल ठेगाना',
      'password': 'पासवर्ड',
      'fillAllFields': 'कृपया सबै खाली ठाउँहरू भर्नुहोस्।',
      'welcome': 'स्वागत छ!',
    },
    'English': {
      'appName': 'Thalo',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email Address',
      'password': 'Password',
      'fillAllFields': 'Please fill in all fields.',
      'welcome': 'Welcome!',
    },
    // अन्य भाषाहरूका लागि पनि थप्न सकिन्छ
  };

  static String get(String key, String lang) {
    return localizedValues[lang]?[key] ?? localizedValues['Nepali']?[key] ?? key;
  }
}

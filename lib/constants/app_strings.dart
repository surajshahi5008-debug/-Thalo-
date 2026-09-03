class AppStrings {
  static const Map<String, Map<String, String>> localizedValues = {
    'en': {
      'app_title': 'Thalo App',
      'login': 'Login',
      'register': 'Register',
      'loginAppBar': 'Login',
      'loginTitle': 'Welcome Back',
      'emailLabel': 'Email',
      'passwordLabel': 'Password',
      'forgotPassword': 'Forgot Password?',
      'loginButton': 'Login',
      'noAccount': 'Don\'t have an account? Register',
      'registerAppBar': 'Register',
      'registerTitle': 'Create Account',
      'firstName': 'First Name',
      'middleName': 'Middle Name (Optional)',
      'lastName': 'Last Name',
      'dob': 'Date of Birth',
      'nextButton': 'Next',
      'hasAccount': 'Already have an account? Login',
    },
    'ne': {
      'app_title': 'थलो एप',
      'login': 'लगइन',
      'register': 'दर्ता गर्नुहोस्',
      'loginAppBar': 'लगइन',
      'loginTitle': 'पुनः स्वागत छ',
      'emailLabel': 'इमेल',
      'passwordLabel': 'पासवर्ड',
      'forgotPassword': 'पासवर्ड बिर्सनुभयो?',
      'loginButton': 'लगइन गर्नुहोस्',
      'noAccount': 'खाता छैन? दर्ता गर्नुहोस्',
      'registerAppBar': 'दर्ता गर्नुहोस्',
      'registerTitle': 'नयाँ खाता बनाउनुहोस्',
      'firstName': 'पहिलो नाम',
      'middleName': 'बीचको नाम (ऐच्छिक)',
      'lastName': 'थर',
      'dob': 'जन्म मिति',
      'nextButton': 'पछाडि / अर्को',
      'hasAccount': 'पहिले नै खाता छ? लगइन गर्नुहोस्',
    },
    // अन्य भाषाहरूका लागि थप गर्न सक्नुहुन्छ
  };

  static String get(String key, String lang) {
    if (localizedValues.containsKey(lang) && localizedValues[lang]!.containsKey(key)) {
      return localizedValues[lang]![key]!;
    }
    return localizedValues['en']?[key] ?? key;
  }
}

class LocalizationHelper {
  static const Map<String, Map<String, String>> localizedValues = {
    'English': {
      'loginAppBar': 'Thalo - Login',
      'loginTitle': 'Welcome Back to Thalo',
      'emailLabel': 'Email or Phone Number',
      'passwordLabel': 'Password',
      'loginButton': 'Login',
      'noAccount': "Don't have an account? Sign Up here",
      'forgotPassword': 'Forgot Password / Username?',
      'registerAppBar': 'Thalo - Sign Up',
      'registerTitle': 'Create New Account',
      'firstName': 'First Name',
      'middleName': 'Middle Name (Optional)',
      'lastName': 'Last Name',
      'dob': 'Date of Birth',
      'nextButton': 'Next',
      'gender': 'Select Gender',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
      'phoneOrEmail': 'Email or 10-digit Phone Number',
      'terms': 'I accept the Terms & Conditions',
      'registerButton': 'Sign Up & Send Verification',
      'hasAccount': 'Already have an account? Login here',
      'okButton': 'OK',
      'cancelButton': 'Cancel',
      'verificationTitle': 'Account Verification',
      'verificationSubtitle': 'Please enter the 6-digit SMS OTP sent to your phone.',
      'verifyButton': 'Verify & Complete',
      'smsOtpLabel': 'Enter 6-digit OTP',
      'emailLinkNotice': 'Verification link has been sent to your Gmail. Please click the link to verify.',
      'errEmailAlreadyInUse': 'This Gmail account is already registered. Please log in. If you are creating a new Thalo account, please try again with a different Gmail account or phone number.',
      'errPhoneAlreadyInUse': 'This phone number is already registered in Thalo. Please log in. If you are creating a new Thalo account, please try again with a different phone number or Gmail account.',
      'errEmailNotRegistered': 'This email is not registered in Thalo.',
      'errPhoneNotRegistered': 'This phone number is not registered in Thalo.',
      'errIncorrectPassword': 'Password is incorrect.',
    },
    'नेपाली': {
      'loginAppBar': 'थलो - लगइन',
      'loginTitle': 'थलोमा स्वागत छ',
      'emailLabel': 'इमेल वा फोन नम्बर',
      'passwordLabel': 'पासवर्ड',
      'loginButton': 'लगइन',
      'noAccount': 'खाता छैन? यहाँ रजिस्टर गर्नुहोस्',
      'forgotPassword': 'पासवर्ड वा युजरनेम बिर्सनुभयो?',
      'registerAppBar': 'थलो - साइन अप',
      'registerTitle': 'नयाँ खाता खोल्नुहोस्',
      'firstName': 'पहिलो नाम',
      'middleName': 'बीचको नाम (ऐच्छिक)',
      'lastName': 'थर',
      'dob': 'जन्म मिति',
      'nextButton': 'अर्को',
      'gender': 'लिङ्ग छान्नुहोस्',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'अन्य',
      'phoneOrEmail': 'इमेल वा १० अंकको मोबाइल नम्बर',
      'terms': 'म सर्त तथा नियमहरू स्वीकार गर्दछु',
      'registerButton': 'साइन अप र भेरिफिकेसन पठाउनुहोस्',
      'hasAccount': 'पहिले नै खाता छ? यहाँ लगइन गर्नुहोस्',
      'okButton': 'ठीक छ',
      'cancelButton': 'रद्द गर्नुहोस्',
      'verificationTitle': 'खाता प्रमाणीकरण',
      'verificationSubtitle': 'कृपया तपाईंको मोबाइलमा आएको ६ अंकको SMS OTP यहाँ हाल्नुहोस्।',
      'verifyButton': 'प्रमाणित गरी पूरा गर्नुहोस्',
      'smsOtpLabel': '६ अंकको OTP',
      'emailLinkNotice': 'तपाईंको जिमेलमा भेरिफिकेसन लिङ्क पठाइएको छ। कृपया इमेलमा गएर लिङ्कमा क्लिक गरी अकाउन्ट प्रमाणित गर्नुहोस्।',
      'errEmailAlreadyInUse': 'यो जिमेल खाता पहिले नै दर्ता भइसकेको छ कृपया लग इन गर्नुहोस् यदि नयाँ थलो खाता बनाउँदै हुनुहुन्छ भने अर्को जिमेल खाता वा फोन नम्बर राखेर फेरि प्रयत्न गर्नुहोस्।',
      'errPhoneAlreadyInUse': 'यो फोन नम्बर थलोमा पहिले नै दर्ता भइसकेको छ कृपया लग इन गर्नुहोस् यदि नयाँ थलो खाता बनाउँदै हुनुहुन्छ भने अर्को फोन नम्बर वा जिमेल खाता राखेर फेरि प्रयत्न गर्नुहोस्।',
      'errEmailNotRegistered': 'यो इमेल थलोमा दर्ता भएको छैन।',
      'errPhoneNotRegistered': 'यो फोन नम्बर थलोमा दर्ता भएको छैन।',
      'errIncorrectPassword': 'पासवर्ड मिलेन।',
    },
    // अन्य भाषाहरू (नेपाल भाषा, हिन्दी, اردو) यहाँ राख्न सक्नुहुन्छ...
  };

  static String getText(String lang, String key) {
    return localizedValues[lang]?[key] ?? localizedValues['नेपाली']![key]!;
  }

  static String formatNumber(int number, String lang, String calendar) {
    if (calendar == 'AD' || lang == 'English') {
      return number.toString();
    }
    String numStr = number.toString();
    if (lang == 'नेपाली' || lang == 'नेपाल भाषा') {
      const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const nepaliDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
      for (int i = 0; i < 10; i++) {
        numStr = numStr.replaceAll(englishDigits[i], nepaliDigits[i]);
      }
    }
    return numStr;
  }
}

class Helpers {
  // इमेल सही फॉर्मेटमा छ कि छैन चेक गर्ने साधारण फंक्सन
  static bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }
}

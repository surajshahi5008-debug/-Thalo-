import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const MaterialApp(
    home: ThaloLoginScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

// ================= १. AUTHENTICATION & LOGIC SERVICE =================
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // अमर्यादित शब्दहरूको Blocklist
  final List<String> _forbiddenWords = [
    'muji', 'radi', 'randi', 'kado', 'lado', 'chikne', 'bhalu', 'mura', 'bhaate',
    'fuck', 'shit', 'bitch', 'asshole', 'bastard', 'cunt', 'dick', 'pussy',
    'bhosdike', 'madarchod', 'behenchod', 'gandu', 'chutiya', 'harami'
  ];

  // नाम परीक्षण गर्ने Validation Logic
  bool isInvalidName(String name) {
    String cleanName = name.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
    List<String> words = cleanName.split(RegExp(r'\s+'));

    for (String word in words) {
      if (_forbiddenWords.contains(word)) {
        return true;
      }
    }
    return false;
  }

  // इमेलबाट दर्ता (Registration)
  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String dob,
    required String gender,
  }) async {
    if (isInvalidName(name)) {
      throw 'कृपया मर्यादित र उपयुक्त नाम मात्र प्रयोग गर्नुहोस्।';
    }

    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    User? user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name.trim());
      await user.sendEmailVerification();

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'userId': email.trim(),
        'dob': dob,
        'gender': gender,
        'authType': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // OTP पठाउने (Phone Auth)
  Future<void> sendPhoneOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMsg) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'OTP पठाउन सकिएन।');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // OTP Verification र खाता सिर्जना
  Future<void> verifyOTPAndCreateAccount({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phoneNumber,
    required String password,
    required String dob,
    required String gender,
  }) async {
    if (isInvalidName(name)) {
      throw 'कृपया मर्यादित र उपयुक्त नाम मात्र प्रयोग गर्नुहोस्।';
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      await user.updatePassword(password);
      await user.updateDisplayName(name.trim());

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'phoneNumber': phoneNumber.trim(),
        'userId': phoneNumber.trim(),
        'dob': dob,
        'gender': gender,
        'authType': 'phone',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Login Logic
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'यो खाता फेला परेन।';
      case 'wrong-password':
      case 'invalid-credential':
        return 'पासवर्ड मिलेन।';
      case 'email-already-in-use':
        return 'यो इमेल पहिले नै प्रयोगमा छ।';
      case 'invalid-phone-number':
        return 'मान्य फोन नम्बर हाल्नुहोस्।';
      case 'invalid-verification-code':
        return 'OTP कोड मिलेन।';
      default:
        return e.message ?? 'त्रुटि देखा पर्यो।';
    }
  }
}

// ================= २. लगइन स्क्रिन =================
class ThaloLoginScreen extends StatefulWidget {
  const ThaloLoginScreen({super.key});

  @override
  State<ThaloLoginScreen> createState() => _ThaloLoginScreenState();
}

class _ThaloLoginScreenState extends State<ThaloLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedLang = 'नेपाली';

  final List<String> _languages = ['नेपाली', 'हिन्दी', 'English', 'Urdu'];

  Map<String, String> _getLoginLabels(String lang) {
    switch (lang) {
      case 'हिन्दी':
        return {
          'title': 'अपने खाते में लॉगिन करें',
          'email': 'ईमेल या मोबाइल नंबर (ID)',
          'pass': 'पासवर्ड',
          'btn': 'लॉगिन करें',
          'noAccount': 'खाता नहीं है?',
          'signUpLink': 'साइन अप करें'
        };
      case 'English':
        return {
          'title': 'Log in to your account',
          'email': 'Email or Mobile Number (ID)',
          'pass': 'Password',
          'btn': 'Log In',
          'noAccount': "Don't have an account?",
          'signUpLink': 'Sign Up'
        };
      case 'Urdu':
        return {
          'title': 'اپنے اکاؤنٹ میں لاگ ان کریں',
          'email': 'ای میل یا موبائل نمبر',
          'pass': 'پاس ورڈ',
          'btn': 'لاگ ان کریں',
          'noAccount': 'اکاؤنٹ نہیں ہے؟',
          'signUpLink': 'سائن اپ کریں'
        };
      default:
        return {
          'title': 'आफ्नो खातामा लगइन गर्नुहोस्',
          'email': 'इमेल वा मोबाइल नम्बर (ID)',
          'pass': 'पासवर्ड',
          'btn': 'लगइन गर्नुहोस्',
          'noAccount': 'खाता छैन?',
          'signUpLink': 'साइन अप गर्नुहोस्'
        };
    }
  }

  TextDirection _getDirection(String lang) =>
      lang == 'Urdu' ? TextDirection.rtl : TextDirection.ltr;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.loginWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ThaloNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = _getLoginLabels(_selectedLang);
    final dir = _getDirection(_selectedLang);

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Thalo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text(labels['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 35),
                  InternationalPhoneNumberInput(
  onInputChanged: (PhoneNumber number) {
    // यो कोडले फोन नम्बरको पूरा format (जस्तै +977... वा +91...) लिन्छ
    _emailController.text = number.phoneNumber ?? '';
  },
  selectorConfig: const SelectorConfig(
    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
    showFlags: true,
    setSelectorButtonAsPrefixIcon: true,
    leadingPadding: 12,
  ),
  ignoreBlank: false,
  autoValidateMode: AutovalidateMode.disabled,
  initialValue: PhoneNumber(isoCode: 'NP'), // सुरुमा नेपालको झण्डा देखाउने
  textFieldController: _emailController,
  formatInput: true,
  keyboardType: TextInputType.text,
  inputDecoration: InputDecoration(
    hintText: labels['email_phone_hint'] ?? 'इमेल वा मोबाइल नम्बर',
    filled: true,
    fillColor: const Color(0xfff5f6f8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'कृपया इमेल वा मोबाइल नम्बर हाल्नुहोस्';
    }
    return null;
  },
),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    textDirection: dir,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: labels['pass']!,
                      filled: true,
                      fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'पासवर्ड हाल्नुहोस्'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(labels['btn']!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(labels['noAccount']!,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ThaloRegisterScreen()),
                        ),
                        child: Text(labels['signUpLink']!,
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedLang,
                        underline: const SizedBox(),
                        items: _languages.map((String lang) {
                          return DropdownMenuItem<String>(
                            value: lang,
                            child: Text(lang,
                                style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (String? newLang) {
                          if (newLang != null) {
                            setState(() => _selectedLang = newLang);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= ३. साइन अप (रजिस्टर) स्क्रिन =================
class ThaloRegisterScreen extends StatefulWidget {
  const ThaloRegisterScreen({super.key});

  @override
  State<ThaloRegisterScreen> createState() => _ThaloRegisterScreenState();
}

  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedLang = 'नेपाली';
  String? _selectedGender;
  String? _calculatedAgeText;

  bool _isPhoneAuth = false;

  final List<String> _languages = ['नेपाली', 'हिन्दी', 'English', 'Urdu'];
  final List<String> _genders = ['पुरुष (Male)', 'महिला (Female)', 'अन्य (Other)'];

  Map<String, String> _getRegisterLabels(String lang) {
    switch (lang) {
      case 'हिन्दी':
        return {
          'title': 'थलो अकाउंट बनाएं',
          'name': 'पूरा नाम',
          'dob': 'जन्म तिथि (DOB)',
          'gender': 'लिंग चुनें',
          'email': 'ईमेल पता',
          'phone': 'मोबाइल नंबर (+977...)',
          'pass': 'पासवर्ड बनाएं',
          'btn': 'साइन अप करें',
          'sendOtp': 'OTP कोड भेजें',
          'haveAccount': 'पहले से खाता है?',
          'loginLink': 'लॉगिन करें'
        };
      case 'English':
        return {
          'title': 'Create Thalo Account',
          'name': 'Full Name',
          'dob': 'Date of Birth',
          'gender': 'Select Gender',
          'email': 'Email Address',
          'phone': 'Mobile Number (+977...)',
          'pass': 'Create Password',
          'btn': 'Sign Up',
          'sendOtp': 'Send OTP Code',
          'haveAccount': 'Already have an account?',
          'loginLink': 'Log In'
        };
      case 'Urdu':
        return {
          'title': 'تھلو اکاؤنٹ بنائیں',
          'name': 'پورا نام',
          'dob': 'تاریخ پیدائش',
          'gender': 'جنس منتخب کریں',
          'email': 'ای میل کا پتہ',
          'phone': 'موبائل نمبر (+977...)',
          'pass': 'پاس ورڈ بنائیں',
          'btn': 'سائن اپ کریں',
          'sendOtp': 'OTP کوڈ بھیجیں',
          'haveAccount': 'پہلے سے اکاؤنٹ ہے؟',
          'loginLink': 'لاگ ان کریں'
        };
      default:
        return {
          'title': 'थलो खाता बनाउनुहोस्',
          'name': 'पूरा नाम',
          'dob': 'जन्ममिति (DOB)',
          'gender': 'लिङ्ग छान्नुहोस्',
          'email': 'इमेल ठेगाना',
          'phone': 'मोबाइल नम्बर (+977...)',
          'pass': 'पासवर्ड राख्नुहोस्',
          'btn': 'साइन अप गर्नुहोस्',
          'sendOtp': 'OTP कोड पठाउनुहोस्',
          'haveAccount': 'पहिले नै खाता छ?',
          'loginLink': 'लगइन गर्नुहोस्'
        };
    }
  }

  TextDirection _getDirection(String lang) =>
      lang == 'Urdu' ? TextDirection.rtl : TextDirection.ltr;

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

        int years = now.year - picked.year;
        DateTime lastBirthday = DateTime(now.year, picked.month, picked.day);

        if (now.isBefore(lastBirthday)) {
          years--;
          lastBirthday = DateTime(now.year - 1, picked.month, picked.day);
        }

        int days = now.difference(lastBirthday).inDays;
        _calculatedAgeText = "उमेर: $years वर्ष, $days दिन";
      });
    }
  }

  void _showOTPDialog(String verificationId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("OTP कोड पुष्टि गर्नुहोस्", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min, // सच्याइएको ठाउँ (Corrected Line)
          children: [
            Text("${_phoneController.text} मा पठाइएको ६ अंकको OTP हाल्नुहोस्।",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "000000",
                counterText: "",
              ),
            ),
          ],
        ),
                      actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("रद्द गर्नुहोस्"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    if (_otpController.text.length < 6) return;
                    Navigator.pop(context);
                    setState(() => _isloading = true);
                    try {
                      await _authService.verifyOTP(
                        verificationId: verificationId,
                        smsCode: _otpController.text,
                      );
                    } catch (e) {
                      setState(() => _isloading = false);
                    }
                  },
                  child: const Text("प्रमाणित गर्नुहोस्"),
                ),
              ],

        

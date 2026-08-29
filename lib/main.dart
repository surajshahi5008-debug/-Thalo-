import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "यहाँ_apiKey_राख्नुहोस्",
      authDomain: "यहाँ_authDomain_राख्नुहोस्",
      projectId: "thalo-cd9f4",
      storageBucket: "thalo-cd9f4.firebasestorage.app",
      messagingSenderId: "1026967924822",
      appId: "1:1026967924822:web:cc091378a54b7f43e6",
    ),
  );

  runApp(const MaterialApp(
    home: ThaloRegisterScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw _mapErrorToMessage(e);
    }
  }

  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapErrorToMessage(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapErrorToMessage(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'यो इमेल पहिले नै प्रयोगमा छ।';
      case 'invalid-email':
        return 'मान्य इमेल ठेगाना हाल्नुहोस्।';
      case 'weak-password':
        return 'पासवर्ड धेरै कमजोर छ, अर्को प्रयास गर्नुहोस्।';
      case 'user-not-found':
        return 'यो इमेलसँग कुनै खाता फेला परेन।';
      case 'wrong-password':
      case 'invalid-credential':
        return 'इमेल वा पासवर्ड मिलेन।';
      case 'too-many-requests':
        return 'धेरै प्रयास भयो। केही समयपछि फेरि प्रयास गर्नुहोस्।';
      case 'network-request-failed':
        return 'इन्टरनेट जडान जाँच गर्नुहोस्।';
      default:
        return 'त्रुटि भयो: ${e.message ?? "पुनः प्रयास गर्नुहोस्"}';
    }
  }
}

class ThaloRegisterScreen extends StatefulWidget {
  const ThaloRegisterScreen({super.key});

  @override
  State<ThaloRegisterScreen> createState() => _ThaloRegisterScreenState();
}

class _ThaloRegisterScreenState extends State<ThaloRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedLang = 'नेपाली';

  final List<String> _languages = [
    'नेपाली', 'हिन्दी', 'English', 'Bhojpuri (भोजपुरी)', 'डोटेली', 'नेपालभाषा', 'Urdu', 'Tamil', 'Telugu', 'Punjabi'
  ];

  Map<String, String> _getRegisterLabels(String lang) {
    switch (lang) {
      case 'नेपाली': return {'title': 'थलो खाता बनाउनुहोस्', 'name': 'पूरा नाम', 'email': 'इमेल ठेगाना', 'pass': 'पासवर्ड', 'btn': 'साइन अप र थलोमा जोडिनुहोस्', 'haveAccount': 'पहिले नै खाता छ?', 'loginLink': 'लगइन गर्नुहोस्'};
      case 'हिन्दी': return {'title': 'थलो अकाउंट बनाएं', 'name': 'पूरा नाम', 'email': 'ईमेल पता', 'pass': 'पासवर्ड', 'btn': 'साइन अप और थलो से जुड़ें', 'haveAccount': 'पहले से खाता है?', 'loginLink': 'लॉगिन करें'};
      case 'English': return {'title': 'Create Thalo Account', 'name': 'Full Name', 'email': 'Email Address', 'pass': 'Password', 'btn': 'Sign Up & Connect to Thalo', 'haveAccount': 'Already have an account?', 'loginLink': 'Log In'};
      case 'Bhojpuri (भोजपुरी)': return {'title': 'थलो खाता बनाईं', 'name': 'पूरा नाम', 'email': 'ईमेल पता', 'pass': 'पासवर्ड', 'btn': 'साइन अप करीं अउर थलो से जुडीं', 'haveAccount': 'पहिलहीं खाता बा?', 'loginLink': 'लॉगिन करीं'};
      case 'डोटेली': return {'title': 'थलो खाता बणाया', 'name': 'पूरो नाउँ', 'email': 'इमेल ठेगान', 'pass': 'पासवर्ड', 'btn': 'साइन अप अर थलोमी जोडिए', 'haveAccount': 'पहलनैं खाता छ?', 'loginLink': 'लगइन गर'};
      case 'नेपालभाषा': return {'title': 'थःगु थलो खाता चूलाकादिसँ', 'name': 'मछिं नां', 'email': 'इमेल ठेगाना', 'pass': 'पासवर्ड', 'btn': 'साइन अप याना थलोस स्वानादिसँ', 'haveAccount': 'खाता दुगु?', 'loginLink': 'लगइन याना दिसँ'};
      case 'Urdu': return {'title': 'تھلو اکاؤنٹ بنائیں', 'name': 'پورا نام', 'email': 'ای میل کا پتہ', 'pass': 'پاس ورڈ', 'btn': 'سائن اپ کریں', 'haveAccount': 'پہلے سے اکاؤنٹ ہے؟', 'loginLink': 'لاگ ان کریں'};
      case 'Tamil': return {'title': 'தலோ கணக்கை உருவாக்குங்கள்', 'name': 'முழு பெயர்', 'email': 'மின்னஞ்சல் முகவரி', 'pass': 'கடவுச்சொல்', 'btn': 'பதிவு செய்யவும்', 'haveAccount': 'ஏற்கனவே கணக்கு உள்ளதா?', 'loginLink': 'உள்நுழைக'};
      case 'Telugu': return {'title': 'థలో ఖాతాను సృష్టించండి', 'name': 'పూర్తి పేరు', 'email': 'ఇమెయిల్ చిరునామా', 'pass': 'పాస్‌వర్డ్', 'btn': 'సైన్ అప్ చేయండి', 'haveAccount': 'ఇప్పటికే ఖాతా ఉందా?', 'loginLink': 'లాగిన్ చేయండి'};
      case 'Punjabi': return {'title': 'ਥਲੋ ਖਾਤਾ ਬਣਾਓ', 'name': 'ਪੂਰਾ ਨਾਮ', 'email': 'ਈਮੇਲ ਪਤਾ', 'pass': 'ਪਾਸਵਰਡ', 'btn': 'ਸਾਈਨ ਅਪ ਕਰੋ', 'haveAccount': 'ਪਹਿਲਾਂ ਹੀ ਖਾਤਾ ਹੈ?', 'loginLink': 'ਲੌਗਇਨ ਕਰੋ'};
      default: return {'title': 'Create Thalo Account', 'name': 'Full Name', 'email': 'Email Address', 'pass': 'Password', 'btn': 'Sign Up', 'haveAccount': 'Already have an account?', 'loginLink': 'Log In'};
    }
  }

  TextDirection _getDirection(String lang) {
    if (lang == 'Urdu') return TextDirection.rtl;
    return TextDirection.ltr;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.registerWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThaloNavigationScreen()),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = _getRegisterLabels(_selectedLang);
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
                  const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('Thalo', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 5),
                  Text(labels['title']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 35),

                  TextFormField(
                    controller: _nameController,
                    textDirection: dir,
                    decoration: InputDecoration(hintText: labels['name']!, filled: true, fillColor: const Color(0xfff5f6f8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.person_outline, color: Colors.grey)),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    textDirection: dir,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: labels['email']!, filled: true, fillColor: const Color(0xfff5f6f8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey)),
                    validator: (value) => (value == null || !value.contains('@')) ? 'Please enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    textDirection: dir,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: labels['pass']!, filled: true, fillColor: const Color(0xfff5f6f8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => (value == null || value.length < 6) ? 'Password must be 6+ characters' : null,
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(labels['btn']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(labels['haveAccount']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ThaloLoginScreen()),
                          );
                        },
                        child: Text(labels['loginLink']!, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xfff5f6f8), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLang,
                            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                            onChanged: (val) => setState(() => _selectedLang = val!),
                            items: _languages.map((v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(),
                          ),
                        ),
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

  final List<String> _languages = [
    'नेपाली', 'हिन्दी', 'English', 'Bhojpuri (भोजपुरी)', 'डोटेली',
    'नेपालभाषा', 'Urdu', 'Tamil', 'Telugu', 'Punjabi'
  ];

  Map<String, String> _getLoginLabels(String lang) {
    switch (lang) {
      case 'नेपाली':
        return {'title': 'थलोमा फेरि स्वागत छ', 'email': 'इमेल ठेगाना', 'pass': 'पासवर्ड', 'forgot': 'पासवर्ड बिर्सनुभयो?', 'btn': 'लगइन गर्नुहोस्', 'noAccount': 'खाता छैन?', 'registerLink': 'साइन अप गर्नुहोस्', 'invalidEmail': 'मान्य इमेल हाल्नुहोस्', 'invalidPass': 'पासवर्ड ६ वर्ण भन्दा बढी हुनुपर्छ'};
      case 'हिन्दी':
        return {'title': 'थलो में फिर से स्वागत है', 'email': 'ईमेल पता', 'pass': 'पासवर्ड', 'forgot': 'पासवर्ड भूल गए?', 'btn': 'लॉगिन करें', 'noAccount': 'खाता नहीं है?', 'registerLink': 'साइन अप करें', 'invalidEmail': 'मान्य ईमेल दर्ज करें', 'invalidPass': 'पासवर्ड 6 अक्षर से अधिक होना चाहिए'};
      case 'English':
        return {'title': 'Welcome Back to Thalo', 'email': 'Email Address', 'pass': 'Password', 'forgot': 'Forgot Password?', 'btn': 'Log In', 'noAccount': "Don't have an account?", 'registerLink': 'Sign Up', 'invalidEmail': 'Please enter a valid email', 'invalidPass': 'Password must be 6+ characters'};
      case 'Bhojpuri (भोजपुरी)':
        return {'title': 'थलो में फिर से स्वागत बा', 'email': 'ईमेल पता', 'pass': 'पासवर्ड', 'forgot': 'पासवर्ड भुला गइनी?', 'btn': 'लॉगिन करीं', 'noAccount': 'खाता नइखे?', 'registerLink': 'साइन अप करीं', 'invalidEmail': 'सही ईमेल डालीं', 'invalidPass': 'पासवर्ड 6 अक्षर से बेसी होखे के चाहीं'};
      case 'डोटेली':
        return {'title': 'थलोमी फेरी स्वागत छ', 'email': 'इमेल ठेगान', 'pass': 'पासवर्ड', 'forgot': 'पासवर्ड बिर्सनुभयो?', 'btn': 'लगइन गर', 'noAccount': 'खाता छैन?', 'registerLink': 'साइन अप गर', 'invalidEmail': 'मान्य इमेल हाल', 'invalidPass': 'पासवर्ड ६ वर्ण भन्दा बढी हुनुपर्छ'};
      case 'नेपालभाषा':
        return {'title': 'थलोय् पुनः स्वागतय्', 'email': 'इमेल ठेगाना', 'pass': 'पासवर्ड', 'forgot': 'पासवर्ड म्हसीलागु?', 'btn': 'लगइन याना दिसँ', 'noAccount': 'खाता मदु?', 'registerLink': 'साइन अप याना दिसँ', 'invalidEmail': 'मान्य इमेल छ्यलादिसँ', 'invalidPass': 'पासवर्ड ६ वर्ण स्वया ल्हाब्ला जुइमा'};
      case 'Urdu':
        return {'title': 'تھلو میں دوبارہ خوش آمدید', 'email': 'ای میل کا پتہ', 'pass': 'پاس ورڈ', 'forgot': 'پاس ورڈ بھول گئے؟', 'btn': 'لاگ ان کریں', 'noAccount': 'اکاؤنٹ نہیں ہے؟', 'registerLink': 'سائن اپ کریں', 'invalidEmail': 'براہ کرم درست ای میل درج کریں', 'invalidPass': 'پاس ورڈ 6 حروف سے زیادہ ہونا چاہیے'};
      case 'Tamil':
        return {'title': 'தலோவிற்கு மீண்டும் வரவேற்கிறோம்', 'email': 'மின்னஞ்சல் முகவரி', 'pass': 'கடவுச்சொல்', 'forgot': 'கடவுச்சொல் மறந்துவிட்டதா?', 'btn': 'உள்நுழைக', 'noAccount': 'கணக்கு இல்லையா?', 'registerLink': 'பதிவு செய்யவும்', 'invalidEmail': 'சரியான மின்னஞ்சலை உள்ளிடவும்', 'invalidPass': 'கடவுச்சொல் 6+ எழுத்துக்கள் இருக்க வேண்டும்'};
      case 'Telugu':
        return {'title': 'థలోకి తిరిగి స్వాగతం', 'email': 'ఇమెయిల్ చిరునామా', 'pass': 'పాస్‌వర్డ్', 'forgot': 'పాస్‌వర్డ్ మర్చిపోయారా?', 'btn': 'లాగిన్ చేయండి', 'noAccount': 'ఖాతా లేదా?', 'registerLink': 'సైన్ అప్ చేయండి', 'invalidEmail': 'చెల్లుబాటు అయ్యే ఇమెయిల్ నమోదు చేయండి', 'invalidPass': 'పాస్‌వర్డ్ 6+ అక్షరాలు ఉండాలి'};
      case 'Punjabi':
        return {'title': 'ਥਲੋ ਵਿੱਚ ਮੁੜ ਸੁਆਗਤ ਹੈ', 'email': 'ਈਮੇਲ ਪਤਾ', 'pass': 'ਪਾਸਵਰਡ', 'forgot': 'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ?', 'btn': 'ਲੌਗਇਨ ਕਰੋ', 'noAccount': 'ਖਾਤਾ ਨਹੀਂ ਹੈ?', 'registerLink': 'ਸਾਈਨ ਅੱਪ ਕਰੋ', 'invalidEmail': 'ਵੈਧ ਈਮੇਲ ਦਰਜ ਕਰੋ', 'invalidPass': 'ਪਾਸਵਰਡ 6+ ਅੱਖਰ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ'};
      default:
        return {'title': 'Welcome Back to Thalo', 'email': 'Email Address', 'pass': 'Password', 'forgot': 'Forgot Password?', 'btn': 'Log In', 'noAccount': "Don't have an account?", 'registerLink': 'Sign Up', 'invalidEmail': 'Please enter a valid email', 'invalidPass': 'Password must be 6+ characters'};
    }
  }

  TextDirection _getDirection(String lang) {
    if (lang == 'Urdu') return TextDirection.rtl;
    return TextDirection.ltr;
  }

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
        MaterialPageRoute(builder: (context) => const ThaloNavigationScreen()),
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

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('पहिले माथि इमेल हाल्नुहोस्।')),
      );
      return;
    }
    try {
      await _authService.sendPasswordReset(_emailController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link इमेलमा पठाइयो।')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
                  const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('Thalo', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),const SizedBox(height: 5),
                  Text(labels['title']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 35),

                  TextFormField(
                    controller: _emailController,
                    textDirection: dir,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: labels['email']!, filled: true, fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
                    ),
                    validator: (value) => (value == null || !value.contains('@')) ? labels['invalidEmail'] : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    textDirection: dir,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: labels['pass']!, filled: true, fillColor: const Color(0xfff5f6f8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => (value == null || value.length < 6) ? labels['invalidPass'] : null,
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: dir == TextDirection.rtl ? Alignment.centerLeft : Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: Text(labels['forgot']!, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            labels['btn']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        labels['noAccount']!,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          labels['registerLink']!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xfff5f6f8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLang,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (val) =>
                                setState(() => _selectedLang = val!),
                            items: _languages
                                .map((v) => DropdownMenuItem<String>(
                                      value: v,
                                      child: Text(v),
                                    ))
                                .toList(),
                          ),
                        ),
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

class ThaloNavigationScreen extends StatefulWidget {
  const ThaloNavigationScreen({super.key});

  @override
  State<ThaloNavigationScreen> createState() => _ThaloNavigationScreenState();
}

class _ThaloNavigationScreenState extends State<ThaloNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('🏠 Thalo Home Screen', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16))),
    const Center(child: Text('🔍 Search Screen', style: TextStyle(color: Colors.grey, fontSize: 16))),
    const Center(child: Text('📊 Analytics Screen', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16))),
    const Center(child: Text('👤 Profile Screen', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        shape: const CircleBorder(),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat Room Button Clicked!')),
          );
        },
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () => setState(() => _currentIndex = 0)),
            IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _currentIndex = 1)),
            const SizedBox(width: 40),
            IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => setState(() => _currentIndex = 2)),
            IconButton(icon: const Icon(Icons.person), onPressed: () => setState(() => _currentIndex = 3)),
          ],
        ),
      ),
    );
  }
}

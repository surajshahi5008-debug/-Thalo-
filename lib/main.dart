import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const ThaloApp());
}

class ThaloApp extends StatelessWidget {
  const ThaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thalo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
        ),
      ),
      home: const ThaloRegisterScreen(),
    );
  }
}

// =====================================================
// AUTH SERVICE
// =====================================================

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await result.user?.updateDisplayName(name.trim());
      await result.user?.reload();

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw _errorMessage(e);
    }
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _errorMessage(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _errorMessage(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'यो इमेल पहिले नै प्रयोगमा छ।';

      case 'invalid-email':
        return 'मान्य इमेल ठेगाना हाल्नुहोस्।';

      case 'weak-password':
        return 'पासवर्ड कम्तीमा ६ अक्षरको हुनुपर्छ।';

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
        return e.message ?? 'केही समस्या भयो। फेरि प्रयास गर्नुहोस्।';
    }
  }
}

// =====================================================
// LANGUAGE DATA
// =====================================================

class LanguageData {
  static const List<String> languages = [
    'नेपाली',
    'हिन्दी',
    'English',
    'Urdu',
  ];

  static Map<String, String> register(String lang) {
    switch (lang) {
      case 'हिन्दी':
        return {
          'title': 'थलो अकाउंट बनाएं',
          'name': 'पूरा नाम',
          'email': 'ईमेल पता',
          'password': 'पासवर्ड',
          'button': 'साइन अप और थलो से जुड़ें',
          'already': 'पहले से अकाउंट है?',
          'login': 'लॉगिन करें',
        };

      case 'English':
        return {
          'title': 'Create Thalo Account',
          'name': 'Full Name',
          'email': 'Email Address',
          'password': 'Password',
          'button': 'Sign Up & Connect to Thalo',
          'already': 'Already have an account?',
          'login': 'Log In',
        };

      case 'Urdu':
        return {
          'title': 'تھلو اکاؤنٹ بنائیں',
          'name': 'پورا نام',
          'email': 'ای میل کا پتہ',
          'password': 'پاس ورڈ',
          'button': 'سائن اپ کریں اور تھلو سے جڑیں',
          'already': 'پہلے سے اکاؤنٹ ہے؟',
          'login': 'لاگ ان کریں',
        };

      default:
        return {
          'title': 'थलो खाता बनाउनुहोस्',
          'name': 'पूरा नाम',
          'email': 'इमेल ठेगाना',
          'password': 'पासवर्ड',
          'button': 'साइन अप र थलोमा जोडिनुहोस्',
          'already': 'पहिले नै खाता छ?',
          'login': 'लगइन गर्नुहोस्',
        };
    }
  }

  static Map<String, String> login(String lang) {
    switch (lang) {
      case 'हिन्दी':
        return {
          'title': 'थलो में फिर से स्वागत है',
          'email': 'ईमेल पता',
          'password': 'पासवर्ड',
          'forgot': 'पासवर्ड भूल गए?',
          'button': 'लॉगिन करें',
          'new': 'नया अकाउंट है?',
          'signup': 'साइन अप करें',
        };

      case 'English':
        return {
          'title': 'Welcome Back to Thalo',
          'email': 'Email Address',
          'password': 'Password',
          'forgot': 'Forgot Password?',
          'button': 'Log In',
          'new': "Don't have an account?",
          'signup': 'Sign Up',
        };

      case 'Urdu':
        return {
          'title': 'تھلو میں دوبارہ خوش آمدید',
          'email': 'ای میل کا پتہ',
          'password': 'پاس ورڈ',
          'forgot': 'پاس ورڈ بھول گئے؟',
          'button': 'لاگ ان کریں',
          'new': 'نیا اکاؤنٹ ہے؟',
          'signup': 'سائن اپ کریں',
        };

      default:
        return {
          'title': 'थलोमा फेरि स्वागत छ',
          'email': 'इमेल ठेगाना',
          'password': 'पासवर्ड',
          'forgot': 'पासवर्ड बिर्सनुभयो?',
          'button': 'लगइन गर्नुहोस्',
          'new': 'नयाँ खाता हो?',
          'signup': 'साइन अप गर्नुहोस्',
        };
    }
  }
}

// =====================================================
// REGISTER SCREEN
// =====================================================

class ThaloRegisterScreen extends StatefulWidget {
  const ThaloRegisterScreen({super.key});

  @override
  State<ThaloRegisterScreen> createState() =>
      _ThaloRegisterScreenState();
}

class _ThaloRegisterScreenState
    extends State<ThaloRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = AuthService();

  bool _loading = false;
  bool _hidePassword = true;

  String _language = 'नेपाली';

  TextDirection get _direction {
    return _language == 'Urdu'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _auth.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ThaloHomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
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
    final text = LanguageData.register(_language);

    return Directionality(
      textDirection: _direction,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Thalo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      text['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // NAME
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: text['name'],
                        prefixIcon:
                            const Icon(Icons.person_outline),
                        filled: true,
                        fillColor:
                            const Color(0xfff5f6f8),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'कृपया आफ्नो नाम हाल्नुहोस्';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: text['email'],
                        prefixIcon:
                            const Icon(Icons.mail_outline),
                        filled: true,
                        fillColor:
                            const Color(0xfff5f6f8),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            !value.contains('@')) {
                          return 'मान्य इमेल हाल्नुहोस्';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        hintText: text['password'],
                        prefixIcon:
                            const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _hidePassword =
                                  !_hidePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor:
                            const Color(0xfff5f6f8),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.length < 6) {
                          return 'पासवर्ड कम्तीमा ६ अक्षरको हुनुपर्छ';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // REGISTER BUTTON
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.black87,
                          foregroundColor:
                              Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                text['button']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // LOGIN
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          text['already']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ThaloLoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            text['login']!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // LANGUAGE
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xfff5f6f8),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child:
                              DropdownButtonHideUnderline(
                            child:
                                DropdownButton<String>(
                              value: _language,
                              items: LanguageData
                                  .languages
                                  .map(
                                    (lang) =>
                                        DropdownMenuItem(
                                      value: lang,
                                      child: Text(lang),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;

                                setState(() {
                                  _language = value;
                                });
                              },
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
      ),
    );
  }
}

// =====================================================
// LOGIN SCREEN
// =====================================================

class ThaloLoginScreen extends StatefulWidget {
  const ThaloLoginScreen({super.key});

  @override
  State<ThaloLoginScreen> createState() =>
      _ThaloLoginScreenState();
}

class _ThaloLoginScreenState
    extends State<ThaloLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = AuthService();

  bool _loading = false;
  bool _hidePassword = true;

  String _language = 'नेपाली';

  TextDirection get _direction {
    return _language == 'Urdu'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _auth.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ThaloHomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _forgotPassword() async {
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'पहिले आफ्नो इमेल ठेगाना हाल्नुहोस्।',
          ),
        ),
      );
      return;
    }

    try {
      await _auth.resetPassword(
        _emailController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset link इमेलमा पठाइएको छ।',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
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
    final text = LanguageData.login(_language);

    return Directionality(
      textDirection: _direction,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Thalo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      text['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: text['email'],
                        prefixIcon:
                            const Icon(Icons.mail_outline),
                        filled: true,
                        fillColor:
                            const Color(0xfff5f6f8),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            !value.contains('@')) {
                          return 'मान्य इमेल हाल्नुहोस्';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        hintText: text['password'],
                        prefixIcon:
                            const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _hidePassword =
                                  !_hidePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor:
                            const Color(0xfff5f6f8),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.length < 6) {
                          return 'पासवर्ड कम्तीमा ६ अक्षरको हुनुपर्छ';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment:
                          Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: Text(
                          text['forgot']!,
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // LOGIN BUTTON
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.black87,
                          foregroundColor:
                              Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                text['button']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          text['new']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ThaloRegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            text['signup']!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // LANGUAGE
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xfff5f6f8),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child:
                              DropdownButtonHideUnderline(
                            child:
                                DropdownButton<String>(
                              value: _language,
                              items: LanguageData
                                  .languages
                                  .map(
                                    (lang) =>
                                        DropdownMenuItem(
                                      value: lang,
                                      child: Text(lang),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;

                                setState(() {
                                  _language = value;
                                });
                              },
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
      ),
    );
  }
}

// =====================================================
// TEMPORARY HOME SCREEN
// =====================================================
// अहिले Login/Register सफल भएपछि यहाँ आउँछ।
// पछि यही ठाउँमा Thalo को मुख्य Feed, Chat, Games,
// Creator आदि सुविधाहरू थप्दै जानेछौँ.

class ThaloHomeScreen extends StatelessWidget {
  const ThaloHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thalo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                'थलोमा स्वागत छ!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                user?.displayName ?? 'Thalo User',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                user?.email ?? '',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ThaloRegisterScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

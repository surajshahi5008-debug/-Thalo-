import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ThaloApp());
}

// Persistent Language and State Controller (सधैं भाषा सुरक्षित राख्ने कन्ट्रोलर)
class LanguageController extends ChangeNotifier {
  String _currentLanguage = 'English';
  String get currentLanguage => _currentLanguage;

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }
}

final languageController = LanguageController();

class ThaloApp extends StatelessWidget {
  const ThaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: languageController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Thalo - Multilingual Social Media',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
          // Firebase Auth State Wrapper for seamless authentication routing
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const ThaloNavigationScreen();
            },
          ),
        );
      },
    );
  }
}

class ThaloNavigationScreen extends StatefulWidget {
  const ThaloNavigationScreen({super.key});

  @override
  State<ThaloNavigationScreen> createState() => _ThaloNavigationScreenState();
}

class _ThaloNavigationScreenState extends State<ThaloNavigationScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation Controllers for Home Screen 3-Word Sequence ("Connect", "Create", "Be Happy")
  late AnimationController _word1Controller;
  late AnimationController _word2Controller;
  late AnimationController _word3Controller;
  late AnimationController _blinkController;

  late Animation<double> _word1Scale;
  late Animation<double> _word2Scale;
  late Animation<double> _word3Scale;
  late Animation<double> _blinkOpacity;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // 1. Word 1: Connect (Pop-up animation)
    _word1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _word1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _word1Controller, curve: Curves.elasticOut),
    );

    // 2. Word 2: Create (Pop-up animation)
    _word2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _word2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _word2Controller, curve: Curves.elasticOut),
    );

    // 3. Word 3: Be Happy (Pop-up animation)
    _word3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _word3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _word3Controller, curve: Curves.elasticOut),
    );

    // 4. Blink Effect on the final word
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _blinkOpacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Trigger Synchronized Animation & Progressive Sound Sequence
    _startSequence();
  }

  void _startSequence() async {
    try {
      // Step 1: Connect + First Ting (Volume 0.5)
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _word1Controller.forward();
      await _audioPlayer.setVolume(0.5);
      await _audioPlayer.play(AssetSource('ting.mp3'));

      // Step 2: Create + Second Ting (Volume 0.8)
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _word2Controller.forward();
      await _audioPlayer.setVolume(0.8);
      await _audioPlayer.play(AssetSource('ting.mp3'));

      // Step 3: Be Happy + Final Ting (Volume 1.0)
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _word3Controller.forward();
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('ting.mp3'));

      // Concluding Blink Effect on the last word
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _blinkController.repeat(reverse: true);
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }
  }

  @override
  void dispose() {
    _word1Controller.dispose();
    _word2Controller.dispose();
    _word3Controller.dispose();
    _blinkController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Accurate Ordinal Age Calculation Utility (अर्डिनल गणना जस्तै ३२औं, 32nd)
  String _getOrdinalNumber(int number, String lang) {
    if (lang == 'Nepali' || lang == 'Hindi') {
      return '$numberऔं';
    } else if (lang == 'Nepal Bhasa') {
      return '$numberगु';
    } else {
      if (number % 100 >= 11 && number % 100 <= 13) {
        return '${number}th';
      }
      switch (number % 10) {
        case 1: return '${number}st';
        case 2: return '${number}nd';
        case 3: return '${number}rd';
        default: return '${number}th';
      }
    }
  }

  // Dynamic Calendar Date Converter (AD, BS, Nepal Sambat integration)
  Map<String, String> _convertCalendarDates(DateTime adDate) {
    int bsYear = adDate.year + 56;
    int bsMonth = adDate.month + 8;
    if (bsMonth > 12) {
      bsMonth -= 12;
      bsYear += 1;
    }
    int nsYear = adDate.year - 880;

    return {
      'ad': '${adDate.year}-${adDate.month.toString().padLeft(2, '0')}-${adDate.day.toString().padLeft(2, '0')}',
      'bs': '$bsYear-$bsMonth-${adDate.day}',
      'ns': '$nsYear Nepal Sambat',
    };
  }

  // Multilingual Text Dictionary (Supported: English, Nepali, Nepal Bhasa, Hindi, Urdu)
  String _getLocalizedText(String key) {
    final lang = languageController.currentLanguage;
    final Map<String, Map<String, String>> localizedValues = {
      'English': {
        'connect': 'Connect',
        'create': 'Create',
        'be_happy': 'Be Happy',
        'home': 'Home',
        'calendar': 'Calendar',
        'profile': 'Profile',
        'settings': 'Settings',
        'cal_title': 'Dynamic Calendar & Date Converter',
        'profile_title': 'User Profile & Account',
        'logout': 'Sign Out',
      },
      'Nepali': {
        'connect': 'जोडिनुहोस्',
        'create': 'सिर्जना गर्नुहोस्',
        'be_happy': 'खुसी रहनुहोस्',
        'home': 'गृहपृष्ठ',
        'calendar': 'पात्रो',
        'profile': 'प्रोफाइल',
        'settings': 'सेटिङ्स',
        'cal_title': 'डाइनामिक पात्रो र मिति रूपान्तरण',
        'profile_title': 'प्रयोगकर्ता प्रोफाइल र खाता',
        'logout': 'लगआउट गर्नुहोस्',
      },
      'Nepal Bhasa': {
        'connect': 'स्वापू तयादिसँ',
        'create': 'सृष्टि यानादिसँ',
        'be_happy': 'हर्षित जुयादिसँ',
        'home': 'छेँ',
        'calendar': 'पात्रो',
        'profile': 'विवरण',
        'settings': 'मिलायेगु',
        'cal_title': 'पात्रो व तिथि हिलाबुला',
        'profile_title': 'छ्यमि प्रोफाइल व ल्याः',
        'logout': 'पिहाँ वनेगु',
      },
      'Hindi': {
        'connect': 'जुड़ें',
        'create': 'बनाएं',
        'be_happy': 'खुश रहें',
        'home': 'होम',
        'calendar': 'कैलेंडर',
        'profile': 'प्रोफ़ाइल',
        'settings': 'सेटिंग्स',
        'cal_title': 'डाइनामिक कैलेंडर और तिथि रूपांतरण',
        'profile_title': 'उपयोगकर्ता प्रोफ़ाइल और खाता',
        'logout': 'साइन आउट',
      },
      'Urdu': {
        'connect': 'جੁڑیں',
        'create': 'تخلیق کریں',
        'be_happy': 'خوش رہیں',
        'home': 'ہوم',
        'calendar': 'کیلنڈر',
        'profile': 'پروفাইল',
        'settings': 'ترتیبات',
        'cal_title': 'ڈائنامಿಕ್ کیلنڈر اور تاریخ کی تبدیلی',
        'profile_title': 'صارف پروفাইল اور اکاؤنٹ',
        'logout': 'سائن آؤٹ',
      },
    };

    return localizedValues[lang]?[key] ?? localizedValues['English']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    final String currentLang = languageController.currentLanguage;
    final convertedDates = _convertCalendarDates(DateTime.now());

    final List<Widget> screens = [
      // 1. Home Screen with Pop-up Animations & Synchronized Ting Sounds
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _word1Scale,
              child: Text(
                _getLocalizedText('connect'),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 16),
            ScaleTransition(
              scale: _word2Scale,
              child: Text(
                _getLocalizedText('create'),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            ScaleTransition(
              scale: _word3Scale,
              child: FadeTransition(
                opacity: _blinkOpacity,
                child: Text(
                  _getLocalizedText('be_happy'),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // 2. Calendar Screen (Supporting AD, BS, Nepal Sambat & Ordinal Age like '32औं')
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                _getLocalizedText('cal_title'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('AD (इस्वी): ${convertedDates['ad']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const Divider(),
                      Text('BS (विक्रम): ${convertedDates['bs']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const Divider(),
                      Text('NS (नेपाल संवत्): ${convertedDates['ns']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ordinal Age Example: ${_getOrdinalNumber(32, currentLang)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.deepPurple),
              ),
            ],
          ),
        ),
      ),

      // 3. Profile Screen (Firebase User Profile)
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                _getLocalizedText('profile_title'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('surajshahi5008@gmail.com', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: Text(_getLocalizedText('logout')),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),

      // 4. Settings / Language Screen (Persistent Language Switcher)
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select App Language / भाषा छान्नुहोस्',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: currentLang,
                  underline: const SizedBox(),
                  items: ['English', 'Nepali', 'Nepal Bhasa', 'Hindi', 'Urdu']
                      .map((lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang, style: const TextStyle(fontSize: 16)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      languageController.setLanguage(val);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Thalo - $currentLang'),
        centerTitle: true,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _getLocalizedText('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: _getLocalizedText('calendar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: _getLocalizedText('profile'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: _getLocalizedText('settings'),
          ),
        ],
      ),
    );
  }
}

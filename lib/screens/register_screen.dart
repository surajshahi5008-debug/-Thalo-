import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/lang_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  
  // बहु-चरण (Multi-step) को लागि करेन्ट स्टेप कन्ट्रोलर
  int _currentStep = 0;

  // इनपुट कन्ट्रोलरहरू
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  DateTime? _selectedDate;
  int? _calculatedAge;
  String _selectedLang = 'English';
  bool _isLoading = false;
  String _errorMessage = '';

  // उमेर गणना गर्ने फंक्सन
  void _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    setState(() {
      _selectedDate = birthDate;
      _calculatedAge = age;
    });
  }

  // जन्म मिति छान्ने बक्स देखाउने फंक्सन
  Future<void> _pickBirthDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _calculateAge(picked);
    }
  }

  // दर्ता गर्ने मुख्य फंक्सन
  void _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        age: _calculatedAge ?? 0,
      );
      // सफल भएपछि गरिने कामहरू (पछिल्लो चरणमा थप्नेछौं)
    } catch (e) {
      setState(() {
        _errorMessage = getLocalizedError(e.toString(), _selectedLang);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedLang == 'English' ? 'Register' : 'दर्ता गर्नुहोस्'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildLang_bar(_selectedLang, (lang) {
              setState(() {
                _selectedLang = lang;
              });
            }),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() {
                      _currentStep += 1;
                    });
                  } else {
                    _register();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                steps: [
                  // चरण १: सामान्य विवरण (नाम, इमेल, पासवर्ड)
                  Step(
                    title: Text(_selectedLang == 'English' ? 'Account Info' : 'खाता विवरण'),
                    content: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: _selectedLang == 'English' ? 'Full Name' : 'पूरा नाम',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: _selectedLang == 'English' ? 'Email' : 'इमेल',
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: _selectedLang == 'English' ? 'Password' : 'पासवर्ड',
                          ),
                          obscureText: true,
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                  ),
                  
                  // चरण २: जन्म मिति र उमेर गणना
                  Step(
                    title: Text(_selectedLang == 'English' ? 'Date of Birth' : 'जन्म मिति'),
                    content: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickBirthDate(context),
                          child: Text(_selectedDate == null
                              ? (_selectedLang == 'English' ? 'Select Birth Date' : 'जन्म मिति छान्नुहोस्')
                              : '${_selectedDate!.toLocal()}'.split(' ')[0]),
                        ),
                        const SizedBox(height: 12),
                        if (_calculatedAge != null)
                          Text(
                            _selectedLang == 'English'
                                ? 'Calculated Age: $_calculatedAge years'
                                : 'गणित गरिएको उमेर: $_calculatedAge वर्ष',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                  ),

                  // चरण ३: पुष्टिकरण र सबमिट
                  Step(
                    title: Text(_selectedLang == 'English' ? 'Confirmation' : 'पुष्टिकरण'),
                    content: Text(
                      _selectedLang == 'English'
                          ? 'Review your details and click submit to finish registration.'
                          : 'तपाईंको विवरणहरू जाँच गर्नुहोस् र दर्ता पूरा गर्न सबमिट थिच्नुहोस्।',
                    ),
                    isActive: _currentStep >= 2,
                  ),
                ],
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

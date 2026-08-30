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
  
  // बहु-चरण (Multi-step) कन्ट्रोलर
  int _currentStep = 0;

  // नामका इनपुट कन्ट्रोलरहरू
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  
  // इमेल र पासवर्ड कन्ट्रोलरहरू
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // लिङ्ग र जन्म मिति चरहरू
  String? _selectedGender;
  final List<String> _gendersEnglish = ['Male', 'Female', 'Other'];
  final List<String> _gendersNepali = ['पुरुष', 'महिला', 'अन्य'];

  DateTime? _selectedDate;
  int? _years;
  int? _days;
  
  String _selectedLang = 'English';
  bool _isLoading = false;
  String _errorMessage = '';

  // उमेर र दिन गणना गर्ने फंक्सन
  void _calculateAgeAndDays(DateTime birthDate) {
    DateTime today = DateTime.now();
    
    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (days < 0) {
      months--;
      // अघिल्लो महिनामा कति दिन थियो भन्ने हिसाब गर्न
      DateTime prevMonth = DateTime(today.year, today.month - 1, 0);
      days += prevMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    // कुल दिनको अनुमान वा महिना-दिन देखाउन सकिन्छ, यहाँ हामी सटीक वर्ष र दिन निकाल्छौं
    int totalDays = today.difference(birthDate).inDays;

    setState(() {
      _selectedDate = birthDate;
      _years = years;
      _days = totalDays; // कुल दिन वा बचेको दिन देखाउन सकिन्छ
    });
  }

  // जन्म मिति छान्ने बक्स
  Future<void> _pickBirthDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _calculateAgeAndDays(picked);
    }
  }

  // दर्ता गर्ने मुख्य फंक्सन
  void _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String fullName = '${_firstNameController.text} ${_middleNameController.text} ${_lastNameController.text}'.trim();

    try {
      await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: fullName,
        age: _years ?? 0,
      );
      // सफल भएपछि गरिने काम
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
    bool isEng = _selectedLang == 'English';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEng ? 'Create Thalo Account' : 'थलो खाता सिर्जना गर्नुहोस्'),
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
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(_currentStep == 0 
                              ? (isEng ? 'Next' : 'अर्को') 
                              : (isEng ? 'Sign Up' : 'साइन अप')),
                        ),
                        if (_currentStep > 0) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: Text(isEng ? 'Back' : 'पछाडि'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                onStepContinue: () {
                  if (_currentStep < 1) {
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
                  // चरण १: नाम, लिङ्ग र जन्म मिति
                  Step(
                    title: Text(isEng ? 'Personal Details' : 'व्यक्तिगत विवरण'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: isEng ? 'First Name' : 'पहिलो नाम',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _middleNameController,
                          decoration: InputDecoration(
                            labelText: isEng ? 'Middle Name (Optional)' : 'बीचको नाम (ऐच्छिक)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: isEng ? 'Last Name' : 'थर',
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            labelText: isEng ? 'Gender' : 'लिङ्ग',
                          ),
                          items: (isEng ? _gendersEnglish : _gendersNepali)
                              .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _pickBirthDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_selectedDate == null
                              ? (isEng ? 'Select Birth Date' : 'जन्म मिति छान्नुहोस्')
                              : '${_selectedDate!.toLocal()}'.split(' ')[0]),
                        ),
                        const SizedBox(height: 12),
                        if (_years != null && _days != null)
                          Text(
                            isEng
                                ? 'Age: $_years years (Total approx. $_days days)'
                                : 'उमेर: $_years वर्ष (जम्मा करिब $_days दिन)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                  ),
                  
                  // चरण २: इमेल र पासवर्ड
                  Step(
                    title: Text(isEng ? 'Account Credentials' : 'खाताको विवरण'),
                    content: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: isEng ? 'Email Address' : 'इमेल ठेगाना',
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: isEng ? 'Password' : 'पासवर्ड',
                          ),
                          obscureText: true,
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 1,
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

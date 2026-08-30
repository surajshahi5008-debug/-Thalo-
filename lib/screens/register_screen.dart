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

  // जन्म मिति छान्ने र उमेर तथा दिन गणना गर्ने फंक्सन
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculateAgeAndDays(picked);
      });
    }
  }

  void _calculateAgeAndDays(DateTime birthDate) {
    DateTime today = DateTime.now();
    
    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (months < 0 || (months == 0 && days < 0)) {
      years--;
    }

    // कुल दिनको गणना
    Duration difference = today.difference(birthDate);
    
    setState(() {
      _years = years;
      _days = difference.inDays;
    });
  }

  // दर्ता प्रक्रिया पूरा गर्ने फंक्सन
  void _handleRegister() async {
    setState(() => _isLoading = true);
    
    String firstName = _firstNameController.text.trim();
    String middleName = _middleNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    
    String fullName = middleName.isEmpty 
        ? '$firstName $lastName' 
        : '$firstName $middleName $lastName';

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      await _authService.registerWithEmailAndPassword(email, password, fullName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentGenders = _selectedLang == 'Nepali' ? _gendersNepali : _gendersEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedLang == 'Nepali' ? 'थालो खाता सिर्जना गर्नुहोस्' : 'Create Thalo Account'),
      ),
      body: Column(
        children: [
          LangBar(
            selectedLang: _selectedLang,
            onLangChanged: (lang) => setState(() => _selectedLang = lang),
          ),
          Expanded(
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              onStepContinue: () {
                if (_currentStep < 1) {
                  setState(() => _currentStep += 1);
                } else {
                  _handleRegister();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              steps: [
                // चरण १: व्यक्तिगत विवरण (Name, Gender, DOB)
                Step(
                  title: Text(_selectedLang == 'Nepali' ? 'व्यक्तिगत विवरण' : 'Personal Details'),
                  content: Column(
                    children: [
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: _selectedLang == 'Nepali' ? 'पहिलो नाम' : 'First Name',
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _middleNameController,
                        decoration: InputDecoration(
                          labelText: _selectedLang == 'Nepali' ? 'बुवाको वा बीचको नाम (ऐच्छिक)' : 'Middle Name (Optional)',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: _selectedLang == 'Nepali' ? 'थथर (लास्ट नेम)' : 'Last Name',
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        hint: Text(_selectedLang == 'Nepali' ? 'लिङ्ग छान्नुहोस्' : 'Select Gender'),
                        items: currentGenders.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.wc),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? (_selectedLang == 'Nepali' ? 'जन्म मिति छनौट गरिएको छैन' : 'No Date Chosen')
                                  : '${_selectedLang == 'Nepali' ? 'जन्म मिति' : 'DOB'}: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: Text(_selectedLang == 'Nepali' ? 'मिति छान्नुहोस्' : 'Pick Date'),
                          ),
                        ],
                      ),
                      if (_years != null && _days != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _selectedLang == 'Nepali'
                              ? 'उमेर: $_years वर्ष ($_days दिन)'
                              : 'Age: $_years years ($_days days)',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                  isActive: _currentStep >= 0,
                ),
                // चरण २: इमेल र पासवर्ड (Email & Password)
                Step(
                  title: Text(_selectedLang == 'Nepali' ? 'लगइन विवरण' : 'Login Credentials'),
                  content: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: _selectedLang == 'Nepali' ? 'इमेल ठेगाना' : 'Email Address',
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: _selectedLang == 'Nepali' ? 'पासवर्ड' : 'Password',
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      if (_isLoading) ...[
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                  isActive: _currentStep >= 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

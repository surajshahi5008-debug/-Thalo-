import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ThaloApp());
}

class ThaloApp extends StatelessWidget {
  const ThaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthWrapper(),
    );
  }
}


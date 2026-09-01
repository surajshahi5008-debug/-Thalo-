
import 'package:flutter/material.dart';
import 'package:thalo/screens/login_screen.dart';
import 'package:thalo/screens/register_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ThaloApp());
}

class ThaloApp extends StatefulWidget {
  const ThaloApp({Key? key}) : super(key: key);

  @override
  State<ThaloApp> createState() => _ThaloAppState();
}

class _ThaloAppState extends State<ThaloApp> {
  void _handleNotificationTap(String? payload) {
    debugPrint("Notification tapped with payload: $payload");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thalo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(
              onNotificationTap: _handleNotificationTap,
            ),
        '/register': (context) => RegisterScreen(
              onNotificationTap: _handleNotificationTap,
            ),
      },
    );
  }
}

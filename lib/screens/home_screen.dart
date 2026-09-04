import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thalo Home'),
      ),
      body: const Center(
        child: Text(
          'स्वागत छ! (Welcome to Home Screen)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

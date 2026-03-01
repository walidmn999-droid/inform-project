import 'package:flutter/material.dart';
import 'ui/login_page.dart';

void main() {
  runApp(const InformDesktopApp());
}

class InformDesktopApp extends StatelessWidget {
  const InformDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'inform typing photo copy',
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A43D8)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

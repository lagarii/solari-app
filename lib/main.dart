import 'package:flutter/material.dart';
import 'screens/giris_ekrani.dart';

void main() {
  runApp(const SolariApp());
}

class SolariApp extends StatelessWidget {
  const SolariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GirisEkrani(),
    );
  }
}

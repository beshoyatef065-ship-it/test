import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NearestChurchApp());
}

class NearestChurchApp extends StatelessWidget {
  const NearestChurchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أقرب كنيسة',
      debugShowCheckedModeBadge: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

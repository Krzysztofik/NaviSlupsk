import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/welcome_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Oyko'),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

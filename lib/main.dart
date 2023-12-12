import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/app4slupsk.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Oyko'),
      home: const App4Slupsk(),
      debugShowCheckedModeBanner: false,
    );
  }
}
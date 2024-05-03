import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/main_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

//Ekran startowy
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aplikacja nawigacyjna audio',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.anchor_sharp),
          color: Colors.black,
          onPressed: () {},
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapScreen()),
            );
          },
          child: const Text('Do mapy'),
        ),
      ),
    );
  }
}

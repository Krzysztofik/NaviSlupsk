import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/main_screen.dart';

class App4Slupsk extends StatelessWidget {
  const App4Slupsk({super.key});

//Ekran startowy, imitacja App4Slupsk menu z kafelkami.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App4Słupsk',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.anchor_sharp),
          color: Colors.black,
          onPressed: () {
          },
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

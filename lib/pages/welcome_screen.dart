// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _buttonController;
  late Animation<Offset> _buttonSlideAnimation;

  bool _showButtons = false; // Kontrola wyświetlania przycisków

  @override
  void initState() {
    super.initState();

    // Animacja logo
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Czas trwania animacji
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Animacja przycisków (slide up)
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start poza ekranem
      end: Offset.zero, // Pojawienie się na ekranie
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    _controller.forward();

    // Po zakończeniu animacji logo wyświetl przyciski
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showButtons = true;
        });
        _buttonController.forward(); // Animacja przycisków
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonController.dispose(); // Pamiętaj o zamknięciu obu kontrolerów
    super.dispose();
  }

  // Funkcja nawigacji z efektem fade, po kliknięciu przycisku
  void _navigateWithFade() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MapScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      ),
    );
  }

  // Funkcja stylu przycisku
  Widget _buildLanguageButton(String label, String flagAsset, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white, // Kolor tekstu
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 5,
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      icon: Image.asset(flagAsset, width: 24, height: 24), // Ikona flagi
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animacja logo i tekstu
          Center(
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2), // Czas trwania animacji
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo512.png',
                          width: 200, // Możesz dostosować rozmiar
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        // Tekst
                        Text(
                          'NaviSłupsk',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Przycisk wyboru języka (po zakończeniu animacji)
          if (_showButtons)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _buttonSlideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Przycisk wyboru polskiego
                    _buildLanguageButton(
                      'Polski',
                      'assets/images/poland_flag.png',
                      () {
                        _navigateWithFade(); // Po kliknięciu
                      },
                    ),
                    const SizedBox(height: 20), // Odstęp między przyciskami
                    // Przycisk wyboru angielskiego
                    _buildLanguageButton(
                      'English',
                      'assets/images/uk_flag.png',
                      () {
                        _navigateWithFade(); // Po kliknięciu
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

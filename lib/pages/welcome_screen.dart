import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/boarding_screen.dart';
import 'package:google_maps_app/pages/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class WelcomeScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged; // Funkcja zmieniająca język

  const WelcomeScreen({super.key, required this.onLanguageChanged});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _buttonController;
  late Animation<Offset> _buttonSlideAnimation;

  bool _showButtons = false; // Kontrola wyświetlania przycisków
  bool _isFirstLaunch = true; // Flaga pierwszego uruchomienia

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch(); // Sprawdzenie, czy to pierwsze uruchomienie

    // Animacja logo
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    _controller.forward();

    // Po zakończeniu animacji logo wyświetl przyciski tylko, jeśli to pierwsze uruchomienie
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isFirstLaunch) {
        setState(() {
          _showButtons = true;
        });
        _buttonController.forward(); // Animacja przycisków
      } else if (!_isFirstLaunch) {
        _navigateWithFade(); // Jeśli nie jest to pierwsze uruchomienie, przejdź bezpośrednio do następnego ekranu
      }
    });
  }

  // Sprawdzenie, czy to pierwsze uruchomienie aplikacji
  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstLaunch = prefs.getBool('firstLaunch');
    String? savedLanguageCode = prefs.getString('selectedLanguageCode');

    if (firstLaunch == null || firstLaunch) {
      // Jeśli to pierwsze uruchomienie, ustaw flagę
      _isFirstLaunch = true;
      prefs.setBool('firstLaunch', false); // Zapisz, że użytkownik uruchomił aplikację po raz pierwszy
    } else {
      _isFirstLaunch = false;
      // Jeśli język był wcześniej wybrany, ustaw go
      if (savedLanguageCode != null) {
        widget.onLanguageChanged(Locale(savedLanguageCode));
      }
    }
  }

  // Zapisz wybrany język i przejdź do następnego ekranu
  Future<void> _onLanguageSelected(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguageCode', languageCode); // Zapisz wybrany język
    widget.onLanguageChanged(Locale(languageCode)); // Zmień język
    _navigateWithFade();
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonController.dispose(); // Pamiętaj o zamknięciu obu kontrolerów
    super.dispose();
  }

  // Funkcja nawigacji z efektem fade, po kliknięciu przycisku
  void _navigateWithFade() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (_isFirstLaunch == true) {
    // Jeśli to pierwsze uruchomienie, przejdź do ekranu onboardingu
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(),
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
  } else {
    // Jeśli to nie pierwsze uruchomienie, przejdź do głównego ekranu
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
  }
}


  // Funkcja stylu przycisku
  Widget _buildLanguageButton(String label, String flagAsset, String languageCode) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 5,
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      icon: Image.asset(flagAsset, width: 24, height: 24),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () => _onLanguageSelected(languageCode), // Zapisz i zmień język
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
              duration: const Duration(seconds: 2),
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
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        // Tekst
                        const Text(
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
                      'pl', // Kod języka
                    ),
                    const SizedBox(height: 20),
                    // Przycisk wyboru angielskiego
                    _buildLanguageButton(
                      'English',
                      'assets/images/uk_flag.png',
                      'en', // Kod języka
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

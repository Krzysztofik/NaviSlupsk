import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/boarding_screen.dart';
import 'package:google_maps_app/pages/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_app/models/globals.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_app/providers/locale_provider.dart';

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

  bool _showButtons = false; 
  bool _isFirstLaunch = true; 

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();

    // Logo animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Buttons slide up animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isFirstLaunch) {
        setState(() {
          _showButtons = true;
        });
        _buttonController.forward(); 
      } else if (!_isFirstLaunch) {
        _navigateWithSlide(); 
      }
    });
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstLaunch = prefs.getBool('firstLaunch');
    String? savedLanguageCode = prefs.getString('selectedLanguageCode');

    if (firstLaunch == null || firstLaunch) {
      _isFirstLaunch = true;
      prefs.setBool('firstLaunch', false); 
    } else {
      _isFirstLaunch = false;
      if (savedLanguageCode != null) {
        Provider.of<LocaleProvider>(context, listen: false).setLocale(Locale(savedLanguageCode));
      }
    }
  }

  Future<void> _onLanguageSelected(String languageCode) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguageCode', languageCode);
    
    localeProvider.setLocale(Locale(languageCode)); 
    final globals = Globals();
    globals.setLanguageCode(languageCode);
    _navigateWithSlide();
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _navigateWithSlide() {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return _isFirstLaunch ? OnboardingScreen() : MapScreen();
      },
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

  Widget _buildLanguageButton(String label, String flagAsset, String languageCode) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, 
        backgroundColor: Colors.white,
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
      onPressed: () => _onLanguageSelected(languageCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
                        Image.asset(
                          'assets/images/logo512.png',
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 20),
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
                    _buildLanguageButton(
                      'Polski',
                      'assets/images/poland_flag.png',
                      'pl',
                    ),
                    const SizedBox(height: 20),
                    _buildLanguageButton(
                      'English',
                      'assets/images/uk_flag.png',
                      'en',
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

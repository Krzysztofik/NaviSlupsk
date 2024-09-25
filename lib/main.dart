import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_app/pages/welcome_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white, // Kolor dolnego paska nawigacji
    systemNavigationBarIconBrightness: Brightness.light, // Jasność ikon w dolnym pasku nawigacji
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    ]);
  runApp(MyApp());
  }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('pl');

  // Funkcja do zmiany języka
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Oyko'),
      home: WelcomeScreen(onLanguageChanged: setLocale), // Przekazujemy funkcję zmiany języka
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // Angielski
        Locale('pl'), // Polski
      ],
    );
  }
}

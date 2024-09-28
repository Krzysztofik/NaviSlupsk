import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_app/pages/welcome_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_app/providers/globals.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wykonanie kodu asynchronicznego przed uruchomieniem aplikacji.
  await Firebase.initializeApp(); // Inicjalizacja Firebase przed uruchomieniem aplikacji

  // Ustawienie koloru dolnego paska nawigacji i jasności ikon w systemie.
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
  ));

  // Globalne zmienne i ładowanie zapisanego wcześniej kodu języka.
  final globals = Globals();
  await globals.loadLanguageCode();

  // Ustawienie preferowanej orientacji na pionową.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Uruchomienie aplikacji.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider dostarcza LocaleProvider do wszystkich widgetów aplikacji
    return ChangeNotifierProvider(
      // Tworzenie nowego LocaleProvider, używając zapisanego języka z Globals.
      create: (context) => LocaleProvider(Locale(Globals().languageCode)),
      // Consumer nasłuchuje zmian w LocaleProvider i odświeża widżety przy zmianie.
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            theme: ThemeData(fontFamily: 'Oyko'), // Motyw aplikacji.
            home: WelcomeScreen(), // Ekran do którego przechodzi aplikacja.
            debugShowCheckedModeBanner: false, // Baner trybu debugowania.
            locale: localeProvider.locale, // Bieżąca lokalizacja (localeProvider).
            localizationsDelegates: [
              AppLocalizations.delegate, // Lokalizacje dla aplikacji
              GlobalMaterialLocalizations.delegate, // Lokalizacje materiałowe
              GlobalWidgetsLocalizations.delegate, // Lokalizacje dla widżetów
              GlobalCupertinoLocalizations.delegate, // Lokalizacje dla Cupertino
            ],
            supportedLocales: const [
              Locale('en'), // Angielski
              Locale('pl'), // Polski
            ],
          );
        },
      ),
    );
  }
}

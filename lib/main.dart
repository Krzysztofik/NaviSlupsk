import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_app/pages/welcome_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_app/providers/globals.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'providers/audio_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wykonanie kodu asynchronicznego przed uruchomieniem aplikacji.
  await Firebase.initializeApp(); // Inicjalizacja Firebase przed uruchomieniem aplikacji

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
    // Używamy MultiProvider, aby zarządzać wieloma providerami
    return MultiProvider(
      providers: [
        // LocaleProvider do zarządzania językiem
        ChangeNotifierProvider(
          create: (context) => LocaleProvider(Locale(Globals().languageCode)),
        ),
        // AudioState do zarządzania stanem wyciszenia dźwięków
        ChangeNotifierProvider(
          create: (context) => AudioState(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            theme: ThemeData(fontFamily: 'Oyko'),
            home: WelcomeScreen(),
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('pl'),
            ],
          );
        },
      ),
    );
  }
}
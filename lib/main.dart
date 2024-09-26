import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_app/pages/welcome_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_app/models/globals.dart';
import 'package:provider/provider.dart'; // Importujemy provider
import 'providers/locale_provider.dart'; // Importujemy nasz nowy provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white, // Kolor dolnego paska nawigacji
    systemNavigationBarIconBrightness: Brightness.light, // Jasność ikon w dolnym pasku nawigacji
  ));

  final globals = Globals();
  await globals.loadLanguageCode();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(Locale(Globals().languageCode)), // Użycie LocaleProvider
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            theme: ThemeData(fontFamily: 'Oyko'),
            home: WelcomeScreen(), // Przekazujemy funkcję zmiany języka
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale, // Używamy lokalizacji z provider
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
        },
      ),
    );
  }
}

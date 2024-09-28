import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_app/providers/globals.dart';
import 'package:google_maps_app/models/route_model.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale; // Prywatna zmienna z aktualnym językiem aplikacji.
  List<RouteModel> _routes = []; // Trasy w zależności od wybranego języka.

  Locale? get locale => _locale; // Getter zwracający bieżący język.
  List<RouteModel> get routes => _routes; // Getter zwracający listę tras.

  LocaleProvider(this._locale); // Konstruktor przyjmujący początkową lokalizację.

  // Funkcja ustawiająca nowy język aplikacji.
  void setLocale(Locale locale) async {
    // Nowa zmienna języka do zmiennej prywatnej.
    _locale = locale;

    // Powiadamiamy obserwatorów o zmianie.
    notifyListeners();
    
    // Aktualizacja globalnego kodu języka w aplikacji.
    Globals().languageCode = locale.languageCode;

    // Zapisz wybrany kod języka w pamięci lokalnej
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguageCode', locale.languageCode);

    // Załaduj trasy w zależności od nowego języka.
    await loadRoutes();
  }

  // Funkcja ładująca zapisanego języka z pamięci lokalnej.
  Future<void> loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Pobierz zapisany kod języka z SharedPreferences.
    String? savedLanguageCode = prefs.getString('selectedLanguageCode');

    // Jeśli zapisany kod języka istnieje, ustaw go jako bieżący.
    if (savedLanguageCode != null) {
      _locale = Locale(savedLanguageCode);
      await loadRoutes(); 
    }
  }

  // Funkcja ładująca trasy w zależności od bieżącego języka.
  Future<void> loadRoutes() async {
    _routes = await RouteModel.getRoutes();
    notifyListeners(); 
  }
}

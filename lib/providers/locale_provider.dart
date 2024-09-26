import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_app/models/globals.dart';
import 'package:google_maps_app/models/route_model.dart'; // Ensure you import the route model

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  List<RouteModel> _routes = [];

  Locale? get locale => _locale;
  List<RouteModel> get routes => _routes;

  LocaleProvider(this._locale);

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    print('Setting locale to: ${locale.languageCode}'); // Logowanie zmiany języka


    Globals().languageCode = locale.languageCode;

    // Save the selected language code to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguageCode', locale.languageCode);

    // Load routes based on the new locale
    await loadRoutes();
  }

  Future<void> loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguageCode = prefs.getString('selectedLanguageCode');

    if (savedLanguageCode != null) {
      _locale = Locale(savedLanguageCode);
      await loadRoutes(); // Load routes when locale is loaded
    }
  }

  Future<void> loadRoutes() async {
    // Fetch routes based on current locale
    _routes = await RouteModel.getRoutes();
    notifyListeners(); // Notify listeners to refresh UI
  }
}

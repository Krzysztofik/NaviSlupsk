library globals;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isSoundEnabled = true;

  bool isBottomMenuVisible = true;
  bool isInfoVisible = false;
  bool isNavigationActive = false;
  

class Globals with ChangeNotifier {
  static final Globals _instance = Globals._internal();
  factory Globals() => _instance;

  Globals._internal();
  
  String languageCode = 'pl'; // default language code
  String get _languageCode => languageCode;
  Future<void> loadLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguageCode = prefs.getString('selectedLanguageCode');
    if (savedLanguageCode != null) {
      languageCode = savedLanguageCode;
      print('Loaded language code from SharedPreferences: $languageCode');
    }
    notifyListeners();
  }

  void setLanguageCode(String newLanguageCode) {
  languageCode = newLanguageCode; // This should be the class variable
  print('Language code set to: $languageCode'); // Log language code setting
  notifyListeners();
}
}


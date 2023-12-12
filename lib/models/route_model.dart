import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

//Zaciąganie informacji i tworzenie modelu trasy na podstawie pliku JSON.
class RouteModel {
  String name;
  String imagePath;
  List<Map<String, double>> points;

  RouteModel({
    required this.name,
    required this.imagePath,
    required this.points,
  });

  static Future<List<RouteModel>> getRoutes() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/routes.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    List<RouteModel> menus = [];

    for (var item in jsonData) {
      List<Map<String, double>> pointsList = [];
      if (item['points'] != null) {
        for (var point in item['points']) {
          pointsList.add({
            'latitude': point['latitude'].toDouble(),
            'longitude': point['longitude'].toDouble(),
          });
        }
      }

      menus.add(
        RouteModel(
          name: item['name'],
          imagePath: item['imagePath'],
          points: pointsList,
        ),
      );
    }

    return menus;
  }
}

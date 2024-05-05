import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

// Load route information and create a route model based on a JSON file.
class RouteModel {
  final String name;
  final String imagePath;
  final List<Map<String, double>> points;

  const RouteModel({
    required this.name,
    required this.imagePath,
    required this.points,
  });

  static Future<List<RouteModel>> getRoutes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/json/routes.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      final List<RouteModel> routes = [];

      for (var item in jsonData) {
        final List<Map<String, double>> pointsList = [];
        if (item['points']!= null) {
          for (var point in item['points']) {
            pointsList.add({
              'latitude': point['latitude'].toDouble(),
              'longitude': point['longitude'].toDouble(),
            });
          }
        }

        routes.add(
          RouteModel(
            name: item['name'],
            imagePath: item['imagePath'],
            points: pointsList,
          ),
        );
      }

      // Print all route information to the console
      for (var route in routes) {
        print('Route: ${route.name}');
        print('  Image Path: ${route.imagePath}');
        print('  Points:');
        for (var point in route.points) {
          print('    Latitude: ${point['latitude']}, Longitude: ${point['longitude']}');
        }
      }

      return routes;
    } catch (e) {
      print('Error loading routes: $e');
      return [];
    }
  }
}
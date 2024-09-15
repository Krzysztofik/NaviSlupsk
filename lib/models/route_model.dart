// ignore_for_file: avoid_print
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class PointModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int routeId;
  final String? imagePath;
  final String? description;
  final String? longDescription;
  bool isDiscovered;

  PointModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.routeId,
    this.imagePath,
    this.description,
    this.longDescription, 
    this.isDiscovered = false
  });
}

class RouteModel {
  final int id;
  final String name;
  final String imagePath;
  final List<PointModel> points;

  const RouteModel({
    required this.id,
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
        final List<PointModel> pointsList = [];
        if (item['points']!= null) {
          for (var point in item['points']) {
            pointsList.add(
              PointModel(
                id: point['id'],
                name: point['name'],
                latitude: point['latitude'].toDouble(),
                longitude: point['longitude'].toDouble(),
                routeId: point['routeId'],
                imagePath: point['imagePath'],
                description: point['description'],
                longDescription: point['longDescription'],
              ),
            );
          }
        }

        routes.add(
          RouteModel(
            id: item['id'],
            name: item['name'],
            imagePath: item['imagePath'],
            points: pointsList,
          ),
        );
      }

      return routes;
    } catch (e) {
      print('Error loading routes: $e');
      return [];
    }
  }
}
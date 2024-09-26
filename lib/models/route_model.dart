// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_app/models/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PointModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int routeId;
  final String? imagePath;
  final String? description;
  final String? longDescription;
  final String? audioPath;
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
    this.audioPath,
    this.isDiscovered = false
  });
  
  Future<void> saveDiscoveryState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('point_$id', isDiscovered);
  }

  static Future<bool> getDiscoveryState(int pointId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('point_$pointId') ?? false;
  }

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

      final globals = Globals();
      String languageCode = globals.languageCode;

      final storageRef = FirebaseStorage.instance.ref();
      String routeRefPath;

      if (languageCode == 'pl') {

        routeRefPath = 'routes.json';

        print('POLSKI JSON');

      } else if (languageCode == 'en') {

        routeRefPath = 'routes_en.json';

        print('ANGIELSKI JSON');

      } else {

        throw Exception('Unsupported language code: $languageCode');

      }
      final routeRef = storageRef.child(routeRefPath); // Ścieżka do pliku w Firebase Storage
      final url = await routeRef.getDownloadURL();

      // Pobierz dane z URL
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load routes');
      }

      final String jsonString = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonData = json.decode(jsonString);

      final List<RouteModel> routes = [];

      for (var item in jsonData) {
        final List<PointModel> pointsList = [];
        if (item['points'] != null) {
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
                audioPath: point['audioPath'],
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
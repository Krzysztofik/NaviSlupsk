import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

//Zaciąganie informacji i tworzenie modelu markera na podstawie pliku JSON.
class MarkerModel {
  String name;
  double latitude;
  double longitude;

  MarkerModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  static Future<List<MarkerModel>> getMarkers() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/markers.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    List<MarkerModel> markers = [];

    for (var item in jsonData) {
      final latitudeString = item['latitude']?.toString();
      final longitudeString = item['longitude']?.toString();

      if (latitudeString != null && longitudeString != null) {
        markers.add(
          MarkerModel(
            name: item['name'],
            latitude: double.parse(latitudeString),
            longitude: double.parse(longitudeString),
          ),
        );
      }
    }

    return markers;
  }
}

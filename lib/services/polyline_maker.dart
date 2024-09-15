import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PolylineService {
  final String apiKey;

  PolylineService(this.apiKey);

  // Metoda do pobrania trasy pieszej między dwoma punktami
  Future<List<LatLng>> getWalkingRoute(LatLng origin, LatLng destination) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=walking'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      return _decodePoly(points);
    } else {
      throw Exception('Failed to load route');
    }
  }

  // Metoda do dekodowania zakodowanych punktów polilinii
  List<LatLng> _decodePoly(String encoded) {
    final List<LatLng> poly = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final plat = (lat / 1E5);
      final plng = (lng / 1E5);

      poly.add(LatLng(plat, plng));
    }

    return poly;
  }

  // Oblicz odległość między dwoma punktami
  Future<double> calculateDistance(LatLng origin, LatLng destination) async {
    return Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
  }

  // Metoda do tworzenia polilinii
  Future<Set<Polyline>> createPolylines(
      Position currentUserLocation, List<LatLng> routePoints, int centeredRouteId) async {
    final origin = LatLng(currentUserLocation.latitude, currentUserLocation.longitude);

    // Lista wszystkich punktów do porównania
    final allMarkers = [origin, ...routePoints];

    // Oblicz odległości między punktami
    final distances = <LatLng, double>{};
    for (final marker in allMarkers) {
      distances[marker] = await calculateDistance(origin, marker);
    }

    // Posortuj markery według odległości
    final sortedMarkers = allMarkers.toList()
      ..sort((a, b) => (distances[a] ?? 0).compareTo(distances[b] ?? 0));

    // Tworzenie polilinii na podstawie posortowanych markerów
    final polylines = <Polyline>[];
    for (int i = 0; i < sortedMarkers.length - 1; i++) {
      final origin = sortedMarkers[i];
      final destination = sortedMarkers[i + 1];

      try {
        final walkingRoute = await getWalkingRoute(origin, destination);
        polylines.add(Polyline(
          polylineId: PolylineId('walking_route_$i'),
          points: walkingRoute,
          color: Colors.blueAccent, // Kolor polilinii
          width: 6, // Szerokość
          patterns: [PatternItem.dot, PatternItem.gap(10)], // Wzory linii
        ));
      } catch (e) {
        print('Error fetching walking route: $e');
      }
    }

    return polylines.toSet();
  }
}

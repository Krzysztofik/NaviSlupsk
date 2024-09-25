import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PolylineService {
  final Map<String, List<LatLng>> _routeCache = {}; // Mapa do cache'owania tras

  // Tworzymy unikalny klucz na podstawie współrzędnych
  String _getCacheKey(LatLng origin, LatLng destination) {
    return '${origin.latitude},${origin.longitude}-${destination.latitude},${destination.longitude}';
  }

  // Metoda do pobrania trasy pieszej między dwoma punktami
  Future<List<LatLng>> getFullWalkingRoute(List<LatLng> waypoints) async {
  // Tworzymy listę współrzędnych do zapytania
  final coordinates = waypoints.map((point) => '${point.longitude},${point.latitude}').join(';');
  
  // API OSRM pozwala na przekazywanie wielu punktów trasy naraz
  final url = 'http://router.project-osrm.org/route/v1/foot/$coordinates?overview=full&geometries=geojson';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

    // Przekonwertuj współrzędne na listę LatLng
    return coordinates.map<LatLng>((coord) {
      return LatLng(coord[1], coord[0]);
    }).toList();
  } else {
    throw Exception('Failed to load route');
  }
}


  Future<double> calculateDistance(LatLng origin, LatLng destination) async {
    return Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
  }

  List<LatLng> _removeDuplicatePoints(List<LatLng> points, {double thresholdInMeters = 10}) {
  if (points.isEmpty) return [];

  final filteredPoints = <LatLng>[];
  LatLng? previousPoint;

  for (var point in points) {
    if (previousPoint == null) {
      filteredPoints.add(point);
    } else {
      final distance = Geolocator.distanceBetween(
        previousPoint.latitude, previousPoint.longitude,
        point.latitude, point.longitude,
      );

      if (distance > thresholdInMeters) {
        filteredPoints.add(point);
      }
    }
    previousPoint = point;
  }

  return filteredPoints;
}


  // Metoda do tworzenia polilinii
  Future<Set<Polyline>> createPolylines(
  Position currentUserLocation, List<LatLng> routePoints, int centeredRouteId) async {
  
  final origin = LatLng(currentUserLocation.latitude, currentUserLocation.longitude);

  // Dodajemy punkt początkowy do trasy
  final allMarkers = [origin, ...routePoints];

  try {
    // Pobieramy całą trasę w jednym zapytaniu
    final fullRoute = await getFullWalkingRoute(allMarkers);

    // Filtrowanie zduplikowanych punktów
    final filteredRoute = _removeDuplicatePoints(fullRoute);

    // Tworzymy jedną polilinię dla całej trasy
    final polylines = <Polyline>{
      Polyline(
        polylineId: PolylineId('full_walking_route'),
        points: filteredRoute,  // Używamy przefiltrowanych punktów
        color: Colors.green,
        width: 4,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
      ),
    };

    return polylines;
  } catch (e) {
    print('Error fetching full walking route: $e');
    return {};
  }
}
}

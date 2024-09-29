import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PolylineService {

  // Metoda do pobrania trasy pieszej między punktami.
  Future<List<LatLng>> getFullWalkingRoute(List<LatLng> waypoints) async {

  // Konwersja listy punktów na format wymagany przez API OSRM (separator ';').
  final coordinates = waypoints.map((point) => '${point.longitude},${point.latitude}').join(';');
  
  // Budowanie URL do API OSRM, które zwraca pełną trasę dla pieszych w formacie GeoJSON.
  final url = 'http://router.project-osrm.org/route/v1/foot/$coordinates?overview=full&geometries=geojson';

  // Wysłanie zapytania HTPP do API.
  final response = await http.get(Uri.parse(url));

  // Jeżeli odpowiedź poprawna - dekodowanie danych w formacie JSON.
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

    // Konwersja współrzędnych na listę obiektów LatLng.
    return coordinates.map<LatLng>((coord) {
      return LatLng(coord[1], coord[0]);
    }).toList();
  } else {
    throw Exception('Failed to load route');
  }
}

  // Funkcja usuwająca zduplikowane punkty trasy.
  // Jeżeli punkty są zbyt blisko siebie (np. 10 metrów), jeden z nich jest usuwany.
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


  // Metoda tworząca polilinie na mapie, łącząca punkty użytkownika z trasą.
  Future<Set<Polyline>> createPolylines(
  Position currentUserLocation, List<LatLng> routePoints, int centeredRouteId) async {
  
  final origin = LatLng(currentUserLocation.latitude, currentUserLocation.longitude);
  final allMarkers = [origin, ...routePoints];

  try {
    final fullRoute = await getFullWalkingRoute(allMarkers);
    final filteredRoute = _removeDuplicatePoints(fullRoute);
    
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

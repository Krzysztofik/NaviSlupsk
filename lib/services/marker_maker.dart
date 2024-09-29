import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:google_maps_app/providers/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_app/ui/custom_info_window_check.dart';
import 'package:google_maps_app/ui/custom_info_window.dart';
import 'package:confetti/confetti.dart';

late BitmapDescriptor defaultMarker; // Podstawowy marker.
late BitmapDescriptor discoveredMarker; // Odkryty marker.
late BitmapDescriptor navigationMarker; // Marker w trybie nawigacji.
late BitmapDescriptor
    userMarker; // Marker użytkownika (gdy nie jest w trybie nawigacji).
late BitmapDescriptor
    userMarkerDiff; // Podstawowy marker (używany do aktualizacji).

List<PointModel> markers =
    []; // Lista obiektów PointModel, czyli wszystkie markery dostępne.

// Ładuje wszystkie ikony markerów, pobiera trasy RouteMotel i tworzy listę punktów markers.
Future<void> loadMarkers() async {
  defaultMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/default_marker.png',
  );

  discoveredMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/discovered_marker.png',
  );

  navigationMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/navigation_marker.png',
  );

  userMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/user_marker.png',
  );

  userMarkerDiff = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/user_marker.png',
  );

  final routes = await RouteModel.getRoutes();
  markers = routes
      .fold<List<PointModel>>([], (list, route) => list..addAll(route.points));
  await _initializeDiscoveredStates(markers);
}

// Pobiera zapisane w pamięci dane (SharedPrefernces), aby określić które markery są już odkryte.
Future<void> _initializeDiscoveredStates(List<PointModel> points) async {
  final prefs = await SharedPreferences.getInstance();
  for (var point in points) {
    point.isDiscovered = prefs.getBool('marker_${point.id}') ?? false;
  }
}

// Tworzy markery dla wybranej trasy, marker zmienia wielkość w zależności czy odkryty, wywołuje showCustomInfoWindow po kliknięciu w marker.
Set<Marker> buildMarkers(
  int _centeredRouteId,
  CustomInfoWindowController customInfoWindowController,
  BuildContext context,
  bool _isSoundEnabled,
  ConfettiController confettiControllerSmall,
  ConfettiController confettiControllerBig,
  List<RouteModel> _routes,
  Function _updateDiscoveryState,
  Function _updateMarkerInfo,
) {
  List<PointModel> centeredPoints =
      markers.where((point) => point.routeId == _centeredRouteId).toList();

  return centeredPoints.map((marker) {
    return Marker(
      markerId: MarkerId(marker.name),
      position: LatLng(marker.latitude, marker.longitude),
      icon: marker.isDiscovered ? discoveredMarker : defaultMarker,
      onTap: () {
  if (marker.isDiscovered) {
    // Show the custom info window for discovered markers
    showCustomInfoWindowCheck(
      marker,
      customInfoWindowController,
      context,
      isSoundEnabled,
      confettiControllerSmall,
      confettiControllerBig,
      _centeredRouteId,
      _routes,
      _updateDiscoveryState,
      _updateMarkerInfo,
    );
  } else {
    // Show the custom info window for undiscovered markers
    showCustomInfoWindow(
      marker,
      customInfoWindowController,
      context,
      isSoundEnabled,
      confettiControllerSmall,
      confettiControllerBig,
      _centeredRouteId,
      _routes,
    );
  }
},
    );
  }).toSet();
}

// Rozszerza klasę Marker i tworzy marker użytkownika.
class UserLocationMarker extends Marker {
  UserLocationMarker({
    required LatLng position,
    required BitmapDescriptor icon,
    required CustomInfoWindowController customInfoWindowController,
  }) : super(
          markerId: MarkerId('user_location'),
          position: position,
          icon: icon,
          onTap: () {
            customInfoWindowController.addInfoWindow!(
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  "Jesteś tutaj!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              position,
            );
          },
        );
}

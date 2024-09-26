import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_maps_app/models/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_app/services/custom_info_window.dart';
import 'package:confetti/confetti.dart';

// Logika tworzenia markerów.

late BitmapDescriptor defaultMarker;
late BitmapDescriptor bigDefaultMarker;

late BitmapDescriptor discoveredMarker;
late BitmapDescriptor bigDiscoveredMarker;

late BitmapDescriptor navigationMarker;

late BitmapDescriptor userMarker;
late BitmapDescriptor bigUserMarker;

late BitmapDescriptor userMarkerDiff;

List<PointModel> markers = [];
final AudioPlayer _audioPlayer = AudioPlayer();

void _playSound(String soundFileName) async {
  await _audioPlayer.play(AssetSource('$soundFileName'));
}

Future<void> loadMarkers() async {
  defaultMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/default_marker.png',
  );

  bigDefaultMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/big_default_marker.png',
  );

  discoveredMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/discovered_marker.png',
  );

  bigDiscoveredMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/big_discovered_marker.png',
  );

  navigationMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/navigation_marker.png',
  );

  userMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/user_marker.png',
  );

  bigUserMarker = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/markers/big_user_marker.png',
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

Future<void> _initializeDiscoveredStates(List<PointModel> points) async {
  final prefs = await SharedPreferences.getInstance();
  for (var point in points) {
    point.isDiscovered = prefs.getBool('marker_${point.id}') ?? false;
  }
}

Set<Marker> buildMarkers(
  int _centeredRouteId,
  CustomInfoWindowController customInfoWindowController,
  BuildContext context,
  bool _isSoundEnabled,
  Function(String) playSound,
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
      icon: marker.isDiscovered
          ? discoveredMarker
          : defaultMarker, // Zmieniaj ikonę, jeśli marker odkryty
      onTap: () {
        showCustomInfoWindow(
          marker,
          customInfoWindowController,
          context,
          isSoundEnabled,
          _playSound,
          confettiControllerSmall,
          confettiControllerBig,
          _centeredRouteId,
          _routes,
          _updateDiscoveryState,
          _updateMarkerInfo,
          
        );
      },
    );
  }).toSet();
}

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
            // Wyświetlamy custom info window z tekstem "Jesteś tutaj!"
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
              position, // Pozycja markera użytkownika
            );
          },
        );
}

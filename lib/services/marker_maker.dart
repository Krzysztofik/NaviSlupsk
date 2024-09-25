import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:audioplayers/audioplayers.dart';

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
}

Set<Marker> buildMarkers(int centeredRouteId,
    CustomInfoWindowController customInfoWindowController) {
  List<PointModel> centeredPoints =
      markers.where((point) => point.routeId == centeredRouteId).toList();

  return centeredPoints.map((marker) {
    return Marker(
      markerId: MarkerId(marker.name),
      position: LatLng(marker.latitude, marker.longitude),
      icon: marker.isDiscovered
          ? discoveredMarker
          : defaultMarker, // Zmieniaj ikonę, jeśli marker odkryty
      onTap: () {
        customInfoWindowController.addInfoWindow!(
    StatefulBuilder(
      builder: (context, setState) {
        final screenSize = MediaQuery.of(context).size;
        final double windowWidth = 300;
        final double windowHeight = 100;

        return Container(
          padding: const EdgeInsets.all(12.0),
          width: windowWidth,
          constraints: BoxConstraints( // Normalna wysokość
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Container(
                width: double.infinity,
                height: windowWidth * 0.5, // Proporcjonalna wysokość
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: marker.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          marker.imagePath!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              // Name and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      marker.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blueGrey[900],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.teal,
                        ),
                        onPressed: () {
                            if (marker.audioPath != null) {
                              _playSound(marker.audioPath!);
                            }
                          },
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        color: Colors.teal,
                        onPressed: () {
                          // Akcja przycisku info
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    ),
    LatLng(marker.latitude, marker.longitude),
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

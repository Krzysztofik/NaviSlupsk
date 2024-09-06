import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:audioplayers/audioplayers.dart';

// Logika tworzenia markerów.

late BitmapDescriptor customIcon;
late BitmapDescriptor userLocationIcon;
List<PointModel> markers = [];
final AudioPlayer _audioPlayer = AudioPlayer();

void _playSound(String soundFileName) async {
  await _audioPlayer.play(AssetSource('sounds/$soundFileName'));
}

Future<void> loadMarkers() async {
  customIcon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/marker.png',
  );

  userLocationIcon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/usermarker.png',
  );

  final routes = await RouteModel.getRoutes();
  markers = routes.fold<List<PointModel>>([], (list, route) => list..addAll(route.points));
}

Set<Marker> buildMarkers(int centeredRouteId, CustomInfoWindowController customInfoWindowController) {
  List<PointModel> centeredPoints = markers.where((point) => point.routeId == centeredRouteId).toList();

  return centeredPoints.map((marker) {
    return Marker(
      markerId: MarkerId(marker.name),
      position: LatLng(marker.latitude, marker.longitude),
      icon: customIcon,
      onTap: () {
        customInfoWindowController.addInfoWindow!(
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8)],
            ),
            child: Column(
              children: [
                // Obrazek
                Container(
                  width: double.infinity,
                  height: 0.7 * 200,
                  child: marker.imagePath != null
                      ? Image.asset(
                          marker.imagePath!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          marker.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.volume_up,
                              color: Color.fromRGBO(77, 182, 172, 1),
                            ),
                            onPressed: () {
                              _playSound('zabytek9.mp3');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
  }) : super(
          markerId: MarkerId('user_location'),
          position: position,
          icon: icon,
          infoWindow: InfoWindow(
            title: 'Your Location',
          ),
        );
}

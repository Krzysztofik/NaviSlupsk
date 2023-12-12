import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/models/marker_model.dart';

//Logika tworzenia markerów.

late BitmapDescriptor customIcon;
List<MarkerModel> markers = [];

Future<void> loadMarkers() async {
  final icon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/marker.png',
  );
  customIcon = icon;
  markers = await MarkerModel.getMarkers();
}

Set<Marker> buildMarkers() {
  return markers.map((marker) {
    return Marker(
      markerId: MarkerId(marker.name),
      position: LatLng(marker.latitude, marker.longitude),
      icon: customIcon,
      infoWindow: InfoWindow(
        title: marker.name,
      )
    );
  }).toSet();
}
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/models/route_model.dart';

//Logika tworzenia markerów.

late BitmapDescriptor customIcon;
List<PointModel> markers = [];

Future<void> loadMarkers() async {
  final icon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/images/marker.png',
  );
  customIcon = icon;

  final routes = await RouteModel.getRoutes();
  markers = routes.fold<List<PointModel>>([], (list, route) => list..addAll(route.points));
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
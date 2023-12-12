import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_app/models/constants.dart';

//Logika tworzenia tras.

List<RouteModel> routes = [];

Future<void> loadRoutes() async {
  routes = await RouteModel.getRoutes();
  await loadAndDrawPolylines();
}

PolylinePoints polylinePoints = PolylinePoints();
Map<PolylineId, Polyline> polylines = {};
List<LatLng> polylineCoordinates = [];

Future<void> loadAndDrawPolylines() async {
  for (var route in routes) {
    if (route.points.isNotEmpty) {
      List<LatLng> singleRouteCoordinates = [];
      for (var point in route.points) {
        singleRouteCoordinates
            .add(LatLng(point['latitude']!, point['longitude']!));
      }

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(singleRouteCoordinates.first.latitude,
            singleRouteCoordinates.first.longitude),
        PointLatLng(singleRouteCoordinates.last.latitude,
            singleRouteCoordinates.last.longitude),
        travelMode: TravelMode.walking,
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          singleRouteCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        addPolyLine(singleRouteCoordinates);
      }
    }
  }
}

addPolyLine(List<LatLng> polylineCoordinates) {
  PolylineId id = const PolylineId("poly");
  Polyline polyline = Polyline(
    polylineId: id,
    color: const Color.fromRGBO(77, 182, 172, 1),
    points: polylineCoordinates,
    width: 4,
  );
  polylines[id] = polyline;
}

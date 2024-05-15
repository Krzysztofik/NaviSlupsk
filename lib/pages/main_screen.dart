// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_maps_app/ui/app_bar.dart';
import 'package:google_maps_app/ui/bottom_menu.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/services/marker_maker.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum ScreenState { mapState, routeListState }
ScreenState _currentScreenState = ScreenState.mapState;
late GoogleMapController mapController;
const LatLng _slupskCenter = LatLng(54.4643, 17.0282); //Koordynaty centrum Słupska.

void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int centeredRouteId = 0; // Dodaj zmienną przechowującą identyfikator wyśrodkowanej trasy
  bool _locationPermissionGranted = false;
  Position? _currentUserLocation;
  bool _isBottomMenuVisible = true;

  @override
void initState() {
  super.initState();
  _requestLocationPermission();
  loadMarkers().then((_) {
    setState(() {}); // Odśwież
  });
  RouteModel.getRoutes().then((routes) {
    if (routes.isNotEmpty) {
      setState(() {
        // Ustaw domyślnie identyfikator pierwszej trasy
        centeredRouteId = routes.first.id;
      });
    }
  });
}

Future<void> _requestLocationPermission() async {
  final permissionStatus = await Permission.location.request();
  if (permissionStatus == PermissionStatus.granted) {
    setState(() {
      _locationPermissionGranted = true;
      _getCurrentLocation();
    });
  } else {
    setState(() {
      _locationPermissionGranted = false;
    });
  }
}

  Future<void> _getCurrentLocation() async {
    if (_locationPermissionGranted) {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentUserLocation = position;
      });
    }
  }

List<Polyline> _buildPolylines() {
  final polylines = <Polyline>[];

  // Get the current route points
  final routePoints = markers.where((point) => point.routeId == centeredRouteId).toList();

  // Add polyline from user location to the nearest marker
  if (_currentUserLocation != null) {
    final nearestMarker = routePoints.reduce((a, b) {
      final distanceA = Geolocator.distanceBetween(
        _currentUserLocation!.latitude,
        _currentUserLocation!.longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = Geolocator.distanceBetween(
        _currentUserLocation!.latitude,
        _currentUserLocation!.longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA < distanceB ? a : b;
    });
    polylines.add(
      Polyline(
        polylineId: PolylineId('user_to_nearest'),
        points: [
          LatLng(_currentUserLocation!.latitude, _currentUserLocation!.longitude),
          LatLng(nearestMarker.latitude, nearestMarker.longitude),
        ],
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  // Add polylines between markers
  for (int i = 0; i < routePoints.length - 1; i++) {
    final pointA = routePoints[i];
    final pointB = routePoints[i + 1];
    polylines.add(
      Polyline(
        polylineId: PolylineId('marker_${i}_to_${i + 1}'),
        points: [
          LatLng(pointA.latitude, pointA.longitude),
          LatLng(pointB.latitude, pointB.longitude),
        ],
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  return polylines;
}


  
  //Builder google mapy.
 Widget _buildMap() {
  return Stack(
    children: [
      GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _slupskCenter,
          zoom: 14.0,
        ),
        markers: {
          ...buildMarkers(centeredRouteId),
          if (_currentUserLocation != null)
            UserLocationMarker(
              position: LatLng(
                _currentUserLocation!.latitude,
                _currentUserLocation!.longitude,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
        },
        polylines: _buildPolylines().toSet(),
      ),
      Positioned(
        top: 16,
        left: 16,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: [
            FloatingActionButton(
              onPressed: _centerMapOnUserLocation,
              child: const Icon(Icons.my_location),
              backgroundColor: Color.fromRGBO(77, 182, 172, 1),
            ),
            FloatingActionButton(
              onPressed: toggleBottomMenu,
              child: Icon(_isBottomMenuVisible ? Icons.arrow_upward : Icons.arrow_downward),
              backgroundColor: Color.fromRGBO(77, 182, 172, 1),
            ),
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
              backgroundColor: Color.fromRGBO(77, 182, 172, 1),
            ),
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.pedal_bike),
              backgroundColor: Color.fromRGBO(77, 182, 172, 1),
            ),
          ],
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: BottomMenu(
          onPageChanged: onPageChanged,
          isVisible: _isBottomMenuVisible,
        ),
      ),
    ],
  );
}

  //Główny Scaffold aplikacji.
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: MyAppBar(
      onMapIconPressed: () {
        setState(() {
          _currentScreenState = ScreenState.mapState;
        });
      },
      onListIconPressed: () {
        setState(() {
          _currentScreenState = ScreenState.routeListState;
        });
      },
    ),
    body: _buildBody(),
  );
}

Future<void> _centerMapOnUserLocation() async {
  if (_locationPermissionGranted && _currentUserLocation != null) {
    final cameraPosition = CameraPosition(
      target: LatLng(
        _currentUserLocation!.latitude,
        _currentUserLocation!.longitude,
      ),
      zoom: 14.0,
    );
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
}
  //Builder body
  Widget _buildBody() {
    switch (_currentScreenState) {
      case ScreenState.mapState:
        return _buildMap();
      case ScreenState.routeListState:
        return _buildRouteList();
    }
  }

  //Builder listy tras
  Widget _buildRouteList() {
    return const Center(
      child: Text(
        'Lista tras',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  // Metoda do odświeżania widoku mapy po zmianie trasy
  void refreshMap() {
    setState(() {}); // Odśwież
  }

  // Metoda do obsługi zmiany trasy w bottom menu
  void onPageChanged(int routeId) {
    setState(() {
      centeredRouteId = routeId; // Zaktualizuj identyfikator wyśrodkowanej trasy
    });
  }

  void toggleBottomMenu() {
    setState(() {
      _isBottomMenuVisible = !_isBottomMenuVisible;
    });
  }
}

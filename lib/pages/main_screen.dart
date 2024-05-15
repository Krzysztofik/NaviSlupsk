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

  
  //Builder google mapy.
 Widget _buildMap() {
  return Stack(
    children: [
      Expanded(
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: _slupskCenter,
            zoom: 14.0,
          ),
          markers: buildMarkers(centeredRouteId),
          myLocationEnabled: _locationPermissionGranted,
          myLocationButtonEnabled: _locationPermissionGranted,
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
      floatingActionButton: FloatingActionButton(
        onPressed: toggleBottomMenu,
        child: Icon(_isBottomMenuVisible ? Icons.arrow_upward : Icons.arrow_downward),
      ),
    );
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




import 'package:flutter/material.dart';
import 'package:google_maps_app/ui/app_bar.dart';
import 'package:google_maps_app/ui/bottom_menu.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/services/marker_maker.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_app/pages/route_list_screen.dart';
import 'package:custom_info_window/custom_info_window.dart';

enum ScreenState { mapState, routeListState }
ScreenState _currentScreenState = ScreenState.mapState;
late GoogleMapController mapController;
const LatLng _slupskCenter = LatLng(54.4643, 17.0282); // Koordynaty centrum Słupska.

void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  int centeredRouteId = 0; 
  bool _locationPermissionGranted = false;
  Position? _currentUserLocation;
  bool _isBottomMenuVisible = true;
  bool _isSoundEnabled = true;
  late AnimationController _animationController;
  List<RouteModel> routes = [];
  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    loadMarkers().then((_) {
      setState(() {});
    });
    RouteModel.getRoutes().then((loadedRoutes) {
      if (loadedRoutes.isNotEmpty) {
        setState(() {
          routes = loadedRoutes;
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

    final routePoints = markers.where((point) => point.routeId == centeredRouteId).toList();

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
          polylineId: const PolylineId('user_to_nearest'),
          points: [
            LatLng(_currentUserLocation!.latitude, _currentUserLocation!.longitude),
            LatLng(nearestMarker.latitude, nearestMarker.longitude),
          ],
          color: Colors.blue,
          width: 5,
        ),
      );
    }

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

  Widget _buildMap() {
  return Stack(
    children: [
      GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _onMapCreated(controller);
          _customInfoWindowController.googleMapController = controller;
        },
        initialCameraPosition: const CameraPosition(
          target: _slupskCenter,
          zoom: 14.0,
        ),
        markers: {
          ...buildMarkers(centeredRouteId, _customInfoWindowController,),
          if (_currentUserLocation != null)
            Marker(
              markerId: const MarkerId('user_location'),
              position: LatLng(
                _currentUserLocation!.latitude,
                _currentUserLocation!.longitude,
              ),
              icon: userLocationIcon,
            ),
        },
        polylines: _buildPolylines().toSet(),
        onTap: (position) {
          _customInfoWindowController.hideInfoWindow!();
        },
        onCameraMove: (position) {
          _customInfoWindowController.onCameraMove!();
        },
      ),
      CustomInfoWindow(
        controller: _customInfoWindowController,
        height: 204,
        width: 300,
      ),
      AnimatedPositioned(
        duration: const Duration(milliseconds: 500),
        bottom: _isBottomMenuVisible ? 270 : 16,
        left: 16,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: [
            FloatingActionButton(
              onPressed: _centerMapOnUserLocation,
              child: const Icon(Icons.my_location),
              backgroundColor: const Color.fromRGBO(77, 182, 172, 1),
            ),
            FloatingActionButton(
              onPressed: () {
                toggleBottomMenu();
                setState(() {});
              },
              child: Icon(_isBottomMenuVisible ? Icons.arrow_downward : Icons.arrow_upward),
              backgroundColor: const Color.fromRGBO(77, 182, 172, 1),
            ),
            FloatingActionButton(
              onPressed: toggleSound,
              child: Icon(_isSoundEnabled ? Icons.volume_up : Icons.volume_off),
              backgroundColor: _isSoundEnabled ? Color.fromRGBO(77, 182, 172, 1) : Colors.grey,
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
          onHideInfoWindow: _hideInfoWindow,
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        onMapIconPressed: () {
          setState(() {
            _currentScreenState = ScreenState.mapState;
            _isBottomMenuVisible = true; // Pokazuj menu na dole na mapie
          });
        },
        onListIconPressed: () {
          setState(() {
            _currentScreenState = ScreenState.routeListState;
            _isBottomMenuVisible = false; // Ukryj dolne menu na liście
          });
        },
        currentScreenState: _currentScreenState,
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

  Widget _buildBody() {
    switch (_currentScreenState) {
      case ScreenState.mapState:
        return _buildMap();
      case ScreenState.routeListState:
        return _buildRouteList();
    }
  }

  Widget _buildRouteList() {
    return RouteListScreen(
      routes: routes,
      initialRouteId: centeredRouteId,
    );
  }

  void refreshMap() {
    setState(() {}); // Odśwież
  }

  void onPageChanged(int routeId) {
    setState(() {
      centeredRouteId = routeId;
    });
  }

  void toggleBottomMenu() {
    setState(() {
      _isBottomMenuVisible = !_isBottomMenuVisible;
    });
  }

  void toggleSound() {
    setState(() {
      _isSoundEnabled = !_isSoundEnabled;
    });
  }

  void _hideInfoWindow() {
  _customInfoWindowController.hideInfoWindow!();
}


  @override
  void dispose() {
    _animationController.dispose();
    _customInfoWindowController.dispose();
    super.dispose();
  }
}

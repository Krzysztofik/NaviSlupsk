import 'dart:async'; // Dodaj import dla StreamSubscription
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/ui/app_bar.dart';
import 'package:google_maps_app/ui/bottom_menu.dart';
import 'package:google_maps_app/services/marker_maker.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_app/pages/route_list_screen.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:google_maps_app/services/polyline_maker.dart';
import 'package:flutter_compass/flutter_compass.dart';

enum ScreenState { mapState, routeListState }

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  ScreenState _currentScreenState = ScreenState.mapState;
  late GoogleMapController _mapController;
  int _centeredRouteId = 1;

  String _navigationInfo = "";
  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _locationPermissionGranted = false;
  Position? _currentUserLocation;
  StreamSubscription<Position>?
      _positionStreamSubscription; // Stream lokalizacji

  bool _isBottomMenuVisible = true;
  bool _isSoundEnabled = true;

  late AnimationController _animationController;

  List<RouteModel> _routes = [];
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  Set<Polyline> _polylines = {};
  late PolylineService _polylineService;

  @override
  void initState() {
    super.initState();
    _polylineService =
        PolylineService('AIzaSyBC9gtINw2qYfr-odHCe-lWBvBd4BuWYPc');
    _requestLocationPermission();
    loadMarkers().then((_) {
      setState(() {});
    });
    RouteModel.getRoutes().then((loadedRoutes) {
      if (loadedRoutes.isNotEmpty) {
        setState(() {
          _routes = loadedRoutes;
          _centeredRouteId = _routes.first.id;
        });
        _updateMarkerInfo();
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    final permissionStatus = await Permission.location.request();
    if (permissionStatus == PermissionStatus.granted) {
      setState(() {
        _locationPermissionGranted = true;
        _startLocationUpdates(); // Rozpocznij śledzenie lokalizacji
      });
    } else {
      setState(() {
        _locationPermissionGranted = false;
      });
    }
  }

  // Funkcja nasłuchująca na zmiany lokalizacji
  Future<void> _startLocationUpdates() async {
    if (_locationPermissionGranted) {
      // Konfiguracja dla Androida
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, // Ustawienie wysokiej dokładności
        distanceFilter: 1, // Opcjonalne: aktualizuj lokalizację co 2 metry
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        setState(() {
          _currentUserLocation = position;
        });
        _updatePolylines(); // Aktualizuj polilinie po zmianie lokalizacji
      });
    }
  }

  Future<void> _updatePolylines() async {
    if (_currentUserLocation != null) {
      final routePoints =
          markers.where((point) => point.routeId == _centeredRouteId).toList();

      if (routePoints.isNotEmpty) {
        final origin = LatLng(
            _currentUserLocation!.latitude, _currentUserLocation!.longitude);

        final allMarkers = [
          origin,
          ...routePoints
              .map((marker) => LatLng(marker.latitude, marker.longitude))
        ];

        _polylines = await _polylineService.createPolylines(
            _currentUserLocation!, allMarkers, _centeredRouteId);

        setState(() {});
      }
    }
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _customInfoWindowController.googleMapController = controller;
            _updatePolylines(); // Wywołaj aktualizację polilinii po stworzeniu mapy
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(54.4643, 17.0282), // Koordynaty centrum Słupska.
            zoom: 14.0,
            bearing: 0,
            tilt: 0,
          ),
          markers: {
            ...buildMarkers(
              _centeredRouteId,
              _customInfoWindowController,
            ),
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
          polylines: _polylines,
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
                child: Icon(_isBottomMenuVisible
                    ? Icons.arrow_downward
                    : Icons.arrow_upward),
                backgroundColor: const Color.fromRGBO(77, 182, 172, 1),
              ),
              FloatingActionButton(
                onPressed: toggleSound,
                child:
                    Icon(_isSoundEnabled ? Icons.volume_up : Icons.volume_off),
                backgroundColor: _isSoundEnabled
                    ? Color.fromRGBO(77, 182, 172, 1)
                    : Colors.grey,
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
            onNavigate: _navigate,
            onMarkerInfoUpdate: _updateMarkerInfo,
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.black.withOpacity(0.5),
            child: Text(
              _navigationInfo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      body: _currentScreenState == ScreenState.mapState
          ? _buildMap()
          : _buildRouteList(),
    );
  }

  Future<void> _centerMapOnUserLocation() async {
    if (_locationPermissionGranted && _currentUserLocation != null) {
      _compassSubscription?.cancel();
      final cameraPosition = CameraPosition(
        target: LatLng(
          _currentUserLocation!.latitude,
          _currentUserLocation!.longitude,
        ),
        zoom: 14.0,
      );
      _mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

Future<void> _navigate() async {
    if (_locationPermissionGranted && _currentUserLocation != null) {
      // Zaktualizuj pozycję kamery z nowymi wartościami tilt i bearing
      final CameraPosition initialPosition = CameraPosition(
        target: LatLng(
          _currentUserLocation!.latitude,
          _currentUserLocation!.longitude,
        ),
        zoom: 24,  // Dostosuj zoom według potrzeb
        tilt: 80,  // Dostosuj tilt według potrzeb
      );

      // Ustaw początkową pozycję kamery
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(initialPosition),
      );

      // Subskrybuj zmiany kierunku z kompasu
      final Stream<CompassEvent>? compassStream = FlutterCompass.events;
      if (compassStream != null) {
        _compassSubscription?.cancel(); // Anuluj poprzednią subskrypcję, jeśli istnieje
        _compassSubscription = compassStream.listen(
          (CompassEvent event) async {
            final double? heading = event.heading;
            if (heading != null) {
              // Ustaw nową pozycję kamery
              final CameraPosition updatedPosition = CameraPosition(
                target: LatLng(
                  _currentUserLocation!.latitude,
                  _currentUserLocation!.longitude,
                ),
                zoom: 24,  // Dostosuj zoom według potrzeb
                tilt: 80,  // Dostosuj tilt według potrzeb
                bearing: heading,  // Ustaw bearing na wartość odczytu kompasu
              );

              // Animuj zoom w krótszym czasie
              await _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(updatedPosition),
              );
            }
          },
          onError: (error) {
            print('Error in compass stream: $error');
          },
          onDone: () {
            print('Compass stream closed');
          },
        );
      }
    }
  }

  void _resetCameraToDefault() async {
  if (_locationPermissionGranted && _currentUserLocation != null) {
    final CameraPosition defaultPosition = CameraPosition(
      target: LatLng(
        _currentUserLocation!.latitude,
        _currentUserLocation!.longitude,
      ),
      zoom: 14, // Przywróć do normalnego zoomu
      tilt: 0,  // Przywróć do normalnego tilt
      bearing: 0, // Przywróć do normalnego bearing
    );

    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(defaultPosition),
    );
  }
}

  void _updateMarkerInfo() {
    final route = _routes.firstWhere((r) => r.id == _centeredRouteId);
    final totalMarkers = route.points.length;

    setState(() {
      _navigationInfo = "${route.name}, odkryłeś 0/$totalMarkers obiektów!";
    });
  }

  Widget _buildRouteList() {
    return RouteListScreen(
      routes: _routes,
      initialRouteId: _centeredRouteId,
    );
  }

  void onPageChanged(int routeId) {
    setState(() {
      _centeredRouteId = routeId;
    });
    _updatePolylines();
    _compassSubscription?.cancel();
    _resetCameraToDefault();
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
    _positionStreamSubscription
        ?.cancel(); // Zatrzymaj nasłuchiwanie lokalizacji
    _animationController.dispose();
    _customInfoWindowController.dispose();
    super.dispose();
  }
}

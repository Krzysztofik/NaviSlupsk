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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

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
  late ConfettiController _confettiControllerSmall;
  late ConfettiController _confettiControllerBig;

  int _centeredRouteId = 1;
  int _discoveredMarkers = 0;
  int _totalMarkers = 0;

  String _navigationInfo = "";
  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _locationPermissionGranted = false;
  Position? _currentUserLocation;
  StreamSubscription<Position>?
      _positionStreamSubscription; // Stream lokalizacji

  bool _isBottomMenuVisible = true;
  bool _isSoundEnabled = true;
  bool _isInfoVisible = false;
  bool _isNavigationActive = false;

  late AnimationController _animationController;

  List<RouteModel> _routes = [];
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  Set<Polyline> _polylines = {};

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _confettiControllerSmall = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    _confettiControllerBig = ConfettiController(
      duration: const Duration(seconds: 3),
    );

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
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
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

  void _playSound(String soundFileName) async {
    await _audioPlayer.play(AssetSource('$soundFileName'));
  }

  void showCustomInfoWindow(PointModel marker) {
    _customInfoWindowController.addInfoWindow!(
      StatefulBuilder(
        builder: (context, setState) {
          final double windowWidth = 300;
          // 75% szerokości ekranu
          final double windowHeight = 100;
          // 35% wysokości ekranu

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12.0),
            width: windowWidth,
            height: windowHeight,
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
                  height: windowWidth * 0.45, // Proporcjonalna wysokość
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
                            if (_isSoundEnabled && marker.audioPath != null) {
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
                const SizedBox(height: 5),
                // Checkbox (only visible when navigation is active)
                if (_isNavigationActive)
                  AnimatedOpacity(
                    opacity: _isNavigationActive ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: marker.isDiscovered,
                      title: const Text('Odkryłeś ten znacznik?',
                          style: TextStyle(fontSize: 14)),
                      onChanged: (bool? value) {
                        setState(() {
                          marker.isDiscovered = value ?? false;
                          // Uaktualnij listę markerów w kolekcji
                          final route = _routes
                              .firstWhere((r) => r.id == _centeredRouteId);
                          final index =
                              route.points.indexWhere((p) => p.id == marker.id);
                          if (index != -1) {
                            route.points[index] =
                                marker; // Zaktualizuj obiekt markera w liście
                          }
                          print(
                              'Marker ${marker.name} isDiscovered: ${marker.isDiscovered}');
                        });
                        _updateMarkerInfo();
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      LatLng(marker.latitude, marker.longitude),
    );
  }

  Future<void> _checkMarkersInRange() async {
    if (_currentUserLocation == null) return;

    // Pobierz aktualny widoczny region mapy
    LatLngBounds visibleRegion = await _mapController.getVisibleRegion();

    print(
        "Widoczny region mapy: ${visibleRegion.southwest}, ${visibleRegion.northeast}");

    // Filtrowanie markerów na podstawie aktualnej trasy (_centeredRouteId)
    List<PointModel> routeMarkers =
        markers.where((marker) => marker.routeId == _centeredRouteId).toList();

    for (PointModel marker in routeMarkers) {
      final double distance = Geolocator.distanceBetween(
        _currentUserLocation!.latitude,
        _currentUserLocation!.longitude,
        marker.latitude,
        marker.longitude,
      );

      print(
          "Marker: ${marker.name}, Odległość: $distance, Lokalizacja: ${marker.latitude}, ${marker.longitude}");

      // Sprawdź, czy marker jest w zasięgu użytkownika (150 metrów)
      if (distance <= 150 &&
          !marker.isDiscovered &&
          _isNavigationActive == true) {
        // Sprawdź, czy marker jest w aktualnym widocznym regionie mapy
        if (visibleRegion.contains(LatLng(marker.latitude, marker.longitude))) {
          print("Marker ${marker.name} jest w zasięgu i widoczny na mapie");

          setState(() {
            _updateMarkerInfo();
          });

          // Wyświetl okno informacyjne, jeśli marker jest w granicach widocznego regionu
          showCustomInfoWindow(marker);
        } else {
          print("Marker ${marker.name} NIE jest widoczny na mapie.");
        }
      } else {
        print("Marker ${marker.name} NIE jest w zasięgu.");
      }
    }
  }

  Future<void> _updatePolylines() async {
    if (_currentUserLocation != null) {
      // Pobierz markery trasy, ignorując odkryte markery
      final routePoints = markers
          .where((point) =>
              point.routeId == _centeredRouteId && !point.isDiscovered)
          .toList();

      if (routePoints.isNotEmpty) {
        final origin = LatLng(
            _currentUserLocation!.latitude, _currentUserLocation!.longitude);

        final allMarkers = [
          origin,
          ...routePoints
              .map((marker) => LatLng(marker.latitude, marker.longitude))
        ];

        final polylineService = PolylineService();
        _polylines = await polylineService.createPolylines(
            _currentUserLocation!, allMarkers, _centeredRouteId);

        setState(() {});
      }
    }
  }

  void _stopSound() async {
    await _audioPlayer.stop(); // Zatrzymuje odtwarzanie
  }

  Widget _buildMap() {
    return Stack(
      alignment: Alignment.center,
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
                icon: userMarker,
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
          height:
              MediaQuery.of(context).size.height * 0.35, // 40% wysokości ekranu
          width:
              MediaQuery.of(context).size.width * 0.75, // 75% szerokości ekranu
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          bottom: _isBottomMenuVisible ? 270 : 16,
          left: 16,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: [
              FloatingActionButton(
                  elevation: 0,
                  mini: true,
                  onPressed: _centerMapOnUserLocation,
                  child:
                      Image.asset('assets/images/buttonicons/user_center.png'),
                  backgroundColor: Colors.transparent),
              FloatingActionButton(
                elevation: 0,
                mini: true,
                onPressed: () {
                  toggleBottomMenu();
                  setState(() {});
                },
                child: Image.asset('assets/images/buttonicons/menu_icon.png'),
                backgroundColor: Colors.transparent,
              ),
              FloatingActionButton(
                elevation: 0,
                mini: true,
                onPressed: toggleSound,
                child: Image.asset(
                  _isSoundEnabled
                      ? 'assets/images/buttonicons/audio_on_icon.png'
                      : 'assets/images/buttonicons/audio_off_icon.png',
                ),
                backgroundColor: Colors.transparent,
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
            onStop: _resetCameraToDefault,
            discoveredMarkers: _discoveredMarkers,
            totalMarkers: _totalMarkers,
            onListIconPressed: () {
              setState(() {
                _currentScreenState = ScreenState.routeListState;
                _isBottomMenuVisible =
                    false; // Ukryj dolne menu, gdy widok to lista tras
              });
            },
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: _isInfoVisible
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: Offset(0, 4),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .navigation, // Dodaj ikonę lub inny widget według potrzeb
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8), // Odstęp między ikoną a tekstem
                      Text(
                        _navigationInfo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ),
        ConfettiWidget(
          blastDirectionality: BlastDirectionality.explosive,
          confettiController: _confettiControllerSmall,
          numberOfParticles:
              5, // Increase the number of particles for larger confetti
        ),
        ConfettiWidget(
          blastDirectionality: BlastDirectionality.explosive,
          confettiController: _confettiControllerBig,
          numberOfParticles:
              20, // Increase the number of particles for larger confetti
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
        zoom: 18, // Dostosuj zoom według potrzeb
        tilt: 80, // Dostosuj tilt według potrzeb
      );

      // Ustaw początkową pozycję kamery
      await _mapController.animateCamera(
        CameraUpdate.newCameraPosition(initialPosition),
      );

      // Subskrybuj zmiany kierunku z kompasu
      final Stream<CompassEvent>? compassStream = FlutterCompass.events;
      if (compassStream != null) {
        _compassSubscription
            ?.cancel(); // Anuluj poprzednią subskrypcję, jeśli istnieje
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
                zoom: 18, // Dostosuj zoom według potrzeb
                tilt: 80, // Dostosuj tilt według potrzeb
                bearing: heading, // Ustaw bearing na wartość odczytu kompasu
              );

              // Animuj zoom w krótszym czasie
              await _mapController.animateCamera(
                CameraUpdate.newCameraPosition(updatedPosition),
              );
            }
          },
          onError: (error) {
            print('Error in compass stream: $error');
          },
          onDone: () {
            print('Compass stream closed');
            // Przywróć poprzedni stan ikony po zakończeniu nasłuchiwania
          },
        );
      }

      // Zaktualizuj stan UI, aby pokazać kontener z informacjami
      setState(() {
        _isInfoVisible = true;
        _isNavigationActive = true;
        userMarker = navigationMarker; // Pokaż kontener z informacjami
      });

      _checkMarkersInRange(); // Sprawdź markery w zasięgu
    }
  }

  void _resetCameraToDefault() async {
    final CameraPosition defaultPosition = CameraPosition(
      target: LatLng(54.4643, 17.0282),
      zoom: 14, // Przywróć do normalnego zoomu
      tilt: 0, // Przywróć do normalnego tilt
      bearing: 0, // Przywróć do normalnego bearing
    );
    _customInfoWindowController.hideInfoWindow!();
    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(defaultPosition),
    );
    _compassSubscription?.cancel();
    setState(() {
      _isInfoVisible = false;
      userMarker = userMarkerDiff;
      _customInfoWindowController.hideInfoWindow!();
    });
  }

  void _updateMarkerInfo() {
    final route = _routes.firstWhere((r) => r.id == _centeredRouteId);
    final totalMarkers = route.points.length;

    // Debugowanie: Zaloguj każdy marker w liście
    for (var marker in route.points) {
      print('Marker ${marker.name}: isDiscovered=${marker.isDiscovered}');
    }

    // Zlicz markery, które są odkryte (isDiscovered == true)
    final discoveredMarkers = route.points.where((p) => p.isDiscovered).length;

    print(
        'Updating marker info: totalMarkers=$totalMarkers, discoveredMarkers=$discoveredMarkers'); // Debug log

    setState(() {
      _discoveredMarkers = discoveredMarkers; // Zaktualizuj discoveredMarkers
      _totalMarkers = totalMarkers; // Zaktualizuj totalMarkers
      _navigationInfo =
          "${route.name}, ${AppLocalizations.of(context)!.discovered} $discoveredMarkers/$totalMarkers ${AppLocalizations.of(context)!.places}!";
    });

    if (discoveredMarkers > 0 && discoveredMarkers < totalMarkers) {
      _confettiControllerSmall.play();
    }

    if (discoveredMarkers == totalMarkers) {
      _confettiControllerBig.play();
    }
  }

  Widget _buildRouteList() {
    return RouteListScreen(
      routes: _routes,
      initialRouteId: _centeredRouteId,
      discoveredMarkers: _discoveredMarkers,
      totalMarkers: _totalMarkers,
    );
  }

  Future<void> _centerMapOnFirstRoutePoint() async {
    final route = _routes.firstWhere((r) => r.id == _centeredRouteId);
    if (route.points.isNotEmpty) {
      final firstPoint = route.points.first;
      final cameraPosition = CameraPosition(
        target: LatLng(firstPoint.latitude, firstPoint.longitude),
        zoom: 14.0, // Dostosuj zoom według potrzeb
      );
      await _mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  void onPageChanged(int routeId) {
    setState(() {
      _centeredRouteId = routeId;
    });
    _updatePolylines();
    _compassSubscription?.cancel();
    _centerMapOnFirstRoutePoint();
  }

  void toggleBottomMenu() {
    setState(() {
      _isBottomMenuVisible = !_isBottomMenuVisible;
    });
  }

  void toggleSound() {
    setState(() {
      _isSoundEnabled = !_isSoundEnabled;

      if (!_isSoundEnabled) {
        _stopSound(); // Zatrzymuje dźwięk, gdy dźwięk jest wyłączony
      }
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

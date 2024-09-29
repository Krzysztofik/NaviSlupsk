import 'dart:async'; // Dodaj import dla StreamSubscription
import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/boarding_screen.dart';
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
import 'package:google_maps_app/providers/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_app/providers/locale_provider.dart';
import 'package:google_maps_app/ui/custom_info_window.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  late ConfettiController confettiControllerSmall;
  late ConfettiController confettiControllerBig;

  int _centeredRouteId = 1;

  String _navigationInfo = "";
  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _locationPermissionGranted = false;
  Position? _currentUserLocation;
  StreamSubscription<Position>?
      _positionStreamSubscription; // Stream lokalizacji
  List<RouteModel> _routes = [];
  CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();

  //INICJALIZACJA PO ROZPOCZĘCIU APLIKACJI
  @override
  void initState() {
    super.initState();
    confettiControllerSmall = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    confettiControllerBig = ConfettiController(
      duration: const Duration(seconds: 2),
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

  void _changeLanguage(String value) {
    setState(() {
      final globals = Globals();
      globals.setLanguageCode(value); // Update the language code in globals

      // Update the locale in the provider
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      Locale newLocale = Locale.fromSubtags(languageCode: value);
      print(
          'User selected locale: ${newLocale.languageCode}'); // Log user selected locale
      localeProvider.setLocale(newLocale);

      // Save the selected language code to SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('selectedLanguageCode', value);
      });
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
  }

  //MAPA GOOGLE
  Widget _buildMap() {
    return Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            customInfoWindowController.googleMapController = controller;
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
              customInfoWindowController,
              context,
              isSoundEnabled,
              _playSound,
              confettiControllerSmall,
              confettiControllerBig,
              _routes,
              _updateDiscoveryState,
              _updateMarkerInfo,
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
            customInfoWindowController.hideInfoWindow!();
            _checkMarkersInRange();
          },
          onCameraMove: (position) {
            customInfoWindowController.onCameraMove!();
          },
        ),
        CustomInfoWindow(
          controller: customInfoWindowController,
          height: 292,
          width: 300,
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          bottom: isBottomMenuVisible ? 270 : 16,
          left: 16,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: [
              FloatingActionButton(
                heroTag: null,
                elevation: 0,
                mini: true,
                onPressed: _centerMapOnUserLocation,
                child: Image.asset('assets/images/buttonicons/user_center.png'),
                backgroundColor: Colors.transparent,
              ),
              FloatingActionButton(
                heroTag: null,
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
                heroTag: null,
                elevation: 0,
                mini: true,
                onPressed: toggleSound,
                child: Image.asset(
                  isSoundEnabled
                      ? 'assets/images/buttonicons/audio_on_icon.png'
                      : 'assets/images/buttonicons/audio_off_icon.png',
                ),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: null,
                elevation: 0,
                mini: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          OnboardingScreen(fromWelcome: false),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin =
                            Offset(0.0, -1.0); // Start from the bottom
                        const end = Offset.zero; // End at the current position
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/buttonicons/help_icon.png',
                ),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 10),
              SpeedDial(
                direction: SpeedDialDirection.down,
                child: Image.asset(
                  'assets/images/buttonicons/language_icon.png', // Główna ikona języka
                  width: 40,
                  height: 40,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                overlayColor: Colors.transparent,
                overlayOpacity: 0.0,
                animationCurve: Curves.elasticInOut,
                animationDuration: Duration(milliseconds: 300),
                children: [
                  SpeedDialChild(
                    child: Image.asset(
                      'assets/images/buttonicons/poland_icon.png', // Ikona Polski
                      width: 40,
                      height: 40,
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    onTap: () => _changeLanguage('pl'),
                  ),
                  SpeedDialChild(
                    child: Image.asset(
                      'assets/images/buttonicons/england_icon.png', // Ikona Anglii
                      width: 40,
                      height: 40,
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    onTap: () => _changeLanguage('en'),
                  ),
                ],
              )
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomMenu(
            onPageChanged: onPageChanged,
            isVisible: isBottomMenuVisible,
            onHideInfoWindow: _hideInfoWindow,
            onNavigate: _navigate,
            onMarkerInfoUpdate: _updateMarkerInfo,
            onStop: _resetCameraToDefault,
            onListIconPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      RouteListScreen(
                    routes: _routes,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, -1.0); // Start from the bottom
                    const end = Offset.zero; // End at the current position
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: isInfoVisible
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
          confettiController: confettiControllerSmall,
          numberOfParticles:
              5, // Increase the number of particles for larger confetti
        ),
        ConfettiWidget(
          blastDirectionality: BlastDirectionality.explosive,
          confettiController: confettiControllerBig,
          numberOfParticles:
              10, // Increase the number of particles for larger confetti
        ),
      ],
    );
  }

  //GŁÓWNY SCAFFOLD APLIKACJI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          onMapIconPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MapScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // Start from the right
                  const end = Offset.zero; // End at the current position
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
          onListIconPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    RouteListScreen(
                  routes: _routes,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, -1.0); // Start from the bottom
                  const end = Offset.zero; // End at the current position
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        body: _buildMap());
  }

  //SCHOWAJ KAFELEK INFOWINDOW NAD MARKEREM
  void _hideInfoWindow() {
    customInfoWindowController.hideInfoWindow!();
  }

  //FUNKCJA URUCHAMIAJĄCA "TRYB" NAWIGOWANIA
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
      await mapController.animateCamera(
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
              await mapController.animateCamera(
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
      if (mounted)
        setState(() {
          isInfoVisible = true;
          isNavigationActive = true;
          userMarker = navigationMarker;
        });

      _checkMarkersInRange();
    }
  }

  //ZAKTUALIZUJ INFO O MARKERACH
  void _updateMarkerInfo() async {
    final route = _routes.firstWhere((r) => r.id == _centeredRouteId);
    final totalMarkers = route.points.length;

    // Debugowanie: Zaloguj każdy marker w liście
    for (var marker in route.points) {
      // Odczytaj stan odkrycia z SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      marker.isDiscovered =
          prefs.getBool('marker_${marker.id}') ?? false; // Ustaw stan odkrycia
    }

    // Zlicz markery, które są odkryte (isDiscovered == true)
    final discoveredMarkers = route.points.where((p) => p.isDiscovered).length;
    if (mounted)
      setState(() {
        _navigationInfo =
            "${route.name}, ${AppLocalizations.of(context)!.discovered} $discoveredMarkers/$totalMarkers ${AppLocalizations.of(context)!.places}!";
      });
  }

  //NASŁUCHIWANIE ZMIAN W LOKALIZACJI UŻYTKOWNIKA
  Future<void> _startLocationUpdates() async {
    if (_locationPermissionGranted) {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        if (mounted)
          setState(() {
            _currentUserLocation = position;
          });
        _updatePolylines();
        _checkMarkersInRange();
      });
    }
  }

  //WYŚLIJ ZAPYTANIE O LOKALIZACJĘ UŻYTKOWNIKA
  Future<void> _requestLocationPermission() async {
    final permissionStatus = await Permission.location.request();
    if (permissionStatus == PermissionStatus.granted) {
      if (mounted)
        setState(() {
          _locationPermissionGranted = true;
          _startLocationUpdates(); // Rozpocznij śledzenie lokalizacji
        });
    } else {
      if (mounted)
        setState(() {
          _locationPermissionGranted = false;
        });
    }
  }

  //ZAKTUALIZUJ ODKRYTE MARKERY
  Future<void> _updateDiscoveryState(int markerId, bool isDiscovered) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('marker_$markerId', isDiscovered); // Użyj unikalnego klucza
  }

  //SPRAWDŹ MARKERY W ZASIĘGU
  Future<void> _checkMarkersInRange() async {
    if (_currentUserLocation == null) return;

    // Pobierz aktualny widoczny region mapy
    LatLngBounds visibleRegion = await mapController.getVisibleRegion();

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

      // Sprawdź, czy marker jest w zasięgu użytkownika (150 metrów)
      if (distance <= 50 &&
          !marker.isDiscovered &&
          isNavigationActive == true) {
        // Sprawdź, czy marker jest w aktualnym widocznym regionie mapy
        if (visibleRegion.contains(LatLng(marker.latitude, marker.longitude))) {
          if (mounted)
            setState(() {
              _updateMarkerInfo();
            });

          // Wyświetl okno informacyjne, jeśli marker jest w granicach widocznego regionu
          showCustomInfoWindow(
            marker,
            customInfoWindowController,
            context,
            isSoundEnabled,
            _playSound,
            confettiControllerSmall,
            confettiControllerBig,
            _centeredRouteId,
            _routes,
            _updateDiscoveryState,
            _updateMarkerInfo,
          );
        }
      }
    }
  }

  //ZAKTUALIZUJ POLILINIĘ NA MAPIE
  Set<Polyline> _polylines = {};

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
        if (mounted) setState(() {});
      }
    }
  }

  //WYCENTRUJ MAPĘ NA LOKALIZACJI UŻYTKOWNIKA
  Future<void> _centerMapOnUserLocation() async {
    if (_locationPermissionGranted && _currentUserLocation != null) {
      final cameraPosition = CameraPosition(
        target: LatLng(
          _currentUserLocation!.latitude,
          _currentUserLocation!.longitude,
        ),
        zoom: 14.0,
      );
      mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  //WYCENTRUJ MAPĘ NA PIERWSZYM PUNKCIE Z TRASY
  Future<void> _centerMapOnFirstRoutePoint() async {
    final route = _routes.firstWhere((r) => r.id == _centeredRouteId);
    if (route.points.isNotEmpty) {
      final firstPoint = route.points.first;
      final cameraPosition = CameraPosition(
        target: LatLng(firstPoint.latitude, firstPoint.longitude),
        zoom: 14.0, // Dostosuj zoom według potrzeb
      );
      await mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  //WYCENTRUJ MAPĘ NA POCZĄTKOWE MIEJSCE
  void _resetCameraToDefault() async {
    final CameraPosition defaultPosition = CameraPosition(
      target: LatLng(54.4643, 17.0282),
      zoom: 14, // Przywróć do normalnego zoomu
      tilt: 0, // Przywróć do normalnego tilt
      bearing: 0, // Przywróć do normalnego bearing
    );
    customInfoWindowController.hideInfoWindow!();
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(defaultPosition),
    );
    _compassSubscription?.cancel();
    if (mounted)
      setState(() {
        isInfoVisible = false;
        userMarker = userMarkerDiff;
        customInfoWindowController.hideInfoWindow!();
        isNavigationActive = false;
      });
  }

  //PO ZMIANIE KAFELKA NA DOLNYM MENU
  void onPageChanged(int routeId) {
    setState(() {
      _centeredRouteId = routeId;
      isInfoVisible = false;
    });
    _updatePolylines();
    _compassSubscription?.cancel();
    _centerMapOnFirstRoutePoint();
  }

  //PRZEŁĄCZ WIDOK BOTTOM_MENU
  void toggleBottomMenu() {
    setState(() {
      isBottomMenuVisible = !isBottomMenuVisible;
    });
  }

  //ZARZĄDZANIE AUDIO
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playSound(String soundFileName) async {
    await _audioPlayer.play(AssetSource('$soundFileName'));
  }

  void _stopSound() async {
    await _audioPlayer.stop(); // Zatrzymuje odtwarzanie
  }

  void toggleSound() {
    setState(() {
      isSoundEnabled = !isSoundEnabled;

      if (!isSoundEnabled) {
        _stopSound(); // Zatrzymuje dźwięk, gdy dźwięk jest wyłączony
      }
    });
  }

  //ZAKAŃCZANIE NASŁUCHIWAŃ
  @override
  void dispose() {
    _positionStreamSubscription
        ?.cancel(); // Zatrzymaj nasłuchiwanie lokalizacji
    customInfoWindowController.dispose();
    super.dispose();
  }
}

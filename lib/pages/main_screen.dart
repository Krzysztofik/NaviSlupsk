import 'package:flutter/material.dart';
import 'package:google_maps_app/ui/app_bar.dart';
import 'package:google_maps_app/ui/bottom_menu.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_app/services/marker_maker.dart';
import 'package:google_maps_app/models/route_model.dart';

enum ScreenState { Map, RouteList }
ScreenState _currentScreenState = ScreenState.Map;
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

  @override
void initState() {
  super.initState();
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
  //Builder google mapy.
  Widget _buildMap() {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _slupskCenter,
              zoom: 14.0,
            ),
            markers: buildMarkers(centeredRouteId), // Użyj zaktualizowanej funkcji buildMarkers() z przekazanym identyfikatorem wyśrodkowanej trasy
          ),
        ),
        BottomMenu(onPageChanged: onPageChanged), // Dodaj bottom menu
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
            _currentScreenState = ScreenState.Map;
          });
        },
        onListIconPressed: () {
          setState(() {
            _currentScreenState = ScreenState.RouteList;
          });
        },
      ),
      body: _buildBody(),
    );
  }

  //Builder body
  Widget _buildBody() {
    switch (_currentScreenState) {
      case ScreenState.Map:
        return _buildMap();
      case ScreenState.RouteList:
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
}

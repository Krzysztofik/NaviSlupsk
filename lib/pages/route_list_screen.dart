import 'package:flutter/material.dart';
import 'package:google_maps_app/models/route_model.dart';

class RouteListScreen extends StatelessWidget {
  final List<RouteModel> routes;
  final int? initialRouteId; // Opcjonalny parametr, który określa, która trasa ma być rozwinięta

  const RouteListScreen({Key? key, required this.routes, this.initialRouteId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          final points = route.points;

          return ExpansionTile(
            initiallyExpanded: route.id == initialRouteId, // Sprawdzamy, czy ta trasa powinna być rozwinięta
            title: Text(route.name),
            leading: Image.asset(
              route.imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            children: [
              ...points.map((point) {
                return ListTile(
                  title: Text(point.name),
                  subtitle: Text('Lat: ${point.latitude}, Lng: ${point.longitude}'),
                  onTap: () {
                    // Dodaj logikę, która centrowałaby mapę na tym punkcie lub przenosiła do widoku szczegółowego.
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

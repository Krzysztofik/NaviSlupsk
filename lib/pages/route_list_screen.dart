import 'package:flutter/material.dart';
import 'package:google_maps_app/models/route_model.dart';

class RouteListScreen extends StatelessWidget {
  final List<RouteModel> routes;
  final int? initialRouteId;
  final int? selectedPointId;

  const RouteListScreen({Key? key, required this.routes, this.initialRouteId, this.selectedPointId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          final points = route.points;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ExpansionTile(
              initiallyExpanded: route.id == initialRouteId,
              textColor: Color.fromRGBO(77, 182, 172, 1),
              iconColor: Color.fromRGBO(77, 182, 172, 1),
              title: Text(
                route.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              leading: Image.asset(
                route.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              children: [
                ...points.map((point) {
                  final isSelected = point.id == selectedPointId;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      tileColor: isSelected ? Color.fromRGBO(77, 182, 172, 1) : null,
                      title: Row(
                        children: [
                          // Obrazek punktu
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: point.imagePath != null
                                ? Image.asset(
                                    point.imagePath!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  point.name,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text('Lat: ${point.latitude}, Lng: ${point.longitude}'),
                                if (point.description != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      point.description!,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Wyświetl szczegółowy opis w modalnym oknie
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    point.name,
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  if (point.imagePath != null)
                                    Image.asset(
                                      point.imagePath!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Lat: ${point.latitude}, Lng: ${point.longitude}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  if (point.description != null)
                                    Text(
                                      point.description!,
                                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                    ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Zamknij modalne okno
                                    },
                                    child: const Text('Zamknij'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

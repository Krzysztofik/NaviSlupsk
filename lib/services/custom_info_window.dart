// custom_info_window.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:google_maps_app/models/globals.dart';
import 'package:confetti/confetti.dart';

void showCustomInfoWindow(
    PointModel marker,
    CustomInfoWindowController customInfoWindowController,
    BuildContext context,
    bool isSoundEnabled,
    Function(String) playSound,
    ConfettiController confettiControllerSmall,
    ConfettiController confettiControllerBig,
    int centeredRouteId,
    List<RouteModel> routes,
    Function updateDiscoveryState,
    Function updateMarkerInfo) {
  customInfoWindowController.addInfoWindow!(
    StatefulBuilder(
      builder: (context, setState) {
        final double windowWidth = 300;
        final double windowHeight = 100;

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
              Container(
                width: double.infinity,
                height: windowWidth * 0.45,
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
                          if (isSoundEnabled && marker.audioPath != null) {
                            playSound(marker.audioPath!);
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        color: Colors.teal,
                        onPressed: () {
                          setState(() {
                            // Update the state to show the route list
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              if (isNavigationActive)
                AnimatedOpacity(
                  opacity: isNavigationActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: marker.isDiscovered,
                    title: const Text('Odkryłeś ten znacznik?',
                        style: TextStyle(fontSize: 14)),
                    onChanged: (bool? value) async {
                      setState(() {
                        marker.isDiscovered = value ?? false;

                        final route =
                            routes.firstWhere((r) => r.id == centeredRouteId);
                        final index =
                            route.points.indexWhere((p) => p.id == marker.id);
                        if (index != -1) {
                          route.points[index] = marker;
                        }

                        bool allDiscovered =
                            route.points.every((p) => p.isDiscovered);

                        if (allDiscovered) {
                          confettiControllerBig.play();
                        } else {
                          confettiControllerSmall.play();
                        }
                      });

                      await updateDiscoveryState(
                          marker.id, marker.isDiscovered);
                      updateMarkerInfo();
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

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_app/providers/audio_provider.dart';

void showCustomInfoWindow(
  PointModel marker,
  CustomInfoWindowController customInfoWindowController,
  BuildContext context,
  bool isSoundEnabled,
  ConfettiController confettiControllerSmall,
  ConfettiController confettiControllerBig,
  int centeredRouteId,
  List<RouteModel> routes,
) {

  customInfoWindowController.addInfoWindow!(
    StatefulBuilder(
      builder: (context, setState) {
        final double windowWidth = 300;
        final double windowHeight = 150;

        Color backgroundColor =Colors.white;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16.0),
          width: windowWidth,
          height: windowHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20), // Zaokrąglone rogi
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
              const SizedBox(
                  height: 12), // Większa przerwa między obrazkiem a tekstem
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      marker.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          // Uzyskaj dostęp do AudioState za pomocą Provider
                          final audioState =
                          Provider.of<AudioState>(context, listen: false);
                          if (!audioState.isMuted && marker.audioPath != null) {
                            audioState.playSound(marker
                                .audioPath!); // Użyj metody playSound w AudioState
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
    LatLng(marker.latitude, marker.longitude),
  );
}

// custom_info_window.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:google_maps_app/models/globals.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void showMarkerDiscoveryNotification(BuildContext context) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Center(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AppLocalizations.of(context)!.markerAlert,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Po sekundzie zniknij
  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

void showRouteDiscoveryNotification(BuildContext context) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Center(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AppLocalizations.of(context)!.routeAlert,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Po sekundzie zniknij
  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

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
    Function updateMarkerInfo,
) {
  bool isCheckboxPreviouslyChecked = marker.isDiscovered;
  bool shouldShowCheckbox = marker.isDiscovered || isNavigationActive;

  customInfoWindowController.addInfoWindow!(
    StatefulBuilder(
      builder: (context, setState) {
        final double windowWidth = 300;
        final double windowHeight = 150;

        // Kolor tła na podstawie stanu odkrycia
        Color backgroundColor = marker.isDiscovered ? Colors.greenAccent : Colors.white;

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
              const SizedBox(height: 12), // Większa przerwa między obrazkiem a tekstem
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
                          color: Colors.teal,
                        ),
                        onPressed: () {
                          if (isSoundEnabled && marker.audioPath != null) {
                            playSound(marker.audioPath!);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (shouldShowCheckbox)
                AnimatedOpacity(
                  opacity: shouldShowCheckbox ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: marker.isDiscovered,
                    title: Text(AppLocalizations.of(context)!.checkBox,
                        style: TextStyle(fontSize: 14)),
                    onChanged: (bool? value) async {
                      setState(() {
                        marker.isDiscovered = value ?? false;

                        if (marker.isDiscovered && !isCheckboxPreviouslyChecked) {
                          final route = routes.firstWhere((r) => r.id == centeredRouteId);
                          final index = route.points.indexWhere((p) => p.id == marker.id);
                          if (index != -1) {
                            route.points[index] = marker;
                          }

                          bool allDiscovered = route.points.every((p) => p.isDiscovered);
                          if (allDiscovered) {
                            confettiControllerBig.play();
                            showRouteDiscoveryNotification(context); 
                          } else {
                            confettiControllerSmall.play();
                            showMarkerDiscoveryNotification(context);
                          }
                        }

                        isCheckboxPreviouslyChecked = marker.isDiscovered;
                      });

                      await updateDiscoveryState(marker.id, marker.isDiscovered);
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




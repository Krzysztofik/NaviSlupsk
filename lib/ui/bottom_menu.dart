import 'package:flutter/material.dart';
import 'package:google_maps_app/models/route_model.dart';


class BottomMenu extends StatefulWidget {
  final void Function(int) onPageChanged;
  final bool isVisible;
  final VoidCallback onHideInfoWindow;
  final VoidCallback onNavigate;
  final VoidCallback onMarkerInfoUpdate;
  final VoidCallback onStop;
  final int discoveredMarkers;
  final int totalMarkers;
  final VoidCallback onListIconPressed;

  const BottomMenu(
      {Key? key,
      required this.onPageChanged,
      this.isVisible = true,
      required this.onHideInfoWindow,
      required this.onNavigate,
      required this.onMarkerInfoUpdate,
      required this.onStop,
      required this.discoveredMarkers,
      required this.totalMarkers,
      required this.onListIconPressed})
      : super(key: key);

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  List<RouteModel> menus = [];
  final PageController _pageController = PageController(viewportFraction: 0.7);
  int _currentRouteId = 1;

  bool isNavigating = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    final loadedRoutes = await RouteModel.getRoutes();
    setState(() {
      menus = loadedRoutes;
    });
  }

  void _onPageChanged() {
    final double currentPage = _pageController.page ?? 0;
    final int roundedPage = currentPage.round();

    if ((currentPage - roundedPage).abs() < 0.01) {
      final RouteModel currentRoute = menus[roundedPage];
      _currentRouteId = currentRoute.id;
      widget.onPageChanged(currentRoute.id);
      widget.onMarkerInfoUpdate();

      setState(() {
        isNavigating = true;
      });
    }
  }

  ElevatedButton _buildIconButton(String assetPath, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: widget.isVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 500),
      child: Container(
        color: Colors.white,
        height: 254,
        child: PageView.builder(
          itemCount: menus.length,
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 2.70 / 5 * 250,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.asset(
                          menus[index].imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 8),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          menus[index].name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 75),
                          child: Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (isNavigating) {
                                    widget
                                        .onNavigate(); // Wywołaj funkcję onNavigate
                                  } else {
                                    widget.onStop(); // Wywołaj funkcję onStop
                                  }
                                  isNavigating =
                                      !isNavigating; // Zmień stan na przeciwny
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Image.asset(
                                isNavigating
                                    ? 'assets/images/buttonicons/start_button.png'
                                    : 'assets/images/buttonicons/stop_button.png',
                                fit: BoxFit.cover,
                                width: 50, // Szerokość obrazu
                                height: 50, // Wysokość obrazu
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                widget.onListIconPressed();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Image.asset(
                                'assets/images/buttonicons/info_button.png',
                                fit: BoxFit.cover,
                                width: 50, // Szerokość obrazu
                                height: 50, // Wysokość obrazu
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          onPageChanged: (index) {
            widget.onHideInfoWindow();
            widget.onMarkerInfoUpdate();
          },
        ),
      ),
    );
  }
}

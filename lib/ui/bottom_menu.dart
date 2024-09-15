import 'package:flutter/material.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:google_maps_app/pages/route_list_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomMenu extends StatefulWidget {
  final void Function(int) onPageChanged;
  final bool isVisible;
  final VoidCallback onHideInfoWindow;
  final VoidCallback onNavigate;
  final VoidCallback onMarkerInfoUpdate;

  const BottomMenu({
    Key? key,
    required this.onPageChanged,
    this.isVisible = true,
    required this.onHideInfoWindow,
    required this.onNavigate,
    required this.onMarkerInfoUpdate, // Przekazanie funkcji nawigacji
  }) : super(key: key);

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  List<RouteModel> menus = [];
  final PageController _pageController = PageController(viewportFraction: 0.6);
  int _currentRouteId = 1;

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
    RouteModel.getRoutes().then((loadedRoutes) {
      setState(() {
        menus = loadedRoutes;
      });
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
    }
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
                    height: 3 / 5 * 250,
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
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        menus[index].name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              showRouteDetails(_currentRouteId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(77, 182, 172, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(105, 35),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.showPlaces,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onNavigate();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(77, 182, 172, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(105, 35),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.navigate,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
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
  void showRouteDetails(int routeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteListScreen(
          routes: menus,
          initialRouteId: routeId,
        ),
      ),
    );
  }
}

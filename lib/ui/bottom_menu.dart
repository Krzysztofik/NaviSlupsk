import 'package:flutter/material.dart';
import 'package:google_maps_app/models/route_model.dart';

class BottomMenu extends StatefulWidget {
  final void Function(int) onPageChanged; // Funkcja wywoływana, gdy zmienia się PageView.
  final bool isVisible; // Czy menu ma być widoczne? Domyślnie true.
  final VoidCallback onHideInfoWindow; // Funkcja ukrywająca okienko nad markerem.
  final VoidCallback onNavigate; // Funkcja wywoływana po rozpoczęciu nawigacji.
  final VoidCallback onMarkerInfoUpdate; // Funkcja wywoływana po aktualizacji info o markerze.
  final VoidCallback onStop; // Funkcja wywoływana po zakończeniu nawigacji. // Liczba wszystkich markerów.
  final VoidCallback onListIconPressed; // Funkcja wywoływana po naciśnięciu szczegółów trasy.

  const BottomMenu(
      {Key? key,
      required this.onPageChanged,
      this.isVisible = true,
      required this.onHideInfoWindow,
      required this.onNavigate,
      required this.onMarkerInfoUpdate,
      required this.onStop,
      required this.onListIconPressed})
      : super(key: key);

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  List<RouteModel> menus = []; // Lista obiektów RouteModel, dostępne trasy.
  final PageController _pageController = PageController(viewportFraction: 0.7); // Kontroler przewijania elementów w PageView.

  bool isNavigating = true; // Flaga nawigacji (start/stop).

  // Inicjuje ładowanie tras i nasłuchuje zmian strony w PageView.
  @override
  void initState() {
    super.initState();
    _loadRoutes();
    _pageController.addListener(_onPageChanged);
  }

  // Usuwa kontroler strony, aby uniknąć wycieków pamięci.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Asynchronicznie ładuje trasy z modelu RouteModel i aktualizuje stan komponentu.
  Future<void> _loadRoutes() async {
    final loadedRoutes = await RouteModel.getRoutes();
    setState(() {
      menus = loadedRoutes;
    });
  }

  // Sprawdza, która strona w PageView jest aktualnie wyświetlana i aktualizuje stan nawigacji.
  void _onPageChanged() {
    final double currentPage = _pageController.page ?? 0;
    final int roundedPage = currentPage.round();

    if ((currentPage - roundedPage).abs() < 0.01) {
      final RouteModel currentRoute = menus[roundedPage];
      widget.onPageChanged(currentRoute.id);
      widget.onMarkerInfoUpdate();

      setState(() {
        isNavigating = true;
      });
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 2.70 / 5 * 275,
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
                      padding: const EdgeInsets.only(top: 6),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (isNavigating) {
                                  widget
                                      .onNavigate(); 
                                } else {
                                  widget.onStop(); 
                                }
                                isNavigating =
                                    !isNavigating; 
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white, 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), 
                                side: BorderSide(
                                  color: isNavigating
                                      ? Colors.green
                                      : Colors.red, 
                                  width: 1, 
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 18,
                              ),
                              elevation: 3, 
                              shadowColor: isNavigating
                                  ? Colors.green
                                  : Colors.red, 
                            ),
                            child: Text(
                              isNavigating
                                  ? 'Start'
                                  : 'Stop', 
                              style: TextStyle(
                                color: isNavigating
                                    ? Colors.green
                                    : Colors.red, 
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10), 
                        ElevatedButton(
                          onPressed: () {
                            widget
                                .onListIconPressed(); 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .white, 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), 
                              side: BorderSide(
                                color: Colors
                                    .blue,
                                width: 1, 
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 18,
                            ),
                            elevation: 3, 
                            shadowColor: Colors.blueAccent, 
                          ),
                          child: Text(
                            'Info', 
                            style: TextStyle(
                              color: Colors
                                  .blue, 
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
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

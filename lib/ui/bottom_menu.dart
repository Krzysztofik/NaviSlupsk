// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_maps_app/models/route_model.dart';

class BottomMenu extends StatefulWidget {
  const BottomMenu({Key? key}) : super(key: key);

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  List<RouteModel> menus = [];
  final PageController _pageController = PageController(viewportFraction: 0.6);

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
    final double currentPage = _pageController.page?? 0;
    final int roundedPage = currentPage.round();

    if ((currentPage - roundedPage).abs() < 0.01) {
      final RouteModel currentRoute = menus[roundedPage];
      print("Wyśrodkowano element id${currentRoute.id} o nazwie ${currentRoute.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        height: 254,
        child: PageView.builder(
          itemCount: menus.length,
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
              ),
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
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          menus[index].name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(77, 182, 172, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(220, 35),
                              ),
                              child: const Text(
                                'Pokaż miejsca',
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
        ),
      ),
    );
  }
}
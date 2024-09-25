import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_app/pages/main_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMapIconPressed;
  final VoidCallback onListIconPressed;
  final ScreenState currentScreenState; // Dodajemy parametr do śledzenia stanu

  const MyAppBar({
    Key? key,
    required this.onMapIconPressed,
    required this.onListIconPressed,
    required this.currentScreenState, // Otrzymujemy stan ekranu
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      title: Text(
        AppLocalizations.of(context)!.routesTitle,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        Row(
          children: [
            IconButton(
              icon: Opacity(
                opacity: currentScreenState == ScreenState.routeListState ? 1.0 : 0.5, // Adjust opacity
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Image.asset('assets/images/buttonicons/list_icon.png'),
                ),
              ),
              onPressed: onListIconPressed,
            ),
            IconButton(
              icon: Opacity(
                opacity: currentScreenState == ScreenState.mapState ? 1.0 : 0.5, // Adjust opacity
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Image.asset('assets/images/buttonicons/map_icon.png'),
                ),
              ),
              onPressed: onMapIconPressed,
            ),
          ],
        ),
      ],
    );
  }
}

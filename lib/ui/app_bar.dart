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
              icon: Icon(
                currentScreenState == ScreenState.routeListState
                    ? Icons.view_list_rounded
                    : Icons.view_list_outlined,
              ),
              color: currentScreenState == ScreenState.routeListState
                  ? Color.fromRGBO(77, 182, 172, 1)
                  : Colors.black,
              onPressed: onListIconPressed,
            ),
            IconButton(
              icon: Icon(
                currentScreenState == ScreenState.mapState
                    ? Icons.place_rounded
                    : Icons.place_outlined,
              ),
              color: currentScreenState == ScreenState.mapState
                  ? Color.fromRGBO(77, 182, 172, 1)
                  : Colors.black,
              onPressed: onMapIconPressed,
            ),
          ],
        ),
      ],
    );
  }
}

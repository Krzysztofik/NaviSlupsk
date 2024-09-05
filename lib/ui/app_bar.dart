import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_app/pages/welcome_screen.dart';
import 'package:google_maps_app/models/route_model.dart';
import 'package:google_maps_app/pages/route_list_screen.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMapIconPressed;
  final VoidCallback onListIconPressed;

  const MyAppBar({
    Key? key,
    required this.onMapIconPressed,
    required this.onListIconPressed,
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        },
      ),
      title: const Text(
        'Trasy audio',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.black,
              onPressed: onListIconPressed,
            ),
            IconButton(
              icon: const Icon(Icons.place),
              color: Colors.black,
              onPressed: onMapIconPressed,
            ),
          ],
        ),
      ],
    );
  }
}

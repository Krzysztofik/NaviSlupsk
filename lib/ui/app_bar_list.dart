import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {

  const MyAppBar({Key? key,}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Preferowany rozmiar paska AppBar.

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Kolor tła paska statusu.
        systemNavigationBarColor: Colors.white, // Kolor tła dolnego paska nawigacji.
      ),
      backgroundColor: Colors.white, // Kolor tła paska AppBar.
      title: Text(
        AppLocalizations.of(context)!.routesTitle, // Tytuł AppBar (pobierany z aktualnej lokalizacji językowej).
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        Row(
          children: [
            IconButton(
              icon: Opacity(
                opacity: 1, // Gdy zaznaczona - bez przeźroczystości.
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Image.asset('assets/images/buttonicons/list_icon.png'),
                ),
              ),
              onPressed: null, // Po naciśnięciu przejdź do listy tras.
            ),
            IconButton(
              icon: Opacity(
                opacity: 0.5, // Gdy zaznaczona - bez przeźroczystości.
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Image.asset('assets/images/buttonicons/map_icon.png'),
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  context
                );
            }, // Po naciśnięciu przejdź do mapy.
            ),
          ],
        ),
      ],
    );
  }
}

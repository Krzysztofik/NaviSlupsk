import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/main_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accessing localization strings
    final localization = AppLocalizations.of(context)!;

    // Map data with localized titles and descriptions
    final List<Map<String, dynamic>> mapData = [
      {
        'image': 'assets/images/markers/default_marker.png',
        'title': localization.defaultTitle,
        'description': localization.defaultDescription,
      },
      {
        'image': 'assets/images/markers/discovered_marker.png',
        'title': localization.discoveredTitle,
        'description': localization.discoveredDescription,
      },
      {
        'image': 'assets/images/markers/user_marker.png',
        'title': localization.userTitle,
        'description': localization.userDescription,
      },
      {
        'image': 'assets/images/markers/navigation_marker.png',
        'title': localization.naviTitle,
        'description': localization.naviDescription,
      },
    ];

    final List<Map<String, dynamic>> mapButtonData = [
      {
        'image': 'assets/images/buttonicons/audio_off_icon.png',
        'title': localization.audioOffTitle,
        'description': localization.audioOffDescription,
      },
      {
        'image': 'assets/images/buttonicons/audio_on_icon.png',
        'title': localization.audioOnTitle,
        'description': localization.audioOnDescription,
      },
      {
        'image': 'assets/images/buttonicons/menu_icon.png',
        'title': localization.menuTitle,
        'description': localization.menuDescription,
      },
      {
        'image': 'assets/images/buttonicons/user_center.png',
        'title': localization.userCenterTitle,
        'description': localization.userCenterDescription,
      },
    ];

    // Updated menuButtonData with buttons instead of images
    final List<Map<String, dynamic>> menuButtonData = [
      {
        'button': ElevatedButton(
          onPressed: () {
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Białe wypełnienie przycisku
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Mniejsze zaokrąglone rogi
            side: BorderSide(
              color: Colors.green, // Kolor obramowania
              width: 1, // Grubość obramowania
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 18,
          ),
          elevation: 3, // Efekt podniesienia
          shadowColor:Colors.green, // Kolor cienia
        ),
          child: Text(
          'Start', // Tekst przycisku
          style: TextStyle(
            color: Colors.green, // Kolor tekstu
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ), 
        ),
        'title': localization.startTitle,
        'description': localization.startDescription,
      },
      {
        'button': ElevatedButton(
          onPressed: () {
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Białe wypełnienie przycisku
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Mniejsze zaokrąglone rogi
            side: BorderSide(
              color: Colors.red, // Kolor obramowania
              width: 1, // Grubość obramowania
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 18,
          ),
          elevation: 3, // Efekt podniesienia
          shadowColor:Colors.red, // Kolor cienia
        ),
          child: Text(
          'Stop', // Tekst przycisku
          style: TextStyle(
            color: Colors.red, // Kolor tekstu
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ), 
        ),
        'title': localization.stopTitle,
        'description': localization.stopDescription,
      },
      {
        'button': ElevatedButton(
          onPressed: () {
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Białe wypełnienie przycisku
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Mniejsze zaokrąglone rogi
            side: BorderSide(
              color: Colors.blue, // Kolor obramowania
              width: 1, // Grubość obramowania
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 18,
          ),
          elevation: 3, // Efekt podniesienia
          shadowColor:Colors.blue, // Kolor cienia
        ),
          child: Text(
          'Info', // Tekst przycisku
          style: TextStyle(
            color: Colors.blue, // Kolor tekstu
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ), 
        ),
        'title': localization.infoTitle,
        'description': localization.infoDescription,
      },
    ];

    final List<Map<String, dynamic>> navigationData = [
      {
        'image': 'assets/images/buttonicons/map_icon.png',
        'title': localization.mapTitle,
        'description': localization.mapDescription,
      },
      {
        'image': 'assets/images/buttonicons/list_icon.png',
        'title': localization.listTitle,
        'description': localization.listDescription,
      },
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            SectionHeader(title: localization.iconSection),
            ...mapData.map((data) {
              return OnboardingItem(
                imagePath: data['image'],
                title: data['title'],
                description: data['description'],
              );
            }).toList(),
            const SizedBox(height: 20),
            SectionHeader(title: localization.mapSection),
            ...mapButtonData.map((data) {
              return OnboardingItem(
                imagePath: data['image'],
                title: data['title'],
                description: data['description'],
              );
            }).toList(),
            const SizedBox(height: 20),
            SectionHeader(title: localization.menuSection),
            // Updated rendering logic for buttons
            ...menuButtonData.map((data) {
              return OnboardingItem(
                button: data['button'], // Passing the button widget
                title: data['title'],
                description: data['description'],
              );
            }).toList(),
            const SizedBox(height: 20),
            SectionHeader(title: localization.naviSection),
            ...navigationData.map((data) {
              return OnboardingItem(
                imagePath: data['image'],
                title: data['title'],
                description: data['description'],
              );
            }).toList(),
            const SizedBox(height: 20),
            Text(
              localization.routeInfo,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/calibration.gif',
              width: 250,
              height: 200,
            ),
            const SizedBox(height: 10),
            Text(
              localization.compassSection,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              },
              child: Text(
                localization.startButton,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ).copyWith(
                shadowColor: MaterialStateProperty.all(
                    Colors.blue.withOpacity(0.5)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Define the OnboardingItem widget
class OnboardingItem extends StatelessWidget {
  final String? imagePath; // Optional imagePath
  final Widget? button; // Optional button widget
  final String title;
  final String description;

  const OnboardingItem({
    this.imagePath,
    this.button,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath!,
              width: 50,
              height: 50,
            ),
          if (button != null) button!, // Display button if available
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// Define the SectionHeader widget
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

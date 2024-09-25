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
        'title': localization.defaultTitle,  // Localized string
        'description': localization.defaultDescription,  // Localized string
      },
      {
        'image': 'assets/images/markers/discovered_marker.png',
        'title': localization.discoveredTitle,  // Localized string
        'description': localization.discoveredDescription,  // Localized string
      },
      {
        'image': 'assets/images/markers/user_marker.png',
        'title': localization.userTitle,  // Localized string
        'description': localization.userDescription,  // Localized string
      },
      {
        'image': 'assets/images/markers/navigation_marker.png',
        'title': localization.naviTitle,  // Localized string
        'description': localization.naviDescription,  // Localized string
      },
    ];

    final List<Map<String, dynamic>> mapButtonData = [
      {
        'image': 'assets/images/buttonicons/audio_off_icon.png',
        'title': localization.audioOffTitle,  // Localized string
        'description': localization.audioOffDescription,  // Localized string
      },
      {
        'image': 'assets/images/buttonicons/audio_on_icon.png',
        'title': localization.audioOnTitle,  // Localized string
        'description': localization.audioOnDescription,  // Localized string
      },
      {
        'image': 'assets/images/buttonicons/menu_icon.png',
        'title': localization.menuTitle,  // Localized string
        'description': localization.menuDescription,  // Localized string
      },
      {
        'image': 'assets/images/buttonicons/user_center.png',
        'title': localization.userCenterTitle,  // Localized string
        'description': localization.userCenterDescription,  // Localized string
      },
    ];

    final List<Map<String, dynamic>> menuButtonData = [
      {
        'image': 'assets/images/buttonicons/start_button.png',
        'title': localization.startTitle,  // Localized string
        'description': localization.startDescription,  // Localized string
      },
      {
        'image': 'assets/images/buttonicons/stop_button.png',
        'title': localization.stopTitle,  // Localized string
        'description': localization.stopDescription,  // Localized string
      },
      {
        'image': 'assets/images/buttonicons/info_button.png',
        'title': localization.infoTitle,  // Localized string
        'description': localization.infoDescription,  // Localized string
      },
    ];

    final List<Map<String, dynamic>> navigationData = [
      {
        'image': 'assets/images/buttonicons/map_icon.png',
        'title': localization.mapTitle,  // Localized string
        'description': localization.mapDescription,  // Localized string
      },
      {
        'image': 'assets/images/buttonicons/list_icon.png',
        'title': localization.listTitle,  // Localized string
        'description': localization.listDescription,  // Localized string
      },
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            SectionHeader(title: localization.iconSection),  // Localized section header
            ...mapData.map((data) {
              return OnboardingItem(
                imagePath: data['image'],
                title: data['title'],
                description: data['description'],
              );
            }).toList(),
            const SizedBox(height: 20),
            SectionHeader(title: localization.mapSection),  // Localized section header
            ...mapButtonData.map((data) {
              return OnboardingItem(
                imagePath: data['image'],
                title: data['title'],
                description: data['description'],
              );
            }).toList(),
            const SizedBox(height: 20),
            SectionHeader(title: localization.menuSection),  // Localized section header
            ...menuButtonData.map((data) {
              return OnboardingItem(
                imagePath: data['image'],
                title: data['title'],
                description: data['description'],
              );
            }).toList(),
            const SizedBox(height: 20),
            SectionHeader(title: localization.naviSection),  // Localized section header
            ...navigationData.map((data) {
              return OnboardingItem(
                imagePath: data['image'],
                title: data['title'],
                description: data['description'],
              );
            }).toList(),
            const SizedBox(height: 20),
            Text(
              localization.routeInfo,  // Localized text
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
              localization.compassSection,  // Localized text
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
                localization.startButton,  // Localized button text
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
  final String imagePath;
  final String title;
  final String description;

  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 50,
            height: 50,
          ),
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

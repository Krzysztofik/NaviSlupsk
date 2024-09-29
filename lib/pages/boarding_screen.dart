import 'package:flutter/material.dart';
import 'package:google_maps_app/pages/main_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  final bool fromWelcome;

  OnboardingScreen({required this.fromWelcome});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

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

    final List<Map<String, dynamic>> menuButtonData = [
      {
        'button': ElevatedButton(
          onPressed: () {
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.green,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 18,
          ),
          elevation: 3,
          shadowColor:Colors.green,
        ),
          child: Text(
          'Start', 
          style: TextStyle(
            color: Colors.green, 
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.red,
              width: 1, 
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 18,
          ),
          elevation: 3,
          shadowColor:Colors.red, 
        ),
          child: Text(
          'Stop', 
          style: TextStyle(
            color: Colors.red, 
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
          backgroundColor: Colors.white, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), 
            side: BorderSide(
              color: Colors.blue, 
              width: 1, 
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 18,
          ),
          elevation: 3, 
          shadowColor:Colors.blue,
        ),
          child: Text(
          'Info', // Tekst przycisku
          style: TextStyle(
            color: Colors.blue,
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
            ...menuButtonData.map((data) {
              return OnboardingItem(
                button: data['button'],
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
                if (fromWelcome) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                } else {
                  Navigator.of(context).pop();
                }
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


class OnboardingItem extends StatelessWidget {
  final String? imagePath; 
  final Widget? button; 
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
          if (button != null) button!, 
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

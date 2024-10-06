import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_app/pages/main_screen.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    // Wspólny styl tekstu
    TextStyle titleStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
    TextStyle descriptionStyle = TextStyle(fontSize: 18, color: Colors.black54);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnBoardingSlider(
        headerBackgroundColor: Colors.white,
        finishButtonText: localization.startButton,
        finishButtonStyle: FinishButtonStyle(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        background: [
          Image.asset('assets/images/markers/default_marker.png'),
          Image.asset('assets/images/markers/discovered_marker.png'),
          Image.asset('assets/images/markers/user_marker.png'),
          Image.asset('assets/images/markers/navigation_marker.png'),
          Image.asset('assets/images/buttonicons/audio_off_icon.png'),
          Image.asset('assets/images/buttonicons/audio_on_icon.png'),
          Image.asset('assets/images/buttonicons/menu_icon.png'),
          Image.asset('assets/images/buttonicons/user_center.png'),
          Image.asset('assets/images/buttonicons/map_icon.png'),
          Image.asset('assets/images/buttonicons/list_icon.png'),
          Image.asset('assets/images/buttonicons/help_icon.png'),
          Image.asset('assets/images/buttonicons/language_icon.png'),
        ],
        controllerColor: Colors.blueAccent,
        centerBackground: true,
        totalPage: 12,
        speed: 1.8,
        pageBodies: [
          // Pierwszy slajd: Default Marker
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.defaultTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.defaultDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          // Drugi slajd: Discovered Marker
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.discoveredTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.discoveredDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          // Trzeci slajd: User Marker
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.userTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.userDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          // Czwarty slajd: Navigation Marker
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.naviTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.naviDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          // Kolejne slajdy
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.audioOffTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.audioOffDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.audioOnTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.audioOnDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.menuTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.menuDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.userCenterTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.userCenterDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.mapTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.mapDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.listTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.listDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.helpTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.helpDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    localization.languageTitle,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    localization.languageDescription,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
        onFinish: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        },
      ),
    );
  }
}

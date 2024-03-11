import 'package:flutter/material.dart';

class ProfileParser extends ChangeNotifier {
  late List<String> _allProfiles = [];
  late List<String> _openProfiles = [];
  late List<String> _closedProfiles = [];
  late bool _viewMode = false;
  PageController _pageController = PageController(initialPage: 0);


  List<String> get allProfiles => _allProfiles;
  List<String> get openProfiles => _openProfiles;
  List<String> get closedProfiles => _closedProfiles;
  PageController get pageController => _pageController;

  void populateProfiles(List<dynamic> userProfiles) {
    if (allProfiles.isEmpty) {
      for (var profile in userProfiles) {
        _allProfiles.add(profile);
      }
      
      parseOpenProfile();
      parseClosedProfile();
    }
  }

  void parseOpenProfile() {
    for (var profile in allProfiles) {
      if (profile.substring(0,4) == 'open') {_openProfiles.add(profile);}
    }
  }

  void parseClosedProfile() {
    for (var profile in allProfiles) {
      if (profile.substring(0,4) != 'open') {_closedProfiles.add(profile);}
    }
  }
}

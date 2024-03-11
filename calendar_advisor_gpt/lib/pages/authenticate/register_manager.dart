import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';

class RegisterManager extends ChangeNotifier{
  bool _isPersonal = true;
  bool get isPersonal => _isPersonal;

  void setIsPersonal(bool isPersonal) {
    _isPersonal = isPersonal;
    notifyListeners();
  }

}
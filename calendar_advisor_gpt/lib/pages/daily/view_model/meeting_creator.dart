import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';

import '../../../shared/calendar_functions.dart';

class MeetingCreator extends ChangeNotifier {
  late DateTime _currentDate = dateOnly(DateTime.now());
  late List<DateTime> _dailyDate = [
    dateOnly(DateTime.now()),
    dateOnly(DateTime.now())
  ];
  late List<String> _dailyTime = [
    DateTime.now().toString().substring(11, 16),
    DateTime.now().toString().substring(11, 16)
  ];
  late List<int> _dailyAngles = [228, 48];
  late Color _color = Color(0xff8281FA);
  late String _errorMsg = '';
  late String _recurrenceRule = '';
  late int _colors_theme = 0;
  late List<List<Color>> _colors_list = [
        [
      Color(0xff8281FA),
      Color(0xff5E5CEC),
      Color(0xff5562FE),
      Color(0xff2E65F4),
      Color(0xff5599FE),
      Color(0xff71CCFF),
      
    ],
    [
      Color.fromRGBO(106, 103, 172, 100), // Very Peri (Main CalBack Color)
      Color.fromRGBO(130, 129, 250, 1), // HM color
      Color.fromRGBO(157, 144, 190, 100), // purple
      Color.fromRGBO(60, 109, 167, 100), // Navy
      Colors.purple,
      Colors.deepPurple
    ],
    [
      Colors.red,
      Colors.pink,
      Colors.yellow,
      Colors.orange,
      Colors.indigo,
      Colors.blue
    ],
    [
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime
    ],
    [
      Color.fromARGB(255, 192, 65, 65),
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime
    ],
  ];

  List<List<Color>> get colors_list => _colors_list;
  int get color_theme => _colors_theme;
  DateTime get currentDate => _currentDate;
  List<String> get dailyTime => _dailyTime;
  List<DateTime> get dailyDate => _dailyDate;
  List<int> get dailyAngles => _dailyAngles;
  Color get color => _color;
  String get errorMsg => _errorMsg;
  String get recurrenceRule => _recurrenceRule;

  void addColorTheme(List<Color> colorSet) {
    _colors_list.add(colorSet);
    notifyListeners();
  }

  void changeColorTheme(int idx) {
    _colors_theme = idx;
    notifyListeners();
  }

  void setErrorMsg(String msg) {
    _errorMsg = msg;
    notifyListeners();
  }

  void changeColor(Color selectedColor, bool notify) {
    _color = selectedColor;
    if (notify) {
      notifyListeners();
    }
  }

  void setDailyAngles(int startAngle, int endAngle) {
    _dailyAngles = [startAngle, endAngle];
  }

  void setDailyDate(DateTime dailyDateStart, DateTime dailyDateEnd) {
    _dailyDate = [dateOnly(dailyDateStart), dateOnly(dailyDateEnd)];
  }

  void setDailyTime(String dailyTimeStart, String dailyTimeEnd) {
    _dailyTime = [dailyTimeStart, dailyTimeEnd];
  }

  void setCurrentDate(DateTime currentDate) {
    _currentDate = dateOnly(currentDate);
    notifyListeners();
  }

  void setRecurrenceRule(String rRule) {
    _recurrenceRule = rRule;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../all_pages.dart';



class ColorPalette extends ChangeNotifier {
  Color _pickerColor = uiSettingColor.minimal_1;
  Color get pickerColor => _pickerColor;


  void resetColor () {
    _pickerColor = uiSettingColor.minimal_1;
    notifyListeners();
  }

  void changeColor(Color color) {
    _pickerColor = color;
    notifyListeners();
  }

  void changeEditColor(Color color) {
    _pickerColor = color;
    notifyListeners();
  }

  static const List<Color> defaultColors = [Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan, Colors.teal, Colors.green,
    Colors.lightGreen, Colors.lime, Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,];
}

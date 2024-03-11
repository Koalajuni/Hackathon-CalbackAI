import 'dart:ui';

import 'package:flutter/material.dart';

import 'all_pages.dart';


class ColorSetting{
  //CalBack Color Scheme
  Color hm_1 = Color(0xff5562FE);
  Color minimal_1 = Color.fromRGBO(106, 103, 172,1);     // Very Peri (Main CalBack Color)
  Color minimal_2 = Color.fromRGBO(215, 212, 241, 100); // light purple
  Color minimal_3 = Color.fromRGBO(157, 144, 190,100); // purple
  Color minimal_4 = Color.fromRGBO(60, 109, 167, 100); // Navy
  Color minimal_5 = Color.fromRGBO(28, 39, 41, 100);// blue-black
  Color borderColor = Color.fromRGBO(106, 103, 172,1);   

}


class FontSetting{
  TextStyle head_1 = TextStyle(fontSize: 36, fontFamily: 'Roboto-Medium');
  TextStyle head_2 = TextStyle(fontSize: 32, fontFamily: 'Roboto-Light');
  TextStyle head_3 = TextStyle(fontSize: 28, fontFamily: 'Roboto-Regular');
  TextStyle head_4 = TextStyle(fontSize: 24, fontFamily: 'Roboto-Regular');
  TextStyle head_5 = TextStyle(fontSize: 18, fontFamily: 'Roboto-Bold');
  TextStyle head_6 = TextStyle(fontSize: 16, fontFamily: 'Roboto-Medium');
  TextStyle subtitleRegular = TextStyle(fontSize: 14, fontFamily: 'Roboto-Regular');
  // TextStyle bodyRegular = TextStyle(fontSize: 36, fontFamily: 'Roboto-Medium');
  TextStyle subtitleSmall = TextStyle(fontSize: 12, fontFamily: 'Roboto-Medium');
  // TextStyle bodySmall = TextStyle(fontSize: 36, fontFamily: 'Roboto-Medium');
  // TextStyle button = TextStyle(fontSize: 36, fontFamily: 'Roboto-Medium');
  TextStyle caption = TextStyle(fontSize: 10, fontFamily: 'Roboto-Regular');

}

class Alert{

  showAlertDialog(BuildContext context){
    Widget okButton = ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.black, shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),),),
      child: Text( AppLocalizations.of(context)!.ok),
        onPressed:(){
    Navigator.of(context).pop();
    },
    );

    AlertDialog alert = AlertDialog(
        title: Text(AppLocalizations.of(context)!.alert_title),
        content: Text(AppLocalizations.of(context)!.alert_overlappingTime),
        actions:[
          okButton,
        ], );

    showDialog(
      context: context,
      builder: (BuildContext context){
        return alert;
      },
    );
  }

}

class TimeZone {
  String current = 'Korea Standard Time';
}

BoxDecoration myMonthCell() {
    return BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xffD9D9D9),
              width: 1,
            ),
          ),
        );
}

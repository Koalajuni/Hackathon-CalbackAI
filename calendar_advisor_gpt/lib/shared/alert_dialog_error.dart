import 'package:flutter/material.dart';
import '../pages/all_pages.dart';

showAlertDialog(context, body) {
  Widget okButton = TextButton(
    style: TextButton.styleFrom(
        primary: Colors.white, backgroundColor: ColorSetting().minimal_4),
    onPressed: () {
      Navigator.of(context).pop();
    },
    child: Text(AppLocalizations.of(context)!.ok),
  );

  AlertDialog alert = AlertDialog(
    title: Text(AppLocalizations.of(context)!.error,
        style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black)),
    content: Text(body,
        style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            color: Colors.black54)),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (context) {
      return alert;
    },
  );
}

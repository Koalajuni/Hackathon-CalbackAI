
import 'package:calendar/services/auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';
import 'package:calendar/shared/globals.dart' as globals;


// binding User Agreement: If Declined will delete User account
class OnBoarding {

  final AuthService _auth = AuthService();

  Future onBoardingAlert(context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:(BuildContext context) {
        return FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.5,
        child:  AlertDialog(
            title: Text("캘박AI 시작"),
            content: Column(
              children: [
                Text(
                    '캘박 AI를 보다 잘 이용하시려면 캘린더에서 적어도 일정 3개를 등록해주세요! \n 캘박이 분석해드립니다! '),
                // arithmetic number of n which will be multiplied by a (weeks chosen) for count
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async{
                  Navigator.pop(context);
                  },
                child:Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: (){
                  globals.bnbIndex = 1;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/wrapper', (Route<dynamic> route) => false);
                },
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
      }
    );
  }


}
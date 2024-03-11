import 'package:calendar/pages/authenticate/onboarding.dart';
import 'package:calendar/services/auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';
import 'package:calendar/shared/globals.dart' as globals;


// binding User Agreement: If Declined will delete User account
class UserAgreement {

  final Uri eulaUrl = Uri.parse('https://sites.google.com/view/calback-eula/home');
  final Uri privacyUrl = Uri.parse('https://sites.google.com/view/calback/home');
  static bool isVisible = false;
  final AuthService _auth = AuthService();
  final OnBoarding onBoarding = OnBoarding(); 


  Future UserLicenseAlert(context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:(BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.eula),
          content: Column(
            children: [
              Text(
                  'By using this application, you agree to the End User License Agreement and the Privacy Statement.'),
              Container(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: () {
                      isVisible = !isVisible;
                    },
                    style: TextButton.styleFrom(
                        primary: uiSettingColor.minimal_1,
                        textStyle: const TextStyle(
                            fontSize: 16, fontFamily: 'Roboto-Bold')),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: launchEulaUrl,
                          child: Text(AppLocalizations.of(context)!.eula),
                        ),
                        SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: launchPrivacyUrl,
                          child: Text(AppLocalizations.of(context)!.privacy_policy),
                        ),
                      ],
                    )
                ),
              ),
              // arithmetic number of n which will be multiplied by a (weeks chosen) for count
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async{
                await _auth.deleteUser();
                Navigator.pop(context);
                },
              child:Text(AppLocalizations.of(context)!.reject),
            ),
            TextButton(
              onPressed: ()async {
                globals.bnbIndex = 1;
                await onBoarding.onBoardingAlert(context); 
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/wrapper', (Route<dynamic> route) => false);
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      }
    );
  }

  Future<void> launchEulaUrl() async {
    if (!await launchUrl(eulaUrl)) {
      throw 'Could not launch $eulaUrl';
    }
  }

  Future<void> launchPrivacyUrl() async {
    if (!await launchUrl(privacyUrl)) {
      throw 'Could not launch $privacyUrl';
    }
  }


}


// non binding user Agreement: No accept or decline (used for display)
class UserAgreementDisplay {

  final Uri eulaUrl = Uri.parse('https://sites.google.com/view/calback-eula/home');
  final Uri privacyUrl = Uri.parse('https://sites.google.com/view/calback/home');
  static bool isVisible = false;

  Future UserLicenseAlert(context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder:(BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.eula),
            content: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                      onPressed: () {
                        isVisible = !isVisible;
                      },
                      style: TextButton.styleFrom(
                          primary: uiSettingColor.minimal_1,
                          textStyle: const TextStyle(
                              fontSize: 16, fontFamily: 'Roboto-Bold')),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60,
                            width: 300,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black,
                              ),
                              onPressed: launchEulaUrl,
                              child: Text(AppLocalizations.of(context)!.eula),
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 60,
                            width: 300,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black,
                              ),
                              onPressed: launchPrivacyUrl,
                              child: Text(AppLocalizations.of(context)!.privacy_policy),
                            ),
                          ),
                        ],
                      )
                  ),
                ),
                // arithmetic number of n which will be multiplied by a (weeks chosen) for count
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          );
        }
    );
  }

  Future<void> launchEulaUrl() async {
    if (!await launchUrl(eulaUrl)) {
      throw 'Could not launch $eulaUrl';
    }
  }

  Future<void> launchPrivacyUrl() async {
    if (!await launchUrl(privacyUrl)) {
      throw 'Could not launch $privacyUrl';
    }
  }


}



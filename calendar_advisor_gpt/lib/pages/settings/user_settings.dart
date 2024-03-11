import 'dart:io';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/services/auth.dart';
import 'package:calendar/services/database.dart';
import 'package:flutter/material.dart';
import '../authenticate/user_agreement.dart';
import 'account_settings.dart';
import 'friends_settings.dart';
import 'language_settings.dart';
import 'package:calendar/shared/globals.dart' as globals;

class SettingsForm extends StatefulWidget {
  const SettingsForm({ Key? key }) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {


  final ImagePicker _picker = ImagePicker();
  final UserAgreementDisplay userAgreementDisplay = UserAgreementDisplay();
  final _formKey = GlobalKey<FormState>(); //needed to use form as database


  @override
  Widget build(BuildContext context) {

    final user = Provider.of<MyUser?>(context);
    final AuthService _auth = AuthService();
    final eventProvider = Provider.of<EventMaker>(context);
    
    return StreamBuilder<MyUser>(
      stream: DatabaseService(uid: user!.uid).userData,
      builder: (context, snapshot) { //snapshot of above stream
      print(snapshot.error);
        if(snapshot.hasData){
            MyUser? myUserData = snapshot.data;            
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                iconTheme: IconThemeData(
                      color: Colors.black
                    ),
                bottomOpacity: 0,
                elevation: 0,
                toolbarHeight: 60,
                backgroundColor: Colors.white70,
                title: Text(AppLocalizations.of(context)!.settings,
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.black, fontFamily: 'Roboto', fontWeight: FontWeight.bold
                    )
                ),
                centerTitle: false,
              ),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget> [
                        SizedBox(height: 20),
                        ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(2),
                          children:<Widget> [
                            ListTile(
                              leading: Icon(Icons.account_circle_outlined),
                              title: Text(AppLocalizations.of(context)!.account),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onTap:() {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettings()));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.people),
                              title: Text(AppLocalizations.of(context)!.friends),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onTap:(){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => FriendSettings()));
                              },
                            ),
                            // ListTile(
                            //   leading: Icon(Icons.info_outline),
                            //   title: Text(AppLocalizations.of(context)!.help),
                            //   trailing: Icon(Icons.keyboard_arrow_right),
                            //   onTap:(){
                            //     print('Help');
                            //   },
                            // ),
                            ListTile(
                              leading: Icon(Icons.language_outlined),
                              title: Text(AppLocalizations.of(context)!.languages),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onTap:(){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSettings()));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.help_outline),
                              title: Text(AppLocalizations.of(context)!.terms),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onTap:(){
                                userAgreementDisplay.UserLicenseAlert(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.exit_to_app),
                              title: Text(AppLocalizations.of(context)!.logout,),
                              onTap:() async {
                                globals.bnbIndex = 0;
                                eventProvider.resetEvent();
                                await _auth.signOut();
                              } ,
                            ),

                          ],
                        ),
                    ],
                  ),
                  ),
                ),
              ),
            );
        }
        else{
          print(user.uid);
          print(user.name);
          print(user.email);
          print(user.flag);
          print(user.reqSent);
          print(user.reqReceived);
          return Loading();
        }
      });
    
  }

}


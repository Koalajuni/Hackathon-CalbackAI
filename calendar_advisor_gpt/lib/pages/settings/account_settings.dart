import 'package:calendar/services/notification_services/push_notification.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/services/auth.dart';
import 'package:calendar/shared/globals.dart' as globals;
import 'dart:io';
import 'package:calendar/models/user.dart';
import 'package:calendar/services/database.dart';
import '../../shared/constants.dart';
import '../authenticate/user_agreement.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({ Key? key }) : super(key: key);

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {

  final ImagePicker _picker = ImagePicker();
  final UserAgreement userAgreement = UserAgreement();
  final _formKey = GlobalKey<FormState>();//needed to use form as database
  File? _photo;  // do not remove.
  String? _currentName;
  bool isLoadingPhoto = false;
  ColorSetting colorSetting = ColorSetting();

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final user = Provider.of<MyUser?>(context);
    final eventProvider = Provider.of<EventMaker>(context);

    if (user != null) {
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
                    backgroundColor: Colors.white70,
                    elevation: 0,
                    title: Text(AppLocalizations.of(context)!.account,
                        style:TextStyle(
                          color: Colors.black,
                        )),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            if(_formKey.currentState!.validate()) {   //removed formkey meantime as it sent errors
                              await DatabaseService(uid: myUserData!.uid).setUserData(
                                  _currentName ?? myUserData.name, myUserData.email, myUserData.flag, myUserData.friends, 
                                  myUserData.reqReceived, myUserData.reqSent, myUserData.photoUrl, 
                                  myUserData.blockedUsers, myUserData.token, myUserData.openPrivacy);
                              showDialog(
                                context: context,
                                builder:(context) =>  AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.updated),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: Text(AppLocalizations.of(context)!.ok),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          // setState(() {});
                                        },
                                      ),
                                    ]
                                ),
                              );
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.ok,
                            style: TextStyle(color: uiSettingColor.minimal_1, fontSize: 16),
                          )
                      ),
                    ],
                  ),
                  body: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                            children: <Widget> [
                              StatefulBuilder(
                                builder: (context, setPhoto) {
                                  return InkWell(
                                    onTap: () async {
                                      final pickedFile = await _picker.pickImage(
                                          source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        _photo = File(pickedFile.path);
                                        final path = pickedFile.path;
                                        String fileName = 'profile';
                                        setPhoto((){
                                          isLoadingPhoto = true;
                                        });
                                        await Storage(uid: user.uid)
                                            .uploadFile(path, fileName).then((value) => print('done'));
                                        await DatabaseService(uid: user.uid).loadImage(fileName);
                                        setPhoto((){
                                          isLoadingPhoto = false;
                                        });
                                      }
                                      else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('No file selected'),
                                          ),
                                        );
                                        }
                                      },
                                    child: ClipOval(
                                      child: isLoadingPhoto 
                                      ? CircleAvatar(
                                          radius: 80,
                                          backgroundColor: colorSetting.minimal_2,
                                          child: CircularProgressIndicator(
                                            color: colorSetting.hm_1,
                                          )
                                        ) 
                                      : CircleAvatar(
                                          backgroundColor: Colors.black12,
                                          radius: 80.0,
                                          backgroundImage: myUserData!.photoUrl != '' ? CachedNetworkImageProvider(myUserData!.photoUrl) : null,
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 60),
                                                  CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: Colors.white70,
                                                    child: Icon(Icons.camera_alt_outlined, color: uiSettingColor.minimal_1)
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),),
                                  );
                                }
                              ),
                              SizedBox(height: 20),
                              Divider(),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppLocalizations.of(context)!.accountSettings_name,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                decoration: textInputDecoration.copyWith(hintText: "Name"),
                                initialValue: myUserData!.name,
                                validator: (val) {
                                  if(val!.isEmpty){
                                    return "Enter ID";
                                  }
                                  else if(val.length > 13){
                                    return "12 characters Max";
                                  }
                                  _currentName = val;
                                },
                                onSaved: (val) => setState(() {
                                  _currentName = val;
                                }),
                              ),
                              SizedBox(height: 50),
                              ListView(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(2),
                                children:<Widget> [
                                  ListTile(
                                    leading: Icon(Icons.exit_to_app),
                                    title: Text(AppLocalizations.of(context)!.logout),
                                    trailing: Icon(Icons.keyboard_arrow_right),
                                    onTap:() async {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            height: 100,
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.symmetric(
                                              horizontal:20,
                                              vertical: 20,
                                            ),
                                            child: Column(
                                              children:<Widget> [
                                                Text(
                                                  AppLocalizations.of(context)!.logout,
                                                  style: uiSettingFont.head_5,
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                ElevatedButton.icon(
                                                    icon: Icon(Icons.close),
                                                    label: Text(AppLocalizations.of(context)!.logout),
                                                    style: ElevatedButton.styleFrom(
                                                      primary: Colors.black,
                                                    ),
                                                    onPressed: () async {
                                                      globals.bnbIndex = 0;
                                                      eventProvider.resetEvent();
                                                      // Navigator.of(context).pop();
                                                      // Navigator.of(context).pop();
                                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                                        '/wrapper', (Route<dynamic> route) => false);
                                                      await _auth.signOut();
                                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
                                                    }
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.people),
                                    title: Text(AppLocalizations.of(context)!.delete_account),
                                    trailing: Icon(Icons.keyboard_arrow_right),
                                    onTap:(){
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            height: 100,
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.symmetric(
                                              horizontal:20,
                                              vertical: 20,
                                            ),
                                            child: Column(
                                              children:<Widget> [
                                                Text(
                                                  AppLocalizations.of(context)!.delete_account,
                                                  style: uiSettingFont.head_5,
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                ElevatedButton.icon(
                                                    icon: Icon(Icons.close),
                                                    label: Text(AppLocalizations.of(context)!.delete_account),
                                                    style: ElevatedButton.styleFrom(
                                                      primary: Colors.black,
                                                    ),
                                                    onPressed: () async {
                                                      await _auth.deleteUser();
                                                        Navigator.of(context).pushNamedAndRemoveUntil(
                                                        '/wrapper', (Route<dynamic> route) => false);
                                                    }
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
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
        return Loading();
      }
      });
    } else {
      return Container();
    }

  }

}
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../../models/user.dart';
import '../../services/database.dart';
import '../../services_kakao/kakao_link_with_dynamic_link.dart';
import '../all_pages.dart';
import 'friend_search.dart';


  addFriendButton(context) {
    final user = Provider.of<MyUser>(context, listen: false);
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return SimpleDialog(
              title: Text(AppLocalizations.of(context)!.opening_addFriend, style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
              contentPadding: EdgeInsets.only(left: 20),
              children: <Widget> [
                SizedBox(height: 30),
                Row(
                  children: [
                    Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage('assets/icons/app_icon.png'),
                            fit: BoxFit.fill,
                          ),
                        )
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(46, 46, 46, 1),
                        fixedSize: Size(170, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)
                        ),
                      ),
                      //style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 25)),
                      child: Text(AppLocalizations.of(context)!.opening_calbackSearch, style: TextStyle(color:Colors.white,fontSize: 16),),
                      onPressed: () { Navigator.push(context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => StreamProvider(
                              create: (context) => DatabaseService(uid: user.uid).userData,
                              initialData: MyUser(uid:user.uid),
                              builder: (context, child) => FriendSearch(),
                            ),
                          )
                      );
                      },
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/icons/kakao_logo.png'),
                            fit: BoxFit.fitHeight,
                          ),
                        )
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(251, 226, 0, 1),
                        fixedSize: Size(170, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)
                        ),
                      ),
                      //style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 25)),
                      child: Text(AppLocalizations.of(context)!.opening_kakaoFriend, style: TextStyle(color:Colors.black,fontSize: 16)),
                      onPressed: ()  async {
                        try {
                          String link = await KakaoLinkWithDynamicLink()
                              .buildDynamicLinkFriend(user.uid);

                          print("whats my link ${link}");
                          KakaoLinkWithDynamicLink()
                              .isKakaotalkInstalled()
                              .then((installed){
                            if(installed){

                              print("//////link ${link}");
                              KakaoLinkWithDynamicLink()
                                  .shareMyCodeFriend(user, link);
                            } else {
                              ShareClient.instance.shareScrap(url: link);
                            }
                          });
                        } catch (e) {
                          print("Error adding friend request through Kakao:: $e");
                        }
                      },
                    )
                  ],
                ),
                SizedBox(height: 30)
              ]
          );
        }
    );
  }



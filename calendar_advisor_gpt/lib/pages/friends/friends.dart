import 'package:badges/badges.dart';
import 'package:calendar/pages/notifications/notifications_main.dart';
import 'package:calendar/pages/group/group_time_final.dart';
import 'package:calendar/pages/group/group_create.dart';
import 'package:flutter/material.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/pages/friends/friend_search.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/friends/person_tile.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../../services_kakao/kakao_link_with_dynamic_link.dart';
import '../homepage/drawer_builder.dart';
import 'package:calendar/pages/friends/view/profile_view.dart';

import 'view_model/profile_parser.dart';

// Click on profile picture for weekly schedule
// Click on calendar button for monthly (separate button to change to weekly mode)
// monthly.dart friends bar is going to be a mini-version of profile picture

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    int friendCount = 0;
    user.friends.forEach((friend){
      if (friend.substring(0,5) != 'open:'){    // i realized this is the same as parser in profile_view
        friendCount += 1;
      }
    });
    int friendNum = friendCount;
    return ChangeNotifierProvider<ProfileParser>(
      create: ((context) => ProfileParser()),
      child: Consumer<ProfileParser>(
        builder: (context, profileParser, child) {
          profileParser.populateProfiles(user.friends);
          return Scaffold(
            backgroundColor: Color(0xffF6F6F6),
            appBar: AppBar(      
              toolbarHeight: 64.h,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                color: user.uid.substring(0,5) != "open:" ? Color(0xff5562FE) : Colors.black,
                size: 24.h,
              ),
              title: user.uid.substring(0,5) != "open:" ? 
                      Text("CalBack",
                        style: TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: uiSettingColor.minimal_1,
                        ),
                      ):Text("CalBack Biz",
                        style: TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black
                        ),
                      ),
              centerTitle: false,
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: Color(0xffF6F6F6), 
                    height: 90.h,
                    width: MediaQuery.of(context)!.size.width,
                    child: InkWell(
                      onTap: (){
                        addFriendButton(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                                  width: 320.w,
                                  height: 50.h,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12,0,0,0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                              child: Container(
                                                height: 32.h,
                                                width: 32.w,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(6.0),
                                                  child: Container(
                                                    child: Image.asset('assets/icons/add_friend.png', fit:BoxFit.contain)),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xff5E5CEC),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width:16.w),
                                            Text(AppLocalizations.of(context)!.friend_statementUnder, 
                                            style: TextStyle(fontFamily: 'Spoqa', fontSize: 16.sp, fontWeight: FontWeight.w700,color: Color(0xff5562FE)
                        ),),
                                      ],
                                    ),
                                  ), 
                                  decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8)
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xff5562FE),
                                      blurRadius:5,
                                      offset: Offset(0,2), // changes position of shadow
                                    ),
                                  ],
                                  ),
                                ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height:10.h),
                  SizedBox(
                    width: 320.w,
                    height: friendNum > 5 ? 569.h + ((friendNum - 5) * 82) : 569.h,    // 기본 사이즈 569 + 80 height for every added friend (if friend is more than 5) 
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                            )
                          ]
                      ),
                      child: ProfileView(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      )
    );
  }
}

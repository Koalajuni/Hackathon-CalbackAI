import 'package:calendar/local_data/shared_preferences/shared_preferences_functions.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/homepage/drawer_builder.dart';
import 'package:calendar/pages/homepage/home_agenda_widget.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/shared/calendar_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/meeting.dart';
import '../../models/user.dart';
import 'package:intl/intl.dart';
import '../../services/database.dart';
import 'package:simple_shadow/simple_shadow.dart';
import '../../custom_widgets/agenda_widget.dart';
import 'group_story.dart';


class Opening extends StatefulWidget {
  const Opening({Key? key}) : super(key: key);

  @override
  _OpeningState createState() => _OpeningState();
}



class _OpeningState extends State<Opening> {

  ColorSetting colorSetting = ColorSetting();
  late Map<String, dynamic> notificationStates;
  late String uid;

  Future refresh() async {
    setState(() {
      notificationStates.clear();
      print('HOMEPAGE REFRESH STATE DONE');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    final eventProvider = Provider.of<EventMaker>(context);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    
    uid = user.uid;
    // List<String> subscribedGroups; for when subscribed instead of all
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xffF6F6F6),
        endDrawer: DrawerBuilder(),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start, 
              crossAxisAlignment: CrossAxisAlignment.start,      
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 19, 20, 0),
                    height: 56.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                        ],
                      ),
                      color: colorSetting.hm_1,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 28.h,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              user.uid.substring(0,5) != "open:" ? 
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  FutureBuilder(
                    future: SharedPreferencesFunctions().checkNotifications(user.uid),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Container(height: 128.h,);
                        default:
                          if (snapshot.hasData) {
                            notificationStates = snapshot.data as Map<String, dynamic>;
                            return GroupStory(notificationStates: notificationStates, callback: refresh);
                          }

                          else {
                            return Container(height: 120.h,);
                          }
                      }
                    }
                  ),
                  
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        HomeAgenda(user: user, meetingData: eventProvider.events, currentDate: dateOnly(DateTime.now()), maxLength: 180,)
                      ],
                    )
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 28.w),
                    child: Container(
                      height: 53.h,
                      color: Color(0xFFF5F7F9),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '피드 탐색',
                            style: TextStyle(
                              color: Color(0xFF303030),
                              fontSize: 16.sp,
                              fontFamily: 'Pretendard Variable',
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      width: ScreenUtil().screenWidth,
                      color: Color(0xFFFFFFFF),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                SizedBox(height: 35,),
                                Image.asset('assets/icons/smile.png', width: 24, height: 24,), 
                                SizedBox(height: 6,),
                                Text('피드 페이지 준비중',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard', 
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff565778)
                                  ) 
                                ),
                                SizedBox(height: 4,),
                                Text('그룹 콘텐츠는 조만간 확인하실 수 있을꺼에요!',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff565778)
                                  ) 
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      );
  }
}

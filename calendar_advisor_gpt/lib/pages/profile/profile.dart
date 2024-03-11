import 'package:calendar/custom_widgets/agenda_widget.dart';
import 'package:calendar/models/meeting.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/friends/friend_calendar.dart';
import 'package:calendar/pages/monthly/monthly_custom_cell.dart';
import 'package:calendar/pages/profile/profile_tile.dart';
import 'package:calendar/pages/profile/state_manager/date_controller.dart';
import 'package:calendar/pages/profile/view/profile_month_calendar.dart';
import 'package:calendar/pages/profile/view/profile_week_calendar.dart';
import 'package:calendar/shared/calendar_functions.dart';
import 'package:flutter/material.dart';
import 'package:calendar/services/auth.dart';
import 'package:calendar/services/database.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../friends/person_tile.dart';
import 'view/follow_button.dart';
import 'view/privacy_checkbox.dart';

//User Builder

class MyProfile extends StatefulWidget{
  const MyProfile({Key? key, required this.user}) : super(key: key);
  final MyUser? user;

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  void dispose() {
    Get.delete<DateController>();
    super.dispose();
  }
  late bool isOpenPrivacy;
  final PageController pageController = PageController(initialPage: 0);
  final uiSettingFont = FontSetting();
  final double coverHeight = 100;
  final double profileHeight = 100;
  final DateController dateController = Get.put(DateController());
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    isOpenPrivacy = widget.user!.openPrivacy;
  }

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight/2;
    final bottom = profileHeight/2;
    final otherUser = widget.user ?? MyUser(uid: 'profile.dart');
    final myUser = Provider.of<MyUser>(context);
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xffF6F6F6),
          appBar: AppBar(
            bottomOpacity: 0,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black,
              size: 30,
            ),
            backgroundColor: Colors.white,
            toolbarHeight: 50,
            automaticallyImplyLeading: false,
            title: Row( //TODO
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BackButton()),
                  SizedBox(width: 78.w),
                Text('${otherUser.name}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'Spoqa',
                    fontWeight: FontWeight.w500)
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: StreamBuilder<List<Meeting>>(
            stream: DatabaseService(uid: otherUser.uid).meetingsData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Meeting> meetingData = snapshot.data as List<Meeting>;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    otherUser.uid.substring(0,5) == 'open:' 
                      ? openProfileTile(otherUser)
                      : closedProfileTile(otherUser),
                      SizedBox(height: 12,),
                      GetBuilder<DateController>(
                        builder: (dateController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Color(0xffDAD9FE),
                              borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            width: double.infinity,
                            height: 56,
                            margin: EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Text("${dateController.headerDate.value.year}년 ${dateController.headerDate.value.month}월",
                                      style: TextStyle(
                                        fontFamily: 'Spoqa',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Color(0xff222222)
                                      ),
                                    ),
                                  ),

                                  otherUser.uid.substring(0,5) != 'open:' 
                                  ? currentPage == 0  
                                    ? Padding(
                                        padding: const EdgeInsets.only(right: 16.0),
                                        child: InkWell(
                                          onTap: (){
                                            setState(() {
                                              currentPage = 1;
                                            });
                                            pageController.jumpToPage(1);
                                          },
                                          child: Image.asset('assets/icons/to_weekly.png', width: 24, height: 24,),
                                          
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(right: 16.0),
                                        child: InkWell(
                                          onTap: (){
                                            setState(() {
                                              currentPage = 0;
                                            });
                                            pageController.jumpToPage(0);
                                          },
                                          child: Image.asset('assets/icons/to_monthly.png', width: 24, height: 24,),
                                        ),
                                      )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      myUser.uid == otherUser.uid  
                                        ? Padding(
                                          padding: EdgeInsets.only(right: 16.0.w),
                                          child: PrivacyCheckbox(myUser: myUser, groupUser: otherUser)
                                        )

                                        : Padding(
                                          padding: EdgeInsets.only(right: 16.w),
                                          child: FollowButton(myUser: myUser, groupUser: otherUser),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                          );
                        }
                      ),
                      SizedBox(height: 10,),
                      Flexible(
                        child: Container(
                          height: MediaQuery.of(context).size.height -50 -90 -78 - 30, // appbar, photo, 2023년 n 월, bottom padding
                          child: PageView(
                            controller: pageController,
                            children: [
                              ProfileMonthCalendar(myUser: myUser, otherUser: otherUser, dateController: dateController, meetingData: meetingData),
                              // ProfileWeekCalendar(myUser: myUser, otherUser: otherUser, dateController: dateController, meetingData: meetingData),
                            ],
                          ),
                        ),
                      ),
                  ],
          
                );
              }else {
                  return Container(
                    height: MediaQuery.of(context).size.height -50,
                    child: Center(
                      child: CircularProgressIndicator()
                    ),
                  );
                }
            }
          ),
        ),
      ),
    );
  }

  buildCoverImage() => Container(
    color: uiSettingColor.minimal_2, //todo
    width: double.infinity,
    height: coverHeight,
    //child: Image.asset('assets/images/profile.png'), //todo 없는게 더 이쁘다
  );
}


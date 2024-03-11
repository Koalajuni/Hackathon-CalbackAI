import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/homepage/drawer_builder.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/shared/calendar_functions.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'package:intl/intl.dart';
import '../../services/database.dart';
import '../../custom_widgets/agenda_widget.dart';


class Opening extends StatefulWidget {
  const Opening({Key? key}) : super(key: key);

  @override
  _OpeningState createState() => _OpeningState();
}

class _OpeningState extends State<Opening> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    final eventProvider = Provider.of<EventMaker>(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 245, 255, 1),
      appBar: AppBar(
        bottomOpacity: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 40,
            width: 150.w,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/logo_name_whiteBG.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      endDrawer: DrawerBuilder(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.opening_statement,
                          style: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text(
                          AppLocalizations.of(context)!.opening_statement_under,
                          style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                  SizedBox(width: 14),
                  Container(
                    height: 44,
                    width: 44.w,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/logo_icon_whiteBG.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150.w,
                  height: 150,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        primary: Colors.white,
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          CustomPageRoute(
                            child: StreamProvider<MyUser>(
                              create: (context) => DatabaseService(uid: user.uid).userData,
                              initialData: MyUser(uid: user.uid),
                              builder: (context, child) => Daily(),
                            ),
                            direction: AxisDirection.right,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 14),
                              SizedBox(
                                width: 79.w,
                                child: Text(
                                  AppLocalizations.of(context)!.opening_addEvents,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 8),
                              SizedBox(
                                width: 79.w,
                                child: Text(
                                  AppLocalizations.of(context)!.opening_addEvents_under,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  )
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50.w,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/icons/opening_icon_time.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  width: 150.w,
                  height: 150,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        primary: Colors.white,
                      ),
                      onPressed: () async {
                        await Navigator.push(context,
                          CustomPageRoute(
                            child: StreamProvider(
                              create: (context) => DatabaseService(uid: user.uid).userData,
                              initialData: MyUser(uid: user.uid),
                              builder: (context, child) => GroupTime(),
                            ),
                            direction: AxisDirection.up,
                          )
                        );
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 14),
                              SizedBox(
                                width: 79.w,
                                child: Text(
                                  AppLocalizations.of(context)!.opening_availableTime,
                                  style: TextStyle(
                                    color: uiSettingColor.minimal_1,
                                    fontSize: 18.sp,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 8),
                              SizedBox(
                                width: 79.w,
                                child: Text(
                                    AppLocalizations.of(context)!.opening_availableTime_under,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    )
                                  ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60.w,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/icons/opening_icon_group.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      )),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 325.w,
              height: 160,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    addFriendButton(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.opening_friendProfile,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8.w),
                          Text("${user.friends.length}",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              )),
                          Spacer(),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.add, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 6),
                      SizedBox(
                        width: 300.w,
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: user.friends.length,
                          itemBuilder: (BuildContext context, int index) {
                            return MyFriendView(
                                UID: user.friends[index]);
                          },
                        ),
                      ),
                    ],
                  )),
            ),
            SizedBox(height: 20),
            Container(
              width: 325.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                    )
                  ]),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 14.w),
                      Text(
                        AppLocalizations.of(context)!.opening_todayList,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.sp,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Agenda(user: user, meetingData: eventProvider.events, currentDate: dateOnly(DateTime.now()), maxLength: 180,)
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}
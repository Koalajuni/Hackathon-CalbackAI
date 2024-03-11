
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/chatgpt_stuff/backend/chat_api.dart';
import 'package:calendar/pages/group/group_pending_list.dart';
import 'package:calendar/pages/group/group_create.dart';
import 'package:calendar/pages/group/choose_preference_week.dart';
import 'package:calendar/services/notification_services/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import '../models/meeting.dart';
import '../models/userSchedule.dart';
import '../services/database.dart';
import 'package:intl/intl.dart';
import 'chatgpt_model/frontend/chat_home_page.dart';
import 'chatgpt_model/frontend/gpt_daily.dart';
import 'group/group_time_final.dart';


class EventButton extends StatelessWidget  {
  const EventButton({Key? key}) : super(key: key);
  
  Future<List<String>> meetingsToText(List<Meeting> meetings) async {
  final meetingSchedule = meetings.map((meeting) =>
      [  
        '${((meeting.from).toString()).substring(0,16)}',
        '${((meeting.to).toString()).substring(0,16)}',
        meeting.content]).toList();
  
  final List<String> meetingText = [];
  for (final meeting in meetingSchedule) {
    final String text = meeting.join(", ");
    meetingText.add(text);
  }
  
  print("These are all the meeting texts: $meetingText");
  return meetingText;
}
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    final isDialOpen = ValueNotifier(false);
    print("global button ${user.name}");
    return 
  //   SpeedDial(
  //         animatedIcon: AnimatedIcons.add_event,
  //         animatedIconTheme: IconThemeData(
  //           color: Colors.white,
  //         ),
  //         backgroundColor: uiSettingColor.minimal_1,
  //         spaceBetweenChildren: 12,
  //         closeManually: false,
  //         openCloseDial: isDialOpen,
  //         buttonSize: Size(70,70),
  //         childrenButtonSize: Size(60,60),
  //         children: [
  //           // SpeedDialChild(
  //           //   child: Icon(Icons.groups_rounded, color: Colors.white),
  //           //   foregroundColor: Colors.black,
  //           //   backgroundColor: uiSettingColor.minimal_4,
  //           //   label: 'Group Search',
  //           //   onTap: () async {
  //           //     // await  Navigator.push(context,
  //           //     //     CustomPageRoute(
  //           //     //         child: StreamProvider(
  //           //     //         create: (context) => DatabaseService(uid: user.uid).userData,
  //           //     //         initialData: MyUser(uid:user.uid),
  //           //     //         builder: (context, child) => GroupMeetings(),
  //           //     //       ),
  //           //     //       direction: AxisDirection.up,
  //           //     //     )
  //           //     // );
  //           //   },
  //           // ), //todo activate later when we know users are adding all the events in the calendar
  //           // SpeedDialChild(
  //           //   child: Icon(Icons.more_time),
  //           //   foregroundColor: Colors.white,
  //           //   backgroundColor: uiSettingColor.minimal_4,
  //           //   label: AppLocalizations.of(context)!.opening_addEvents,
  //           //   onTap: () async {
  //           //     await  Navigator.of(context).push(
  //           //       CustomPageRoute(
  //           //         child: StreamProvider<MyUser>(
  //           //           create: (context) => DatabaseService(uid: user.uid).userData,
  //           //           initialData: MyUser(uid: user.uid),
  //           //           builder: (context, child) => Daily(),
  //           //         ),
  //           //         direction: AxisDirection.right,
  //           //       ),
  //           //     );
  //           //   },
  //           // ),
  //           // SpeedDialChild(
  //           //   child: Icon(Icons.table_chart_outlined, color: Colors.white),
  //           //   foregroundColor: Color.fromARGB(255, 105, 78, 78),
  //           //   backgroundColor: uiSettingColor.minimal_5,
  //           //   label:"GPT 추천",
  //           //   onTap: () async  {
  //           //   final myMeetings = await DatabaseService(uid: user.uid).getMeetings();
  //           //    final meetingSchedule = await meetingsToText(myMeetings);
  //           //    print(meetingSchedule);
  //           //    final userSchedule = UserSchedule(profileUid: user.uid, schedule: meetingSchedule);
  //           //    DatabaseService(uid: user.uid).addUserSchedule(userSchedule);

  //           //   Navigator.push(context,
  //           //     CustomPageRoute(
  //           //       child: StreamProvider(
  //           //         create: (context) => DatabaseService(uid: user.uid).userData,
  //           //         initialData: MyUser(uid:user.uid),
  //           //         builder: (context, child) =>  GPTDaily(),
  //           //       ),
  //           //       direction: AxisDirection.up,
  //           //     )
  //           // );
  //           //   },
  //           // ),
  //           // SpeedDialChild(
  //           //   child: Icon(Icons.calendar_view_day, color: Colors.white),
  //           //   foregroundColor: Colors.black,
  //           //   backgroundColor: uiSettingColor.minimal_1,
  //           //   label: AppLocalizations.of(context)!.pending,
  //           //   onTap: () async {
  //           //     await  Navigator.push(context,
  //           //         CustomPageRoute(
  //           //           child: StreamProvider(
  //           //             create: (context) => DatabaseService(uid: user.uid).userData,
  //           //             initialData: MyUser(uid:user.uid),
  //           //             builder: (context, child) => GroupPending(),
  //           //           ),
  //           //           direction: AxisDirection.up,
  //           //         )
  //           //     );
  //           //   },
  //           // ),
  //         ],
  //       );
  // //
  FloatingActionButton(onPressed: () async  {
              final myMeetings = await DatabaseService(uid: user.uid).getMeetings();
               final meetingSchedule = await meetingsToText(myMeetings);
               print(meetingSchedule);
               final userSchedule = UserSchedule(profileUid: user.uid, schedule: meetingSchedule);
               DatabaseService(uid: user.uid).addUserSchedule(userSchedule);

              Navigator.push(context,
                CustomPageRoute(
                  child: StreamProvider(
                    create: (context) => DatabaseService(uid: user.uid).userData,
                    initialData: MyUser(uid:user.uid),
                    builder: (context, child) =>  GPTDaily(),
                  ),
                  direction: AxisDirection.up,
                )
            );
              },
  backgroundColor: uiSettingColor.minimal_1,
  child: Icon(Icons.add, size: 30.0) ,
  );
  }
}

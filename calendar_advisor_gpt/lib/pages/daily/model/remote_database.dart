import 'package:calendar/main.dart';
import 'package:calendar/pages/events/event_maker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import '../../../models/meeting.dart';
import '../../../services/database.dart';
import '../../../services_kakao/kakao_link_with_dynamic_link.dart';
import '../../../shared/calendar_functions.dart';
import '../../all_pages.dart';
import '../view_model/recurrent_events.dart';
import '../view_model/time_builder.dart';
import 'package:calendar/shared/globals.dart' as globals;

Future<dynamic> combineDateTime(
    List<DateTime> selectedDates, List<int> timeAngles) async {
  late DateTime startDate;
  late DateTime endDate;
  startDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(selectedDates[0]) +
      ' ' +
      TimeSetter().formatTime(timeAngles[0]));
  endDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(selectedDates[1]) +
      ' ' +
      TimeSetter().formatTime(timeAngles[1]));
  return [startDate, endDate];
}

Future saveForm(
    Meeting? meetingData,
    String meetingContent,
    String uid,
    Color pickerColor,
    List<String> addedFriends,
    bool isEdit,
    List<DateTime> selectedDates,
    List<int> timeAngles,
    String rRule,
    String ownerName, 
    List<String> tokens,
    ) async {

  List<DateTime> dateTimeData =
      await combineDateTime(selectedDates, timeAngles);
  String mid = '';
  List<String> og_involved = [];
  List<String> og_pendingInvolved = [];
  List<String> new_pendingInvolved = [];
  List<String> new_friends = new List<String>.from(addedFriends);
  List<String> new_friendsPending = new List<String>.from(addedFriends);
  if (isEdit && meetingData != null) {
    List<String> og_to_remove = [];
    mid = meetingData.MID;
    og_involved = meetingData.involved;
    og_pendingInvolved = meetingData.pendingInvolved;
    
    new_friendsPending.removeWhere( (item) => og_pendingInvolved.contains(item));
    // print('newly added friends that werent there before: ${new_friends}');

    new_pendingInvolved = meetingData.pendingInvolved + new_friendsPending; 
    new_pendingInvolved.removeWhere((item) => og_involved.contains(item));


    og_involved.forEach((friend) {
      if (new_friends.contains(friend)) {
        new_friends.remove(friend);
      } else {
        og_to_remove.add(friend);
      }
    });
    og_to_remove.forEach((delFriend) {
      og_involved.remove(delFriend);
    });
  } else {
    mid = "${DateTime.now().toString().replaceAll(" ", "")}${uid}";
  }

  bool allDay = false;
  if (dateOnly(dateTimeData[0]) != dateOnly(dateTimeData[1])) {
    allDay = true;
  }

  final meeting = Meeting(
    owner: uid,
    MID: mid,
    content: meetingContent,
    from: dateTimeData[0],
    to: dateTimeData[1],
    background: pickerColor,
    isAllDay: allDay,
    involved: isEdit ? og_involved : [],
    pendingInvolved: isEdit ? new_pendingInvolved : addedFriends,
    recurrenceRule: rRule,
  );

  // Send requests to all participants to be shared with
  if (isEdit) {
    if (new_friends.isNotEmpty) {
      new_friends.forEach((friend) {
        DatabaseService(uid: uid).sendMeetReq(uid, friend, mid);
        try {
          DatabaseService(uid: uid).addPendingInvolved(friend, mid);
        } catch (e) {
          print("Error implementing pendingInvolved in foreach in daily: $e");
        }
      });
    }
  } else {
    addedFriends.forEach((friend) {
      DatabaseService(uid: uid).sendMeetReq(uid, friend, mid);
    });
  }

  //
  final eventProvider =
      Provider.of<EventMaker>(navigatorKey.currentContext!, listen: false);

  String dateBodyForm = "\n" + (dateTimeData[0].toString().substring(0,16) +"\n" +  dateTimeData[1].toString().substring(0,16)); 
   String notificationBody = meetingContent  + dateBodyForm; 
print("this is the token list : $tokens");
    tokens.forEach((element){
      print("this is the friend token: $element");
      sendPushNotification(element,
     "${ownerName}" , (meetingContent.isEmpty) ? "일정  $dateBodyForm" : notificationBody ); 
    });




  if (isEdit) {
    //EDIT MODE
    eventProvider.editEvent(meeting, meetingData!, uid);
    globals.bnbIndex = 2;
    Navigator.of(navigatorKey.currentContext!)
        .pushNamedAndRemoveUntil('/wrapper', (Route<dynamic> route) => false);
  } else {
    // CREATE NEW MEETING MODE
    eventProvider.addEvent(meeting, uid);
    // TODO: below code allows instance kakao msgs to be sent (up to 8 people at once)
    // List<String> _kakaoFriendUid = [];
    // meeting.involved.forEach((element) {
    //   List<String> friendEmailSplit =
    //       checkbox[element]!.friendEmail.split('@');
    //   if (friendEmailSplit[1] == "kakao.com") {
    //     _kakaoFriendUid.add(friendEmailSplit[0]);
    //   }
    // });

    // if (_kakaoFriendUid.isNotEmpty) {
    //   try {
    //     String link = await KakaoLinkWithDynamicLink()
    //         .buildDynamicLinkMeeting(
    //             uid,
    //             meeting.content,
    //             meeting.from,
    //             meeting.to,
    //             meeting.background,
    //             meeting.isAllDay,
    //             meeting.involved,
    //             meeting.MID);

    //     KakaoLinkWithDynamicLink()
    //         .sendDirectKakaoMsgMeeting(meeting, link, _kakaoFriendUid);

    //     print('카카오톡 공유 완료');
    //   } catch (error) {
    //     print('카카오톡 공유 실패 $error');
    //   }
    // }
    Navigator.of(navigatorKey.currentContext!).pop();
  }
}

Future kakaoShare(
    String meetingContent,
    String uid,
    Color pickerColor,
    List<String> addedFriends,
    List<DateTime> selectedDates,
    List<int> timeAngles,
    String rRule
    ) async {
  List<DateTime> dateTimeData =
      await combineDateTime(selectedDates, timeAngles);

  bool allDay = false;
  if (dateOnly(dateTimeData[0]) != dateOnly(dateTimeData[1])) {
    allDay = true;
  }

  final meeting = Meeting(
    owner: uid,
    MID: "shared${DateTime.now().toString().replaceAll(" ", "")}${uid}",
    content: meetingContent,
    from: dateTimeData[0],
    to: dateTimeData[1],
    background: pickerColor,
    isAllDay: allDay,
    involved: addedFriends,
    pendingInvolved: addedFriends,
    recurrenceRule: rRule,
  );

  try {
    DatabaseService(uid: uid).addMeetings(meeting);
    String link = await KakaoLinkWithDynamicLink().buildDynamicLinkMeeting(
        uid,
        meeting.content,
        meeting.from,
        meeting.to,
        meeting.background,
        meeting.isAllDay,
        meeting.involved,
        meeting.pendingInvolved,
        meeting.MID,
        meeting.recurrenceRule,
      );
// TODO send rRUle
    print("whats my link ${link}");
    KakaoLinkWithDynamicLink().isKakaotalkInstalled().then((installed) {
      if (installed) {
        print("//////link ${link}");
        KakaoLinkWithDynamicLink().shareMyCodeMeeting(meeting, link);
      } else {
        ShareClient.instance.shareScrap(url: link);
      }
    });

    print('카카오톡 공유 완료');
  } catch (error) {
    print('카카오톡 공유 실패 $error');
  }
  globals.bnbIndex = 2;
  Navigator.of(navigatorKey.currentContext!)
      .pushNamedAndRemoveUntil('/wrapper', (Route<dynamic> route) => false);
}

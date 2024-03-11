import 'package:calendar/main.dart';
import 'package:intl/intl.dart';
import 'package:calendar/pages/chatgpt_stuff/chat_dependencies.dart';
import 'package:calendar/shared/globals.dart' as globals;

// outputParsing(String gptOutput) {
//   List<Map<String, dynamic>> scheduleEvents = [];
//   List<Meeting> finalSchedule = [];
//   String editableString = gptOutput;
//   int numOfEvents = 0;

//   final regex = RegExp(r'^\d\. ()$');

//   while() {
//     int indexEntryNumber = editableString.indexOf('.');

//     int indexParenthesisStart = editableString.indexOf('(');
//     int indexParenthesisEnd = editableString.indexOf(',');

//     int indexTimeDash = editableString.indexOf('-');
//     int indexTimeColon = editableString.indexOf(':');

//     Map<String, dynamic> gptOutputParts  = {
//       'monthDate_wordForm' : editableString.substring(indexEntryNumber, indexParenthesisStart).trim(), 
//       'weekday_wordForm': editableString.substring(indexParenthesisStart, indexParenthesisEnd).trim(),
//       'timeStart' : editableString.substring(indexParenthesisEnd + 1, indexTimeDash).trim(),
//       'timeEnd' : editableString.substring(indexTimeDash + 1, indexTimeColon).trim(),
//       'content' : editableString.substring(indexTimeColon + 1),
//     };

//     scheduleEvents[numOfEvents] = gptOutputParts;
//     editableString = editableString.substring()
//     numOfEvents++;
//   }
// }

List<Meeting> outputParsing(String gptOutput, String uid, String ownerName) {
  List<Map<String, dynamic>> scheduleEvents = [];
  int parsingIndex = 0;
  
  List<Meeting> finalSchedule = [];

  // \[(startDate)\s(endDate)\s(content)\]\,
  final regex = RegExp(r'\[?\[([^\,]+),\s*([^\,]+),\s*([^\,]+)\]\]?\,?');
  Iterable<Match> matches = regex.allMatches(gptOutput, 0);

  for (final Match match in matches) {
    Map<String, dynamic> gptOutputParts  = {
      'unformattedString' : match.group(0),
      'timeStart' : match.group(1),
      'timeEnd' : match.group(2),
      'content' : match.group(3),
    };
    scheduleEvents.add(gptOutputParts);

    String mid = "${DateTime.now().toString().replaceAll(" ", "")}${uid}";
    finalSchedule.add(Meeting(
      owner: uid,
      content: scheduleEvents[parsingIndex]['content'],
      from: timeFormat(scheduleEvents[parsingIndex]['timeStart']),
      to: timeFormat(scheduleEvents[parsingIndex]['timeEnd']),
      background: Color(0xff8281FA),
      MID: mid,
    ));

    parsingIndex++;
  }

  return finalSchedule;
}

DateTime timeFormat(String date) {
  DateTime formattedDate = DateTime.parse(date);
  return formattedDate;
}

// saveGPTForm(
//   null, 
//   scheduleEvents[parsingIndex]['content'], 
//   uid,
//   Color(0xff8281FA),
//   [],
//   false,
//   [timeFormat(gptOutputParts['timeStart']), 
//     timeFormat(gptOutputParts['timeEnd'])],
//   '', 
//   ownerName,
// );


Future saveGPTForm(
  Meeting? meetingData,
  String meetingContent,
  String uid,
  Color pickerColor,
  List<String> addedFriends,
  bool isEdit,
  List<DateTime> selectedDates,
  String rRule,
  ) async {

  List<DateTime> dateTimeData = selectedDates;
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

  final eventProvider =
      Provider.of<EventMaker>(navigatorKey.currentContext!, listen: false);

  if (isEdit) {
    //EDIT MODE
    eventProvider.editEvent(meeting, meetingData!, uid);
    globals.bnbIndex = 2;
    Navigator.of(navigatorKey.currentContext!)
        .pushNamedAndRemoveUntil('/wrapper', (Route<dynamic> route) => false);
  } else {
    // CREATE NEW MEETING MODE
    eventProvider.addEvent(meeting, uid);
  }
}



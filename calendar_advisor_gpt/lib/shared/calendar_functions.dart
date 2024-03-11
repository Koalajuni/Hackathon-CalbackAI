import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/meeting.dart';
import '../pages/ui_settings.dart';
import '../services/database.dart';

// Function takes pendingMeetingData and returns a 
// Future Data of all calendar datas that needs to be filtered
Future groupMeetingsFuture (String uid, Map<String, dynamic> pendingMeetData, Meeting meeting) async {
  List<Meeting> meetings = [];
  List<List<Meeting>> wantedTime = [];
  List<String> pendingMeetingInvolved = (new List.from(pendingMeetData.keys));
  bool isCheckedAll = false;
  int flag = 0;
  pendingMeetingInvolved.remove("mid");

  await Future.forEach(pendingMeetingInvolved, (element) async {
    if(pendingMeetData["$element"]['isDone'] == true && pendingMeetData['$element']['individualTime'].isEmpty) {
      final List<Meeting> meetingsInvolvedPersonal = await DatabaseService(uid: element as String).getFilteredContentMeetings();
      meetings.addAll(meetingsInvolvedPersonal);
    } else if (pendingMeetData["$element"]['isDone'] == true && pendingMeetData['$element']['individualTime'].isNotEmpty){
      final List<Meeting> wantedTimeOwned = wantedTimeList2MeetingObject(
        new List<DateTime>.from(pendingMeetData['$element']['individualTime'].map((element)=>dateTimeFilter(element.toDate())).toList()), element as String);
      wantedTime.add(wantedTimeOwned);
      flag ++;
    }
  });
  if (pendingMeetingInvolved.length == flag){
    isCheckedAll = true;
  }

  print("return length: ${meetings.length}");
  return [meetings, wantedTime, isCheckedAll];
}

// Intakes List<DateTime> wantedTime, converts and returns List<Meeting> wantedTime
List<Meeting> wantedTimeList2MeetingObject(List<DateTime> wantedTime, String myUid) {
  List<Meeting> wantedTimeMeetings = [];

  List<DateTime> timesList = wantedTime;
  timesList.sort(((a, b) => a.compareTo(b)));
  for(int i = 0; i < timesList.length - 1; i = i + 2){
    wantedTimeMeetings.add(
      Meeting(owner: myUid, content: '', from: timesList[i], to: timesList[i + 1], background: ColorSetting().minimal_1, MID: 'dummyFromWantedTime', recurrenceRule: "")
    );
  }

  return wantedTimeMeetings;
}

// Intakes all unfiltered calendar datas from pendingMeeting and returns 
// Available Regions as idx 0 and Unavailable Regions as idx 1
List<Object> filterMeetings (List<Meeting> meetings, List<List<Meeting>> wantedTimeList, bool isCheckedAll, startDate, endDate, int doneUsersLength) {
  List<Meeting> filterMeetings = [];
  List<TimeRegion> unavailRegions = <TimeRegion>[];

  // All Pref Meetings Are Checked
  if(isCheckedAll){
    if(doneUsersLength == 1){
      List<Object> calendarData = filterSingleCheckedMeetings(wantedTimeList, startDate, endDate);
      filterMeetings = calendarData[0] as List<Meeting>;
      unavailRegions = calendarData[1] as List<TimeRegion>;
    }
    else{
      List<Object> calendarData = filterCheckedAllMeetings(wantedTimeList, startDate, endDate);
      filterMeetings = calendarData[0] as List<Meeting>;
      unavailRegions = calendarData[1] as List<TimeRegion>;
    }
  } 
  // All Pref Meetings Are Sent Calendars
  else if(wantedTimeList.isEmpty){
    List<Object> calendarData = filterCalendarAllMeetings(meetings, startDate, endDate);
    filterMeetings = calendarData[0] as List<Meeting>;
    unavailRegions = calendarData[1] as List<TimeRegion>;
  }
  // Mixed Cases
  else{
    // Getting available time as Meeting object
    List<Meeting> inversedMeeting = [];
    List<Object> calendarData = filterCalendarAllMeetings(meetings, startDate, endDate);
    inversedMeeting = calendarData[0] as List<Meeting>;

    // Creating totalWantedTime Including CalendarData
    List<List<Meeting>> totalWantedTime = wantedTimeList;
    totalWantedTime.add(inversedMeeting);
    
    List<Object> checkedAllCalData = filterCheckedAllMeetings(totalWantedTime, startDate, endDate);
    filterMeetings = checkedAllCalData[0] as List<Meeting>;
    unavailRegions = checkedAllCalData[1] as List<TimeRegion>;
  }
  
  return [filterMeetings, unavailRegions];

}
List<Object> filterSingleCheckedMeetings(List<List<Meeting>> wantedTimeList, startDate, endDate){
  List<Meeting> filterMeetings = [];
  List<TimeRegion> unavailRegions = <TimeRegion>[];

  DateTime currentDateTime = startDate;
  DateTime currentDate = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day);
  int period = (endDate.difference(startDate).inHours / 24).round();

  for (int i = 0; i < wantedTimeList[0].length; i ++) {
    filterMeetings.add(
       Meeting(owner: '', content: '', from: wantedTimeList[0][i].from, to: wantedTimeList[0][i].to, background: ColorSetting().minimal_1, MID: 'dummyFromAllChecked', recurrenceRule: "")
    );
  }

  return [filterMeetings, unavailRegions];
}

// Intakes all wantedTime
// returns Available Regions as idx 0 and Unavailable Regions as idx 1
List<Object> filterCheckedAllMeetings(List<List<Meeting>> wantedTimeList, startDate, endDate){
  List<Meeting> filterMeetings = [];
  List<TimeRegion> unavailRegions = <TimeRegion>[];
  Map<int, Map<DateTime, List<Meeting>>> meetingMapPerUser = {};

  DateTime currentDateTime = startDate;
  DateTime currentDate = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day);
  int period = (endDate.difference(startDate).inHours / 24).round();

  print("filter meeting Case : checkAll");
  for(int i = 0; i < wantedTimeList.length; i ++){
    meetingMapPerUser[i] = {};
    wantedTimeList[i].forEach((meetingElement) { 
      if(meetingMapPerUser[i]![dateOnly(meetingElement.from)] == null){
        meetingMapPerUser[i]![dateOnly(meetingElement.from)] = [meetingElement];
      } else if(meetingMapPerUser[i]![dateOnly(meetingElement.from)] != null){
        meetingMapPerUser[i]![dateOnly(meetingElement.from)]!.add(meetingElement);
      }
    });
  }
  meetingMapPerUser.forEach((key, mapOfValue) { 
    mapOfValue.forEach((key, value) { 
      value.sort(((a, b) => a.from.compareTo(b.from)));
    });
  });

  List<DateTime> filledDays = [];
  List<DateTime> emptyDays = [];
  for (int i = 0; i < period + 1; i ++) {
    int counter = 0;
    DateTime dateElement = currentDate.add(Duration(days: i));
      for(int j = 0 ; j < wantedTimeList.length; j ++){
        if(meetingMapPerUser[j]![dateOnly(dateElement)] != null){
          counter ++;
        }
      }
      if(counter != meetingMapPerUser.keys.length){
          emptyDays.add(dateElement);
      }  else {
        filledDays.add(dateElement);
      }
    }

  for (int i = 0; i < period + 1; i ++) {
    DateTime dateElement = currentDate.add(Duration(days: i));

    List<Meeting> WTOnDay = [];

    for(int i = 0 ; i < wantedTimeList.length; i ++){
      if(meetingMapPerUser[i]![dateOnly(dateElement)] != null){
        WTOnDay.addAll(meetingMapPerUser[i]![dateOnly(dateElement)]!);
      }
    }
    WTOnDay.sort((a,b) {
      int fromComp = a.from.compareTo(b.from);
      if(fromComp == 0){
        return -a.to.compareTo(b.to);
      }
      return fromComp;
    });

    for(int i = 0 ; i < WTOnDay.length; i ++){
      List<String> holderForInv = [];
      List<int> holderForIdx = [];
      Meeting currentIdxMeeting = WTOnDay[i];
      holderForInv.add(currentIdxMeeting.owner);
      holderForIdx.add(i);
      for(int j = i + 1 ; j < WTOnDay.length; j ++) {
        if(WTOnDay[j].from.isBefore(currentIdxMeeting.to)) {
          for(int k = 0; k < holderForIdx.length; k ++){
            if(WTOnDay[holderForIdx[k]].to.isBefore(WTOnDay[j].from)){
              holderForInv.removeAt(k);
              holderForIdx.removeAt(k);
            }
          }
          if(holderForInv.contains(WTOnDay[j].owner)){
            int idx = holderForInv.indexOf(WTOnDay[j].owner);
            holderForInv.removeAt(idx);
            holderForIdx.removeAt(idx);
            holderForInv.add(WTOnDay[j].owner);
            holderForIdx.add(j);
          }
          else{
            holderForInv.add(WTOnDay[j].owner);
            holderForIdx.add(j);
          }

          if(holderForInv.length == wantedTimeList.length){

            // Defining dummy Meeting, from time
            DateTime startTime = WTOnDay[j].from;

            // Defining dummy Meeting, to time
            List<DateTime> toList = [];
            holderForIdx.forEach((holderIdx) { 
              toList.add(WTOnDay[holderIdx].to);
            });
            toList.sort(((a, b) => a.compareTo(b)));
            DateTime endTime = toList[0];
            
            // Creating and adding dummy available meeting time 
            // if startTime != endTime
            filterMeetings.add(
              Meeting(owner: '', content: '', from: startTime, to: endTime, background: ColorSetting().minimal_1, MID: 'dummyFromAllChecked', recurrenceRule: "")
            );
            
            for(int k = 0; k < holderForInv.length; k ++){ 
              if (j != (WTOnDay.length -1)) {
                if(WTOnDay[holderForIdx[k]].to.isBefore(WTOnDay[j + 1].from)){
                  holderForInv.removeAt(k);
                  holderForIdx.removeAt(k);
                }
              }
            }     
          } 
          print('');
        }
        else{
          break;
        }
      }
    }
  }

  

  return [filterMeetings, unavailRegions];
}

// Intakes all sent calendar data
// returns Available Regions as idx 0 and Unavailable Regions as idx 1
List<Object> filterCalendarAllMeetings (List<Meeting> meetings, startDate, endDate) {
  List<Meeting> filterMeetings = [];
  List<TimeRegion> unavailRegions = <TimeRegion>[];
  Map<DateTime, List<Meeting>> meetingsMap = {};
  
  DateTime currentDateTime = startDate;
  DateTime currentDate = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day);
  int period = (endDate.difference(startDate).inHours / 24).round();

  print("filter meeting Case : calendarAll");
  meetings.forEach((meetingElement) {
    if (meetingElement.MID.substring(0,7) != 'pending') {
      if(meetingsMap[dateOnly(meetingElement.from)] == null){
        meetingsMap[dateOnly(meetingElement.from)] = [meetingElement];

      } else if (meetingsMap[dateOnly(meetingElement.from)] != null){
        meetingsMap[dateOnly(meetingElement.from)]!.add(meetingElement);
      }
    }
  });
  Map<DateTime, List<Meeting>> meetingsMapTo = meetingsMap;
  //meetings 를 날짜별로 선분류

  meetingsMap.forEach((key, value) {
    print(key);
    //각 날짜별 시간을 sort
    meetingsMap[key]!.sort(((a, b) => a.from.compareTo(b.from)));
    meetingsMapTo[key]!.sort(((a, b) => a.to.compareTo(b.to)));
  });

  
  print("aaaaaaa $period");
  for (int i = 0; i < period + 1; i ++) {
    DateTime dateElement = currentDate.add(Duration(days: i));

    if (meetingsMap[dateElement] == null){
        filterMeetings.add(
          Meeting.allDayMeeting(dateElement)
        );  
    } else {
      filterMeetings.add(
        Meeting.combineMeetings(
          dateElement, 
          meetingsMap[dateElement]![0].from)
      );
      for(int j = 0; j < meetingsMap[dateElement]!.length - 1; j++){
        if(j != meetingsMap[dateElement]!.length - 1){
          if(meetingsMap[dateElement]![j].to.isBefore(meetingsMap[dateElement]![j+1].from)){
            filterMeetings.add(
              Meeting.combineMeetings(meetingsMap[dateElement]![j].to, meetingsMap[dateElement]![j+1].from)
            );
          }
        }       
      }  
      filterMeetings.add(
        Meeting.combineMeetings(
          meetingsMapTo[dateElement]![meetingsMap[dateElement]!.length - 1].to, 
          DateTime(dateElement.year, dateElement.month, dateElement.day, 23,59,00))
      );
    }
  }
  for(int i = 0; i < filterMeetings.length - 1; i++){
    unavailRegions.add(TimeRegion(
        startTime: filterMeetings[i].to,
        endTime: filterMeetings[i+1].from,
        enablePointerInteraction: false,
        color: Colors.black26,
        ));
  }
  return [filterMeetings, unavailRegions];
}

// Used when user decides to create preference meeting
// filters out space to unavailable region where user already has a meeting
List<TimeRegion> filterPrefWeek (List<Meeting> meetings, DateTime startTime, DateTime endTime) {
  List<Meeting> filterMeetings = [];
  List<TimeRegion> unavailRegions = [];
  meetings.forEach((meetingElement) { 
    unavailRegions.add(TimeRegion(
        startTime: meetingElement.from,
        endTime: meetingElement.to,
        enablePointerInteraction: false,
        color: Colors.black26,
        ));
  });
  return unavailRegions;
}

DateTime dateOnly(DateTime dateTimeForFilter) {
  DateTime date = DateTime(dateTimeForFilter.year, dateTimeForFilter.month, dateTimeForFilter.day);
  return date;
}

DateTime dateTimeFilter(DateTime dateTimeForFilter) {
  DateTime date = DateTime(dateTimeForFilter.year, dateTimeForFilter.month, dateTimeForFilter.day, dateTimeForFilter.hour, dateTimeForFilter.minute, dateTimeForFilter.second);
  return date;
}

 // Layer 1 of preferedWeekly formatting : combines separate individual time blocks into one joint time block
List<DateTime> joinBlocks(List<DateTime> unformattedTimeList) {
  List<DateTime> wantedTimeList = unformattedTimeList;

  // Sort startingDates in ascending order
  wantedTimeList.sort((a, b) => a.compareTo(b));

  int originalLength = wantedTimeList.length;
  var current = 0;
  DateTime addedEndTime = DateTime.now();

  // Add endDates for corresponding startDates
  for (var i = 0; i < originalLength; i++) {
    addedEndTime = wantedTimeList[current];
    addedEndTime = addedEndTime.add(Duration(minutes: 30));
    current += 1;
    wantedTimeList.insert(current, addedEndTime);
    current += 1;
  }

  // Join continuous time blocks
  current = 0;
  for (var i = 0; i < originalLength; i++) {
    if (wantedTimeList.asMap().containsKey(current + 2)) {
      if (wantedTimeList[current + 1 ] == wantedTimeList[current + 2]) {
        wantedTimeList.removeAt(current + 2); // Remove next startTime
        wantedTimeList.removeAt(current + 1); // Remove current endTime
      }
      else {current += 2;}
    }

    else {
      break;
    }
  }

  return wantedTimeList;
}
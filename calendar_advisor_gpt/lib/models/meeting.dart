import 'dart:convert';

import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  Meeting(
    {required this.owner,
    required this.content,
    required this.from,
    required this.to,
    required this.background,
    this.id,
    this.recurrenceId,
    this.recurrenceRule,
    this.recurrenceExceptionDates,
    this.isAllDay = false,
    required this.MID,
    this.involved = const [],
    this.pendingInvolved = const []}
  );

  final String owner;
  final String content;
  final DateTime from;
  final DateTime to;
  
  final Color background;
  final bool isAllDay;

  Object? id;
  Object? recurrenceId;
  String? recurrenceRule;
  List<DateTime>? recurrenceExceptionDates;

  List<String> involved;
  String MID;
  List<String> pendingInvolved;

  factory Meeting.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    List<dynamic> involvedDynamic = data?['involved'];
    List<String> involvedString = List<String>.from(involvedDynamic);

    List<dynamic>? pendingInvolvedDynamic = data?['pendingInvolved'];
    List<String> pendingInvolvedString;

    // if (pendingInvolvedDynamic != null) {
    //   if (pendingInvolvedDynamic.isNotEmpty) {
    //     pendingInvolvedString = List<String>.from(pendingInvolvedDynamic);
    //   } else {
    //     pendingInvolvedString = [];
    //     // or pendingInvolvedString = null
    //   }
    // } else {
    //   pendingInvolvedString = [];
    //   // or pendingInvolvedString = null
    // }

    return Meeting(
      owner: data?['owner'],
      content: data?['content'],
      from: data?['from'].toDate(),
      to: data?['to'].toDate(),
      background: Color(int.parse(data?['background'], radix: 16)),
      isAllDay: data?['isAllDay'],
      id: data?['id'],
      recurrenceId: data?['recurrenceId'],
      recurrenceExceptionDates: data?['recurrenceExceptionDates'],
      MID: data?['MID'],
      involved: involvedString,
      recurrenceRule: data?['recurrenceRule'],
      pendingInvolved: (pendingInvolvedDynamic != null)
        ? (pendingInvolvedDynamic.isNotEmpty
          ? List<String>.from(pendingInvolvedDynamic)
          : [])
        : [],
    );
  }

  factory Meeting.fromKakao(Map<String, String> queryParams) {
    final data = queryParams;
    String involvedString = data['involved']!
        .substring(1, data['involved']!.length - 1)
        .replaceAll(' ', '');

    String pendingInvolvedString = data['pendingInvolved']!
        .substring(1, data['pendingInvolved']!.length - 1)
        .replaceAll(' ', '');

    print("\n${involvedString.split(",")}");
    print("\n${pendingInvolvedString.split(",")}");

    return Meeting(
        owner: data['owner']!,
        content: data['content']!,
        from: DateTime.parse(data['from']!),
        to: DateTime.parse(data['to']!),
        background: Color(int.parse(data['background']!, radix: 16)),
        isAllDay: data['isAllDay'] == "true",
        id: data['id'],
        recurrenceId: data['recurrenceId'],
        recurrenceExceptionDates: data['recurrenceExceptionDates'] == null 
          ? null : data['recurrenceExceptionDates'] as List<DateTime>,
        involved: involvedString.length != 0 ? involvedString.split(",") : [],
        pendingInvolved: pendingInvolvedString.length != 0
            ? pendingInvolvedString.split(",")
            : [],
        MID: data['MID']!,
        recurrenceRule:
            data['recurrenceRule'] != null ? data['recurrenceRule'] : "");
  }

  factory Meeting.filteredContentFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    List<dynamic> involvedDynamic = data?['involved'];
    List<String> involvedString = List<String>.from(involvedDynamic);
    return Meeting(
        owner: "",
        content: "",
        from: data?['from'].toDate(),
        to: data?['to'].toDate(),
        background: ColorSetting().minimal_1,
        isAllDay: data?['isAllDay'],
        id: data?['id'],
        recurrenceId: data?['recurrenceId'],
        recurrenceExceptionDates: data?['recurrenceExceptionDates'],
        MID: data?['MID'],
        involved: [],
        recurrenceRule: "");
  }

  factory Meeting.allDayMeeting(DateTime givenDateTime) {
    return Meeting(
        owner: "",
        content: "",
        from: DateTime(givenDateTime.year, givenDateTime.month,
            givenDateTime.day, 0, 0, 0),
        to: DateTime(givenDateTime.year, givenDateTime.month, givenDateTime.day,
            23, 59, 59),
        background: ColorSetting().minimal_1,
        isAllDay: false,
        id: 'dummyAllDatMeeting',
        MID: "dummyAllDatMeeting",
        involved: [],
        pendingInvolved: [],
        recurrenceRule: "");
  }

  factory Meeting.combineMeetings(DateTime from, DateTime to) {
    return Meeting(
        owner: "",
        content: "",
        from: from,
        to: to,
        background: ColorSetting().minimal_1,
        isAllDay: false,
        id: 'dummyFromCombine',
        MID: "dummyFromCombine",
        involved: [],
        pendingInvolved: [],
        recurrenceRule: "");
  }

  Map<String, dynamic> toFirestore() {
    return {
      "owner": owner,
      "content": content,
      "from": from,
      "to": to,
      "background": background.toString().split('(0x')[1].split(')')[0],
      "isAllDay": isAllDay,
      "id" : id,
      "recurrenceId" : recurrenceId,
      "recurrenceExceptionDates" : recurrenceExceptionDates,
      "MID": MID,
      "involved": involved,
      "recurrenceRule": recurrenceRule,
      "pendingInvolved": pendingInvolved,
    };
  }

  factory Meeting.filterContentForMonthly(
      Meeting meeting) {
    return Meeting(
        owner: meeting.owner,
        content: "",
        from: meeting.from,
        to: meeting.to,
        background: meeting.background,
        isAllDay: meeting.isAllDay,
        id: meeting.id,
        recurrenceId: meeting.recurrenceId,
        recurrenceExceptionDates: meeting.recurrenceExceptionDates,
        MID: meeting.MID,
        involved: [],
        recurrenceRule: meeting.recurrenceRule);
  }
}

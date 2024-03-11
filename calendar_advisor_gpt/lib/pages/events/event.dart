import 'package:calendar/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final uiSettingColor = ColorSetting();
final uiSettingFont = FontSetting();
final dailyPage = DailyState();

class MeetingDataSource extends CalendarDataSource<Meeting> {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
    //print("${appointments?[0].content}\n${appointments?[0].from}\n${appointments?[0].to}\n${appointments?[0].background}\n${appointments?[0].isAllDay}"); //todo
  }

  Meeting getEvent(int index) => appointments![index] as Meeting;

  @override
  DateTime getStartTime(int index) => getEvent(index).from;

  @override
  DateTime getEndTime(int index) => getEvent(index).to;

  @override
  String getSubject(int index) => getEvent(index).content;

  @override
  Color getColor(int index) => getEvent(index).background;

  @override
  String getRecurrenceRule(int index) => getEvent(index).recurrenceRule!;

  @override
  Object? getId(int index) => getEvent(index).id;

  
  @override
  Meeting? convertAppointmentToObject(
    Meeting? customData, Appointment appointment) 
  {
    return Meeting(
      owner: customData!.owner,
      from: appointment.startTime,
      to: appointment.endTime,
      content: appointment.subject,
      background: appointment.color,
      isAllDay: appointment.isAllDay,
      id: appointment.id,
      recurrenceRule: appointment.recurrenceRule,
      recurrenceId: appointment.recurrenceId,
      recurrenceExceptionDates: appointment.recurrenceExceptionDates,
      MID: customData.MID,
      involved: customData.involved,
      pendingInvolved: customData.pendingInvolved,
    );
  }
  
}

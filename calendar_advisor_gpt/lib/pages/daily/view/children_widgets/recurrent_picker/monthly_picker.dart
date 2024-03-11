import 'package:calendar/models/meeting.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/daily/view_model/recurrent_events.dart';
import 'package:calendar/pages/events/event.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class MonthlyPicker extends StatefulWidget {
  late final Function endDateCallback;

  MonthlyPicker({Key? key, required this.endDateCallback}) : super(key: key);

  @override
  State<MonthlyPicker> createState() => _MonthlyPickerState();
}

class _MonthlyPickerState extends State<MonthlyPicker> {
  DateTime defDate = DateTime.now();
  late DateTime endDate = defDate;
  Color resetColor = Color.fromRGBO(106, 103, 172, 1);
  get dateWithNoTimeEnd => DateFormat('yyyy-MM-dd').format(endDate.add(Duration(days: 1)));
  get dateWithTimeEnd => DateFormat('hh:mm').format(endDate);

  List<Meeting> meetings = [];

  MeetingDataSource _getDataSource (List<Meeting> source) {
    return MeetingDataSource(source);
  }

  @override
  
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF5562FE)),
          bottom: BorderSide(color: Color(0xFF5562FE))
        ),
      ),
      child: SfCalendar(
        view: CalendarView.month,
        dataSource: _getDataSource(meetings),
        onTap: (CalendarTapDetails details) {
          endDate = details.date!;

          if (meetings.isNotEmpty) {
            meetings.removeLast();
          }
          
          meetings.add(Meeting(
            owner: '',
            MID: '',
            content: '',
            from: details.date!,
            to: details.date!,
            background: ColorSetting().minimal_1,
            isAllDay: true,
            involved: [],
            recurrenceRule: '',
          ));

          widget.endDateCallback(endDate);
          print(endDate);
    
          setState(() {});
        }
      ),
    );
  }
}
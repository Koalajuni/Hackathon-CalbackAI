import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar/pages/all_pages.dart';

//-------------------- Month Selected Date Decoration --------------------//
Decoration customSelectedDecoration() {
  return BoxDecoration(
    color: Color.fromRGBO(246, 245, 255, 99),
    borderRadius: BorderRadius.circular(1),
    // border: Border.all(
    //   color: uiSettingColor.minimal_1,
    // ),
    shape: BoxShape.circle,
  );
}

//-------------------- Month View Settings --------------------//
MonthViewSettings customMonthViewSettings() {
  return MonthViewSettings(
    showTrailingAndLeadingDates: true,
    appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
    appointmentDisplayCount: 5,
    showAgenda: false,
    numberOfWeeksInView: 6,
    monthCellStyle: MonthCellStyle(),
  );
}

//-------------------- Month Cell Builder --------------------//

Widget customMonthCellBuilder(BuildContext context, MonthCellDetails details) {
  var mid=details.visibleDates.length~/2.toInt();
  var midDate=details.visibleDates[0].add(Duration(days: mid));
  DateTime now = DateTime.now();
  if(details.date.month != midDate.month) {
    return Container(
          height: 60,
          decoration: myMonthCell(),
          child: Column(
            children: [
              SizedBox(height: 4),
              Container(
                child: Text(details.date.day.toString(),
                    style:
                        TextStyle(color: Colors.grey, height: 1.7)),
              )
            ],
          ),
        );
  }
  else{
    if (details.date.year == now.year &&
        details.date.month == now.month &&
        details.date.day == now.day) {
      return Container(
        height: 60,
        decoration: myMonthCell(),
        child: Column(children: [
          SizedBox(height: 4),
          Container(
            width: 28,
            height: 28,
            decoration:
                BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: Text(
              details.date.day.toString(),
              style: TextStyle(color: Colors.white, height: 1.7),
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      );
    } else {
      if (details.date.weekday == 7) {
        return Container(
          height: 60,
          decoration: myMonthCell(),
          child: Column(
            children: [
              SizedBox(height: 4),
              Container(
                child: Text(details.date.day.toString(),
                    style:
                        TextStyle(color: Color(0xffFF5555), height: 1.7)),
              )
            ],
          ),
        );
      } else if (details.date.weekday == 6) {
        return Container(
          height: 60,
          decoration: myMonthCell(),
          child: Column(
            children: [
              SizedBox(height: 4),
              Container(
                child: Text(details.date.day.toString(),
                    style: TextStyle(color: Color(0xff5570FF), height: 1.7)),
              )
            ],
          ),
        );
      } else {
        return Container(
          height: 60,
          decoration: myMonthCell(),
          child: Column(
            children: [
              SizedBox(height: 4),
              Container(
                child: Text(details.date.day.toString(),
                    style: TextStyle(color: Colors.black, height: 1.7)),
              )
            ],
          ),
        );
      }
    }
    }
}

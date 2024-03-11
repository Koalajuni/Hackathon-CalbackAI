import 'package:calendar/custom_widgets/agenda_widget.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/models/meeting.dart';
import 'package:calendar/pages/events/event.dart';
import 'package:calendar/pages/monthly/monthly_custom_cell.dart';
import 'package:calendar/pages/profile/state_manager/date_controller.dart';
import 'package:calendar/pages/profile/view/open_profile_agenda.dart';
import 'package:calendar/shared/calendar_functions.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ProfileWeekCalendar extends StatelessWidget {
  const ProfileWeekCalendar({
    Key? key,
    required this.myUser,
    required this.otherUser,
    required this.dateController,
    required this.meetingData,
  }) : super(key: key);

  final MyUser myUser;
  final MyUser otherUser;
  final DateController dateController;
  final List<Meeting> meetingData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child : StatefulBuilder(builder: (context, setCalendar) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    height: 500.h,
                    //-------------------- Calendar --------------------//
                    child: SfCalendar(
                      onViewChanged: (ViewChangedDetails viewChangedDetails){
                        try {
                          setCalendar((){
                            dateController.changeHeaderDate(viewChangedDetails
                              .visibleDates[viewChangedDetails.visibleDates.length ~/ 2]);
                          });
                        } catch (e) {}    
                      },
                      view: CalendarView.week,
                      backgroundColor: Color(0xffF6F6F6),
                      initialSelectedDate: dateController.selectedDate.value,
                      headerHeight: 0,
                      monthViewSettings: customMonthViewSettings(),
                      monthCellBuilder: customMonthCellBuilder,
                      dataSource: MeetingDataSource((meetingData) as List<Meeting>),
                      onTap: (details) {
                        if (details.targetElement ==
                            CalendarElement.calendarCell) {
                          setCalendar(() {
                            dateController.changeDate(dateOnly(details.date!));
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              Divider(color: Color(0xffD9D9D9), thickness: 1,),
            ],
          );
        }),
    );
  }
}
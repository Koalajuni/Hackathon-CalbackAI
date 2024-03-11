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

class ProfileMonthCalendar extends StatelessWidget {
  const ProfileMonthCalendar({
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
                    height: 340.h,
                    //-------------------- Calendar --------------------//
                    child: otherUser.openPrivacy 
                      ? SfCalendar(
                        onViewChanged: (ViewChangedDetails viewChangedDetails){
                          try {
                            setCalendar((){
                              dateController.changeHeaderDate(viewChangedDetails
                                .visibleDates[viewChangedDetails.visibleDates.length ~/ 2]);
                            });
                          } catch (e) {}    
                        },
                        view: CalendarView.month,
                        backgroundColor: Color(0xffF6F6F6),
                        initialSelectedDate: dateController.selectedDate.value,
                        headerHeight: 0,
                        monthViewSettings: customMonthViewSettings(),
                        monthCellBuilder: customMonthCellBuilder,
                        dataSource: MeetingDataSource(List<Meeting>.generate(((meetingData) as List).length, (index) {
                                      return Meeting.filterContentForMonthly(((meetingData) as List)[index]);
                                    })),
                        onTap: (details) {
                          if (details.targetElement ==
                              CalendarElement.calendarCell) {
                            setCalendar(() {
                              dateController.changeDate(dateOnly(details.date!));
                            });
                          }
                        },
                      )

                      : otherUser.friends.contains(myUser.uid)
                        ? SfCalendar(
                          onViewChanged: (ViewChangedDetails viewChangedDetails){
                            try {
                              setCalendar((){
                                dateController.changeHeaderDate(viewChangedDetails
                                  .visibleDates[viewChangedDetails.visibleDates.length ~/ 2]);
                              });
                            } catch (e) {}    
                          },
                          view: CalendarView.month,
                          backgroundColor: Color(0xffF6F6F6),
                          initialSelectedDate: dateController.selectedDate.value,
                          headerHeight: 0,
                          monthViewSettings: customMonthViewSettings(),
                          monthCellBuilder: customMonthCellBuilder,
                          dataSource: MeetingDataSource(List<Meeting>.generate(((meetingData) as List).length, (index) {
                                        return Meeting.filterContentForMonthly(((meetingData) as List)[index]);
                                      })),
                          onTap: (details) {
                            if (details.targetElement ==
                                CalendarElement.calendarCell) {
                              setCalendar(() {
                                dateController.changeDate(dateOnly(details.date!));
                              });
                            }
                          },
                        )

                        : Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              foregroundDecoration: BoxDecoration(
                                color: Color(0xAAF6F6F6)
                              ),
                              child: IgnorePointer(
                                child: SfCalendar(
                                  view: CalendarView.month,
                                ),
                              ),
                            ),
                            
                            Text(
                              '비공개입니다',
                              style: TextStyle(
                                fontFamily: 'Pretendard', 
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff565778)
                              ) 
                            ),
                          ]
                        )
                  ),
                ],
              ),
              Divider(color: Color(0xffD9D9D9), thickness: 1,),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.only(left: 20),
                height: 47,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("${dateController.selectedDate.value.day}일",
                    style: TextStyle(
                      fontFamily: 'Spoqa',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Color(0xff222222)
                    ),
                  ),
                )
              ),
            //-------------------- Agenda --------------------//
              otherUser.uid.substring(0,5) == 'open:' && myUser.uid != otherUser.uid
              ? otherUser.openPrivacy
                // Open to public
                ? OpenProfileAgenda(otherUser: otherUser, meetingData: meetingData, currentDate: dateOnly(dateController.selectedDate.value))
                : otherUser.friends.contains(myUser.uid)
                  
                  // Closed but following
                  ? OpenProfileAgenda(otherUser: otherUser, meetingData: meetingData, currentDate: dateOnly(dateController.selectedDate.value))
                  
                  // Closed and not following
                  : Container()
              : Agenda(user: myUser, otherUser: otherUser, meetingData: meetingData, currentDate: dateOnly(dateController.selectedDate.value))
              
            ],
          );
        }),
    );
  }
}
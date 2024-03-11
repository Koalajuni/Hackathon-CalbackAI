import 'package:calendar/models/meeting.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/shared/calendar_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


class HomeAgenda extends StatefulWidget {
  final MyUser user;
  final MyUser? otherUser;
  final List<Meeting> meetingData;
  final DateTime currentDate;
  final double maxLength;
  final List tapDetailsList;
  const HomeAgenda({Key? key, required this.user, this.otherUser, required this.meetingData, required this.currentDate, this.maxLength = 200, this.tapDetailsList = const []}) : super(key: key);
  
  @override
  State<HomeAgenda> createState() => _HomeAgendaState();
}

class _HomeAgendaState extends State<HomeAgenda> {
  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventMaker>(context);
    MyUser user = widget.user;
    List<Meeting> meetingData = widget.meetingData;
    DateTime currentDate = widget.currentDate;
    
    Map<DateTime, List<Meeting>> agendaData = getAgendaData(meetingData);
    
    List tapDetailsList = widget.tapDetailsList;
    List<Meeting>? currentMeetingList = agendaData[currentDate];
    if (tapDetailsList.isNotEmpty) {
      for (var event in tapDetailsList) {
        if (event.recurrenceRule != '') {
          Meeting tapMeeting;
          for (var meeting in eventProvider.events) {
            if (meeting.MID == event.MID && 
              meeting.recurrenceRule == event.recurrenceRule) 
            {
              tapMeeting = Meeting(
                owner: meeting.owner,
                content: meeting.content,
                from: event.from,
                to: event.to,
                background: meeting.background,
                isAllDay: meeting.isAllDay,
                id: event.id,
                recurrenceId: event.recurrenceId,
                recurrenceRule: meeting.recurrenceRule,
                recurrenceExceptionDates: event.recurrenceExceptionDates,
                involved: meeting.involved,
                MID: meeting.MID,
                pendingInvolved: meeting.pendingInvolved
              );
              
              agendaData[currentDate] ??= [];

              bool checkRepeatedAgenda = false;
              for (var agendaEvent in agendaData[currentDate]!) {
                if (agendaEvent.MID == tapMeeting.MID) {
                  checkRepeatedAgenda = true;}
              }
              
              checkRepeatedAgenda 
                ? checkRepeatedAgenda = true 
                : {agendaData[currentDate]!.add(tapMeeting),
                  currentMeetingList ??= [],
                  currentMeetingList.add(tapMeeting)};
            }
          }
        }
      }
    }

    return currentMeetingList == null ?  Container(
      color: Color.fromARGB(185, 129, 129, 250),
      height: 315, 
      width: MediaQuery.of(context).size.width, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            SizedBox(height: 16,),
            InkWell(
              splashColor: Colors.black12,
              onTap: () async {
                await Navigator.of(context).push(
                  CustomPageRoute(
                    child: StreamProvider<MyUser>(
                      create: (context) => DatabaseService(uid: user.uid).userData,
                      initialData: MyUser(uid: user.uid),
                      builder: (context, child) => Daily(),
                    ),
                    direction: AxisDirection.right,
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(56)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10,),
                        CircleAvatar(
                          backgroundColor: Colors.black12,
                          radius: 20,
                          backgroundImage:  user!.photoUrl != '' ? CachedNetworkImageProvider(user!.photoUrl) : null
                        ),
                        SizedBox(width: 10,),
                        Text('내 일정 등록하기',
                          style: TextStyle(
                            fontFamily: 'PretendardVar',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ) 
                        )
            
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Image.asset('assets/icons/arrow_right.png', width: 24, height: 24,)
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              height: 207,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 16),
                    child: Text('오늘의 일정',
                      style: TextStyle(
                        color: Color(0xff303030),
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ) 
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          SizedBox(height: 35,),
                          Image.asset('assets/icons/smile.png', width: 24, height: 24,), 
                          SizedBox(height: 6,),
                          Text('오늘 등록된 일정이 없어요',
                            style: TextStyle(
                              fontFamily: 'Pretendard', 
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff565778)
                            ) 
                          ),
                          SizedBox(height: 4,),
                          Text('일정을 등록하고 친구들을 초대해 보세요!',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff565778)
                            ) 
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
        ]
      ),
    ): Container(
      height: agendaData[currentDate]!.length < 3 ? 88 + 51 + agendaData[currentDate]!.length * 48 + (agendaData[currentDate]!.length - 1) * 8 + 36 : 359,
      color: Color(0xff8281FA),
      child: Column(
        children: [
          SizedBox(height: 18,),
          InkWell(
            splashColor: Colors.black12,
            onTap: () async {
              await Navigator.of(context).push(
                CustomPageRoute(
                  child: StreamProvider<MyUser>(
                    create: (context) => DatabaseService(uid: user.uid).userData,
                    initialData: MyUser(uid: user.uid),
                    builder: (context, child) => Daily(),
                  ),
                  direction: AxisDirection.right,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(56)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      CircleAvatar(
                        backgroundColor: Colors.black12,
                        radius: 20,
                        backgroundImage:  user!.photoUrl != '' ? CachedNetworkImageProvider(user!.photoUrl) : null
                      ),
                      SizedBox(width: 10,),
                      Text('내 일정 등록하기',
                        style: TextStyle(
                          fontFamily: 'Spoqa', // TODO Pretendard
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ) 
                      )
          
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Image.asset('assets/icons/arrow_right.png', width: 24, height: 24,)
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
              height: agendaData[currentDate]!.length < 3 ? 51 + agendaData[currentDate]!.length * 48 + (agendaData[currentDate]!.length - 1) * 8 + 16 : 227,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 16,),
                  Container(
                    height: 19,
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only( left: 12),
                    child: Text('오늘의 일정',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: agendaData[currentDate]!.length < 3 ? agendaData[currentDate]!.length * 48 + (agendaData[currentDate]!.length - 1) * 8 : 160,
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) { 
                            return 
                              SizedBox(height: 8,);
                          },
                          shrinkWrap: true,
                          itemCount: agendaData[currentDate] != null ?
                            agendaData[currentDate]!.length : 0,
                          itemBuilder: (BuildContext context, int index) {
                            //-------------------- clicking agenda opens daily edit --------------------//
                            return TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.white,
                                fixedSize: Size(double.infinity, 48)
                              ),
                              //-------------------- Back End of Agenda --------------------//
                              onPressed: () {
                                if(widget.otherUser == null) {
                                  final agendaMid = agendaData[currentDate]![index].MID;
                                  final eventIndex = meetingData.indexWhere((element) => element.MID == agendaMid);
                                  if (eventIndex != -1) {
                                    print(meetingData[eventIndex]);
                                    Navigator.push(context, 
                                      CustomPageRoute(
                                        child: StreamProvider<MyUser>(
                                          create: (context) => DatabaseService(uid:meetingData[eventIndex].owner).userData,
                                          initialData: MyUser(uid: meetingData[eventIndex].owner),
                                          builder: (context, child) => EventViewer(event: meetingData[eventIndex], myUser: user),
                                        ),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Invalid Meeting"),
                                          content: Text("Someone may have editted the meeting"),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              child: const Text('Ok'),
                                              onPressed: () {
                                                eventProvider.updateEventMaker(user.uid);
                                                Navigator.of(context).pop();
                                                setState(() {});
                                              },
                                            ),
                                          ]
                                        );
                                      }
                                    );
                                  }
                                }
                              },
                              //-------------------- Front End of Agenda --------------------//
                              child: Container(
                                  alignment: Alignment.center,
                                  height: 48,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        width: 67.w,
                                        decoration: BoxDecoration(
                                          color: agendaData[currentDate]![index].background.withOpacity(0.3), //TODO color
                                          borderRadius: BorderRadius.circular(10) //
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            //-------------------- Agenda showing time --------------------//
                                            //from--------------------
                                            SizedBox(
                                              height: 12,
                                              child: Text(
                                                agendaData[currentDate]![index].isAllDay ? 
                                                  '${DateFormat('yyyy-MM-dd \nhh:mm a').format(agendaData[currentDate]![index].from)}' : '${DateFormat('hh:mm a').format(agendaData[currentDate]![index].from)}',
                                                textAlign: TextAlign.center,
                                                style: agendaData[currentDate]![index].isAllDay 
                                                ? TextStyle(
                                                  fontFamily: 'Spoqa',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10.sp,
                                                  color: Color.fromRGBO(85, 85, 85, 1)
                                                ,)
                                                : TextStyle(
                                                  fontFamily: 'Spoqa',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10.sp,
                                                  color: Color.fromRGBO(85, 85, 85, 1)
                                                ),
                                              ),
                                            ),
                                            agendaData[currentDate]![index].isAllDay 
                                              ? SizedBox(height:6.h) 
                                              : SizedBox(height:8),
                                            SizedBox(
                                              height: 12,
                                              child: Text(
                                                agendaData[currentDate]![index].isAllDay
                                                  ? '${DateFormat('yyyy-MM-dd \nhh:mm a').format(agendaData[currentDate]![index].to)}' : '${DateFormat('hh:mm a').format(agendaData[currentDate]![index].to)}',
                                                textAlign: TextAlign.center,
                                                style: agendaData[currentDate]![index].isAllDay 
                                                ? TextStyle(
                                                  fontFamily: 'Spoqa',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10.sp,
                                                  color: Color.fromRGBO(85, 85, 85, 1)
                                                ,)
                                                : TextStyle(
                                                  fontFamily: 'Spoqa',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10.sp,
                                                  color: Color.fromRGBO(85, 85, 85, 1)
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: agendaData[currentDate]![index].background.withOpacity(0.3), //TODO color
                                            borderRadius: BorderRadius.circular(10) //
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 10,),
                                              Container(
                                                padding: EdgeInsets.all(3),
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Image.asset('assets/icons/half_calendar.png', height: 3, width: 3),
                                              ),
                                              SizedBox(width: 10,),
                                              Expanded(
                                                child: Container(
                                                  height: 17,
                                                  child: Text(agendaData[currentDate]![index].content,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: 'Pretendard',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xff303030),
                                                    )
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Padding(
                                                padding: EdgeInsets.only(right: 12),
                                                child: Image.asset('assets/icons/arrow_right.png', width: 24, height: 24,)
                                              ),
                                            ],
                                          )
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );  
  }
}

getAgendaData(List<Meeting> meetingsData) {
  Map<DateTime, List<Meeting>> agendaData = {};
  meetingsData.forEach((meetingElement) {
    // Pending meeting이 아닐시
    if (meetingElement.MID.substring(0, 7) != 'pending') {
      if(meetingElement.isAllDay == false) {
        // SINGLE DAY MEETING 처리
        if (agendaData[dateOnly(meetingElement.from)] == null) { // Agenda Data에 현재 미팅의 from날짜 데이터가 없다면 agendaData에 데이터 생성
          agendaData[dateOnly(meetingElement.from)] = [meetingElement];
        } else if (agendaData[dateOnly(meetingElement.from)] != null) { // 그게 아니라면 현재 meetingElement 데이터가 있는지 없는지 확인하고 추가
          bool addToAgenda = true;
          agendaData[dateOnly(meetingElement.from)]!.forEach((agendaElement) {
            if (agendaElement.MID == meetingElement.MID) {
              addToAgenda = false;
            }
          });
          if (addToAgenda) {
            agendaData[dateOnly(meetingElement.from)]!.add(meetingElement);
          }
        }
      } else {
        // MULTIDAY Meeting 처리
        DateTime startDate = dateOnly(meetingElement.from);
        DateTime endDate = dateOnly(meetingElement.to);
        int period = (endDate.difference(startDate).inHours / 24).round();

        for(int i = 0; i < period + 1; i++){
          DateTime dateElement = startDate.add(Duration(days: i));
          if (agendaData[dateOnly(dateElement)] == null) { // Agenda Data에 현재 미팅의 from날짜 데이터가 없다면 agendaData에 데이터 생성
            agendaData[dateOnly(dateElement)] = [meetingElement];
        } else if (agendaData[dateOnly(meetingElement.from)] != null) {
          bool addToAgenda = true;
          agendaData[dateOnly(dateElement)]!.forEach((agendaElement) { // 그게 아니라면 현재 meetingElement 데이터가 있는지 없는지 확인하고 추가
            if (agendaElement.MID == meetingElement.MID) {
              addToAgenda = false;
            }
          });
          if (addToAgenda) {
            agendaData[dateOnly(dateElement)]!.add(meetingElement);
          }
        }
            

        }
      }
    }
  });
  agendaData.forEach((key, value) {
    //각 날짜별 시간을 sort
    agendaData[key]!.sort(((a, b) => a.from.compareTo(b.from)));
  });
  return agendaData;
}

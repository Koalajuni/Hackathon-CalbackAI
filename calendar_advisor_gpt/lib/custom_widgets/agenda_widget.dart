import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/meeting.dart';
import '../services/database.dart';
import '../shared/calendar_functions.dart';

class Agenda extends StatefulWidget {
  final MyUser user;
  final MyUser? otherUser;
  final List<Meeting> meetingData;
  final DateTime currentDate;
  final double maxLength;
  final List tapDetailsList;
  const Agenda({Key? key, required this.user, this.otherUser, required this.meetingData, required this.currentDate, this.maxLength = 200, this.tapDetailsList = const []}) : super(key: key);
  
  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
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
      alignment: Alignment.center,
      height: 200.h, 
      width: MediaQuery.of(context).size.width, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/logo_icon_whiteBG.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 10.h),
          Text(AppLocalizations.of(context)!.agenda_noEvents, style: TextStyle( color: uiSettingColor.minimal_1, fontSize: 14.sp, fontFamily: 'Spoqa', fontWeight: FontWeight.w700),),
        ],
      ),
    ): Container(
      color: Colors.white,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) { 
          return 
            Divider(
              height: 4.h, 
              thickness: 1,
              indent: 100, 
              endIndent: 16,
              color: Color.fromARGB(255, 54, 50, 50)
            );
        },
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: agendaData[currentDate] != null ?
          agendaData[currentDate]!.length : 0,
        itemBuilder: (BuildContext context, int index) {
          //-------------------- clicking agenda opens daily edit --------------------//
          return TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white
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
                        create: (context) => DatabaseService(uid: meetingData[eventIndex].owner).userData,
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
                height: 74,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          //-------------------- Agenda showing time --------------------//
                          //from--------------------
                          Text(
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
                          agendaData[currentDate]![index].isAllDay 
                            ? SizedBox(height:6.h) 
                            : SizedBox(height:24.h),
                          Text(
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
                        ],
                      ),
                    ),
                    SizedBox(width: 14),
                    //Colored Oval--------------------
                    Container(
                      alignment: Alignment.center,
                      width: 8.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: agendaData[currentDate]![index].background,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    SizedBox(width: 14),
                    Container(
                      height: 50.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //Content --------------------
                          Container(
                            constraints: BoxConstraints(maxWidth: widget.maxLength),
                            child: Text(
                              '${agendaData[currentDate]![index].content}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Spoqa',
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(34, 34, 34, 1),
                                fontSize: 14.sp,
                              )
                            ),
                          ),
                          //involved--------------------
                          Row(
                            children: [
                              //owner avatar
                              StreamBuilder<MyUser>(
                                stream: DatabaseService(uid: agendaData[currentDate]![index].owner).userData,
                                builder:(BuildContext context, snapshot) {
                                  if (snapshot.data != null) {
                                    return Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: SingleProfile(
                                        size: 24,
                                        photoUrl: snapshot.data!.photoUrl,
                                        borderSize: 2
                                      ),
                                    );
                                  } else {
                                    return Text("");
                                  }
                                }
                              ),
                              Container(
                                height: 24.h,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: agendaData[currentDate]![index].involved.length >= 6 ? 6: agendaData[currentDate]![index].involved.length,
                                  itemBuilder: (BuildContext context, int index2) {
                                    if (agendaData[currentDate]![index].involved.isNotEmpty) {
                                      return Row(
                                        children: [
                                          //Circle Avatar of Involved--------------------
                                          StreamBuilder<MyUser>(
                                            stream: DatabaseService(uid: agendaData[currentDate]![index].owner).userData,
                                            builder: (BuildContext context, ownerSnapshot) {
                                              if (ownerSnapshot.data != null) {
                                                return StreamBuilder<MyUser>(
                                                  stream: DatabaseService(uid: agendaData[currentDate]![index].involved[index2]).userData,
                                                  builder: (BuildContext context, snapshot) {
                                                    if (snapshot.data != null) {
                                                      return Padding(
                                                        padding:
                                                          const EdgeInsets.all(1),
                                                        child: ownerSnapshot.data!.openPrivacy
                                                          ? Container()
                                                          : SingleProfile(
                                                            size: 26,
                                                            photoUrl: snapshot.data!.photoUrl,
                                                            borderSize: 2
                                                          ),
                                                      );
                                                    } else {
                                                      return Text("");
                                                    }
                                                  }
                                                );
                                              } else {
                                                return Text("");
                                            } 
                                            }
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Text("");
                                    }
                                  } 
                                ),
                              ),
                              agendaData[currentDate]![index].involved.length >= 6 
                                ? Text("+${(agendaData[currentDate]![index].involved.length)- 6}") 
                                : Text(""),
                            ]
                          )
                        ],
                      ),
                    )
                  ]
                ),
              ),
          );
        },
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

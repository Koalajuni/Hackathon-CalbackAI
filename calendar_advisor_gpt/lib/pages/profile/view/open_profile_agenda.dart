import 'package:calendar/models/meeting.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/shared/calendar_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class OpenProfileAgenda extends StatefulWidget {
  final MyUser otherUser;
  final List<Meeting> meetingData;
  final DateTime currentDate;
  final double maxLength;
  const OpenProfileAgenda({Key? key, required this.otherUser, required this.meetingData, required this.currentDate, this.maxLength = 200}) : super(key: key);
  
  @override
  State<OpenProfileAgenda> createState() => _OpenProfileAgendaState();
}

class _OpenProfileAgendaState extends State<OpenProfileAgenda> {
  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventMaker>(context);

    final MyUser otherUser = widget.otherUser;
    final MyUser user = Provider.of<MyUser>(context);
    List<Meeting> meetingData = widget.meetingData;
    DateTime currentDate = widget.currentDate;
    
    Map<DateTime, List<Meeting>> agendaData = getAgendaData(meetingData);
    return Container(
      color: Colors.white,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) { 
          return 
            Divider(
              height: 4, 
              thickness: 1,
              indent: 100, 
              endIndent: 16,
              color: Color(0xffD6D6D6)
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
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white
            ),
            //-------------------- Back End of Agenda --------------------//
            onPressed: () {
              final agendaMid = agendaData[currentDate]![index].MID;
              final eventIndex = meetingData.indexWhere((element) => element.MID == agendaMid);
              if (eventIndex != -1) {
                print(meetingData[eventIndex]);
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => EventViewer(event: meetingData[eventIndex], 
                    otherUser: otherUser
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
            },
            //-------------------- Front End of Agenda --------------------//
            child: Container(
                alignment: Alignment.center,
                height: 74,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width:20),
                    Container(
                      width: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //-------------------- Agenda showing time --------------------//
                          //from--------------------
                          Text(
                            agendaData[currentDate]![index].isAllDay ? 
                              '${DateFormat('yyyy-MM-dd \nhh:mm a').format(agendaData[currentDate]![index].from)}' : '${DateFormat('hh : mm a').format(agendaData[currentDate]![index].from)}',
                            textAlign: TextAlign.center,
                            style: agendaData[currentDate]![index].isAllDay 
                            ? TextStyle(
                              fontFamily: 'Spoqa',
                              fontWeight: FontWeight.w400,
                              fontSize: 8,
                              color: Color.fromRGBO(85, 85, 85, 1)
                            ,)
                            : TextStyle(
                              fontFamily: 'Spoqa',
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color: Color.fromRGBO(85, 85, 85, 1)
                            ),
                          ),
                          agendaData[currentDate]![index].isAllDay 
                            ? SizedBox(height:6) 
                            : SizedBox(height:24),
                          Text(
                            agendaData[currentDate]![index].isAllDay
                              ? '${DateFormat('yyyy-MM-dd \nhh:mm a').format(agendaData[currentDate]![index].to)}' : '${DateFormat('hh : mm a').format(agendaData[currentDate]![index].to)}',
                            textAlign: TextAlign.center,
                            style: agendaData[currentDate]![index].isAllDay 
                            ? TextStyle(
                              fontFamily: 'Spoqa',
                              fontWeight: FontWeight.w400,
                              fontSize: 8,
                              color: Color.fromRGBO(85, 85, 85, 1)
                            ,)
                            : TextStyle(
                              fontFamily: 'Spoqa',
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
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
                      width: 8,
                      height: 50,
                      decoration: BoxDecoration(
                        color: agendaData[currentDate]![index].background,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    SizedBox(width: 14),
                    Container(
                      height: 50,
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
                                fontSize: 14,
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
                                      padding: const EdgeInsets.only(right: 10),
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
                              otherUser.openPrivacy
                              ? Container()
                              : Container(
                                  height: 24,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: agendaData[currentDate]![index].involved.length >= 3 ? 3: agendaData[currentDate]![index].involved.length,
                                    itemBuilder: (BuildContext context, int index2) {
                                      if (agendaData[currentDate]![index].involved.isNotEmpty) {
                                        return Row(
                                          children: [
                                            //Circle Avatar of Involved--------------------
                                            StreamBuilder<MyUser>(
                                              stream: DatabaseService(uid: agendaData[currentDate]![index].involved[index2]).userData,
                                              builder: (BuildContext context, snapshot) {
                                                if (snapshot.data != null) {
                                                  return Padding(
                                                    padding:
                                                      const EdgeInsets.only(right: 10),
                                                    child: SingleProfile(
                                                      size: 24,
                                                      photoUrl: snapshot.data!.photoUrl,
                                                    ),
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
                                ? Container(
                                  constraints: BoxConstraints(
                                    minWidth: 36.w,
                                  ),
                                    height: 24,
                                    child: Center(
                                      child: Text("+${(agendaData[currentDate]![index].involved.length)- 6}",
                                        style: TextStyle(
                                          fontFamily: 'Spoqa',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Color(0xff5562FE)
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1, color: Color(0xff5562FE)),
                                      borderRadius: BorderRadius.circular(6)
                                    ),
                                )
                                : Container()

                            ]
                          )
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                    InkWell(
                      onTap: () {
                        final agendaMid = agendaData[currentDate]![index].MID;
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: Text('일정 추가'),
                                content: Text('내 일정에 추가하시겠습니까?'),
                                actions: <Widget>[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        child: Text(AppLocalizations.of(context)!.ok),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.black,
                                        ),
                                        onPressed: () async {
                                          DatabaseService(uid: user.uid).pullToMyCalendar(agendaMid);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text(
                                          AppLocalizations.of(context)!.cancel,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white70,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                ]),
                          );
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: 44,
                        child: Image.asset('assets/icons/calendar_add.png', width: 20, height: 20,)
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

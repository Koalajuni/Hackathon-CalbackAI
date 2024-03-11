import 'package:calendar/models/meeting.dart';
import 'package:calendar/models/user.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar/pages/monthly/monthly_custom_cell.dart';
import '../../services/database.dart';
import '../../shared/calendar_functions.dart';
import '../homepage/drawer_builder.dart';
import '../../custom_widgets/agenda_widget.dart';
import 'package:intl/intl.dart';

class Monthly extends StatefulWidget {
  const Monthly({Key? key}) : super(key: key);

  @override
  _MonthlyState createState() => _MonthlyState();
}

class _MonthlyState extends State<Monthly> {
  bool isSetUp = true;
  List<Meeting> passMeetings = [];
  DateTime selectedDate = dateOnly(DateTime.now());
  DateTime headerDate = dateOnly(DateTime.now());
  List selectedDateList = [];
  @override
  Widget build(BuildContext context) {
//-------------------- providers --------------------//
    final user = Provider.of<MyUser>(context);
    final eventProvider = Provider.of<EventMaker>(context, listen: false);
    return Scaffold(
      backgroundColor: Color(0xffF6F6F6),
      floatingActionButton: EventButton(),
//-------------------- app bar --------------------//
      appBar: AppBar(
        bottomOpacity: 0,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 50,
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.calendar,
            style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'Spoqa',
                fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      endDrawer: DrawerBuilder(),

//-------------------- body --------------------//
      body: SingleChildScrollView(
        child: StreamBuilder<List<Meeting>>(
            stream: DatabaseService(uid: user.uid).meetingsData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Meeting> meetingData = snapshot.data as List<Meeting>;
                
                MeetingDataSource dataSource = MeetingDataSource(snapshot.hasData
                  ? List<Meeting>.generate(((meetingData)).length, (index) {
                    return Meeting.filterContentForMonthly(((meetingData))[index]);
                  })
                  : []);

                Map<DateTime, List<Meeting>> agendaData =
                    getAgendaData(meetingData);
                return StatefulBuilder(builder: (context, setCalendar) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 12,),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffDAD9FE),
                              borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            width: double.infinity,
                            height: 40,
                            margin: EdgeInsets.symmetric(horizontal: 12),
                              child: Center(
                                child: Text("${headerDate.year}년 ${headerDate.month}월",
                                  style: TextStyle(
                                    fontFamily: 'Spoqa',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Color(0xff222222)
                                  ),
                                )
                              ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            height: 340.h,
                            //-------------------- Calendar --------------------//
                            child: SfCalendar(
                              onViewChanged: (ViewChangedDetails viewChangedDetails){
                                try {
                                  setCalendar((){
                                    headerDate = viewChangedDetails
                                    .visibleDates[viewChangedDetails.visibleDates.length ~/ 2];
                                  });
                                } catch (e) {}    
                              },
                              view: CalendarView.month,
                              backgroundColor: Color(0xffF6F6F6),
                              initialSelectedDate: selectedDate,
                              headerHeight: 0,
                              monthViewSettings: customMonthViewSettings(),
                              monthCellBuilder: customMonthCellBuilder,
                              dataSource: dataSource,
                              onTap: (details) {
                                setCalendar(() {
                                  selectedDate = dateOnly(details.date!);
                                  selectedDateList = details.appointments!;
                                });
                                
                                eventProvider.setDailyDate(details.date!);
                              },
                            ),
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
                          child: Text("${selectedDate.day}일",
                            style: TextStyle(
                              fontFamily: 'Spoqa',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Color(0xff222222)
                            ),
                          ),
                        )
                      ),
                      // Container(
                      //   height: 40,
                      //   color: Colors.white10,
                      //   alignment: Alignment.centerRight,
                      //   child: Column(
                      //     children: [
                      //       SizedBox(height: 5),
                      //       SizedBox(
                      //         height: 30,
                      //         child: ElevatedButton.icon(
                      //           onPressed: () async {
                      //             await Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => Weekly()),
                      //             );
                      //           },
                      //           style: ElevatedButton.styleFrom(
                      //             shape: new RoundedRectangleBorder(
                      //                 borderRadius:
                      //                     new BorderRadius.circular(10.0)),
                      //             primary: Colors.white,
                      //           ),
                      //           icon: Icon(Icons.calendar_view_week,
                      //               size: 24.0, color: Colors.black),
                      //           label:
                      //               Text(AppLocalizations.of(context)!.weekly,
                      //                   style: TextStyle(
                      //                     color: Colors.black,
                      //                     fontSize: 14,
                      //                     fontFamily: 'Roboto',
                      //                   )),
                      //         ),
                      //       ),
                      //       SizedBox(height: 5),
                      //     ],
                      //   ),
                      // ),
//-------------------- Agenda --------------------//
                      Agenda(
                          user: user,
                          meetingData: meetingData,
                          currentDate: selectedDate,
                          tapDetailsList: selectedDateList,)
                    ],
                  );
                });
              } else {
                print("snapshot.has data no data");
                return Column(
                        children: [
                          SizedBox(height: 12,),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffDAD9FE),
                              borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            width: double.infinity,
                            height: 40,
                            margin: EdgeInsets.symmetric(horizontal: 12),
                              child: Center(
                                child: Text("${headerDate.year}년 ${headerDate.month}월",
                                  style: TextStyle(
                                    fontFamily: 'Spoqa',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Color(0xff222222)
                                  ),
                                )
                              ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            height: 340,
                            //-------------------- Calendar --------------------//
                            child: SfCalendar(
                              view: CalendarView.month,
                              backgroundColor: Color(0xffF6F6F6),
                              initialSelectedDate: selectedDate,
                              headerHeight: 0,
                              monthViewSettings: customMonthViewSettings(),
                              monthCellBuilder: customMonthCellBuilder,

                            ),
                          ),
                        ],
                      );
              }
            }),
      ),
    );
  }
}

import 'package:calendar/pages/chatgpt_stuff/frontend/prompt_testing.dart';

import '../../../animations/animations.dart';
import '../../../models/userSchedule.dart';
import '../../daily/view/daily.dart';
import '../chat_dependencies.dart';
import 'package:intl/intl.dart';

import 'gpt_daily.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({Key? key, required this.chatApi}) : super(key: key);

  final ChatApi chatApi;

  @override
  State<ChatHome> createState() => _ChatHomeState();

  Future<List<List<String>>> midToText(List<Meeting> meetings) async {
  final meetingSchedule = meetings.map((meeting) =>
      [ '${DateFormat("MMMM d, yyyy 'at' h:mm a z").format(meeting.from)}',   '${DateFormat("MMMM d, yyyy 'at' h:mm a z").format(meeting.to)}',    meeting.content]).toList();
  print("These are all the meeting from the user $meetingSchedule");
  return meetingSchedule;
}
}

class _ChatHomeState extends State<ChatHome> {
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
        title: Text("GenAI캘린더",
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 50.h, width: 250.w,
                              child: TextButton(
                                onPressed: () async  { 
                                  final myMeetings = await DatabaseService(uid: user.uid).getMeetings();
                                  final meetingSchedule = await meetingsToText(myMeetings);
                                  print(meetingSchedule);
                                  final userSchedule = UserSchedule(profileUid: user.uid, schedule: meetingSchedule);
                                  DatabaseService(uid: user.uid).addUserSchedule(userSchedule);

                                  Navigator.push(context,
                                    CustomPageRoute(
                                      child: StreamProvider(
                                        create: (context) => DatabaseService(uid: user.uid).userData,
                                        initialData: MyUser(uid:user.uid),
                                        builder: (context, child) =>  GPTDaily(),
                                      ),
                                      direction: AxisDirection.up,
                                    )
                                );
                                  },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 125, 127, 212),
                                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(50.r)),
                                ),
                                child: Text(
                                  '캘박AI 일정 추천',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontFamily: 'PretendardVar',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                     
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 50.h, width: 250.w,
                              child: TextButton(
                                onPressed: () async  { 
                                  Navigator.push(context,
                                    CustomPageRoute(
                                      child: StreamProvider(
                                        create: (context) => DatabaseService(uid: user.uid).userData,
                                        initialData: MyUser(uid:user.uid),
                                        builder: (context, child) =>  Daily(),
                                      ),
                                      direction: AxisDirection.up,
                                    )
                                );
                                  },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xffF6F6F6),
                                  shape: RoundedRectangleBorder( 
                                    borderRadius: BorderRadius.circular(50.r), 
                                    side: BorderSide(color: Color.fromARGB(255, 180, 178, 178), width: 1.0),),
                                ),
                                child: Text(
                                  '일정 직접 추가',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 80, 78, 78),
                                    fontFamily: 'PretendardVar',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                         
                          ],
                        ),

                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 50.h, width: 250.w,
                              child: TextButton(
                                onPressed: () async  { 
                                  Navigator.push(context,
                                    CustomPageRoute(
                                      child: PromptTestingPage(),
                                      direction: AxisDirection.up,
                                    )
                                );
                                  },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xffF6F6F6),
                                  shape: RoundedRectangleBorder( 
                                    borderRadius: BorderRadius.circular(50.r), 
                                    side: BorderSide(color: Color.fromARGB(255, 180, 178, 178), width: 1.0),),
                                ),
                                child: Text(
                                  'Prompt 테스팅',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 80, 78, 78),
                                    fontFamily: 'PretendardVar',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                         
                          ],
                        ),
                        Divider(color: Color(0xffD9D9D9), thickness: 1,),
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
  Future<List<String>> meetingsToText(List<Meeting> meetings) async {
  final meetingSchedule = meetings.map((meeting) =>
      [  
        '${((meeting.from).toString()).substring(0,16)}',
        '${((meeting.to).toString()).substring(0,16)}',
        meeting.content]).toList();
  
  final List<String> meetingText = [];
  for (final meeting in meetingSchedule) {
    final String text = meeting.join(", ");
    meetingText.add(text);
  }
  
  print("These are all the meeting texts: $meetingText");
  return meetingText;
}
}

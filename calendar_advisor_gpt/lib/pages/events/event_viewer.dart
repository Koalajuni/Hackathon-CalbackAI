import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/daily/view_model/weekday_translator.dart';
import 'package:calendar/services/database.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'package:intl/intl.dart';
import '../../services/database.dart';
import 'package:calendar/models/meeting.dart';

class EventViewer extends StatefulWidget {
  final Meeting? event;
  final MyUser? myUser;
  final MyUser? otherUser;
  const EventViewer({
    Key? key,
    this.event,
    this.myUser,
    this.otherUser
  }) : super(key: key);

  @override
  _EventViewerState createState() => _EventViewerState();
}

class _EventViewerState extends State<EventViewer> {
  @override
  Widget build(BuildContext context) {
    ValueNotifier _addedFriends = ValueNotifier<List<String>>([]);
    String UID = Provider.of<MyUser?>(context)!.uid;
    
    final user = widget.myUser ?? Provider.of<MyUser>(context);
      
    final otherUser = widget.otherUser ?? Provider.of<MyUser>(context);

    final eventProvider = Provider.of<EventMaker>(context);
    final event = widget.event!;
    final involved = widget.otherUser != null
      ? otherUser.openPrivacy
        ? []
        : event.involved
      : user.openPrivacy
        ? []
        : event.involved;


    final titleController = TextEditingController();
    DateTime endDate = DateTime.now();
    DateTime startDate = DateTime.now();
    late Color currentColor;

    titleController.text = event.content;
    startDate = event.from;
    endDate = event.to;
    currentColor = event.background;
    final startTime = DateFormat("hh:mm a").format(startDate);
    final endTime = DateFormat("hh:mm a").format(endDate);
    final startDay = DateFormat("yy/MM/dd").format(startDate);
    final endDay = DateFormat("yy/MM/dd").format(endDate);

    String dayView;
    if (startDay == endDay) {
      dayView = startDay;
    } else {
      dayView = "${startDay} - ${endDay}";
    }

    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("${event.from.month}. ${event.from.day}. ${weekday2Korean(event.from.weekday)}요일",
            style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'Spoqa',
                fontWeight: FontWeight.w500)),
          centerTitle: true,
          bottomOpacity: 0,
          elevation: 0,
          backgroundColor: Colors.white,
          toolbarHeight: 74,
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 30,
          ),
          leading: BackButton(),
          actions: <Widget>[
            new InkWell(
              child: (event.owner == user!.uid)
                ? Icon(Icons.edit)
                : (involved.contains(user.uid)) 
                  ? Icon(Icons.exit_to_app_rounded)
                  : Container(
                        alignment: Alignment.centerLeft,
                        width: 44,
                        child: Image.asset('assets/icons/calendar_add.png', width: 20, height: 20,)
                      ),
              onTap: () async {
                if (event == null) {
                  return;
                } else {
                  if (event.owner == user.uid) {
                    // Enable edit if owner
                    await Navigator.push(
                      context,
                      CustomPageRoute(
                        child: StreamProvider<MyUser>(
                          create: (context) =>
                              DatabaseService(uid: user!.uid).userData,
                          initialData: MyUser(uid: user!.uid),
                          builder: (context, child) => Daily(meeting: event),
                        ),
                      ),
                    );
                  } else if (involved.contains(user.uid)) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!
                              .eventviewer_leaveEvent),
                          content: Text(
                            AppLocalizations.of(context)!
                                .eventviewer_leaveQuestion,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Roboto'),
                          ),
                          actions: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  child:
                                      Text(AppLocalizations.of(context)!.exit),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                  onPressed: () async {
                                    await DatabaseService(uid: user.uid)
                                        .leaveInvolvedMeetings(
                                            user.uid, event.MID);
                                    eventProvider.updateEventMaker(user.uid);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.white70,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ]),
                    );
                  } else {
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
                                          DatabaseService(uid: user.uid).pullToMyCalendar(event.MID);
                                          Navigator.of(context).pop();
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
                  }
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 64,
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 20),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Icon(Icons.brush, size: 15, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(event.content,
                      style: TextStyle(
                          color: Color(0xff222222),
                          fontSize: 18,
                          fontFamily: 'Spoqa',
                          fontWeight: FontWeight.w500,
                          height: 1
                      )
                  )
                ],
              )),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 64,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                  width: 1,
                                  color: Color(0xff888888)
                                ),
                              )
                            ),
                            child: Text(startTime,
                              style: TextStyle(
                                fontFamily: 'Spoqa',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color(0xff222222)
                              )
                            ),
                          )
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xffF6F6F6),
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                  width: 1,
                                  color: Color(0xff888888)
                                ),
                              )
                            ),
                            alignment: Alignment.center,
                            child: Text(endTime,
                              style: TextStyle(
                                fontFamily: 'Spoqa',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color(0xff222222)
                              )
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 ,
                    child: ClipPath(
                      child: Container(
                        width: 18,
                        height: 64,
                        color: Colors.white
                      ),
                      clipper: TriangleClipPath(),
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2,
                    child: CustomPaint(
                      painter: BorderPainter(),
                      child: Container(
                        width: 18,
                        height: 64,
                      ),
                    ),
                  )
                ],
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     border: Border(
              //       bottom: BorderSide(width: 1, color: Color(0xffD9D9D9))
              //     )
              //   ),
              //   height: 64,
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       SizedBox(width: 20),
              //       Container(
              //         width: 24,
              //         height: 24,
              //         decoration: BoxDecoration(
              //           color: currentColor,
              //           borderRadius: BorderRadius.all(Radius.circular(8)),
              //         ),
              //         child: Icon(Icons.replay, size: 16, color: Colors.white),
              //       ),
              //       SizedBox(width: 12),
              //       Text(event.recurrenceRule.toString().isEmpty ? '없음' : event.recurrenceRule.toString(),
              //           style: TextStyle(
              //               color: Color(0xff222222),
              //               fontSize: 16,
              //               fontFamily: 'Spoqa',
              //               fontWeight: FontWeight.w400,
              //           )
              //       )
              //     ],
              //   )
              // ),
           
            // TODO
            // Container(
            //     decoration: BoxDecoration(
            //       border: Border(
            //         bottom: BorderSide(width: 1, color: Color(0xffD9D9D9))
            //       )
            //     ),
            //     height: 64,
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       children: [
            //         SizedBox(width: 20),
            //         Container(
            //           width: 24,
            //           height: 24,
            //           decoration: BoxDecoration(
            //             color: currentColor,
            //             borderRadius: BorderRadius.all(Radius.circular(8)),
            //           ),
            //           child: Icon(Icons.person_add, size: 16, color: Colors.white),
            //         ),
            //         SizedBox(width: 12),
            //         Text('참가자',
            //             style: TextStyle(
            //                 color: Color(0xff222222),
            //                 fontSize: 16,
            //                 fontFamily: 'Spoqa',
            //                 fontWeight: FontWeight.w400,
            //             )
            //         )
            //       ],
            //     )
            //   ),
              // Container(
              //   decoration: BoxDecoration(
              //     border: Border(
              //       bottom: BorderSide(width: 1, color: Color(0xffD9D9D9))
              //     )
              //   ),
              //   height: 64,
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       SizedBox(width: 20),
              //       Container(
              //         width: 24,
              //         height: 24,
              //         decoration: BoxDecoration(
              //           color: currentColor,
              //           borderRadius: BorderRadius.all(Radius.circular(8)),
              //         ),
              //         child: Icon(Icons.person_add, size: 16, color: Colors.white),
              //       ),
              //       SizedBox(width: 12),
              //       Text('사진',
              //           style: TextStyle(
              //               color: Color(0xff222222),
              //               fontSize: 16,
              //               fontFamily: 'Spoqa',
              //               fontWeight: FontWeight.w400,
              //           )
              //       )
              //     ],
              //   )
              // ),
              SizedBox(height: 20,),
              Row(
                children: [
                  SizedBox(width: 22),
                  StreamBuilder<MyUser>(
                      stream: DatabaseService(uid: event.owner).userData,
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.data != null) {
                          MyUser? userData = snapshot.data;
                          return Padding(
                            padding: const EdgeInsets.all(1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SingleProfile(
                                    size: 60,
                                    photoUrl: snapshot.data!.photoUrl,
                                    borderSize: 2),
                                Text(userData!.name,
                                    style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          );
                        } else {
                          return Text("");
                        }
                      }),
                ],
              ),
              SizedBox(height: 20),
              
              (event.owner.substring(0, 4) == 'open') && 
                (((widget.otherUser != null) && (otherUser.openPrivacy == true)) || ((widget.otherUser == null) && (otherUser.openPrivacy == true)))
                ? SizedBox(height: 270.h)
                : Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 22),
                        Text(AppLocalizations.of(context)!.eventviewer_involved,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Text("(${involved.length})",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Container(
                          width: MediaQuery.of(context).size.width - 30,
                          child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: involved.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 10.0,
                              ),
                              itemBuilder: (BuildContext context, int index2) {
                                if (involved.isNotEmpty) {
                                  return StreamBuilder<MyUser>(
                                      stream:
                                          DatabaseService(uid: involved[index2])
                                              .userData,
                                      builder: (BuildContext context, snapshot) {
                                        if (snapshot.data != null) {
                                          MyUser? userData = snapshot.data;
                                          return Padding(
                                            padding: const EdgeInsets.all(1),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SingleProfile(
                                                    size: 60,
                                                    photoUrl: snapshot.data!.photoUrl,
                                                    borderSize: 0),
                                                SizedBox(
                                                    width: 80,
                                                    height: 20,
                                                    child: Center(
                                                        child: Text(userData!.name,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.black)))),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Text("");
                                        }
                                      });
                                } else {
                                  return Text("");
                                }
                              }),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(width: 22),
                        Text(
                            AppLocalizations.of(context)!.eventviewer_pendingInvolved,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Text("(${event.pendingInvolved.length})",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Container(
                          width: MediaQuery.of(context).size.width - 30,
                          child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: event.pendingInvolved.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 10.0,
                              ),
                              itemBuilder: (BuildContext context, int index2) {
                                if (event.pendingInvolved.isNotEmpty) {
                                  return StreamBuilder<MyUser>(
                                      stream: DatabaseService(
                                              uid: event.pendingInvolved[index2])
                                          .userData,
                                      builder: (BuildContext context, snapshot) {
                                        if (snapshot.data != null) {
                                          MyUser? userData = snapshot.data;
                                          return Padding(
                                            padding: const EdgeInsets.all(1),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SingleProfile(
                                                    size: 60,
                                                    photoUrl: snapshot.data!.photoUrl,
                                                    borderSize: 0),
                                                SizedBox(
                                                    width: 80,
                                                    height: 20,
                                                    child: Center(
                                                        child: Text(userData!.name,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.black)))),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Text("");
                                        }
                                      });
                                } else {
                                  return Text("");
                                }
                              }),
                        ),
                      ],
                    ), //GridView
                    SizedBox(height: 16),
                  ]
                ),

              (event.owner == user.uid)
                  ? Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                title:
                                    Text(AppLocalizations.of(context)!.delete),
                                actions: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .delete),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.black,
                                        ),
                                        onPressed: () async {
                                          final meeting = widget.event;
                                          eventProvider.deleteEvent(
                                              meeting!, UID);
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text(
                                          AppLocalizations.of(context)!.cancel,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white70,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ]),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.delete,
                            style: TextStyle(fontSize: 16)),
                      ),
                    )
                  : SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class TriangleClipPath extends CustomClipper<Path> {
  var radius=5.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, size.height/2);
    path.lineTo(0.0, size.height);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Color(0xff888888);
    Path path = Path();
//    uncomment this and will get the border for all lines
    path.lineTo(size.width, size.height/2);
    path.lineTo(0.0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
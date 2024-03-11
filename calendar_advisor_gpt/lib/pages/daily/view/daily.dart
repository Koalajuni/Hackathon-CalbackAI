import 'package:calendar/models/meeting.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/daily/view/children_widgets/popup_color_picker.dart';
import 'package:calendar/pages/daily/view/children_widgets/show_color_popup.dart';
import 'package:calendar/pages/daily/view/children_widgets/show_color_popup.dart';
import 'package:calendar/pages/daily/view_model/meeting_creator.dart';
import 'package:calendar/pages/daily/view_model/check_box_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../model/remote_database.dart';
import 'children_widgets/horizontal_date_widget.dart';
import 'children_widgets/circular_time_picker.dart';
import '../../../services/database.dart';
import '../../../shared/alert_dialog_error.dart';
import '../view_model/daily_functions.dart';
import 'children_widgets/popup_color_picker.dart';
import 'children_widgets/recurrent_picker.dart';


class Daily extends StatefulWidget {
  final Meeting? meeting;
  const Daily({Key? key, this.meeting}) : super(key: key);

  @override
  DailyState createState() => DailyState();
}

class DailyState extends State<Daily> {
  Map<String, CheckBoxState> checkbox = {};
  ValueNotifier _addedFriends = ValueNotifier<List<String>>([]);
  ValueNotifier tokens = ValueNotifier<List<String>>([]); 
  bool isEdit = false; //todo changes here
  final titleController = TextEditingController();
  bool needsUpdate = true;
  bool isSetUp = true;
  String formattedRecurrent = '반복';
  final showColorPopup colorPopup= showColorPopup();

  @override
  void initState() {
    super.initState();
    if (widget.meeting != null) {
      isEdit = true;
      final meeting = widget.meeting!;
      titleController.text = meeting.content;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void recurrentFormatted(String selectedString) {
    setState(() {
      if (selectedString == '') {
        formattedRecurrent = '반복';
      }
      
      else {
        formattedRecurrent = selectedString;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MeetingCreator>(
        create: ((context) => MeetingCreator()),
        child: Consumer<MeetingCreator>(
          builder: (context, meetingCreator, child) {
            final user = Provider.of<MyUser>(context);
            final eventProvider =Provider.of<EventMaker>(context, listen: false);
            if (isSetUp) {
              meetingCreator.setDailyDate(eventProvider.dailyDate, eventProvider.dailyDate);
              isSetUp = false;
            }
            if (isEdit && needsUpdate) {
              widget.meeting!.involved.forEach((element) {
                checkbox["${element}"] = CheckBoxState(friendUid: element, value: true);
                _addedFriends.value.add(element);
              });
              _addedFriends.notifyListeners();
              meetingCreator.changeColor(widget.meeting!.background, !isEdit);
              meetingCreator.setDailyDate(widget.meeting!.from, widget.meeting!.to);
              meetingCreator.setDailyTime( widget.meeting!.from.toString().substring(11, 16), widget.meeting!.to.toString().substring(11, 16));
              meetingCreator.setDailyAngles(convertToAngle(widget.meeting!.from.hour, widget.meeting!.from.minute),convertToAngle(widget.meeting!.to.hour, widget.meeting!.to.minute));
              meetingCreator.setRecurrenceRule(widget.meeting!.recurrenceRule!);
              needsUpdate = false;
            }
            return Dismissible(
              direction: DismissDirection.horizontal,
              key: const Key('key'),
              onDismissed: (_) => Navigator.of(context).pop(),
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(80),
                  child: AppBar(
                      shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
                      automaticallyImplyLeading: false,
                      bottomOpacity: 0,
                      elevation: 4,
                      backgroundColor: Colors.white,
                      toolbarHeight: 30,
                      iconTheme: IconThemeData(
                        color: Colors.black,
                        size: 30,
                      ),
                      flexibleSpace: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 13, 0, 13),
                                  child: IconButton(padding: EdgeInsets.zero, iconSize: 20, icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                                    onPressed: () => Navigator.of(context).pop(),),
                                ),
                                Text(AppLocalizations.of(context)!.daily_top,
                                style: TextStyle(fontSize: 18, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color.fromRGBO(34, 34, 34, 1)),)
                              ],
                            ),
                          ],
                        ),
                      )
                      ),
                ),
                resizeToAvoidBottomInset: true,
                body: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // const SizedBox(height: 5),
                          Stack(
                            children: [
                              CircularTimePicker(isEdit: isEdit),
                              Positioned( left: 10.w, top: 324.h,
                                child: CustomPaint(
                                  painter: colorPopup,
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    child: Text("색을 변경할 수 있어요!",
                                        style: TextStyle( fontSize: 8.sp, fontFamily: 'Spoqa', fontWeight: FontWeight.w400, color: Colors.white,)),
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
                          Container(
                            height: 58,
                            color: meetingCreator.color.withOpacity(0.2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 20),
                              PopupColorPicker(),
                                const SizedBox(width: 16),
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(height: 38, width: 300),
                                  child: TextFormField(
                                    style: TextStyle( fontSize: 16, fontFamily: 'Spoqa', fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: const EdgeInsets.fromLTRB(0, 6, 2, 0),
                                      isDense: true, // this allows txt input to be well input without getting cut
                                      hintText: AppLocalizations.of(context)!.daily_eventName,
                                    ),
                                    onFieldSubmitted: (_) => {},
                                    validator: (content) => content != null && content.isEmpty ? 'content cannot be empty': null,
                                    controller: titleController,
                                  ),
                                ),
                              ],
                            ),
                          ), // Color change Button & Event Title
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => showDialog(
                                context: navigatorKey.currentContext!,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                            StateSetter setDialog) =>
                                            Stack(
                                              children: [
                                                Positioned( left: 10, right: 10, top: 172 , 
                                                  child: AlertDialog(
                                                    contentPadding:EdgeInsets.only(top: 10.0),  // 좌우 20 
                                                      shape: RoundedRectangleBorder(
                                                  side: BorderSide( color: Color.fromRGBO(85, 98, 254, 1),
                                                  ),
                                                  borderRadius: BorderRadius.circular(16.0),
                                                ),
                                                scrollable: true,
                                                // todo change to calback friends
                                                content: Container( height: 400, width: MediaQuery.of(context).size.width ,
                                                  child: Column(
                                                    mainAxisAlignment:MainAxisAlignment.start,
                                                    crossAxisAlignment:CrossAxisAlignment.stretch,
                                              children: [
                                                  SizedBox( height: 56, width: 296,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 15),
                                                        Container( height: 30, width: 30,
                                                          decoration: BoxDecoration(
                                                            color: Color.fromRGBO(
                                                                136, 136, 136, 1),
                                                            borderRadius:BorderRadius.all(Radius.circular(8),),
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Container( height: 20, width: 20,
                                                            decoration: BoxDecoration(
                                                              color:Colors.transparent,
                                                              borderRadius:BorderRadius.all(Radius.circular(8)),
                                                              image: DecorationImage(
                                                                image: AssetImage('assets/icons/add_friend.png'),
                                                                fit: BoxFit.fill,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(AppLocalizations.of(context)!.daily_friendPopUp, 
                                                          style: TextStyle(fontSize: 18,fontFamily: 'Spoqa'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox( height: 280,
                                                    child: ListView.separated( shrinkWrap: true,
                                                        itemCount: user.friends.length,
                                                        itemBuilder:(BuildContext context,int index) {
                                                          return StreamBuilder<MyUser>(
                                                              stream: DatabaseService(uid:user.friends[index]).userData,
                                                              builder: (context,snapshot) {
                                                                if (snapshot.hasData) {
                                                                  MyUser? userData =snapshot.data;
                                                                  if (checkbox["${userData!.uid}"] ==null) {
                                                                    checkbox["${userData!.uid}"] = CheckBoxState(
                                                                        friendName: userData.name,
                                                                        friendUid:userData.uid,
                                                                        friendEmail:userData.email);
                                                                  } else {
                                                                    checkbox["${userData!.uid}"]!.friendName = userData.name;
                                                                    checkbox["${userData!.uid}"]!.friendEmail = userData.email;
                                                                  }
                                                                  return CheckboxListTile(
                                                                    activeColor: Color.fromRGBO( 85,98,254,1),
                                                                    side: BorderSide(color: Color.fromRGBO(85,98,254,1)),
                                                                    value: checkbox[ "${userData!.uid}"]!.value,
                                                                    onChanged:(value) {
                                                                      setDialog(() {
                                                                        checkbox["${userData!.uid}"]!.value =value!;
                                                                        if (value) {
                                                                          _addedFriends.value.add(userData.uid);
                                                                          tokens.value.add(userData.token);
                                                                          print("This is the token ${userData?.token}");
                                                                        } else if (value ==false) {
                                                                          _addedFriends.value.remove(userData.uid);
                                                                          tokens.value.remove(userData.token);
                                                                          print("This is the token ${userData?.token}");
                                                                          }
                                                                        _addedFriends.notifyListeners();
                                                                        tokens.notifyListeners();
                                                                      });
                                                                    },
                                                                    title: Row(
                                                                        children: <Widget>[
                                                                          SingleProfile(size: 32, photoUrl: snapshot.data!.photoUrl, borderSize: 1),
                                                                          SizedBox(width: 15),
                                                                          Text(checkbox["${userData!.uid}"]!.friendName, style: TextStyle(fontSize: 14,fontFamily: 'Spoqa'),),
                                                                          Spacer(),
                                                                        ]),
                                                                  );
                                                                } else {
                                                                  return Container();
                                                                }
    
                                                              });
                                                        },
                                                        separatorBuilder:(BuildContext context,int index) => const Divider(height: 0)),),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          child: Container(width: 147,
                                                            padding: EdgeInsets.only(top: 19.0,bottom: 18.0),
                                                            decoration: BoxDecoration(
                                                              color: Color.fromRGBO(218, 217, 254, 1),
                                                              border: Border.all(color: Color.fromRGBO(85, 98, 254, 1), width: 1),
                                                              borderRadius:BorderRadius.only(bottomLeft:Radius.circular(16.0),
                                                              ),
                                                            ),
                                                            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle( color: Color.fromRGBO(94, 92, 236, 1)),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          onTap: () =>Navigator.of(context).pop(),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                            child: Container( width: 147,
                                                              padding: EdgeInsets.only( top: 20.0,bottom: 18.0),
                                                              decoration: BoxDecoration(
                                                                color: Color.fromRGBO(130, 129, 250, 1),
                                                                border: Border.all(color:Color.fromRGBO(85,98,254,100),width: 1),
                                                                borderRadius:BorderRadius.only(bottomRight: Radius.circular(16.0),
                                                                ),
                                                              ),
                                                              child: Text( AppLocalizations.of( context)!.ok,
                                                                style: TextStyle(color: Colors.white,fontSize: 16),
                                                                textAlign:TextAlign.center,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              setState(() {});
                                                              Navigator.of(context).pop();
                                                            }),
                                                      ),
                                                    ],
                                                  ),
                                                 ],
                                                ),
                                                ),
                                              ),
                                                ),
                                              ],
                                            ),
                                  );
                                }),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                              height: _addedFriends.value.length == 0 ? 48 : 75,
                              color: Color.fromRGBO(247, 247, 247, 1),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.zero,
                                    child: Row( mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(width: 20),
                                        SizedBox(height: 24, width: 24,
                                            child: Container(decoration: BoxDecoration(
                                                    borderRadius:BorderRadius.circular(8),
                                                    color:meetingCreator.color),
                                                padding: EdgeInsets.zero,
                                                child: Icon(Icons.person_add, size: 16, color: Colors.white,
                                                ))),
                                        SizedBox(width: 16),
                                        ValueListenableBuilder( valueListenable: _addedFriends,
                                            builder: (context, value, child) {
                                              return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [_addedFriends.value.length == 0? Container(
                                                            padding: EdgeInsets.fromLTRB( 0, 3, 0, 0),
                                                            width: MediaQuery.of(context).size .width -180,
                                                            child: Text(
                                                              AppLocalizations.of(context)!.friend_addFriend,
                                                              style: TextStyle(
                                                                fontSize: 16,fontFamily:'Spoqa',fontWeight:FontWeight .w400,
                                                                color: Color.fromRGBO(136,136,136,1))),): Container(height: 75, width: MediaQuery.of(context).size.width -180,
                                                            child: ListView.separated(
                                                              shrinkWrap: true,
                                                              scrollDirection:Axis.horizontal,
                                                              itemCount: _addedFriends.value.length,
                                                              itemBuilder:(BuildContext context,int index) {
                                                                return StreamBuilder<MyUser>(
                                                                    stream: DatabaseService( uid: _addedFriends.value[ index]).userData,
                                                                    builder:(context,snapshot) {
                                                                      if (snapshot.hasData) {
                                                                        MyUser?userData =snapshot.data;
                                                                        return Column(
                                                                          mainAxisAlignment:MainAxisAlignment.start,
                                                                          children: [
                                                                            SingleProfile(size: 32, photoUrl: userData!.photoUrl != '' ? userData.photoUrl : null),
                                                                            SizedBox(height: 6,
                                                                            ),
                                                                            Text(userData.name, style: TextStyle(fontSize: 10, fontFamily: 'Spoqa', fontWeight: FontWeight.w400, color: Color.fromRGBO(34, 34, 34, 1),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        );
                                                                      } else {
                                                                        return CircularProgressIndicator();
                                                                      }
                                                                    });
                                                              },
                                                              separatorBuilder:
                                                                  (_, __) {
                                                                return SizedBox(width: 12);
                                                              },
                                                            ),
                                                          ),
                                                  ]);
                                            }),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:CrossAxisAlignment.center,
                                    children: [
                                      _addedFriends.value.length == 0 ? Container(width: 0, height: 0) : Padding(
                                              padding:const EdgeInsets.fromLTRB(0, 2, 0, 0),
                                              child: Row(
                                                children: [
                                                  Text("${_addedFriends.value.length}",style: TextStyle(fontSize: 14, fontFamily: 'Spoqa', fontWeight:FontWeight.w700, color: meetingCreator.color),),
                                                  Text(AppLocalizations.of(context)!.ok, style: TextStyle(fontSize: 14, fontFamily: 'Spoqa',fontWeight: FontWeight.w500, color: meetingCreator.color),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Icon(Icons.arrow_forward_ios, size: 16, color: _addedFriends.value.length == 0 ? Color.fromRGBO(136, 136, 136, 1) : meetingCreator.color))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ), // Add Friends Button
                          const SizedBox(height: 8),
                          InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) 
                                => RecurrentPicker(meetingProv: meetingCreator, recurrentFormattedCallback: recurrentFormatted))
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                height: 48,
                                color: Color.fromRGBO(247, 247, 247, 1),
                                child: Row(
                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        SizedBox(height: 24, width: 24,
                                            child: Container(
                                                decoration: BoxDecoration( borderRadius:BorderRadius.circular(8),color: meetingCreator.color),
                                                padding: EdgeInsets.zero,
                                                child: Icon(Icons.replay, size: 16, color: Colors.white,))),
                                        SizedBox(width: 16),
                                        Text(formattedRecurrent, style: TextStyle(fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w400,  color: Color.fromRGBO(136, 136, 136, 1),), )
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 16,color: _addedFriends.value.length == 0 ? Color.fromRGBO(136, 136, 136, 1) : meetingCreator.color),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: SizedBox(height: 60, width: 168,
                                  child: TextButton(
                                    onPressed: () {
                                      if (meetingCreator.errorMsg.isEmpty) {
                                        saveForm(
                                            widget.meeting,
                                            titleController.text,
                                            user.uid,
                                            meetingCreator.color,
                                            _addedFriends.value,
                                            isEdit,
                                            meetingCreator.dailyDate,
                                            meetingCreator.dailyAngles,
                                            meetingCreator.recurrenceRule,
                                            user.name,
                                            tokens.value,
                                            );
                                      } else {
                                        showAlertDialog(context, meetingCreator.errorMsg);
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: meetingCreator.color.withOpacity(0.3),
                                      side: BorderSide( width: 1, color: meetingCreator.color),
                                      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(0)),
                                      minimumSize: Size(50, 40),),
                                    child: Text(AppLocalizations.of(context)!.add,
                                      style: TextStyle(color: meetingCreator.color,
                                      ),
                                    ),
                                  ),
                                ),
                              ), ],
                          ),
                        SizedBox(height: 20)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}


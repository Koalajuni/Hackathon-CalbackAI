import 'package:calendar/models/user.dart';
import 'package:calendar/pages/daily/view_model/check_box_state.dart';
import 'package:calendar/pages/daily/view_model/recurrent_byweek.dart';
import 'package:calendar/pages/group/group_time_final.dart';
import 'package:calendar/pages/group/choose_preference_week.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/services_kakao/kakao_link_with_dynamic_link.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/daily/view_model/color_picker.dart';
import 'package:intl/intl.dart';
import 'package:calendar/shared/globals.dart' as globals;

import 'package:calendar/models/meeting.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../shared/alert_dialog_error.dart';
import '../../shared/calendar_functions.dart';

class GroupTime extends StatefulWidget {
  GroupTime({Key? key, this.event}) : super(key: key);
  final Meeting? event;

  @override
  State<GroupTime> createState() => _GroupTimeState();
}

class _GroupTimeState extends State<GroupTime> {
  Map<String, CheckBoxState> checkbox = {};
  ValueNotifier _addedFriends = ValueNotifier<List<String>>([]);

  final uiSettingColor = ColorSetting();
  final uiSettingFont = FontSetting();
  final colorPalette = ColorPalette();
  final titleController = TextEditingController();

  String dropdownValue = 'This week';
  List<Meeting> meetings = [];

  // for adding for more than one days
  DateTime defDate = DateTime.now();
  late DateTime startDate = defDate;
  late DateTime endDate = defDate;
  Color resetColor = Color.fromRGBO(106, 103, 172, 1);
  get dateWithNoTimeEnd =>
      DateFormat('yyyy-MM-dd').format(endDate.add(Duration(days: 1)));
  get dateWithNoTimeStart => DateFormat('yyyy-MM-dd').format(startDate);
  get dateWithTimeStart => DateFormat('hh:mm').format(startDate);
  get dateWithTimeEnd => DateFormat('hh:mm').format(endDate);

  /*
  void dropdownTimeCallback(String newDropdownTimeValue) {
    print('Current end date: $endDate');

    setState(() {
      if (newDropdownTimeValue == 'This week') {
        dropdownValue = newDropdownTimeValue;
        endDate = startDate.add(Duration(days: 7));
      }

      else { // When dropdown value is 'Next week'
        dropdownValue = newDropdownTimeValue;
        endDate = startDate.add(Duration(days: 14));
      }
    });
    
    if (meetings.isEmpty == false) {
      meetings.removeLast();
    }

    meetings.add(Meeting(
      owner: '',
      MID: '',
      content: '',
      from: startDate,
      to: endDate,
      background: ColorSetting().minimal_1,
      isAllDay: false,
      involved: [],
      recurrenceRule: RecurrentState.selectedTextForm,
    ));
    print('New end date: $endDate');
  }
  */

  MeetingDataSource _getDataSource(List<Meeting> source) {
    return MeetingDataSource(source);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event != null) {
      widget.event!.involved.forEach((element) {
        _addedFriends.value.add(element);
      });
    }
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
            iconTheme: IconThemeData(color: Colors.black),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            leading: BackButton(),
            elevation: 0.0,
            title: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                AppLocalizations.of(context)!.group_time,
                style: TextStyle(
                  fontSize: 22,
                  color: Color.fromARGB(255, 50, 50, 50),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          body: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 6),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Text(
                        AppLocalizations.of(context)!
                            .group_requestAvailableTime,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(height: 10),
                    // dropdownTime(dropdownTimeCallback),
                    SfCalendar(
                        view: CalendarView.month,
                        dataSource: _getDataSource(meetings),
                        onTap: (CalendarTapDetails details) {
                          if (details.date!.isAtSameMomentAs(endDate)) {
                            startDate = details.date!;
                            endDate = details.date!;
                          }

                          if (details.date!.isAtSameMomentAs(startDate)) {
                            startDate = details.date!;
                            endDate = details.date!;
                          } else if (details.date!.isAfter(startDate)) {
                            endDate = details.date!;
                          } else if (details.date!.isBefore(startDate)) {
                            startDate = details.date!;
                            endDate = details.date!;
                          }

                          if (meetings.isNotEmpty) {
                            meetings.removeLast();
                          }

                          meetings.add(Meeting(
                            owner: '',
                            MID: '',
                            content: '',
                            from: startDate,
                            to: endDate,
                            background: ColorSetting().minimal_1,
                            isAllDay: true,
                            involved: [],
                            recurrenceRule:
                                RecurrentByWeekState.selectedTextForm,
                          ));

                          print('Selected time: $startDate //// $endDate');
                          setState(() {});
                        }),
                    SizedBox(height: 25),
                    Divider(),
                    SizedBox(height: 40),
                    colorPicker(),
                    SizedBox(height: 40),
                    // Row(
                    //   children: [
                    //     TextButton.icon(
                    //       icon: Icon(
                    //         Icons.location_on,
                    //         color: Colors.black,
                    //         size: 35
                    //       ),
                    //       onPressed: () {},
                    //       label: Row(
                    //         children: const [
                    //           Text(
                    //             'Select location',
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               fontFamily: 'Roboto-Regular',
                    //               color: Color.fromRGBO(178, 171, 168,1),
                    //             )
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ]
                    // ),
                    SizedBox(height: 70),
                    createButton(),
                  ]))),
    );
  }

// ------------------------------------
  Widget createButton() {
    return Center(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 33, 11, 1),
            fixedSize: Size(170, 55),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0)),
          ),
          //style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 25)),
          child: Text(AppLocalizations.of(context)!.invite),
          onPressed: () {
            shareGroupTimeRequest(
                titleController.text,
                '$dateWithNoTimeStart $dateWithTimeStart',
                '$dateWithNoTimeEnd $dateWithTimeEnd');
          }),
    );
  }

  shareGroupTimeRequest(
      String controllerContent, String startDate, String endDate) {
    final user = Provider.of<MyUser>(context, listen: false);
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return SimpleDialog(
              title: Text(controllerContent),
              contentPadding: EdgeInsets.only(left: 20),
              children: <Widget>[
                SizedBox(height: 15),
                Text(startDate,
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(endDate,
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage('assets/icons/app_icon.png'),
                            fit: BoxFit.fill,
                          ),
                        )),
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(46, 46, 46, 1),
                        fixedSize: Size(170, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)),
                      ),
                      //style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 25)),
                      child: Text(
                        AppLocalizations.of(context)!.group_calbackShare,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        friendChecklist();
                      },
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/icons/kakao_logo.png'),
                            fit: BoxFit.fitHeight,
                          ),
                        )),
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(251, 226, 0, 1),
                        fixedSize: Size(170, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)),
                      ),
                      //style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 25)),
                      child:
                          Text(AppLocalizations.of(context)!.group_kakaoShare,
                              style: TextStyle(
                                color: Colors.black,
                              )),
                      onPressed: () {
                        saveGroupForm(user.uid, colorPalette.pickerColor,
                            _addedFriends.value, true);
                      },
                    )
                  ],
                ),
                SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 33, 11, 1),
                      fixedSize: Size(170, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)),
                    ),
                    //style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 25)),
                    child: Text(AppLocalizations.of(context)!.send),
                    onPressed: () {
                      saveGroupForm(user.uid, colorPalette.pickerColor,
                          _addedFriends.value, false);
                    },
                  ),
                ),
                SizedBox(height: 30)
              ]);
        });
  }

  friendChecklist() {
    final user = Provider.of<MyUser>(context, listen: false);
    showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialog) =>
                AlertDialog(
                    scrollable: true,
                    title: Text(AppLocalizations.of(context)!.friends),
                    content: SizedBox(
                      height: 300,
                      width: double.maxFinite,
                      child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: user.friends.length,
                          itemBuilder: (BuildContext context, int index) {
                            return StreamBuilder<MyUser>(
                                stream:
                                    DatabaseService(uid: user.friends[index])
                                        .userData,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    MyUser? userData = snapshot.data;
                                    if (checkbox["${userData!.uid}"] == null) {
                                      checkbox["${userData!.uid}"] =
                                          CheckBoxState(
                                              friendName: userData.name,
                                              friendUid: userData.uid,
                                              friendEmail: userData.email);
                                    }
                                    return CheckboxListTile(
                                      value:
                                          checkbox["${userData!.uid}"]!.value,
                                      onChanged: (value) {
                                        setDialog(() {
                                          print("Setting State");
                                          print(checkbox["${userData!.uid}"]!
                                              .value);
                                          checkbox["${userData!.uid}"]!.value =
                                              value!;
                                          if (value) {
                                            _addedFriends.value
                                                .add(userData.uid);
                                          } else if (value == false) {
                                            _addedFriends.value
                                                .remove(userData.uid);
                                          }
                                          _addedFriends.notifyListeners();
                                        });
                                      },
                                      title: Row(children: <Widget>[
                                        CircleAvatar(
                                            radius: 27.0,
                                            backgroundImage: userData!
                                                        .photoUrl !=
                                                    ''
                                                ? CachedNetworkImageProvider(
                                                    userData!.photoUrl)
                                                : null),
                                        SizedBox(width: 15),
                                        Text(checkbox["${userData!.uid}"]!
                                            .friendName),
                                        Spacer(),
                                      ]),
                                    );
                                  } else {
                                    return Container();
                                  }
                                });
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                                height: 15,
                              )),
                    ),
                    actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                    child: Text(AppLocalizations.of(context)!.friend_addFriend),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]),
          );
        });
  }

  Future saveGroupForm(String uid, Color pickerColor, List<String> addedFriends,
      bool isKakaoShare) async {
    String mid = "pending${DateTime.now().toString().replaceAll(" ", "")}$uid";

    final event = Meeting(
      owner: uid,
      MID: mid,
      content: titleController.text,
      from: startDate,
      to: endDate.add(Duration(days: 1)),
      background: pickerColor,
      isAllDay: false,
      involved: [],
      recurrenceRule: RecurrentByWeekState.selectedTextForm,
    );

    final eventProvider = Provider.of<EventMaker>(context, listen: false);
    if (dateTimeFilter(startDate) == dateTimeFilter(endDate) ||
        dateTimeFilter(endDate).isBefore(dateTimeFilter(startDate))) {
      showAlertDialog(
          context, AppLocalizations.of(context)!.invalid_time_error);
    } else {
      await DatabaseService(uid: uid).updatePendingTime(uid, mid);
      if (addedFriends.isNotEmpty) {
        addedFriends.forEach((friend) {
          DatabaseService(uid: uid).sendMeetReq(uid, friend, mid);
        });
      }
      eventProvider.addEvent(event, uid);
      globals.bnbIndex = 2;
      Map<String, dynamic> pendingInstance =
          await DatabaseService(uid: uid).getPendingTime(mid);
      if (isKakaoShare) {
        String link =
            await KakaoLinkWithDynamicLink().buildDynamicLinkPendMeet(event);
        KakaoLinkWithDynamicLink().isKakaotalkInstalled().then((installed) {
          if (installed) {
            print("//////link ${link}");
            KakaoLinkWithDynamicLink().shareMyCodePendMeet(event, link);
          } else {
            ShareClient.instance.shareScrap(url: link);
          }
        });
      }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreferredWeekly(
                meeting: event, pendingMeeting: pendingInstance),
          ));
    }
  }

  Widget colorPicker() {
    return Row(children: [
      const SizedBox(width: 10),
      SizedBox(
        height: 24,
        width: 24,
        child: ElevatedButton(
            onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title:
                            Text(AppLocalizations.of(context)!.daily_colorPick),
                        content: SingleChildScrollView(
                          child: Column(children: [
                            ColorPicker(
                              pickerColor: colorPalette.pickerColor,
                              onColorChanged: colorPalette.changeColor,
                            ),
                            BlockPicker(
                              pickerColor: colorPalette.pickerColor,
                              availableColors: [
                                uiSettingColor.minimal_1,
                                uiSettingColor.minimal_2,
                                uiSettingColor.minimal_3,
                                uiSettingColor.minimal_4,
                                uiSettingColor.minimal_5
                              ],
                              onColorChanged: colorPalette.changeColor,
                            ),
                          ]),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text(AppLocalizations.of(context)!.ok),
                            onPressed: () {
                              colorPalette
                                  .changeColor(colorPalette.pickerColor);
                              Navigator.of(context).pop();
                              setState(() {});
                            },
                          ),
                        ]);
                  },
                ),
            style: ElevatedButton.styleFrom(
                primary: colorPalette.pickerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )),
            child: null),
      ),
      SizedBox(width: 15),
      ConstrainedBox(
        constraints: BoxConstraints.tightFor(height: 30, width: 300),
        child: TextFormField(
          style: TextStyle(fontSize: 17),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.daily_eventName,
          ),
          onFieldSubmitted: (_) => {},
          validator: (content) => content != null && content.isEmpty
              ? 'Name cannot be empty'
              : null,
          controller: titleController,
        ),
      ),
    ]);
  }

  dropdownTime(Function callback) {
    DateTime currentTime = DateTime.now();

    List<String> list = ['This week', 'Next week'];

    return DropdownButton(
      value: dropdownValue,
      items: list.map((String value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });

        callback(dropdownValue);
      },
    );
  }

/*
  Widget buildDateTimePickers() => Column(
        children: [
          Divider(),
          buildFrom(),
          SizedBox(height: 20),
          Divider(),
          buildTo(),
        ],
      );

  Widget buildFrom() => buildHeader(
    header: AppLocalizations.of(context)!.daily_start,
    child:   Row(
        children:[
          Expanded(
            flex: 1,
            child: buildDropdownField(
              text: dateWithNoTimeStart,
              onClicked: () => pickFromDateTime(pickDate: true),
            ),
          ),
          Expanded(
            child: buildDropdownField(
              text: dateWithTimeStart,
              onClicked: () => pickFromDateTime(pickDate: false),
            ),
          ),
        ]),
      );

  Widget buildTo() => buildHeader(
    header: AppLocalizations.of(context)!.daily_end,
    child:   Row(
        children:[
          Expanded(
            flex: 1,
            child: buildDropdownField(
              text: dateWithNoTimeEnd,
              onClicked: () => pickToDateTime(pickDate: true),
            ),
          ),
          Expanded(
            child: buildDropdownField(
              text: dateWithTimeEnd,
              onClicked: () => pickToDateTime(pickDate: false),
            ),
          ),
        ]),
      );

  Widget buildDropdownField({
    required String text,
    required VoidCallback onClicked,
  }) =>
      ListTile(
        title: Text(text),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  Widget buildHeader({
    required String header,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: TextStyle(fontWeight: FontWeight.bold)),
          child,
        ],
      );

  Future pickFromDateTime({required bool pickDate}) async {
    final holdingDate = (await pickDateTime(startDate, pickDate: pickDate))!;
    if (holdingDate == null) return;

    if (holdingDate.isAfter(endDate)) {
      endDate = DateTime(holdingDate.year, holdingDate.month, holdingDate.day,
          endDate.hour, endDate.minute);
    }

    setState(() => startDate = holdingDate);
    print(endDate);
  }

  Future pickToDateTime({required bool pickDate}) async {
    final holdingDate = (await pickDateTime(
      endDate,
      pickDate: pickDate,
      firstDate: pickDate ? startDate : null,
    ))!;
    if (holdingDate == null) return;
    setState(() => endDate = holdingDate);
    print(endDate);
  }

  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,
  }) async {
    if (pickDate) {
      final holdingDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(215, 8),
        lastDate: DateTime(2101),
      );
      if (holdingDate == null) return null;
      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);
      return holdingDate.add(time);
      // print(date.add(time));
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (timeOfDay == null) return null;

      final holdingDate =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);

      return holdingDate.add(time);
      // print(date.add(time));
    }
  }
*/
}

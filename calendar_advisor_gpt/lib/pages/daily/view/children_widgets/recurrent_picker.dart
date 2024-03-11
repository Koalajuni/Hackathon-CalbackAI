import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';

import '../../view_model/meeting_creator.dart';
import '../../view_model/recurrent_picker/recurrence_string_daily.dart';
import '../../view_model/recurrent_picker/recurrent_functions.dart';
import 'recurrent_picker/end_date_picker.dart';
import 'recurrent_picker/recurrence_type_selector.dart';
import '../../view_model/recurrent_picker/recurrence_widget_pathing.dart';

class RecurrentPicker extends StatefulWidget {
  late final MeetingCreator meetingProv;
  late final Function recurrentFormattedCallback;

  RecurrentPicker({Key? key, required this.meetingProv, required this.recurrentFormattedCallback}) : super(key: key);

  @override
  State<RecurrentPicker> createState() => _RecurrentPickerState();
}

class _RecurrentPickerState extends State<RecurrentPicker> {
  late bool endDateState;
  late String recurrenceType;
  late DateTime endDate;

  late List<String> weeklyDays;
  late DateTime yearlyDate;

  void endDateStateCallback(bool checkBoxState) {
    setState(() {
      endDateState = checkBoxState;
    });
  }

  void recrrCallback(String rType) {
    setState(() {
      recurrenceType = rType;
    });
  }

  void endDateCallback(DateTime pickedDate) {
    setState(() {
      endDate = pickedDate;
    });
  }

  void weeklyPick(List<String> pickedDays) {
    setState(() {
      weeklyDays = pickedDays;
    });

    print(weeklyDays);
  }

  void yearlyPick(DateTime pickedDate) {
    setState(() {
      yearlyDate = pickedDate;
    });
  }

  @override

  void initState() {
    super.initState();
    endDateState = false;
    recurrenceType = '';
    endDate = widget.meetingProv.dailyDate[0];

    weeklyDays = [];
  }

  Widget build(BuildContext context) {
    final meetingCreator = widget.meetingProv;

    return Scaffold(
      appBar: AppBar(
        shadowColor: Color.fromRGBO(0, 0, 0, 0.1),
        automaticallyImplyLeading: false,
        bottomOpacity: 0,
        elevation: 4,
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        leading: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 13, 0, 13),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                  ),
                ),
                Text(
                  "반복",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Spoqa',
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(34, 34, 34, 1)),
                )
              ],
            ),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecurrenceTypeSelector(callback: recrrCallback),
          Padding(
            padding: EdgeInsets.only(top: 9.0, left: 14.0),
            child: Text(
              '일정 반복 : ${recurrenceString(recurrenceType, !endDateState, endDate, weeklyDays)}',
              style: TextStyle(
                fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color(0xFF888888)
              ),
            ),
          ),
          Divider(thickness: 1.0, color: Color(0xFF555555)),
          SizedBox(
            height: 530,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                weeklyPickerToggle(weeklyPick, recurrenceType),
                endDatePickerToggle(endDateStateCallback, endDateState, recurrenceType),
                endDateLogic(endDateCallback, recurrenceType, endDateState, endDate),
              ],
            )
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 320,
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      fontSize: 16, fontFamily: 'Spoqa', fontWeight: FontWeight.w700
                    ),
                    foregroundColor: Color.fromARGB(255, 255, 255, 255),
                    backgroundColor: Color(0xBF5562FE),
                  ),
                  onPressed: () {
                    meetingCreator.setRecurrenceRule(
                      RecurrentFunctions(
                        rType: recurrenceType, endDate: endDate, isDefault: !endDateState, 
                        weekDays: weeklyDays, dailyDate: meetingCreator.dailyDate[0]
                        ).recurrentPath()
                    );
                    print(meetingCreator.recurrenceRule);

                    widget.recurrentFormattedCallback(recurrenceString(recurrenceType, !endDateState, endDate, weeklyDays));
                    Navigator.of(context).pop();
                  },
                  child: Text('반복 등록하기')
                ),
              ),
            ],
          ),
          
        ]
      ),
    );
  }
}
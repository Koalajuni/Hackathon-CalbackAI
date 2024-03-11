import 'dart:io';

import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/events/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/single_child_widget.dart';
import '../../view_model/color_picker.dart';
import '../../../../shared/calendar_functions.dart';

class RollingTimePicker extends StatefulWidget {
  final String time;

  // bool isEdit;
  RollingTimePicker({
    Key? key,
    required this.time,
  }) : super(key: key);

  @override
  State<RollingTimePicker> createState() => _RollingTimePickerState();
}

class _RollingTimePickerState extends State<RollingTimePicker> {
  bool _value = false;
  DateTime time = DateTime(2016, 5, 10, 22, 35);

  Future<Widget> _showDatePicker(context, time) async {
    // DateTime _chosenTime = DateTime.parse('2020-01-02' + selectedTime);
    DateTime? _chosenTime;
    String? _chosenTimeString;
    // print("initial chosen time is: $selectedTime");
    return await showDialog(
        context: context,
        builder: (_) => Stack(
              children: [
                Positioned(
                  top: 120,
                  child: AlertDialog(
                    contentPadding: EdgeInsets.only(top: 10.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color.fromRGBO(85, 98, 254, 1),
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    content: Container(
                      height: 256,
                      width: 320,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 10,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                            child: SizedBox(
                              height: 130,
                              child: CupertinoDatePicker(
                                  dateOrder: DatePickerDateOrder.dmy,
                                  mode: CupertinoDatePickerMode.time,
                                  initialDateTime:
                                      DateTime.parse("2023-01-31 " + time),
                                  onDateTimeChanged: (val) {
                                    HapticFeedback.selectionClick;
                                    setState(() {
                                      _chosenTime = val;
                                    });
                                  }),
                            ),
                          ),
                          SizedBox(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                child: Container(
                                  width: 160,
                                  padding:
                                      EdgeInsets.only(top: 19.0, bottom: 18.0),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(218, 217, 254, 1),
                                    border: Border.all(
                                        color: Color.fromRGBO(85, 98, 254, 1),
                                        width: 1),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16.0),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                    style: TextStyle(
                                        color: Color.fromRGBO(94, 92, 236, 1)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                onTap: () => Navigator.of(context).pop(),
                              ),
                              InkWell(
                                  child: Container(
                                    width: 160,
                                    padding: EdgeInsets.only(
                                        top: 20.0, bottom: 18.0),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(130, 129, 250, 1),
                                      border: Border.all(
                                          color:
                                              Color.fromRGBO(85, 98, 254, 100),
                                          width: 1),
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(16.0),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.ok,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  onTap: () {
                                    _chosenTimeString = _chosenTime
                                        .toString()
                                        .substring(11, 16);
                                    print("Chosen Time value: ${_chosenTime}");
                                    print(
                                        "Chosen Time String value: ${_chosenTimeString}");
                                    setState(() {
                                      // val = _chosenTimeString!;
                                    });
                                    // startTime = _chosenTimeString!;
                                    Navigator.of(context).pop();
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  @override
  build(BuildContext context) async {
    return await _showDatePicker(context, time);
  }
}

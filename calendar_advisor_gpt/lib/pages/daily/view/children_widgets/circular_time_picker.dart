import 'dart:io';

import 'package:calendar/pages/daily/view_model/daily_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/daily/view/children_widgets/circular_slider/src/double_circular_slider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../models/meeting.dart';
import '../../../all_pages.dart';
import '../../view_model/color_picker.dart';
import '../../view_model/meeting_creator.dart';
import '../../view_model/time_builder.dart';

class CircularTimePicker extends StatefulWidget {
  CircularTimePicker({
    Key? key,
    this.isEdit = false,
  }) : super(key: key);
  bool isEdit;

  @override
  State<CircularTimePicker> createState() => _CircularTimePickerState();
}

class _CircularTimePickerState extends State<CircularTimePicker> {
  final timeSetter = TimeSetter();
  int startAngle = 228; // starting point default at 7:00 am
  int endAngle = 48; // end point default at 16:00 pm
  String startTime = "07:00";
  String endTime = "16:00";
  DateTime? _chosenTime;
  String? _chosenTimeString;

  @override
  Widget build(BuildContext context) {// end point default at 16:00 pm //todo changes here
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  final meetingCreator = Provider.of<MeetingCreator>(context, listen: false);
    if(widget.isEdit){
      startAngle = meetingCreator.dailyAngles[0];
      endAngle = meetingCreator.dailyAngles[1];
      // startTime = meetingCreator.dailyTime[0];
      // endTime = meetingCreator.dailyTime[1];
    }
    return 
        InkWell(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 56.h,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("일정표 기간 설정", 
                              style: TextStyle(fontSize: 16,  fontFamily: 'PretendardVar',fontWeight: FontWeight.bold),),
                              ]
                    ), 
                  ), 
                  SizedBox(height:10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20.w),
                      SizedBox(
                                height: 24,
                                width: 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.amber
                                    ),
                                  padding: EdgeInsets.zero,
                                  child: Icon(Icons.timer, size: 15, color: Colors.white),
                                ),
                              ),
                      SizedBox(width: 20.w),
                      timeSetter.getStringDay((meetingCreator.dailyDate)[0]),
                      // Text(startAngle),
                      SizedBox(width: 44.w),
                      SizedBox(
                                height: 24,
                                width: 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.amber
                                    ),
                                  padding: EdgeInsets.zero,
                                  child: Icon(Icons.timer, size: 15, color: Colors.white),
                                ),
                              ),
                      SizedBox(width: 10.w),
                      timeSetter.getTime((meetingCreator.dailyTime)[0]),     
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: 36, child: Icon(Icons.arrow_forward_ios_rounded, size: 20)),
                      SizedBox(width:34),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20.w),
                      SizedBox(
                                height: 24,
                                width: 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.amber
                                    ),
                                  padding: EdgeInsets.zero,
                                  child: Icon(Icons.timer, size: 15, color: Colors.white),
                                ),
                              ),
                      SizedBox(width: 20.w),
                      timeSetter.getStringDay((meetingCreator.dailyDate)[1]),
                      // Text(startAngle),
                      SizedBox(width: 44.w),
                      SizedBox(
                                height: 24,
                                width: 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.amber
                                    ),
                                  padding: EdgeInsets.zero,
                                  child: Icon(Icons.timer, size: 15, color: Colors.white),
                                ),
                              ),
                      SizedBox(width: 10.w),
                      timeSetter.getTime((meetingCreator.dailyTime)[1]),     
                    ],
                  ),
                  SizedBox(height: 36),
                  
                  ]
              
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context_dialog) {
                  bool isFrom = true;
                  DateTime _fromValue = DateTime.parse(DateFormat('yyyy-MM-dd').format((meetingCreator.dailyDate[0])) +  ' ' + meetingCreator.dailyTime[0]);
                  DateTime _toValue = DateTime.parse(DateFormat('yyyy-MM-dd').format((meetingCreator.dailyDate[1])) +  ' ' + meetingCreator.dailyTime[1]);
                  return
                      Stack(
                        children: [
                          Positioned(left: 10, right: 10, top: MediaQuery.of(context).size.height* 0.22,
                            child: AlertDialog(
                                  insetPadding: EdgeInsets.zero,
                                  contentPadding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color:Color.fromRGBO(85, 98, 254, 1), width: 1),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  content: StatefulBuilder(
                                    builder: (context, setDialog) {
                                      return Stack(
                                        children: [
                                          Column(
                                            children: [
                                              Container(decoration: BoxDecoration(
                                                  boxShadow: [ 
                                                    BoxShadow( color: Color.fromRGBO(0, 0, 0, 0.25),spreadRadius: 0,blurRadius: 4,offset: Offset(0,4),)
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: (){
                                                          setDialog(() {
                                                            isFrom = true;
                                                          });
                                                        },
                                                        child: Container(height: 56,
                                                          decoration:BoxDecoration(color: Color.fromRGBO(85, 98, 254, 1),
                                                            borderRadius:BorderRadius.only(topLeft:Radius.circular(16.0),
                                                            ),
                                                          ),
                                                          child: Container(
                                                            margin: EdgeInsets.only(bottom: 1),
                                                            decoration:BoxDecoration(color: isFrom ? Color.fromRGBO(218, 217, 254, 1): Color.fromRGBO(247, 247, 247, 1),
                                                            borderRadius:BorderRadius.only(topLeft:Radius.circular(16.0) ),
                                                          ),
                                                            child: Center(
                                                              child: Text(AppLocalizations.of(context)!.daily_start,
                                                                style: TextStyle(color: Color.fromRGBO(85, 98, 254, 1),fontSize: 16,fontFamily: 'Spoqa',fontWeight: FontWeight.w500),
                                                                textAlign:TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: (){
                                                          setDialog(() {
                                                            isFrom = true;
                                                          });
                                                        },
                                                        child: Container(height: 56,
                                                          decoration:BoxDecoration(color: Color.fromRGBO(85, 98, 254, 1), borderRadius:BorderRadius.only(topRight:Radius.circular(16.0),
                                                            ),
                                                          ),
                                                          child: Container(
                                                            margin: EdgeInsets.only(bottom: 1),
                                                            decoration:BoxDecoration(color: isFrom ? Color.fromRGBO(247, 247, 247, 1):Color.fromRGBO(218, 217, 254, 1),
                                                            borderRadius:BorderRadius.only(topRight:Radius.circular(16.0),),
                                                          ),
                                                            child: Center(
                                                              child: Text(AppLocalizations.of(context)!.daily_end,
                                                                style: TextStyle(color: Color.fromRGBO(85, 98, 254, 1),fontSize: 16,fontFamily: 'Spoqa', fontWeight: FontWeight.w500),
                                                                textAlign:TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                              Container(width: screenWidth * 0.95,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    Center(
                                                      child: SizedBox(height: 10,),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB( 0, 20, 0, 10),
                                                      child: SizedBox(height: 130,
                                                        child: isFrom ? CupertinoDatePicker(key: UniqueKey(),
                                                            initialDateTime:_fromValue,
                                                            // mode: CupertinoDatePickerMode,
                                                            onDateTimeChanged:(val) => _fromValue = val): CupertinoDatePicker(
                                                            key: UniqueKey(),
                                                            initialDateTime: _toValue,
                                                            // mode: CupertinoDatePickerMode,
                                                            onDateTimeChanged:(val) => _toValue = val
                                                          )
                                                      ),
                                                    ),
                                                    SizedBox(height: 26),
                                                    Row(
                                                      mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Color.fromRGBO(85,98,254,1),
                                                                    borderRadius: BorderRadius.only(bottomLeft:Radius.circular( 16.0),
                                                                    ),
                                                                  ),
                                                                child: Container(
                                                                  margin: EdgeInsets.only(top: 1),
                                                                  padding: EdgeInsets.only(top: 19.0, bottom: 18.0),
                                                                  decoration: BoxDecoration(
                                                                    color: Color.fromRGBO(218, 217, 254, 1),
                                                                    borderRadius: BorderRadius.only(bottomLeft:Radius.circular(16.0),),),
                                                                  child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color:Color.fromRGBO(94,92,236,1)),
                                                                    textAlign:TextAlign.center,
                                                                  ),
                                                                ),
                                                              ),
                                                            onTap: () => Navigator.of(context).pop(),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: InkWell(
                                                            child: Container(
                                                              padding: EdgeInsets.only(top: 20.0, bottom: 18.0),
                                                              decoration:BoxDecoration(
                                                                color: Color.fromRGBO(130, 129, 250, 1),
                                                                border: Border.all(color: Color.fromRGBO(85, 98, 254, 100),width: 1),
                                                                borderRadius:BorderRadius.only(bottomRight:Radius.circular(16.0), ), ),
                                                              child: Text(AppLocalizations.of(context)!.ok,
                                                                style: TextStyle(color: Colors.white,fontSize: 16),
                                                                textAlign:TextAlign.center,),),
                                                            onTap: () {
                                                              if(isFrom) {
                                                                setDialog((){
                                                                  isFrom = false;
                                                                  });
                                                              } else { 
                                                                if (_toValue.isAfter(_fromValue)) {
                                                                  setState(() {
                                                                    startTime = timeSetter.getStringTime(_fromValue);
                                                                    endTime = timeSetter.getStringTime(_toValue);
                                                                    meetingCreator.setDailyTime(startTime, endTime);
                                                                    startAngle = convertToAngle(_fromValue.hour, _fromValue.minute);
                                                                    endAngle = convertToAngle(_toValue.hour, _toValue.minute);
                                                                    meetingCreator.setDailyAngles(startAngle, endAngle);
                                                                    meetingCreator.setDailyDate(_fromValue, _toValue);
                                                                  });            
                                                                  print("this is from: ${_fromValue}");
                                                                  print("this is to: ${_toValue}"); 
                                                                   Navigator.of(context).pop();
                                                                }
                                                              }
                                                            }
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Positioned(left: MediaQuery.of(context).size.width / 2 - 10.w,
                                            child: ClipPath(
                                              child: Container(width: 16, height: 56, color: isFrom ? Color.fromRGBO(218, 217, 254, 1): Color.fromRGBO(247, 247, 247, 1)),
                                              clipper: TriangleClipPath(),
                                            ),
                                          ),
                                          Positioned(left: MediaQuery.of(context).size.width / 2 - 10.w,
                                            child: CustomPaint(
                                              painter: BorderPainter(),
                                              child: Container(width: 16,height: 56,),
                                            ),
                                          )
                                        ],
                                      );
                                    }
                                  ),
                                )
                          ),
                        ],
                      );
                }
              ); 
            }
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
      ..color = Color.fromRGBO(85, 98, 254, 1);
    Path path = Path();
//    uncomment this and will get the border for all lines
    path.lineTo(size.width, size.height/2);
    path.lineTo(0.0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
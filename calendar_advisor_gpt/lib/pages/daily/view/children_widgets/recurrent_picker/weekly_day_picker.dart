import 'package:flutter/material.dart';

class WeeklyDayPicker extends StatefulWidget {
  late final Function weeklyPickCallback;

  WeeklyDayPicker({Key? key, required this.weeklyPickCallback}) : super(key: key);

  @override
  State<WeeklyDayPicker> createState() => _WeeklyDayPickerState();
}

class _WeeklyDayPickerState extends State<WeeklyDayPicker> {
  List<String> weeklyDays = [];
  
  bool mondayColor = false;
  bool tuesdayColor = false;
  bool wednesdayColor = false;
  bool thursdayColor = false;
  bool fridayColor = false;
  bool saturdayColor = false;
  bool sundayColor = false;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (weeklyDays.contains('MO')) {
                  weeklyDays.remove('MO');
                  mondayColor = false;
                }
                else {
                  weeklyDays.add('MO');
                  mondayColor = true;
                }
                
                print(weeklyDays);

                widget.weeklyPickCallback(weeklyDays);
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: mondayColor ? Color(0xFF5562FE) : Color(0xFFDAD9FE)
              ),
              child: Text(
                '월',
                softWrap: true,
                style: TextStyle(
                  fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)
                ),
              ),
            ),
          ),
          
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (weeklyDays.contains('TU')) {
                  weeklyDays.remove('TU');
                  tuesdayColor = false;
                }
                else {
                  weeklyDays.add('TU');
                  tuesdayColor = true;
                }
                
                print(weeklyDays);

                widget.weeklyPickCallback(weeklyDays);
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: tuesdayColor ? Color(0xFF5562FE) : Color(0xFFDAD9FE)
              ),
              child: Text(
                '화',
                softWrap: true,
                style: TextStyle(
                  fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)
                ),
              ),
            ),
          ),
          
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (weeklyDays.contains('WE')) {
                  weeklyDays.remove('WE');
                  wednesdayColor = false;
                }
                else {
                  weeklyDays.add('WE');
                  wednesdayColor = true;
                }
                
                print(weeklyDays);

                widget.weeklyPickCallback(weeklyDays);
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: wednesdayColor ? Color(0xFF5562FE) : Color(0xFFDAD9FE)
              ),
              child: Text(
                '수',
                softWrap: true,
                style: TextStyle(
                  fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)
                ),
              ),
            ),
          ),
          
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (weeklyDays.contains('TH')) {
                  weeklyDays.remove('TH');
                  thursdayColor = false;
                }
                else {
                  weeklyDays.add('TH');
                  thursdayColor = true;
                }
                
                print(weeklyDays);

                widget.weeklyPickCallback(weeklyDays);
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: thursdayColor ? Color(0xFF5562FE) : Color(0xFFDAD9FE)
              ),
              child: Text(
                '목',
                softWrap: true,
                style: TextStyle(
                  fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)
                ),
              ),
            ),
          ),
          
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (weeklyDays.contains('FR')) {
                  weeklyDays.remove('FR');
                  fridayColor = false;
                }
                else {
                  weeklyDays.add('FR');
                  fridayColor = true;
                }
                
                print(weeklyDays);

                widget.weeklyPickCallback(weeklyDays);
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: fridayColor ? Color(0xFF5562FE) : Color(0xFFDAD9FE)
              ),
              child: Text(
                '금',
                softWrap: true,
                style: TextStyle(
                  fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)
                ),
              ),
            ),
          ),
          
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (weeklyDays.contains('SA')) {
                  weeklyDays.remove('SA');
                  saturdayColor = false;
                }
                else {
                  weeklyDays.add('SA');
                  saturdayColor = true;
                }
                
                print(weeklyDays);

                widget.weeklyPickCallback(weeklyDays);
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: saturdayColor ? Color(0xFF5562FE) : Color(0xFFDAD9FE)
              ),
              child: Text(
                '토',
                softWrap: true,
                style: TextStyle(
                  fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)
                ),
              ),
            ),
          ),
          
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (weeklyDays.contains('SU')) {
                  weeklyDays.remove('SU');
                  sundayColor = false;
                }
                else {
                  weeklyDays.add('SU');
                  sundayColor = true;
                }
                
                print(weeklyDays);

                widget.weeklyPickCallback(weeklyDays);
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: sundayColor ? Color(0xFF5562FE) : Color(0xFFDAD9FE)
              ),
              child: Text(
                '일',
                softWrap: true,
                style: TextStyle(
                  fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}
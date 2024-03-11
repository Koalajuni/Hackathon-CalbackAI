import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'monthly_picker.dart';

class EndDatePicker extends StatefulWidget {
  late final Function endDateCallback;
  late final DateTime endDate;

  EndDatePicker({Key? key, required this.endDateCallback, required this.endDate}) : super(key: key);

  @override
  State<EndDatePicker> createState() => _EndDatePickerState();
}

class _EndDatePickerState extends State<EndDatePicker> {

  get buttonDateFormat => DateFormat('yyyy년 MM월 dd일');
  
  late DateTime currentDate;
  late DateTime localEndDate;

  void callback(DateTime pickedDate) {
    setState(() {
      localEndDate = pickedDate;
      widget.endDateCallback(localEndDate);
    });
  }

  @override

  void initState() {
    super.initState();
    currentDate = DateTime.now();
    localEndDate = widget.endDate;
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 64.0),
          child: SizedBox(
            height: 36,
            child: Row(
              children: [
                Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF5562FE)),
                  ),
                  
                  child: TextButton(
                    style: TextButton.styleFrom(
                        textStyle: TextStyle(
                          fontSize: 14, fontFamily: 'Spoqa Han Sans Neo'
                        ),
                        foregroundColor: Color(0xFF5E5CEC),
                        backgroundColor: Color(0xFFE7E7F8),
                      ),
                    onPressed: () async {
                      /*
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        print('Picked end date is $pickedDate');
                        widget.endDateCallback(pickedDate);
                      }

                      else {
                        print('Error: Chosen end date is null');
                        pickedDate = localEndDate;
                      }
                      */
                    },
                    child: Text('${buttonDateFormat.format(localEndDate)}'),
                  ),
                ),

                SizedBox(width: 8.0),
        
                Text(
                  '까지 반복',
                  style: TextStyle(
                    fontSize: 14, fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF555555)
                  ),
                ),
        
              ]
            ),
          ),
        ),

        SizedBox(height: 20),
        MonthlyPicker(endDateCallback: callback),
      ],
    );
  }
}


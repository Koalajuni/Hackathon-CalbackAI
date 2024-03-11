import 'package:weekday_selector/weekday_selector.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';

class RecurrentByWeek extends StatefulWidget {
  const RecurrentByWeek({Key? key}) : super(key: key);

  @override
  RecurrentByWeekState createState() => RecurrentByWeekState();
}

class RecurrentByWeekState extends State<RecurrentByWeek> {
  final values = List.filled(7, false);
  static String selectedTextForm = '';
  bool isVisible = false;
  String dropdownValue = '1';

  int weeksNumber = 1;
  int daysChosen = 1;
  int recurrentCount = 1;

  @override
  Widget build(BuildContext context) {
    if (valuesToEnglishDays(values, true) == '') {
      selectedTextForm = "";
    } else {
      selectedTextForm =
          'FREQ=WEEKLY;BYDAY=${valuesToEnglishDays(values, true)};INTERVAL=1;COUNT=$recurrentCount';
      print("recurrentCount multiplication is $recurrentCount");
      print("weeksNumber is $weeksNumber");
      print("daysChosen is $daysChosen");
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },
              style: TextButton.styleFrom(
                  primary: uiSettingColor.minimal_1,
                  textStyle:
                      const TextStyle(fontSize: 16, fontFamily: 'Roboto-Bold')),
              child: const Text(
                'More...',
              )),
        ),
        Visibility(
          visible: isVisible,
          child: Column(
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Repeated Events:",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto-Medium',
                          color: Colors.grey))),
              WeekdaySelector(
                selectedFillColor: uiSettingColor.minimal_1,
                onChanged: (int day) {
                  setState(() {
                    // Use module % 7 as Sunday's index in the array is 0 and
                    // DateTime.sunday constant integer value is 7.
                    final index = day % 7;
                    // We "flip" the value in this example, but you may also
                    // perform validation, a DB write, an HTTP call or anything
                    // else before you actually flip the value,
                    // it's up to your app's needs.
                    values[index] = !values[index];
                    daysChosen = values.where((item) => item == true).length;
                    recurrentCount = daysChosen * weeksNumber;
                  });
                },
                values: values,
              ),
              const SizedBox(height: 5),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Weeks:",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto-Medium',
                          color: Colors.grey))),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text("Maximum 12 weeks (3 months):",
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Roboto-Medium',
                          color: uiSettingColor.minimal_3)),
                  const SizedBox(width: 20),
                  DropdownButton2(
                    dropdownMaxHeight: 160,
                    dropdownWidth: 80,
                    scrollbarAlwaysShow: true,
                    selectedItemHighlightColor: uiSettingColor.minimal_1,
                    value: dropdownValue,
                    isExpanded: false,
                    items: [
                      '1',
                      '2',
                      '3',
                      '4',
                      '5',
                      '6',
                      '7',
                      '8',
                      '9',
                      '10',
                      '11',
                      '12'
                    ].map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      },
                    ).toList(),
                    onChanged: (String? val) {
                      setState(
                        () {
                          dropdownValue = val!;
                          weeksNumber = int.parse(dropdownValue);
                          recurrentCount = daysChosen * weeksNumber;
                        },
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        // arithmetic number of n which will be multiplied by a (weeks chosen) for count
      ],
    );
  }

  String intDayToEnglish(int day) {
    if (day % 7 == DateTime.monday % 7) return 'MO';
    if (day % 7 == DateTime.tuesday % 7) return 'TU';
    if (day % 7 == DateTime.wednesday % 7) return 'WE';
    if (day % 7 == DateTime.thursday % 7) return 'TH';
    if (day % 7 == DateTime.friday % 7) return 'FR';
    if (day % 7 == DateTime.saturday % 7) return 'SA';
    if (day % 7 == DateTime.sunday % 7) return 'SU';
    throw 'This should never have happened: $day';
  }

  String valuesToEnglishDays(List<bool?> values, bool? searchedValue) {
    final days = <String>[];
    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      // Use v == true, as the value could be null, as well (disabled days).
      if (v == searchedValue) days.add(intDayToEnglish(i));
    }
    if (days.isEmpty) return '';
    return days.join(',');
  }
}

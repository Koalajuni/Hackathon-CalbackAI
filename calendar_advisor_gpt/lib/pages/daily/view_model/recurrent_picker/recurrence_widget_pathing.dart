import 'package:calendar/pages/daily/view/children_widgets/recurrent_picker/end_date_picker.dart';
import 'package:calendar/pages/daily/view/children_widgets/recurrent_picker/monthly_picker.dart';
import 'package:flutter/material.dart';

import '../../view/children_widgets/recurrent_picker/weekly_day_picker.dart';

endDatePickerToggle(Function endDateStateCallback, bool endDateState, String rType) {
  if (rType != '' && rType != 'none') {
    return SizedBox(
      width: 190,
      child: CheckboxListTile(
        activeColor: Color(0xFF5562FE),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: Text(
          '반복 종료일을 설정',
          style: TextStyle(
            fontSize: 14, fontFamily: 'Spoqa', fontWeight: FontWeight.w500, color: Color(0xFF555555)
          ),
        ),
        value: endDateState,
        onChanged: (bool? value) {
          endDateStateCallback(value);
        },
      ),
    );
  }

  else {
    return Container();
  }
}

weeklyPickerToggle(Function weeklyPickCallback, String rType) {
  if (rType == 'weekly') {
    return WeeklyDayPicker(weeklyPickCallback: weeklyPickCallback,);
  }

  else {
    return Container();
  }

}

endDateLogic(Function endDateCallback, String rType, bool checkBoxState, DateTime endDate) {
  if (checkBoxState && (rType != '' && rType != 'none')) {
    return EndDatePicker(endDateCallback: endDateCallback, endDate: endDate);
  }

  else {
    return Container();
  }
}

/*
monthlyToggle(String rType, Function monthlyCallback) {
  if (rType == 'monthly') {
    return MonthlyPicker(monthlyCallback: monthlyCallback);
  }

  else {
    return Container();
  }
}
*/


import 'package:intl/intl.dart';

String recurrenceString(String rType, bool isDefault, DateTime endDate, List<String> weeklyDays) {
  String formatted, until, weekly;

  if (isDefault && rType == 'daily') {
    endDate = endDate.add(Duration(days: 7));
  }

  if (isDefault && rType == 'weekly') {
    endDate = endDate.add(Duration(days: 21));
  }

  if (isDefault && rType == 'monthly') {
    endDate = endDate.add(Duration(days: 90)); // about 3 months
  }

  if (isDefault && rType == 'yearly') {
    endDate = endDate.add(Duration(days: 1100)); // 3 years + 5 days extra just in case
  }

  until = DateFormat('yy년 MM월 dd일').format(endDate);
  formatted = '';

  switch (rType) {
    case '':
      formatted = '';
      break;
    
    case 'none':
      formatted = '';
      break;
    
    case 'daily':
      formatted = '매일 $until까지';
      break;

    case 'weekly':
      weekly = weeklyEngtoKor(weeklyDays).join(', ');
      formatted = '매주 ($weekly) $until까지';
      break;

    case 'monthly':
      formatted = '매월 $until까지';
      break;

    case 'yearly':
      formatted = '매년 $until까지';
      break;

    default:
      print('Formatted string error');
      break;
  }

  return formatted;
}

List<String> weeklyEngtoKor(List<String> weeklyDays) {
  List<String> korDays = [];
  for (var day in weeklyDays) {
    if (day == 'MO') {korDays.add('월');}
    if (day == 'TU') {korDays.add('화');}
    if (day == 'WE') {korDays.add('수');}
    if (day == 'TH') {korDays.add('목');}
    if (day == 'FR') {korDays.add('금');}
    if (day == 'SA') {korDays.add('토');}
    if (day == 'SU') {korDays.add('일');}
  }
  return korDays;
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String translateWeekday2Korean(String weekday) {
  String weekdayKorean = '';
  switch (weekday) {
    case 'Mon':
      return '월';
    case 'Tue':
      return '화';
    case 'Wed':
      return '수';
    case 'Thu':
      return '목';
    case 'Fri':
      return '금';
    case 'Sat':
      return '토';
    case 'Sun':
      return '일';
    default:
      return 'ERR';
  }
  
}

String weekday2Korean(int weekday) {
  String weekdayKorean = '';
  switch (weekday) {
    case 1:
      return '월';
    case 2:
      return '화';
    case 3:
      return '수';
    case 4:
      return '목';
    case 5:
      return '금';
    case 6:
      return '토';
    case 7:
      return '일';
    default:
      return 'ERR';
  }
  
}
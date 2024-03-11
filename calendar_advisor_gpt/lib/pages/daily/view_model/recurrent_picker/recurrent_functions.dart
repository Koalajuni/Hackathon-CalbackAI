import 'package:intl/intl.dart';

class RecurrentFunctions {
  late final String rType;
  DateTime endDate;
  late final bool isDefault;

  late List<String> weekDays;
  late DateTime dailyDate;

  RecurrentFunctions({
    required this.rType,
    required this.endDate,
    required this.isDefault,

    required this.weekDays,
    required this.dailyDate,
  });

  get untilDateFormat => DateFormat('yyyyMMdd');
  get dayDateFormat => DateFormat('dd');
  get monthDateFormat => DateFormat('MM');

  String recurrentPath() {
    late String rRule;

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

    print('THIS IS WEEKDAYS $weekDays');

    switch(rType) {
      case '':
        rRule = '';
        break;

      case 'none':
        rRule = '';
        break;
      
      case 'daily':
        rRule = recrrDaily();
        break;

      case 'weekly':
        rRule = recrrWeekly(weekDays);
        break;

      case 'monthly':
        rRule = recrrMonthly();
        break;

      case 'yearly':
        rRule = recrrYearly();
        break;

      default:
        print('$rType is not a proper type');
    }

    return rRule;
  }
  
  String recrrDaily() {
    return 'FREQ=DAILY;UNTIL=${untilDateFormat.format(endDate)}';
  }

  String recrrWeekly(List<String> weekDays) {
    String weekDaysString = weekDays.join(',');
    
    return 'FREQ=WEEKLY;UNTIL=${untilDateFormat.format(endDate)};BYDAY=$weekDaysString';
  }

  String recrrMonthly() {
    return 'FREQ=MONTHLY;UNTIL=${untilDateFormat.format(endDate)};BYMONTHDAY=${dayDateFormat.format(dailyDate)}';
  }

  String recrrYearly() {
    String day = dayDateFormat.format(dailyDate);
    String month = monthDateFormat.format(dailyDate);
    
    return 'FREQ=YEARLY;UNTIL=${untilDateFormat.format(endDate)};BYMONTHDAY=$day;BYMONTH=$month';
  }
}
class UserSchedule {
  UserSchedule({
    required this.profileUid,
    this.schedule = const [],
  });

  late final String profileUid;
  List<String> schedule;

  Map<String, dynamic> toDocument() {
    return {
      "profileUid": profileUid,
      "schedule": schedule,
    };
  }

  String get scheduleString {
  final formattedSchedule = schedule.map((event) => event.split(' - ').join(', ')).toList();
  return '[' + formattedSchedule.join('], [') + ']';
}

  //  factory UserSchedule.fromJson(Map<String, dynamic> json) {
  //   return UserSchedule(
  //     profileUid: json['profileUid'],
  //     schedule: List<String>.from(json['schedule']),
  //   );
  // }
}
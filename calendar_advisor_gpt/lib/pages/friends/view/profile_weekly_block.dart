import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';

class ProfileWeeklyBlock extends StatefulWidget {
  ProfileWeeklyBlock({Key? key}) : super(key: key);

  @override
  State<ProfileWeeklyBlock> createState() => Profile_WeeklyBlockState();
}

class Profile_WeeklyBlockState extends State<ProfileWeeklyBlock> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 166.w,
      height: 118.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFD9D9D9)),
          right: BorderSide(color: Color(0xFFD9D9D9)),
        )
      ),
    );
  }
}
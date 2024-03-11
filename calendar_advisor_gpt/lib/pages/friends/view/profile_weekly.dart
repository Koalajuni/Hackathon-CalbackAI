import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';

import 'profile_weekly_block.dart';

class ProfileWeekly extends StatefulWidget {
  ProfileWeekly({Key? key}) : super(key: key);

  @override
  State<ProfileWeekly> createState() => _ProfileWeeklyState();
}

class _ProfileWeeklyState extends State<ProfileWeekly> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);

    return Container(
      width: 335.w,
      height: 477.h,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Color(0xFFD9D9D9)),
          top: BorderSide(color: Color(0xFFD9D9D9)),
        )
      ),

      child: Column(
        children: [
          Row(
            children: [
              ProfileWeeklyBlock(),
              ProfileWeeklyBlock(),
            ],
          ),
    
          Row(
            children: [
              ProfileWeeklyBlock(),
              ProfileWeeklyBlock(),
            ],
          ),
    
          Row(
            children: [
              ProfileWeeklyBlock(),
              ProfileWeeklyBlock(),
            ],
          ),
          
          Row(
            children: [
              ProfileWeeklyBlock(),
              ProfileWeeklyBlock(),
            ],
          ),
        ]
      ),
    );
  }
}
import 'package:calendar/models/friendship.dart';
import 'package:calendar/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/user.dart';

class PrivacyCheckbox extends StatefulWidget {
  final MyUser? myUser;
  final MyUser? groupUser;
  PrivacyCheckbox({Key? key, this.myUser, this.groupUser}) : super(key: key);

  @override
  State<PrivacyCheckbox> createState() => _PrivacyCheckboxState();
}

class _PrivacyCheckboxState extends State<PrivacyCheckbox> {
  late bool isOpenPrivacy;
  
  @override
  void initState() {
    super.initState();
    isOpenPrivacy = widget.groupUser!.openPrivacy;
  }

  @override
  Widget build(BuildContext context) {
    return Row(

      children: [
        Text(
          '비공개',
          style: TextStyle(
            fontFamily: 'PretendardVar',
            fontSize: 14.sp
          ),
        ),

        Checkbox(
          activeColor: Color(0xFF5E5CEC),
          value: !isOpenPrivacy,
          onChanged: (bool? value) async {
            await DatabaseService(uid: widget.groupUser!.uid)
              .updateField({'openPrivacy' : !isOpenPrivacy});

            setState(() {
              isOpenPrivacy = !isOpenPrivacy;
            });
          }
        ),
      ],
    );
  }
}
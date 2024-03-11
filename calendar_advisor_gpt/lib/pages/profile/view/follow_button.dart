import 'package:calendar/models/friendship.dart';
import 'package:calendar/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/user.dart';
import '../../all_pages.dart';

class FollowButton extends StatefulWidget {
  final MyUser? myUser;
  final MyUser? groupUser;
  FollowButton({Key? key, this.myUser, this.groupUser}) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late String buttonState;

  @override
  void initState() {
    super.initState();
    buttonState = widget.groupUser!.reqReceived.contains(widget.myUser!.uid)
      ? 'Requested'
      : widget.groupUser!.friends.contains(widget.myUser!.uid)
        ? 'Added'
        : 'Follow';
  }

  @override
  Widget build(BuildContext context) {
    return buttonState == 'Requested'
    ? InkWell(
      onTap: () async {
        await DatabaseService(uid: widget.myUser!.uid).
        declineFriendReq(Friendship(
              myUid: widget.groupUser!.uid, friendUid: widget.myUser!.uid));
            setState(() {
              buttonState = 'Follow';
            });
      },
      child: Container(
        height: 30.h,
        width: 84.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          color: Color.fromARGB(255, 221, 219, 226)
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '요청됨',
            style: TextStyle(
              fontFamily: 'PretendardVar',
              fontSize: 14.sp,
            )
          ),
        ),
      )
    )

    : buttonState == 'Added'
      ? InkWell(
        onTap: () async{
            await DatabaseService(uid: widget.myUser!.uid).
              removeFriend(widget.myUser!.uid, widget.groupUser!.uid);
            setState(() {
              buttonState = 'Follow';
            });

        },
        child: Container(
          height: 30.h,
          width: 84.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Color.fromARGB(255, 243, 242, 242)
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              '팔로잉',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'PretendardVar',
                fontSize: 14.sp
              )
            ),
          ),
        )
      )

      : InkWell(
        onTap: () async {
          if (widget.groupUser!.openPrivacy == false) {
            await DatabaseService(uid: widget.myUser!.uid).
              sendFriendReq(widget.myUser!.uid, widget.groupUser!.uid);
            setState(() {
              buttonState = 'Requested';
            });
          }
          
          else {
            Friendship friendship = Friendship(
              myUid: widget.groupUser!.uid, friendUid: widget.myUser!.uid);

            await DatabaseService(uid: widget.myUser!.uid).
              acceptFriendReq(friendship);

            setState(() {
              buttonState = 'Added';
            });
          }
        },
        child: Container(
          height: 30.h,
          width: 84.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Colors.black
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context)!.follow,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PretendardVar',
                fontSize: 14.sp
              )
            ),
          ),
        )
      );
  }
}
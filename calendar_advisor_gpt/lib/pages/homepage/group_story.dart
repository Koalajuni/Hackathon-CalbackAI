import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/animations/animations.dart';
import 'package:calendar/local_data/shared_preferences/shared_preferences_functions.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import '../../models/meeting.dart';
import '../../models/profileInterest.dart';
import '../all_pages.dart';

class GroupStory extends StatefulWidget {
  final Map<String, dynamic> notificationStates;
  final Function callback;

  GroupStory({Key? key, required this.notificationStates, required this.callback}) : super(key: key);

  @override
  State<GroupStory> createState() => _GroupStoryState();
}

class _GroupStoryState extends State<GroupStory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128.h,
      width: 360.w,
      color: Color(0xFFF5F7F9),
      child: Padding(
        padding: EdgeInsets.only(top: 18.h, left: 16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 344.w,
              height: 92.h,
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => SizedBox(width: 7.w),
                scrollDirection: Axis.horizontal,
                itemCount: widget.notificationStates.length,
                itemBuilder: (BuildContext context, int index) {
                  return IndividualGroupWithNotification(
                    groupUid: widget.notificationStates.keys.elementAt(index),
                    data: widget.notificationStates.values.elementAt(index),
                    notificationStates: widget.notificationStates,
                    callback: widget.callback,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IndividualGroupWithNotification extends StatefulWidget {
  final String groupUid;
  final List<String> data;
  final Map<String, dynamic> notificationStates;
  final Function callback;
  IndividualGroupWithNotification({Key? key, required this.groupUid, required this.data, required this.notificationStates, required this.callback}) : super(key: key);

  @override
  State<IndividualGroupWithNotification> createState() => _IndividualGroupWithNotificationState();
}

class _IndividualGroupWithNotificationState extends State<IndividualGroupWithNotification> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);

    String notificationState = widget.data[0];
    String name = widget.data[1];
    String url = widget.data[2];

    return StreamBuilder<MyUser>(
      stream: DatabaseService(uid: widget.groupUid).userData,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container();
          default:
            if (snapshot.hasData){
              final userData = snapshot.data;
              return Container(
                height: 92.h,
                width: 66.w,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                child: InkWell(
                  onTap: () async {
                    await DatabaseService(uid: widget.groupUid).getProfileInterest(ProfileInterest(profileUid: widget.groupUid));
                    await DatabaseService(uid: widget.groupUid).profileInterestIncr(widget.groupUid);

                    await SharedPreferencesFunctions().
                      notificationReset(widget.data, widget.groupUid);

                    setState(() {
                      notificationState = 'false';
                    });
                    
                    await Navigator.push(context, 
                      CustomPageRoute(
                        child: MyProfile(user: userData),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        badges.Badge(
                          position: badges.BadgePosition.topEnd(top: 0, end: 0),
                          showBadge: notificationState == 'true' ? 
                            true : false,
                          child: CircleAvatar(
                            radius: 25.r,
                            backgroundColor: Colors.transparent,
                            backgroundImage: url != '' ? 
                              CachedNetworkImageProvider(url)
                              : null
                          ),
                        ),
                        
                        SizedBox(height: 8.h),
                        
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: 'PrentedardVariable',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            else {
              return Container();
            }
        }
      }
    );
  }
}
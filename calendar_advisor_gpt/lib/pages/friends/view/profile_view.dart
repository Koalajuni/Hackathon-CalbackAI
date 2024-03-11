import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';

import '../person_tile.dart';
import '../view_model/profile_parser.dart';

class ProfileView extends StatefulWidget {

  ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    final profileParser = Provider.of<ProfileParser>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          SizedBox(height: 16.h),
          
          Text(
            AppLocalizations.of(context)!.friend_myProfile,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontFamily: 'Spoqa',
                fontWeight: FontWeight.w700
            )
          ),

          SizedBox(height: 16.h),
          
          Row(
            children: [
              ProfileTile(UID: user.uid),
            ],
          ),

          // SizedBox(height: 12.h),
          Divider(),
          SizedBox(height: 20.h),

          _header(),
    
          SizedBox(height: 8.h),
          
          _ViewBuilder(),
        ]
      ),
    );
  }
}

class _header extends StatefulWidget {
  _header({Key? key}) : super(key: key);

  @override
  State<_header> createState() => __headerState();
}

class __headerState extends State<_header> {
  int currentPage = 0;
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    final profileParser = Provider.of<ProfileParser>(context);

    profileParser.pageController.addListener(() {
      setState(() {});  
    });

      if (currentPage == 0 || profileParser.pageController.page == 0) {
        if (currentPage == 0) {currentPage = 99;}

        return Row(
          children: [
            Text(
              (user.uid.substring(0,4) == 'open') ? '팔로워' : AppLocalizations.of(context)!.friend_friendProfile,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontFamily: 'Spoqa',
                fontWeight: FontWeight.w700
              )
            ),
            Text(
              "  (${profileParser.closedProfiles.length})",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400
              )
            ),

            SizedBox(width: 20.w),

            InkWell(
              onTap: () {
                profileParser.pageController.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
              },
              child: Text(
                '그룹',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 16.sp,
                  fontFamily: 'Spoqa',
                  fontWeight: FontWeight.w700
                )
              ),
            ),
            Text(
              "  (${profileParser.openProfiles.length})",
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 14.sp,
                fontWeight: FontWeight.w400
              )
            ),
          ],
        );
      }

      else {
        return Row(
          children: [
            InkWell(
              onTap: () {
                profileParser.pageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
              },
              child: Text(
                (user.uid.substring(0,4) == 'open') ? '팔로워' : AppLocalizations.of(context)!.friend_friendProfile,
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 16.sp,
                  fontFamily: 'Spoqa',
                  fontWeight: FontWeight.w700
                )
              ),
            ),
            Text(
                "  (${profileParser.closedProfiles.length})",
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400
                )
            ),

            SizedBox(width: 20.w),

            Text(
              '그룹',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontFamily: 'Spoqa',
                fontWeight: FontWeight.w700
              )
            ),
            Text(
                "  (${profileParser.openProfiles.length})",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400
                )
            ),
          ],
        );
      }

  }
}

class _ViewBuilder extends StatefulWidget {
  _ViewBuilder({Key? key}) : super(key: key);

  @override
  State<_ViewBuilder> createState() => _ViewBuilderState();
}

class _ViewBuilderState extends State<_ViewBuilder> {

  @override
  Widget build(BuildContext context) {
    final profileParser = Provider.of<ProfileParser>(context);
    return Expanded(
      child: PageView(
        controller: profileParser.pageController,
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profileParser.closedProfiles.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return PersonTile(UID: profileParser.closedProfiles[index]);
            },
          ),

          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profileParser.openProfiles.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return PersonTile(UID: profileParser.openProfiles[index]);
            },
          ),

        ]
      ),
    );
  }
}

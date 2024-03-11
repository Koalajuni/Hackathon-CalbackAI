import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/profile/profile_builder.dart';
import 'package:flutter/material.dart';

Container closedProfileTile(MyUser user) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20),
    color: Colors.white,
    height: 90,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SingleProfile(size: 56, photoUrl: user.photoUrl, borderRadius: 16,),
            SizedBox(width: 20,),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children : [
                  Text(user.name,
                    style: TextStyle(
                      fontFamily: 'Spoqa',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Color(0xff222222)
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text('캘박',
                    style: TextStyle(
                      fontFamily: 'Spoqa',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xff888888)
                    ),
                  ),
                ]
              ),
            )
          ],
        ),
        InkWell(
          onTap: (){},
          child: Icon(Icons.settings_outlined, color: Color(0xff888888),),
        )
      ],
    ),
  );
}

Container openProfileTile(MyUser user) {
  return Container(
    color: Color(0xffDAD9FE),
    width: double.infinity,
    height: 90,
    child: user.photoUrl.isNotEmpty 
      ? CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: user.photoUrl,
        errorWidget: (_,__,___) {
          return Container();
        },
      )
      : Container()
  );
}
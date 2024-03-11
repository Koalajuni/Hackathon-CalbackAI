import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/friends/friend_calendar.dart';
import 'package:flutter/material.dart';
import 'package:calendar/services/auth.dart';
import 'package:calendar/services/database.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/meeting.dart';
import '../../shared/calendar_functions.dart';
import '../monthly/monthly_custom_cell.dart';

class ProfileBuilder extends StatelessWidget {
  const ProfileBuilder({Key? key, required this.user}) : super(key: key);
  final MyUser user;

  Widget build(BuildContext context) {
    final meetings = DatabaseService(uid: user.uid).getMeetings();
    DateTime currentDate = dateOnly(DateTime.now());

    return FutureBuilder(
        future: meetings,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final events = snapshot.data as List<Meeting>;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SfCalendar(
                  view: CalendarView.month,
                  backgroundColor: Colors.white,
                  initialSelectedDate: currentDate,
                  headerHeight: 0,
                  headerStyle: CalendarHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                          fontSize: 26, fontFamily: 'Roboto-Black', color: uiSettingColor.minimal_1)),
                  monthViewSettings: MonthViewSettings(
                      appointmentDisplayMode: MonthAppointmentDisplayMode
                          .appointment,
                      appointmentDisplayCount: 3,
                      showAgenda: false,
                      numberOfWeeksInView: 4,
                      monthCellStyle: MonthCellStyle(
                      )
                  ),
                  monthCellBuilder: customMonthCellBuilder,
                  dataSource: MeetingDataSource(events),
                ),
              ),
            );
          }
          else if (snapshot.hasError) {
            return Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            );
          }

          else {
            return CircularProgressIndicator();
          }
          throw UnimplementedError();
        }
    );
  }
}


class HorizontalFriendView extends StatelessWidget  {
  const HorizontalFriendView({Key? key, required this.UID}) : super(key: key);
  final String UID;

  @override
  Widget build(BuildContext context) {
    //MyUserData user = DatabaseService(uid: provider!.uid).userData;
    return StreamBuilder<MyUser>(
        stream: DatabaseService(uid: UID).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MyUser? userData = snapshot.data;
            return Column(
                children: <Widget>[
                  SizedBox(height: 8),
                  CircleAvatar(
                    radius: 20.0,
                    backgroundImage: userData!.photoUrl != '' ? CachedNetworkImageProvider(userData!.photoUrl) : null
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                      width: 70,
                      child: Center(child: Text(userData!.name, style: TextStyle(color: Colors.black54)))),
                ]
            );
          }
          else {
            return Container();
          }
        }
    );
  }
}

class MyFriendView extends StatelessWidget  {
  const MyFriendView({Key? key, required this.UID}) : super(key: key);
  final String UID;

  @override
  Widget build(BuildContext context) {
    //MyUserData user = DatabaseService(uid: provider!.uid).userData;
    return StreamBuilder<MyUser>(
        stream: DatabaseService(uid: UID).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MyUser? userData = snapshot.data;
            return Column(
                children: <Widget>[
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      DatabaseService(uid: UID).userData;
                      Navigator.push(context,
                          CustomPageRoute(
                              child: MyProfile(
                                  user: userData),
                              direction: AxisDirection.up
                          )

                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25.0,
                          backgroundImage: userData!.photoUrl != '' ? CachedNetworkImageProvider(userData!.photoUrl) : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                      width: 70,
                      child: Center(child: Text(userData!.name, style: TextStyle(color: Colors.black54)))),
                ]
            );
          }
          else {
            return Container();
          }
        }
    );
  }
}


// class BuildCoverImage extends StatelessWidget{
//   const BuildCoverImage({Key? key, required this.user}) : super(key: key);
//   final MyUser user;
//
//   Widget build(BuildContext context){
//     return Scaffold(
//       body: Stack(
//         buildCoverImage()
//       children: <Widget>[],
//       ),
//       );
//
//   }
// }

class SingleProfile extends StatelessWidget  {
  const SingleProfile({Key? key, required this.size, required this.photoUrl, this.borderSize, this.borderRadius}) : super(key: key);
  final double size;
  final double? borderRadius;
  final double? borderSize;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey,
        image: photoUrl != '' ? 
          DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(photoUrl!)) :  
            null,
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius ?? size/2.5)
        ),
        border: borderSize != null ?
          Border.all(
            color: ColorSetting().minimal_1,
            width: borderSize!,
          ) : null,
      ),
    );
  }
}

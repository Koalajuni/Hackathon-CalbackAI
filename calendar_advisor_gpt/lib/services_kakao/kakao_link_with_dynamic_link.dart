import 'package:calendar/main.dart';
import 'package:calendar/models/meeting.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/shared/calendar_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:calendar/shared/globals.dart' as globals;
import '../models/friendship.dart';
import '../models/user.dart';
import '../pages/events/event_maker.dart';
import '../pages/group/choose_preference_week.dart';

class KakaoLinkWithDynamicLink {
  static final KakaoLinkWithDynamicLink _manager =
      KakaoLinkWithDynamicLink._internal();

  factory KakaoLinkWithDynamicLink() {
    return _manager;
  }

  KakaoLinkWithDynamicLink._internal() {}

  Future<bool> isKakaotalkInstalled() async {
    bool installed = await isKakaoTalkInstalled();
    return installed;
  }

  // Dynamic Link for meeting requests ------------------------------------------------------------------------------
  void shareMyCodeMeeting(Meeting event, String link) async {
    try {
      var template = getTemplateMeeting(event, link);
      var uri = await ShareClient.instance.shareDefault(template: template);
      await ShareClient.instance.launchKakaoTalk(uri);
    } catch (e) {
      print("error at shareMyCodeMeeting ${e.toString()}");
    }
  }

  FeedTemplate getTemplateMeeting(Meeting event, String link) {

    String finalFormat = ""; 
    String dayInKorean = "일"; 
    String fromWeekDay = DateFormat('EEE','ko').format(event.from);
    String toWeekDay = DateFormat('EEE','ko').format(event.to);
    String sendFormatFrom = DateFormat('MMM d${dayInKorean} (${fromWeekDay}) a h:mm', 'ko').format(event.from);
    String sendFormatTo = DateFormat('MMM d${dayInKorean} (${toWeekDay}) a h:mm', 'ko').format(event.to);


    if (dateOnly(event.from) == dateOnly(event.to)){
      finalFormat = " $sendFormatFrom ~ ${sendFormatTo.substring(10,18)}"; 
    }else{
      finalFormat = " $sendFormatFrom ~ $sendFormatTo "; 
    }



    late String feedTitle;
    if (event.content == "") {
      feedTitle = "캘박 신청";
    } else {
      feedTitle = event.content;
    }
    Content content = Content(
        title: feedTitle,
        imageUrl: Uri.parse(""),
        link: Link(
          mobileWebUrl: null,
        ),
        description: finalFormat);
    // "Let's Calback on $sendFormatFrom to $sendFormatTo");   // english

    FeedTemplate template = FeedTemplate(content: content, buttons: [
      Button(title: "수락", link: Link(mobileWebUrl: Uri.parse(link))),
      Button(title: "거절", link: Link(mobileWebUrl: null))
    ]);

    return template;
  }

  Future<String> buildDynamicLinkMeeting(
    String owner,
    String content,
    DateTime from,
    DateTime to,
    Color background,
    bool isAllDay,
    List<String> involved,
    List<String> pendingInvolved,
    String MID,
    String? rRule,
  ) async {
    String url = "https://testhym.page.link";
    String backgroundID = background.toString().split('(0x')[1].split(')')[0];
    String parameterLink = '$url/?owner=$owner&content=$content&from=$from'
        '&to=$to&background=$backgroundID&isAllDay=$isAllDay&involved=$involved'
        '&pendingInvolved=$pendingInvolved&MID=$MID&recurrenceRule=$rRule';
    String encodedParameterLink = Uri.encodeComponent(parameterLink);
    print("encoded link : ${encodedParameterLink}");
    Uri apn = Uri.parse('com.calback.hym');
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        link: Uri.parse('$url/?link=$encodedParameterLink&apn=$apn&ibi=$apn'),
        uriPrefix: url,
        navigationInfoParameters:
            NavigationInfoParameters(forcedRedirectEnabled: true),
        androidParameters: AndroidParameters(
          packageName: "com.calback.hym.android",
          minimumVersion: 21,
        ),
        //todo with IOS
        iosParameters: IOSParameters(
          bundleId: "com.calback.hym",
          appStoreId: '1639503509',
        ));
    print("inside buildDynamicLink ${parameters.link}");
    final ShortDynamicLink dynamicLink = await FirebaseDynamicLinks.instance
        .buildShortLink(parameters,
            shortLinkType: ShortDynamicLinkType.unguessable);
    // return dynamicUrl.shortUrl.toString();
    print("short dynamic link : ${dynamicLink.shortUrl.toString()}");
    return dynamicLink.shortUrl.toString();
  }

  void sendDirectKakaoMsgMeeting(
      Meeting event, String link, List<String> kakaoFriendUid) async {
    Friends friends;
    try {
      friends = await TalkApi.instance.friends();
      print('카카오톡 친구 목록 받기 성공'
          '\n${friends.elements?.map((friend) => friend.profileNickname).join('\n')}'
          '\n${friends.elements?.length}'
          '\nextrraaa');

      try {
        var template = getTemplateMeeting(event, link);
        // var uri = await ShareClient.instance.shareDefault(template: template);
        // await ShareClient.instance.launchKakaoTalk(uri);
        print("///////Sending Msgs ${kakaoFriendUid[0]}");
        MessageSendResult result = await TalkApi.instance.sendDefaultMessage(
          receiverUuids:
              friends.elements!.map((friend) => friend.uuid).toList(),
          template: template,
        );
        print(friends.elements!.map((friend) => friend.uuid).toList());
        print('메시지 보내기 성공 ${result.successfulReceiverUuids}');

        if (result.failureInfos != null) {
          print('일부 대상에게 메시지 보내기 실패'
              '\n${result.failureInfos}');
        }
      } catch (e) {
        print("error at sendDirectKakaoMsgMeeting ${e.toString()}");
      }
    } catch (error) {
      print('카카오톡 친구 목록 받기 실패 $error');
    }
  }

  // Dynamic Link for friend requests ------------------------------------------------------------------------------
  void shareMyCodeFriend(MyUser user, String link) async {
    try {
      var template = getTemplateFriend(user, link);
      var uri = await ShareClient.instance.shareDefault(template: template);
      await ShareClient.instance.launchKakaoTalk(uri);
    } catch (e) {
      print("error at shareMyCodeFriend ${e.toString()}");
    }
  }

  FeedTemplate getTemplateFriend(MyUser user, String link) {
    Content content = Content(
        title: "캘박으로 친구 추가",
        imageUrl: Uri.parse(""),
        link: Link(
          mobileWebUrl: null,
        ),
        description: "${user.name}님이 캘박 친구 신청을 했습니다");
    // "${user.name} sent you a friend request in CalBack!");   // english

    FeedTemplate template = FeedTemplate(content: content, buttons: [
      Button(title: "수락", link: Link(mobileWebUrl: Uri.parse(link))),
      Button(title: "거절", link: Link(mobileWebUrl: null))
    ]);

    return template;
  }

  Future<String> buildDynamicLinkFriend(
    String requestUid,
  ) async {
    String url = "https://testhym.page.link";
    String parameterLink = '$url/?requestUid=$requestUid';
    String encodedParameterLink = Uri.encodeComponent(parameterLink);
    print("encoded link : ${encodedParameterLink}");
    Uri apn = Uri.parse('com.calback.hym');
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        link: Uri.parse('$url/?link=$encodedParameterLink&apn=$apn&ibi=$apn'),
        uriPrefix: url,
        navigationInfoParameters:
            NavigationInfoParameters(forcedRedirectEnabled: true),
        androidParameters: AndroidParameters(
          packageName: "com.calback.hym.android",
          minimumVersion: 21,
        ),
        //todo with IOS
        iosParameters: IOSParameters(
          bundleId: "com.calback.hym",
          appStoreId: "1639503509",
        ));
    print("inside buildDynamicLink ${parameters.link}");
    final ShortDynamicLink dynamicLink = await FirebaseDynamicLinks.instance
        .buildShortLink(parameters,
            shortLinkType: ShortDynamicLinkType.unguessable);
    // return dynamicUrl.shortUrl.toString();
    print("short dynamic link : ${dynamicLink.shortUrl.toString()}");
    return dynamicLink.shortUrl.toString();
  }

  // Dynamic Link for pending meetings ------------------------------------------------------------------------------
  void shareMyCodePendMeet(Meeting event, String link) async {
    try {
      var template = getTemplatePendMeet(event, link);
      var uri = await ShareClient.instance.shareDefault(template: template);
      await ShareClient.instance.launchKakaoTalk(uri);
    } catch (e) {
      print("error at shareMyCodeMeeting ${e.toString()}");
    }
  }

  FeedTemplate getTemplatePendMeet(Meeting event, String link) {
    String finalFormat = ""; 
    String dayInKorean = "일"; 
    String fromWeekDay = DateFormat('EEE','ko').format(event.from);
    String toWeekDay = DateFormat('EEE','ko').format(event.to);
    String sendFormatFrom = DateFormat('MMM d${dayInKorean} (${fromWeekDay}) a h:mm', 'ko').format(event.from);
    String sendFormatTo = DateFormat('MMM d${dayInKorean} (${toWeekDay}) a h:mm', 'ko').format(event.to);

    if (dateOnly(event.from) == dateOnly(event.to)){
      finalFormat = " $sendFormatFrom ~ ${sendFormatTo.substring(10,18)}"; 
    }else{
      finalFormat = " $sendFormatFrom ~ $sendFormatTo "; 
    }


    late String feedTitle;
    if (event.content == "") {
      feedTitle = "가능한 시간 입력해요";
    } else {
      feedTitle = "${event.content}";
    }
    Content content = Content(
        title: feedTitle,
        imageUrl: Uri.parse(""),
        link: Link(
          mobileWebUrl: null,
        ),
        description: " $finalFormat 사이에 가능한 시간");
    // "Let's Calback on $sendFormatFrom to $sendFormatTo");   // english

    FeedTemplate template = FeedTemplate(content: content, buttons: [
      Button(title: "입력", link: Link(mobileWebUrl: Uri.parse(link))),
      Button(title: "거절", link: Link(mobileWebUrl: null)),
    ]);

    return template;
  }

  Future<String> buildDynamicLinkPendMeet(Meeting meeting) async {
    String owner = meeting.owner;
    String content = meeting.content;
    DateTime from = meeting.from;
    DateTime to = meeting.to;
    Color background = meeting.background;
    bool isAllDay = meeting.isAllDay;
    List<String> involved = meeting.involved;
    List<String> pendingInvolved = meeting.pendingInvolved;
    String MID = meeting.MID;
    String url = "https://testhym.page.link";
    String backgroundID = background.toString().split('(0x')[1].split(')')[0];
    String parameterLink = '$url/?owner=$owner&content=$content&from=$from'
        '&to=$to&background=$backgroundID&isAllDay=$isAllDay&involved=$involved&pendingInvolved=$pendingInvolved&MID=$MID';
    String encodedParameterLink = Uri.encodeComponent(parameterLink);
    print("encoded link : ${encodedParameterLink}");
    Uri apn = Uri.parse('com.calback.hym');
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        link: Uri.parse('$url/?link=$encodedParameterLink&apn=$apn&ibi=$apn'),
        uriPrefix: url,
        navigationInfoParameters:
            NavigationInfoParameters(forcedRedirectEnabled: true),
        androidParameters: AndroidParameters(
          packageName: "com.calback.hym.android",
          minimumVersion: 21,
        ),
        //todo with IOS
        iosParameters: IOSParameters(
          bundleId: "com.calback.hym",
          appStoreId: '1639503509',
        ));
    print("inside buildDynamicLink ${parameters.link}");
    final ShortDynamicLink dynamicLink = await FirebaseDynamicLinks.instance
        .buildShortLink(parameters,
            shortLinkType: ShortDynamicLinkType.unguessable);
    // return dynamicUrl.shortUrl.toString();
    print("short dynamic link : ${dynamicLink.shortUrl.toString()}");
    return dynamicLink.shortUrl.toString();
  }

  // Accepting Dynamic Link Requests ------------------------------------------------------------------------------

  void readDynamicLink(
    Map<String, String> queryParams, String UID, BuildContext context) async {
    if (queryParams["MID"] != null &&
        queryParams["MID"]!.substring(0, 7) == "pending") {
      String pendingMID = queryParams["MID"]!;
      await DatabaseService(uid: UID).updatePendingTime(UID, pendingMID);
      Meeting pendingMeeting =
          await DatabaseService(uid: UID).singleMeetingData(pendingMID);
      Map<String, dynamic> pendingInstance =
          await DatabaseService(uid: UID).getPendingTime(pendingMID);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => StreamProvider<MyUser>(
                create: (context) => DatabaseService(uid: UID).userData,
                initialData: MyUser(uid: UID),
                builder: (context, child) => PreferredWeekly(
                    meeting: pendingMeeting, pendingMeeting: pendingInstance),
              )));
    }
    if (queryParams["requestUid"] == null) {
      if (UID != queryParams['owner']) {
        //await DatabaseService(uid: UID).acceptKakaoEvent(Meeting.fromKakao(queryParams,));
        //await DatabaseService(uid: UID).acceptMeetReq(UID, queryParams['owner']!, queryParams['MID']!);
        //TODO need to take care of agenda here
        globals.bnbIndex = 2;
        final eventProvider = Provider.of<EventMaker>(
            navigatorKey.currentContext!,
            listen: false);
        print(queryParams["involved"]);
        await eventProvider.acceptKakaoEvent(
            Meeting.fromKakao(queryParams), UID);
      }
    } else {
      final String requestUid = queryParams["requestUid"]!;
      globals.bnbIndex = 1;
      print("친구추가");
      if (UID != requestUid) {
        await DatabaseService(uid: UID)
            .acceptFriendReq(Friendship(myUid: UID, friendUid: requestUid));
      }
    }
  }
}

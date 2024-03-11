import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/services/database.dart';

import '../../models/friendship.dart';
import '../profile/view/follow_button.dart';

/* 
1) Use searchController for the search input value
2) Query 'meetingsCollection' for all docs that contain exact 'name' value as searchcontroller
3) FutureBuilder for query and utilize ListView.builder to retrieve each DocumentSnapshot
from QuerySnapshot snapshot
4) Pass snapshot.data!docs[index].id to addFriends() to add user found UID to add to friends list
*/

class FriendSearch extends StatefulWidget {
  FriendSearch({Key? key}) : super(key: key);

  @override
  State<FriendSearch> createState() => _FriendSearchState();
}

class _FriendSearchState extends State<FriendSearch> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override

  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    List<dynamic> searchRes = [];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Color.fromRGBO(246, 245, 255, 1),
        leading: BackButton(color: Colors.black, onPressed:(){int count = 0;
                                            Navigator.of(context).popUntil((_) => count++ >= 2);}),
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search user',
            labelStyle: TextStyle(color: Colors.black45),
          ),
          onFieldSubmitted: (String _) { // whatever string enter --> isShowUsers for search results ON
            setState(() {
              isShowUsers = true;
            });
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: Text(AppLocalizations.of(context)!.friends, style: TextStyle(fontFamily: 'spoqa',fontSize: 18.sp,fontWeight: FontWeight.w400,color: Color.fromARGB(255, 61, 61, 61),),),
            ), 
            SizedBox(),
            Container(
              height: 240.h ,
              child: isShowUsers 
              ? FutureBuilder(
                future: FirebaseFirestore.instance.collection('userCollection').where('name',isEqualTo: searchController.text).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot userData = snapshot.data! as QuerySnapshot;
                    return ListView.builder(
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: (context, index) {
                        print((snapshot.data! as dynamic).docs[index]['name']);
                        print(user.uid);
              
                        // Don't show my own user
                        if ((snapshot.data! as dynamic).docs[index]['name'] == user.name
                        && (snapshot.data! as dynamic).docs[index].id == user.uid) {
                          return Text('');
                        }

                        // Don't show open profile(group) user
                        if (((snapshot.data! as dynamic).docs[index].id).substring(0,5) == "open:") {
                          return null;
                        }
                        
                        // Don't show people that blocked you
                        if ((snapshot.data! as dynamic).docs[index]['blockedUsers']
                        .contains(user.uid)) {
                          return Text('');
                        }
              
                        return Column(
                          children: [
                            SizedBox(height: 25),
                            ListTile(
                              leading: CircleAvatar(
                                radius: 27.0,
                                backgroundImage: (snapshot.data! as dynamic).docs[index]['photoUrl'] != '' ? CachedNetworkImageProvider((snapshot.data! as dynamic).docs[index]['photoUrl']) : null,
                              ),
                              title: Text((snapshot.data! as dynamic).docs[index]['name'],),
                              trailing: 
                              IconButton(
                                icon: Icon(Icons.add_box_rounded),
                                iconSize: 27,
                                onPressed: () {
                                  DatabaseService(uid : (snapshot.data! as dynamic).docs[index].id)
                                .sendFriendReq(user.uid, (snapshot.data! as dynamic).docs[index].id);
                                String notificationBody = "${user.name}"; 
                                sendPushNotification((snapshot.data! as dynamic).docs[index]['token'],
                                AppLocalizations.of(context)!.notification_friendRequest, notificationBody); 

                                showDialog(
                                  context: context,
                                  builder:(context) =>  AlertDialog(
                                      title: const Text('Request Sent'),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          child:Text(AppLocalizations.of(context)!.ok),
                                          onPressed: () {
                                            int count = 0;
                                            Navigator.of(context).popUntil((_) => count++ >= 3);
                                            // setState(() {});
                                          },
                                        ),
                                      ]
                                  ),
                                );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
              ): Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/logo_icon_whiteBG.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.search_friends, style: TextStyle(color:Color.fromARGB(115, 83, 83, 83), fontSize: 14.sp, fontFamily: 'spoqa', fontWeight: FontWeight.w400),),
                  ],
                ),
              ),
            ),
          ////// groups ////// 
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: Text(AppLocalizations.of(context)!.groups, style: TextStyle(fontFamily: 'spoqa',fontSize: 18.sp,fontWeight: FontWeight.w400,color: Color.fromARGB(255, 61, 61, 61),),),
            ), 
            SizedBox(),
          Container(
              height: 300.h,//
              child: isShowUsers 
              ? FutureBuilder(
                future: FirebaseFirestore.instance.collection('userCollection').where('name',isEqualTo: searchController.text).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot userData = snapshot.data! as QuerySnapshot;
                    return ListView.builder(
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: (context, index) {
                        print((snapshot.data! as dynamic).docs[index]['name']);
                        print(user.uid);
              
                        // Don't show my own user
                        if ((snapshot.data! as dynamic).docs[index]['name'] == user.name
                        && (snapshot.data! as dynamic).docs[index].id == user.uid) {
                          return Text('');
                        }

                        if (((snapshot.data! as dynamic).docs[index].id).substring(0,5) != "open:") {
                          return SizedBox();
                        }
                        
                        // Don't show people that blocked you
                        if ((snapshot.data! as dynamic).docs[index]['blockedUsers']
                        .contains(user.uid)) {
                          return Text('');
                        }
                        final group = MyUser(uid: (snapshot.data! as dynamic).docs[index].id);
              
                        return Column(
                          children: [
                            SizedBox(height: 25),
                            InkWell(
                              onTap: () async {
                                print("this is this ${((snapshot.data! as dynamic).docs[index].id)}");
                              // Navigator.push(context,
                                  // CustomPageRoute(
                                  // child: MyProfile(
                                  //     user: ((snapshot.data! as dynamic).docs[index].id)
                                  //     ),
                                  // direction: AxisDirection.up
                                  // )
                              // );
                            },
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 27.0,
                                  backgroundImage: (snapshot.data! as dynamic).docs[index]['photoUrl'] != '' ? CachedNetworkImageProvider((snapshot.data! as dynamic).docs[index]['photoUrl']) : null,
                                ),
                                title: Text((snapshot.data! as dynamic).docs[index]['name'],),
                                trailing: FollowButton(myUser: user, groupUser: group) 
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
              
                  else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
              ): Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/logo_icon_whiteBG.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.search_groups, style: TextStyle(color:Color.fromARGB(115, 83, 83, 83), fontSize: 14.sp, fontFamily: 'spoqa', fontWeight: FontWeight.w400),),
                  ],
                ),
              ),
            ),
            
          
          ],
        ),
      ),
    );
  }
}
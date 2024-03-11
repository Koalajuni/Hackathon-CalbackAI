import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/services/database.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  // 1) Receive search values from buildSearchField() and pass to handleSearch
  // 2) handleSearch() takes search query and gets all documents that match name >= query
  // 3) pass matching documents to searchResultsFuture --> use in main state widget build
  // to decide between buildNoContent or buildSearchResults

  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  final CollectionReference userCollection= FirebaseFirestore.instance.collection('userCollection');
  
  handleSearch(String query) {
    Future<QuerySnapshot> users = userCollection
      .where("name", isGreaterThanOrEqualTo: query)
      .get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch(),
          )
        ),
        onFieldSubmitted: handleSearch,
      )
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation; // Mediaquery returns info about device

    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true, // Resize when keyboard is brought up
          children: const <Widget> [
            Text('Find Users', textAlign: TextAlign.center, 
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        )
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        List<Text> searchResults = [];
        for (var doc in (snapshot.data as QuerySnapshot).docs) {
          //MyUser user = MyUser.fromDocument(doc);
          //searchResults.add(Text(user.name));
        }
        return ListView(
          children: searchResults,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  const UserResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Placeholder');
  }
}
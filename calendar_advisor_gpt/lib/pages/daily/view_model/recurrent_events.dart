import 'package:weekday_selector/weekday_selector.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';

class RecurrentEvents extends StatefulWidget {
  const RecurrentEvents({Key? key}) : super(key: key);

  @override
  RecurrentState createState() => RecurrentState();
}

class RecurrentState extends State<RecurrentEvents> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        appBar: AppBar(
          bottomOpacity: 0,
          elevation: 0,
          backgroundColor: Colors.white,
          toolbarHeight: 60,
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 30,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(),
      ),
    );
  }
}

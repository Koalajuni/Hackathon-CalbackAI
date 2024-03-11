import 'package:calendar/pages/chatgpt_stuff/backend/chat_api.dart';
import 'package:calendar/pages/chatgpt_stuff/backend/db_results.dart';
import 'package:calendar/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../models/userSchedule.dart';

class PromptTestingPage extends StatefulWidget {
  PromptTestingPage({Key? key}) : super(key: key);

  @override
  State<PromptTestingPage> createState() => _PromptTestingPageState();
}

class _PromptTestingPageState extends State<PromptTestingPage> {
  final TextEditingController textController = TextEditingController();
  bool hideTestPage = true;

  int patternsIndex = 0;
  String selectedPattern = '';
  late UserSchedule schedule;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackButton(),
                  Container(
                    child: Text(
                      'ChatGPT Prompt Testing',
                      style: TextStyle(
                        fontSize: 25
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Text('Enter patterns to test (use numbers): '),
              SizedBox(height: 5),
              Container(
                height: 30,
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1
                  )
                ),
                child: TextFormField(
                  controller: textController,
                  onFieldSubmitted: (String _) async {
                    final userSchedule = await DatabaseService(uid: user.uid).getUserSchedule(user.uid);
                    final parsedPatternIndex = int.parse(textController.text) - 1;
                    final parsedPatterString = DatabaseResults().patterns[parsedPatternIndex];

                    setState(() {
                      patternsIndex = parsedPatternIndex;
                      schedule = userSchedule;
                      selectedPattern = parsedPatterString;
                      hideTestPage = false;
                    });
                  }
                ),
              ),

              hideTestPage
                ? Container()
                : _TestingChatBot(
                    pattern: selectedPattern,
                    patternIndex: patternsIndex,
                    schedule: schedule,
                  )
            ]
          ),
        ),
      )
    );
  }
}

class _TestingChatBot extends StatefulWidget {
  _TestingChatBot({Key? key, this.pattern = '', this.patternIndex = 0, this.schedule}) : super(key: key);

  String pattern;
  int patternIndex;
  UserSchedule? schedule;

  @override
  State<_TestingChatBot> createState() => _TestingChatBotState();
}

class _TestingChatBotState extends State<_TestingChatBot> {
  List<String> results = [];
  var _messages = <ChatMessage>[];
  late bool awaitingResponse;
  late String initialRoleMessage;

  late UserSchedule? userSchedule;
  late String? message;

  @override
  void initState() {
    super.initState();

    awaitingResponse = false;
    userSchedule = widget.schedule;
    initialRoleMessage = widget.pattern;

    _getBotResponse(initialRoleMessage, widget.patternIndex, widget.schedule!.scheduleString);
  }

  Future<void> _getBotResponse(String pattern, int patternIndex, String schedule) async {
    awaitingResponse = true;

    print("started getBotREsponse...");
    final response = await DatabaseResults().queryChatGPT(pattern, patternIndex, schedule);
    
    if (mounted) {
      setState(() {
        results = response;
      });
    }

    awaitingResponse = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(results.toString())
    );
  }
}
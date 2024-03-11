import 'dart:io';

import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../models/userSchedule.dart';
import '../../../services/database.dart';
import '../backend/chat_api.dart';
import '../chat_dependencies.dart';
import 'message_bubble.dart';
import 'message_composer.dart';
import 'dart:ui' as ui;

class ChatBot extends StatefulWidget {
  const ChatBot({
    Key? key,
    required this.chatApi,
    required this.message,
    required this.userSchedule,
    this.location,
    this.timeframe,
  }) : super(key: key);

  final ChatApi chatApi;
  final String message;
  final UserSchedule userSchedule;
  final String? location;
  final String? timeframe;

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final _messages = <ChatMessage>[];
  late bool awaitingResponse;
  int dialogue_count = 0; 


  final initialRoleMessage = 
  "You are a schedule bot, give me a detailed schedule plan that accomplishes"
  + " the objective i will give you later,"
  +" make sure the events do not overlap with my schedule. "
  // formatting of output// 
  + "Always give the final answer in the following format: " 
  +"[2023-04-11 12:00, 2023-04-11 13:00, Content of Event],"
  +" [2023-04-11 15:00, 2023-04-11 16:00, Meeting with friends],[2023-04-12 12:00, 2023-04-12 14:00, Concert],[2023-04-14 14:00, 2023-04-15 15:00, Meeting]." 
  +" If objective does not make sense, ask user for clarification and make sure to lead answer to the format said before."
    +"Do not repeat my existing schedule in the answer. \n";

  final formatReminder = "Remember Always give the answer in the following format exactly: " 
  +"[2023-04-11 12:00, 2023-04-11 13:00, Content of Event],"
  +" [2023-04-11 15:00, 2023-04-11 16:00, Meeting with friends].";


  @override
  void initState() {
    super.initState();

    awaitingResponse = false;
      
    final location = (widget.location)!.isNotEmpty ? " in ${widget.location}" : ""; 
    final timeframe = (widget.timeframe) != null ? widget.timeframe : "next week"; 

    final scheduleTextForm = "This is my schedule: ${widget.userSchedule.scheduleString}\n";
    final objective = "My Objective: ${widget.message}${location} ${timeframe}  \n"; 


    // _messages.add(ChatMessage(initialRoleMessage, true, false));
    // _messages.add(ChatMessage(scheduleTextForm, true, false));
    _messages.add(ChatMessage(objective, true, false));
    _getBotResponse([
      ChatMessage(initialRoleMessage, true, false),
      ChatMessage(scheduleTextForm, true, false),
      ChatMessage(objective, true, false)  
      ]);

  }

  Future<void> _getBotResponse(List<ChatMessage> messages) async {
    awaitingResponse = true;

    print("started getBotREsponse...");
    final startTime = DateTime.now();

    final response = await widget.chatApi.getChatResponse(messages);
    
    if(dialogue_count % 2 == 0 && dialogue_count != 0){
      _remindBotFormat([ChatMessage(formatReminder, true, false)]); 
    }
  
    // Record the end time
    final endTime = DateTime.now();
    
    // Calculate the time taken by the API call
    final timeTaken = endTime.difference(startTime).inMilliseconds;
    
    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(response, false, false)); 
      });
    }

    awaitingResponse = false;
  }
  Future<void> _remindBotFormat(List<ChatMessage> messages) async {
    print("reminded Bot of the Format...");
    final response = await widget.chatApi.getChatResponse(messages);
  }

  @override
  Widget build(BuildContext context) {
  final user = Provider.of<MyUser>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('캘박AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: 
            ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  content: msg.content,
                  isUserMessage: msg.isUserMessage,
                  user: user
                );
              },
            )
          ),

          awaitingResponse 
            ? Stack(
              children: [
                IgnorePointer(
                  child: MessageComposer(
                    onSend: (message) async {
                      final chatMessage = ChatMessage(message, true, false);
                      setState(() {
                        _messages.add(chatMessage);
                      });
                      await _getBotResponse(_messages);
                    },
                  ),
                ),

                Positioned(
                  bottom: 60.h,
                  height: 24.h,
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 2.0, sigmaY: 2.0
                    ),
                    child: Container(color: Colors.transparent)
                  ),
                ),
                Center(child: CircularProgressIndicator()),
              ]
            )

            : MessageComposer(
                onSend: (message) async {
                  final chatMessage = ChatMessage(message, true, false);
                  setState(() {
                    _messages.add(chatMessage);
                  });
                  _getBotResponse(_messages);
                  dialogue_count += 1; 
                },
              ),
          
          // Row(
          //   children: [
          //     if (isWaitingForResponse)
          //       Expanded(
          //         child: Center(
          //           child: CircularProgressIndicator(),
          //         ),
          //       ),
          //     SizedBox(width: 16),
          //     Text("Here"),
          //   ],
          // )
        ],
      ),
    );
  }

}

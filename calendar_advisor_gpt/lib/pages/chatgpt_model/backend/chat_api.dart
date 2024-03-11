import 'dart:convert';

import 'package:dart_openai/openai.dart';
import 'package:http/http.dart' as http;

class ChatApi {
  static const _model = 'gpt-3.5-turbo';
  int retries = 0;

  Future<String> getChatResponse(List<ChatMessage> messages) async {
    
    final chatCompletion = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String> {
        'Content-Type' : 'application/json',
        'Authorization' : 'Bearer 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'
      },
      body: jsonEncode(<String, dynamic> {
        'model' : _model,
        'messages' : msgToJson(messages)
      })
    );

    if (chatCompletion.statusCode == 200) {
      return ChatMessage.fromJson(jsonDecode(chatCompletion.body)).content;
    }
    
    else if (chatCompletion.statusCode == 429) {
      retries++;
      if (retries >= 5) {return 'ERROR';}
      return await Future.delayed(Duration(milliseconds: 15000), () async {
        return await getChatResponse(messages);
      });
    }

    return 'ERROR';
  }

  List<Map<String, String>> msgToJson(List<ChatMessage> messages) {
    List<Map<String, String>> convertedMessages = [];

    messages.forEach((message) {
      convertedMessages.add(
        <String, String>{
          'role' : message.isSystemMessage
            ? 'system'
            : message.isUserMessage
              ? 'user'
              : 'assistant',

          'content' : message.content
        }
      );
    });

    return convertedMessages;
  }
}

class ChatMessage {
  ChatMessage(this.content, this.isUserMessage, this.isSystemMessage);

  final String content;
  final bool isUserMessage;
  final bool isSystemMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      json['choices'][0]['message']['content'],
      json['choices'][0]['message']['role'] == 'user' ? true : false,
      json['choices'][0]['message']['role'] == 'system' ? true : false
    );
  }
}
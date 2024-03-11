import 'package:calendar/pages/chatgpt_stuff/chat_dependencies.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.content,
    required this.isUserMessage,
    required this.user,
    Key? key,
  }) : super(key: key);

  final String content;
  final bool isUserMessage;
  final MyUser user;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isUserMessage
            ? themeData.colorScheme.primary.withOpacity(0.4)
            : themeData.colorScheme.secondary.withOpacity(0.4),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isUserMessage ? 'You' : 'AI',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(content),
                ],
              ),
            ),
            outputParsing(content, user.uid, user.name).isNotEmpty 
              ? InkWell(
                child: Container(
                  height: 35.h,
                  width: 35.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40.r)),
                    color: Color(0xFFFFFFFF)
                  ),
                  child: Icon(
                    Icons.arrow_right,
                    size: 40,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return GPTOutputViewer(user: user, message: content); 
                    })
                  );
                },
              )

              : Container()
          ],
        ),
      ),
    );
  }
}
import 'package:calendar/pages/chatgpt_stuff/backend/chat_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseResults{
  final CollectionReference resultsCollection =
      FirebaseFirestore.instance.collection('resultsCollection');

  List<String> patterns = [
    'From now on, “from” means the initial time of an event. “To” means the end of the event and “content” means the name of the event. I would like you to always answer in the following format only [from, to, content]. I would like you to choose events that don’t overlap with my current schedule.',
    'Whenever you produce an output, always answer in the following format only [from, to, content]. Produce answers considering my current schedule and make sure they don’t overlap.Recommend me a schedule based on my objective.',
    'Act as a secretary who will plan me out my next schedule based on my objective. All output should be in the following format “[from, to, content]”. Also, make sure that the answers don’t overlap with my current schedules. ',
    'Generate a schedule that matches my objective that follows the following format [from, to, content] and does not overlap with my current schedules.',
    'I would like to achieve my objective. I need to follow the following rules 1. Do not overlap with my current schedule 2. Always answer in the following format [from, to, content].',
    'I am going to provide a template for your output. Do not show output that overlaps with my current schedule. Try to fit the objective into the following template: Template is [from, to, content] and this is an example  "[2023-04-11 12:00, 2023-04-11 13:00, Content of Event]". Recommend me a schedule based on my objective.',
    'These are facts that will be needed for this prompt. Fact 1: Schedules should not overlap with each other, Fact 2: All output should follow [from, to, content] format. Generate a set of facts that are relevant to the objective. Recommend me a schedule based on my objective.',
    'Whenever you generate an answer, always follow the format: [from, to, content]. Reflect each output and determine whether it overlaps with my current schedule and, if it does, make sure to remove them. Also, reflect whether the answer follows the format and, if it doesn\'t, match the format. Recommend me a schedule based on my objective.',
    'From now on, whenever I give you a task, always find an answer that follows the format [from, to, content], and if this format is not possible re-interpret the task so that you can always answer in the format. Within the scope, check if each output overlaps with my current schedule and if it does remove it from the output. Recommend me a schedule based on my objective.',
    'Recommend me a schedule that achieves my objective. You need to follow two rules: 1. Always answer in the following format only [from, to, content]. 2. Produce answers considering my current schedule and make sure they don’t overlap. If there are alternative ways to accomplish the rules, list the best alternate approaches. Prompt me for which approach I would like to use. ',
    'When you are asked a prompt follow these rules: Do not overlap with my current schedule Always answer in the following format [from,to,content] Generate a number of additional questions that would help more accurately answer the questions that fit the rules. Combine the answers to the individual questions to produce the final answer that follow the rules. Recommend me a schedule based on my objective.',
    'Recommend me a schedule based on my objective. These are the absolute rules: 1. Always answer in the following format only [from, to, content]. 2. Produce answers considering my current schedule and make sure they don’t overlap. Whenever you can’t answer a question, provide alternative responses that match the rules above. Explain why you provided such responses.',
    'Recommend me a schedule based on my objective.I would like you to clarify for me until you can answer the objective following the rules. Rules: 1. Always answer in the following format only [from, to, content]. 2. Produce answers considering my current schedule and make sure they don’t overlap. You should ask questions until the output is met with the rules. ',
    'You are a schedule creator bot. Recommend me a schedule based on my objective. There are a few fundamental rules that need to be addressed: 1. Always answer in the following format only [from, to, content]. 2. Produce answers considering my current schedule and make sure they don’t overlap.',
    'Recommend me a schedule based on my objective. Always respond following the rules.  Rules: 1. Always answer in the following format only [from, to, content]. 2. Produce answers considering my current schedule and make sure they don’t overlap. Here is how to use the input I provide to show an output: [2023-04-11 12:00, 2023-04-11 13:00, Content of an Event].',
    'Recommend me a schedule based on my objective. Within the current schedules, find missing times that you can recommend events for me. Make sure that all answers are in the following format:  [from, to, content]. Consider this example for the format:   [2023-06-01 12:00, 2023-04-11 13:30, Content of an Event], [2023-06-02 11:00, 2023-06-04 11:30, Content of an Event],  [2023-04-11 18:00, 2023-04-11 18:20, Content of an Event]. Please ignore existing repetitive schedules.',
  ];

  List<String> inputs = [
    'Recommend me a home workout routine for next week',
    'Plan me out a weekend trip to Busan, I want to visit the best beaches',
    'I need to study for my Korea University NLP exam due in 1 week Plan me a study schedule I can spend 2 hours a day max',
    'Recommend me the best time and place for a quick drink with my friends in Seoul',
    'What events can I attend if I want to become a machine learning intern?',
    'Hi, recommend me fun events next week',
    'Full body workout routine for 2 weeks',
    'What hackathons are there that I can attend next week',
    'Recommend me fun concerts in 2 weeks',
    'What events will I be interested in starting next month? '
  ];

  void createPatternTemplate(int patternIndex) async {
    await resultsCollection
      .doc('pattern$patternIndex')
      .set({
        'pattern' : patterns[patternIndex]
      });
  }

  void writeResultsToDB(int patternNum, String input, String gptOutput) async {
    Map<String, dynamic> result = {input: gptOutput};
    await resultsCollection
      .doc('pattern$patternNum')
      .update(result);
  }

  Future<List<String>> queryChatGPT(String pattern, int patternIndex, String schedule) async {
    List<String> results = [];

    for (var j = 13; j < 16; j++) {
      DatabaseResults().createPatternTemplate(j);
      print('$j pattern number!!!!!!!!!');
      for (var i = 0; i < 10; i++) {
        List<ChatMessage> messages = [];
        String scheduleForm = "This is my schedule: ${schedule}\n";
        String objective = "My Objective: ${inputs[i]}\n";
        String formatReminder = "Always give the final answer in the following format: " 
                                "[2023-04-11 12:00, 2023-04-11 13:00, Content of Event],"
                                " [2023-04-11 15:00, 2023-04-11 16:00, Meeting with friends],[2023-04-12 12:00, 2023-04-12 14:00, Concert],[2023-04-14 14:00, 2023-04-15 15:00, Meeting]." 
                                " If objective does not make sense, ask user for clarification and make sure to lead answer to the format said before."
                                "Do not repeat my existing schedule in the answer. \n";
        messages.add(ChatMessage(patterns[j], true, false));
        messages.add(ChatMessage(formatReminder, true, false));
        messages.add(ChatMessage(scheduleForm, true, false));
        messages.add(ChatMessage(objective, true, false));
        final response = await ChatApi().getChatResponse(messages);
        DatabaseResults().writeResultsToDB(j, inputs[i], response);
        results.add(response);
        print('Round $i is done with result: $response');
        messages = [];
      }
    }

    return results;
  }
}
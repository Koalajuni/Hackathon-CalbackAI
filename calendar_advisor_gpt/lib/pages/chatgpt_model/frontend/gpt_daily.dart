import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/chatgpt_stuff/chat_dependencies.dart';
import 'package:calendar/pages/chatgpt_stuff/frontend/message_composer.dart';
import '../../daily/view/children_widgets/circular_time_picker.dart';
import '../backend/prompt_output_parsing.dart';
import 'chat_home_page.dart';
import 'package:intl/intl.dart';
import 'chatbot.dart';
import 'loading_screen.dart';


class GPTDaily extends StatefulWidget {
  final Meeting? meeting;
  const GPTDaily({Key? key, this.meeting}) : super(key: key);

  @override
  State<GPTDaily> createState() => _GPTDailyState();
}

class _GPTDailyState extends State<GPTDaily> {
  Map<String, CheckBoxState> checkbox = {};
  ValueNotifier _addedFriends = ValueNotifier<List<String>>([]);
  ValueNotifier tokens = ValueNotifier<List<String>>([]); 
  bool isEdit = false; //todo changes here
  final locationController = TextEditingController();
  bool needsUpdate = true;
  bool isSetUp = true;
  String formattedRecurrent = '반복';
  final showColorPopup colorPopup= showColorPopup();



  @override
  void initState() {
    super.initState();
    if (widget.meeting != null) {
      isEdit = true;
      final meeting = widget.meeting!;
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    messageController.dispose();
    super.dispose();
  }



  final _messages = <ChatMessage>[]; 

  //  final List<List<String>> meetingSchedule = [  ["August 17, 2022 at 10:00 AM UTC+9 - August 17, 2022 at 6:00 PM UTC+9, Startup"],
  // ["August 18, 2022 at 10:00 AM UTC+9 - August 18, 2022 at 6:00 PM UTC+9 , Startup Work"],
  // ["August 19, 2022 at 10:00 AM UTC+9 - August 19, 2022 at 6:00 PM UTC+9, Startup Meeting"],
  // ["August 21, 2022 at 11:00 AM UTC+9 - August 23, 2022 at 6:00 PM UTC+9, Deadline for Project"], 
  // ["August 24, 2022 at 7:00 PM UTC+9  - August 24, 2022 at 8:00 PM UTC+9, Gym"]
// ];

   final TextEditingController messageController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MeetingCreator>(
      create: ((context) => MeetingCreator()),
      child: Consumer<MeetingCreator>(
        builder: (context, meetingCreator, child)  {
          final user = Provider.of<MyUser>(context);
          final eventProvider =Provider.of<EventMaker>(context, listen: false);
           
          if (isSetUp) {
            meetingCreator.setDailyDate(eventProvider.dailyDate, eventProvider.dailyDate);
            isSetUp = false;
          }
          if (isEdit && needsUpdate) {
            widget.meeting!.involved.forEach((element) {
              checkbox["${element}"] = CheckBoxState(friendUid: element, value: true);
              _addedFriends.value.add(element);
            });
            _addedFriends.notifyListeners();
            meetingCreator.changeColor(widget.meeting!.background, !isEdit);
            meetingCreator.setDailyDate(widget.meeting!.from, widget.meeting!.to);
            meetingCreator.setDailyTime( widget.meeting!.from.toString().substring(11, 16), widget.meeting!.to.toString().substring(11, 16));
            meetingCreator.setDailyAngles(convertToAngle(widget.meeting!.from.hour, widget.meeting!.from.minute),convertToAngle(widget.meeting!.to.hour, widget.meeting!.to.minute));
            meetingCreator.setRecurrenceRule(widget.meeting!.recurrenceRule!);
            needsUpdate = false;
          }
          bool _isExpanded = false;
          return Dismissible(
            direction: DismissDirection.horizontal,
            key: const Key('key'),
            onDismissed: (_) => Navigator.of(context).pop(),
            child: Scaffold(
              resizeToAvoidBottomInset: true,

              appBar: PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: AppBar(
                  shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
                  automaticallyImplyLeading: false,
                  bottomOpacity: 0,
                  elevation: 4,
                  backgroundColor: Color(0xFFD9E5FE),
                  toolbarHeight: 60,
                  iconTheme: IconThemeData(
                    color: Colors.black,
                    size: 30,
                  ),
                  leading: BackButton(),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [ 
                      SizedBox(width: 100),
                      Text(
                        '일정 추천',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Arizonia',
                          fontSize: 18.sp,
                          color: Color(0xFF303030),
                        )
                      ),
                    ]
                  ),
                ),
              ),
              
              body: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Description
                        Container(
                          height: 64.h,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFCCCDDC),
                                width: 2.w,
                              )
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: Container(
                                  child: Image.asset('assets/icons/checklist.png', width: 24, height: 24,),
                                  height: 40, width: 40,
                                  color: Color(0xff5E5CEC),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: SizedBox(
                                  height: 22.h, width: 200.w,
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontFamily: 'PretendardVar',
                                      fontWeight: FontWeight.bold
                                    ),
                                    decoration: InputDecoration(
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: const EdgeInsets.fromLTRB(0, 6, 2, 0),
                                      isDense: true, // this allows txt input to be well input without getting cut
                                      hintText: '원하는 목표를 입력하세요',
                                      hintStyle: TextStyle(color: Color.fromARGB(255, 203, 202, 202)),
                                    ),
                                    onFieldSubmitted: (_) => {},
                                    validator: (content) => content != null && content.isEmpty ? 'content cannot be empty': null,
                                    controller: messageController,
                                  ),
                                ),
                              ),
                             
                            ],
                          ),
                        ),
                 Container(
                   decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFCCCDDC),
                                width: 2.w,
                              )
                            )
                          ),
                   child: CircularTimePicker(isEdit: isEdit)
                   ),
                        // Title write and color picker
                        Container(           
                          height: 56.h,
                          color: meetingCreator.color.withOpacity(0.2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 20.w),
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: meetingCreator.color
                                  ),
                                padding: EdgeInsets.zero,
                                child: Icon(Icons.pin_drop, size: 15, color: Colors.white),
                              ),
                            ),
                              SizedBox(width: 16.w),
                              ConstrainedBox(
                                constraints: BoxConstraints.tightFor(height: 38.h, width: 300.w),
                                child: TextFormField(
                                  style: TextStyle( fontSize: 16.sp, fontFamily: 'Spoqa', fontWeight: FontWeight.w400),
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.fromLTRB(0, 6, 2, 0),
                                    isDense: true, // this allows txt input to be well input without getting cut
                                    hintText: '원하는 장소 있을 시 설정',
                                  ),
                                  onFieldSubmitted: (_) => {},
                                  validator: (content) => content != null && content.isEmpty ? 'content cannot be empty': null,
                                  controller: locationController,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 50.h, width: 328.w,
                              child: TextButton(
                                onPressed: () async {
                                  final userSchedules = await DatabaseService(uid: user.uid).getUserSchedule(user.uid);
                                  final timeframe_1 = meetingCreator.dailyDate[0].toString(); 
                                  final timeframe_2 = meetingCreator.dailyDate[1].toString()+ meetingCreator.dailyTime[1];
                                  final timeframe = "from ${timeframe_1.substring(0,11) + meetingCreator.dailyTime[0] } to ${timeframe_2.substring(0,11)+ meetingCreator.dailyTime[1]}"; 
                                  print("this is the timeframe $timeframe");

                                  Navigator.of(context).pop();
                                
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return ChatBot(chatApi: ChatApi(), 
                                      message: messageController.text, 
                                      userSchedule: userSchedules, 
                                      location: locationController.text,
                                      timeframe: timeframe,
                                        );
                                    })
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFF565778),
                                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(50.r)),
                                ),
                                child: Text(
                                  '추천 일정표 생성하기',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontFamily: 'PretendardVar',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 30)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ));
  }

}

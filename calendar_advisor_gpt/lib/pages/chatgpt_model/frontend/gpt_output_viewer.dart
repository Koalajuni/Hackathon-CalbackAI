import 'package:calendar/pages/chatgpt_stuff/chat_dependencies.dart';
import 'package:intl/intl.dart';

class GPTOutputViewer extends StatefulWidget{
  const GPTOutputViewer({Key? key, required this.user, this.gptMeetings, this.message}) : super(key: key);

  final MyUser user;
  final List<Meeting>? gptMeetings;
  final String? message;

  @override
  _GPTOutputViewerState createState() => _GPTOutputViewerState();
}

class _GPTOutputViewerState extends State<GPTOutputViewer> {
  final uiSettingFont = FontSetting();
  late List<Meeting> outputMeetings;

  @override
  void initState() {
    super.initState();
    if (widget.message != null) {
      outputMeetings = outputParsing(widget.message!, widget.user.uid, widget.user.name);;
    }

    else {
      outputMeetings = widget.gptMeetings!;
    }

  }

  @override
  Widget build(BuildContext context) {
    final myUser = widget.user;
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Color(0xffF6F6F6),
        appBar: AppBar(
          bottomOpacity: 0,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 30,
          ),
          backgroundColor: Colors.white,
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          title: Row( //TODO
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BackButton()),
                SizedBox(width: 78.w),
              Text('주천된 일정표',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: 'Spoqa',
                  fontWeight: FontWeight.w500
                )
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: SelectionMeetingList(gptOutputs: outputMeetings,),
      ),
    );
  }
}

class SelectionMeetingList extends StatefulWidget {
  SelectionMeetingList({Key? key, required this.gptOutputs}) : super(key: key);

  final List<Meeting> gptOutputs;

  @override
  State<SelectionMeetingList> createState() => _SelectionMeetingListState();
}

class _SelectionMeetingListState extends State<SelectionMeetingList> {
  late List<Meeting> gptOutputsEditable = widget.gptOutputs;

  callback(String midForRemoval) {
    setState(() {
      gptOutputsEditable.removeWhere((item) => item.MID == midForRemoval);
    });
  }

  saveAll() {
    setState(() {
      gptOutputsEditable = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20.w, top: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 50.h,
                  width: 102.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF565778),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 24.w, height: 24.h,
                          child: Image.asset('assets/icons/calendar_add_white.png', width: 20.w, height: 20.h,)
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '모두 등록',
                          style: TextStyle(
                            fontFamily: 'Spoqa',
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: Color(0xFFFFFFFF)
                          ),
                        ),
                      ]
                    ),
                    onTap: () async {

                      for (var gptOutput in gptOutputsEditable) {
                        await saveGPTForm(
                          null,
                          gptOutput.content,
                          gptOutput.owner,
                          gptOutput.background,
                          [],
                          false,
                          [gptOutput.from, gptOutput.to],
                          "",
                        );
                      }

                      saveAll();
                    }
                  )
                ),
              ],
            ),
          ),
          gptOutputsEditable.length > 0 ? Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 20.w),
            child: Text(
                DateFormat('MM.dd').format(gptOutputsEditable[0].from),
                style: TextStyle(
                  fontFamily: 'Spoqa',
                  fontWeight: FontWeight.w500,
                  fontSize: 18.sp,
                  color: Color(0xFF222222)
                )
              ),
          )
          : Container(),

          gptOutputsEditable.length > 0 ? Center(
            child: SizedBox(
              width: 320.w,
              child: Column(
                children: [
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: gptOutputsEditable.length,
                    separatorBuilder: (BuildContext context, int index) => DateFormat('MM-dd').format(gptOutputsEditable[index + 1].from) != DateFormat('MM-dd').format(gptOutputsEditable[index].from) 
                        ? Padding(
                          padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                          child: Text(
                            DateFormat('MM.dd').format(gptOutputsEditable[index + 1].from),
                            style: TextStyle(
                              fontFamily: 'Spoqa',
                              fontWeight: FontWeight.w500,
                              fontSize: 18.sp,
                              color: Color(0xFF222222)
                            )
                          ),
                        )
                        : SizedBox(height: 20.h),
                    itemBuilder: (BuildContext context, int index) {
                      return SelectionMeetingTile(gptOutput: gptOutputsEditable[index], callback: callback);
                    },
                  ),
                ],
              ),
            ),
          )
          : Container()
        ],
      ),
    );
  }
}

class SelectionMeetingTile extends StatefulWidget {
  SelectionMeetingTile({Key? key, required this.gptOutput, required this.callback}) : super(key: key);

  final Meeting gptOutput;
  final Function callback;

  @override
  State<SelectionMeetingTile> createState() => _SelectionMeetingTileState();
}

class _SelectionMeetingTileState extends State<SelectionMeetingTile> {
  final uiSettingFont = FontSetting();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      width: 320.w,
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Padding(
        padding: EdgeInsets.all(14.h),
        child: Row(
          children: [
            Container(
              width: 6.w,
              height: 62.h,
              color: widget.gptOutput.background
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: SizedBox(
                width: 245.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.gptOutput.content,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: 'Spoqa',
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: Color(0xFF222222)
                      )
                    ),
              
                    SizedBox(height: 5.h),
              
                    Text(
                      "${DateFormat('HH').format(widget.gptOutput.from)}시 - ${DateFormat('HH').format(widget.gptOutput.to)}시",
                      style: TextStyle(
                        fontFamily: 'Spoqa',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Color(0xFF555555)
                      )
                    ),
                  ],
                ),
              ),
            ),

            InkWell(
              child: Image.asset('assets/icons/calendar_add.png', width: 20.w, height: 20.h,),
              onTap: () async {
                await saveGPTForm(
                  null,
                  widget.gptOutput.content,
                  widget.gptOutput.owner,
                  widget.gptOutput.background,
                  [],
                  false,
                  [widget.gptOutput.from, widget.gptOutput.to],
                  "",
                );

                widget.callback(widget.gptOutput.MID);
              }
            )
          ],
        ),
      )
    );
  }
}


import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/daily/view_model/weekday_translator.dart';
import 'package:calendar/pages/events/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/single_child_widget.dart';

import '../../../../l10n/change_language.dart';
import '../../view_model/meeting_creator.dart';
import '../../view_model/color_picker.dart';
import '../../../../shared/calendar_functions.dart';

double container_width = 64.0;
double container_height = 74.0;

class HorizontalDatePicker extends StatefulWidget {
  bool isEdit;
  HorizontalDatePicker({
    Key? key,
    this.isEdit = false,
  }) : super(key: key);

  @override
  State<HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<HorizontalDatePicker> {
  int index = 90;
  ScrollController _scrollController =
      ScrollController(initialScrollOffset: (90 * (container_width + 16) - 20));
  DateTime now = DateTime.now();
  double currentOffset = 90 * container_width;
  DateTime current_date = DateTime.now();
  int day_for_multiple = 90;
  bool isSetUp = true;
  bool isMultiDay = true;

  List<DateTime> muiltiDays = [DateTime.now(), DateTime.now()];
  List<int> muiltiIndexes = [-1, -1];
  _scrollListener() {}
  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<ChangeLanguage>(context);
    final meetingCreator = Provider.of<MeetingCreator>(context, listen: false);
    if (isSetUp) {
      muiltiIndexes[0] = index;
      now = meetingCreator.dailyDate[0];
      current_date = meetingCreator.dailyDate[0];
      isSetUp = false;
      if (widget.isEdit) {
        int index = 90 + meetingCreator.dailyDate[0].difference(now).inDays;
        muiltiIndexes[0] = index;
        now = meetingCreator.dailyDate[0];
        current_date = meetingCreator.dailyDate[0];
      }
    }

    DateTime dates_to_cover = now.subtract(const Duration(days: 90 + 1));
    return Container(
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          child: Row(
            children: List.generate(365, (index) {
              dates_to_cover = dates_to_cover.add(const Duration(days: 1));
              return Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isMultiDay) {
                          muiltiDays[1] =
                              dateOnly(now).add(Duration(days: index - 90));
                          muiltiIndexes[1] = index;
                          muiltiDays.sort();
                          muiltiIndexes.sort();
                          meetingCreator.setDailyDate(
                              muiltiDays[0], muiltiDays[1]);
                          meetingCreator.setErrorMsg("");
                          isMultiDay = false;
                        } else {
                          isMultiDay = true;
                          muiltiIndexes[0] = muiltiIndexes[1] = -1;
                          muiltiDays[0] =
                              dateOnly(now).add(Duration(days: index - 90));
                          muiltiIndexes[0] = index;
                          meetingCreator.setDailyDate(
                              muiltiDays[0], muiltiDays[0]);
                          _scrollController.animateTo(
                              index * (container_width + 16) - 20,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeIn);
                        }
                      });
                    },
                    child: Container(
                      width: container_width,
                      height: container_height,
                      decoration: (index == muiltiIndexes[0])
                          ? BoxDecoration(
                              color: meetingCreator.color,
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                  right: Radius.circular(8)))
                          : (index > muiltiIndexes[0] &&
                                  index < muiltiIndexes[1])
                              ? BoxDecoration(
                                  color: meetingCreator.color.withOpacity(0.3),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))
                              : (index == muiltiIndexes[1]
                                  ? BoxDecoration(
                                      color: meetingCreator.color,
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(8),
                                          right: Radius.circular(16)))
                                  : BoxDecoration(
                                      color: Color.fromRGBO(247, 247, 247, 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8)))),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text(DateFormat.d().format(dates_to_cover),
                                  style: TextStyle(
                                      color: (index == muiltiIndexes[0] ||
                                              index == muiltiIndexes[1])
                                          ? Colors.white
                                          : (index > muiltiIndexes[0] &&
                                                  index < muiltiIndexes[1])
                                              ? Colors.black
                                              : Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'GmarketSans',
                                      fontWeight: FontWeight.w700)),
                            ),
                            Container(
                                child: Text(
                                    languageProvider.locale == 'en'
                                        ? DateFormat.E().format(dates_to_cover)
                                        : translateWeekday2Korean(DateFormat.E()
                                            .format(dates_to_cover)),
                                    style: TextStyle(
                                        color: (index == muiltiIndexes[0] ||
                                                index == muiltiIndexes[1])
                                            ? Colors.white
                                            : (index > muiltiIndexes[0] &&
                                                    index < muiltiIndexes[1])
                                                ? Colors.black
                                                : Colors.black,
                                        fontSize: 14,
                                        fontFamily: 'Spoqa',
                                        fontWeight: FontWeight.w500))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  index == muiltiIndexes[0]
                      ? Container(
                          height: container_height,
                          width: 4,
                          decoration: BoxDecoration(
                              color: meetingCreator.color.withOpacity(0.3),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))))
                      : Container(),
                  SizedBox(
                    width: 8,
                  ),
                ],
              );
            }),
          )),
    );
  }
}

//Container(
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(50),
                            //   color: meetingCreator.color.withOpacity(0.3),
                            // ),
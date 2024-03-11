import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/daily/view/children_widgets/color_theme_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../events/event_maker.dart';
import '../../view_model/meeting_creator.dart';

class PopupColorPicker extends StatefulWidget {
  const PopupColorPicker({Key? key}) : super(key: key);

  @override
  State<PopupColorPicker> createState() => _PopupColorPickerState();
}

class _PopupColorPickerState extends State<PopupColorPicker> {
  int colorIndex = 0;
  @override
  Widget build(BuildContext context) {
    final meetingCreator = Provider.of<MeetingCreator>(context, listen: false);
    int color_theme = meetingCreator.color_theme;
    return InkWell(
      onTap: (){
        showDialog(
          context: context, 
          barrierColor: Colors.white.withOpacity(0),
          builder: (context) {
          return Stack(
            children: [
              Positioned(
                left: 10,
                top: 474,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        blurRadius: 20,
                        offset: Offset(0.0, 2.0)
                      )
                    ]
                  ),
                  width: 268,
                  child: AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    insetPadding: EdgeInsets.zero,
                    elevation: 0,
                    content: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Color.fromRGBO(85, 98, 254, 1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 56,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: meetingCreator.colors_list[color_theme].length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  child: Container(
                                    child: index == colorIndex ? Icon(Icons.check, color: Colors.white,) : null,
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: meetingCreator.colors_list[color_theme][index]
                                  )),
                                ),
                                onTap: (){
                                    Navigator.pop(context);
                                    colorIndex = index;
                                    meetingCreator.changeColor(meetingCreator.colors_list[color_theme][colorIndex], true);
                                },
                              );
                            }, 
                            separatorBuilder: (_,__) {
                              return SizedBox(width: 16,);
                            }
                          ),
                          SizedBox(width: 16,),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff5562FE)
                              ),
                            ),
                          )
                        ]
                      ),
                    )
                    ),
                ),
              )
            ],
          );
        });
      },
      child: SizedBox(
        height: 24,
        width: 24,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: meetingCreator.color
            ),
          padding: EdgeInsets.zero,
          child: Icon(Icons.brush, size: 15, color: Colors.white),
        ),
      ),
    );
  }
}

import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/daily/view_model/meeting_creator.dart';
import 'package:flutter/material.dart';

class ColorThemePicker extends StatefulWidget {
  const ColorThemePicker({Key? key}) : super(key: key);

  @override
  State<ColorThemePicker> createState() => _ColorThemePickerState();
}

class _ColorThemePickerState extends State<ColorThemePicker> {
  @override
  Widget build(BuildContext context) {
    final meetingCreator = Provider.of<MeetingCreator>(context, listen: false);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index){
                return InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      index == meetingCreator.color_theme 
                        ? Icon(Icons.check, size: 24,)
                        : SizedBox(width: 24,)
                      ,
                      Container(
                        width: 24*6,
                        height: 24,
                        child: 
                          ListView.builder(
                            itemCount: meetingCreator.colors_list[index].length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index2){
                              return Container(height: 24, width: 24, color: meetingCreator.colors_list[index][index2]);
                            }),
                      ),
                    ],
                  ),
                  onTap: (){
                    setState(() {
                      meetingCreator.changeColorTheme(index);
                    });
                  },
                );
              }, 
              separatorBuilder: (context, index){
                  return SizedBox(height: 20);
              }, 
              itemCount: meetingCreator.colors_list.length
            ),
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 24),
                OutlinedButton(
                  child: Container(
                    height: 24,
                    width: 100,
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        Text("add theme")
                      ],
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    fixedSize: Size(100,24)
                  ),
                  onPressed: (){
                    showDialog(
                      context: context, 
                      builder: (_){
                        return SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: meetingCreator.color,
                            onColorChanged: (color){},
                          )
                        );
                      }
                    );
                  }
                ),
              ],
            )
          ],
        )
      ),
    );
  }
}
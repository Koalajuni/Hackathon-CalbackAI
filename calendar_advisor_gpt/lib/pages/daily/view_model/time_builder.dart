import 'package:flutter/material.dart';
import 'dart:math';

import '../../all_pages.dart';

class TimeSetter{    // Setting a time value to changes in the circular slider
// 3 functions.

Widget getStringDay(DateTime date){
  return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text((date.toString()).substring(0,10), style:TextStyle(
          fontSize: 16,
          fontFamily: 'Spoqa',
          fontWeight: FontWeight.w500
        ),),
      ],
    );
}

  Widget getTime(String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(time, style:TextStyle(
          fontSize: 16,
          fontFamily: 'Spoqa',
          fontWeight: FontWeight.w500
        ),),
      ],
    );
  }

   String getStringTime(DateTime time){
    return (time.toString()).substring(11,16); 
    
  }

  String formatTime(int? time){
    if (time == null || time == 0){
      return '12:00';
    }
    var hours = time ~/ 12;
    var minutes = (time % 12) * 5;
    if(hours > 12) {
      hours = hours - 12;
      if(hours < 10){
        if(minutes < 10){
          return '0$hours:0$minutes';
        }
        else{
          return '0$hours:$minutes';
        }
      }
    }
    else{
      if(hours == 12){
        if(minutes <10){
          return '00:0$minutes';
        }
        return '00:$minutes';
      }
      hours = hours + 12;
    }

    if(minutes <10){
      return '$hours:0$minutes';
    }
    return '$hours:$minutes';
  }




  String formatIntervalTime(int? start, int? end){
    if(start == null || end == null){
      start = 0;
      end = 0;
    }
    var inBetweenTime = end > start ? end - start: 288 - start + end;
    var hours = inBetweenTime ~/ 12;
    var minutes = (inBetweenTime % 12) * 5;
    if(hours < 1){
      return '${minutes}m';
    }
    return '${hours}h${minutes}m';
  }


}

class TimeBuilder extends CustomPainter{   // This will paint the clock inside the circular slider
  //todo 1 logical pixel(flutter) = 38 pixels (design)

  final hourTickLength = 8;   //272 pixels
  final minuteTickLength = 3.0; //
  final hourTickWidth = 1.0;
  final minuteTickWidth = 1.0;

  late final Paint tickPaint;
  late final TextPainter textPainter;
  late final TextStyle textStyle;

  TimeBuilder():tickPaint= Paint(),
        textPainter = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        textStyle = const TextStyle(
          color: Color.fromRGBO(85, 85, 85,85), // (grey hex: B2ABA8),
          fontSize: 15.0,
        )
  {
    tickPaint.color= Color.fromRGBO(85, 85, 85,85); // (grey hex: B2ABA8)
  }

  @override
  paint(Canvas canvas, Size size){
    dynamic tickMarkLength;
    const angle= 2* pi / 120;
    late double radius;

    radius = min(size.width / 2, size.height / 2);

    canvas.save();

    canvas.translate(radius, radius);
    for (var i = 0; i< 120; i++ ) {
      //make the length and stroke of the tick marker longer and thicker depending
      tickMarkLength = i % 5 == 0 ? hourTickLength: minuteTickLength;
      tickPaint.strokeWidth= i % 3 == 0 ? hourTickWidth : minuteTickWidth;
      canvas.drawLine(
          Offset(.0, -radius+ 2), Offset(0.0, -radius+tickMarkLength + 2), tickPaint);


      //draw the text
      if (i%30==0){  // number here represents: 5 (all hours), 10 (every two hours), 30 (every 6 hours).
        canvas.save();
        canvas.translate(0.0, -radius+30.0);


        textPainter.text= TextSpan(
          text: '${i == 0 ? 12 : i > 60 ? (i~/5)-12 : (i~/5)+12}',  // adjusted to match the circular slider time.
          style: textStyle,
        ); // ask Jun if this doesn't make sense.

        //helps make the text painted vertically
        canvas.rotate(-angle*i);

        textPainter.layout();


        textPainter.paint(canvas, Offset(-((textPainter.width/2)), -((textPainter.height/2))));

        canvas.restore();

      }

      canvas.rotate(angle);
    }

    canvas.restore();

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate){
    return false;
  }
}

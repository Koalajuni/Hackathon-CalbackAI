int convertHours(hours) {
  if (hours < 12) {
    int _result = ((hours + 12) * 12);
    return (_result);
  } else {
    int _result = ((hours - 12) * 12);
    return (_result);
  }
} // all hours -> angles are (hour - 12 ) * 12

int convertMinutes(minutes) {
  int _result = (minutes ~/ 5);
  return (_result);
} // all minutes -> angles are ((minutes/5) * 5)

int convertToAngle(hour, minute) {
  int angle = 0;
  angle = convertHours(hour) + convertMinutes(minute);
  return angle;
}

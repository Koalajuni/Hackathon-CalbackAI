import 'package:get/get.dart';

class DateController extends GetxController{
  Rx<DateTime> headerDate = DateTime.now().obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  changeDate(DateTime date) => selectedDate.value = date;
  void changeHeaderDate(DateTime date) {
    headerDate.value = date;
    update();
  }
}

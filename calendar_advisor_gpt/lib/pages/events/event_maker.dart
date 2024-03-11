import 'package:calendar/models/meeting.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/services/database.dart';
import 'package:flutter/material.dart';
import 'package:calendar/shared/globals.dart' as globals;

import '../ui_settings.dart';

class EventMaker extends ChangeNotifier {
  List<Meeting> _events = [];
  Map<DateTime, List<Meeting>> _agenda = {};
  late DateTime _currentDate = dateOnly(DateTime.now());
  late DateTime _dailyDate = dateOnly(DateTime.now());
  late String _dailyTime = DateTime.now().toString().substring(11, 16);

  List<Meeting> get events => _events;
  Map<DateTime, List<Meeting>> get agenda => _agenda;
  DateTime get currentDate => _currentDate;
  DateTime get dailyDate => _dailyDate;
  String get dailyTime => _dailyTime;

  // Future initAgenda(String UID) async {
  //   _agenda = {};
  //   await updateEventMaker(UID);
  //   DateTime now = DateTime.now();
  //   _events.forEach((element) {
  //     if(element.from.year == now.year &&
  //        element.from.month == now.month &&
  //        element.from.day == now.day)
  //        {
  //           _agenda.add(element);
  //        }
  //   });
  //   notifyListeners();
  // }

  void setDailyDate(DateTime dailyDate) {
    _dailyDate = dateOnly(dailyDate);
  }

  void setDailyTime(String dailyTime) {
    _dailyTime = dailyTime;
  }

  void setCurrentDate(DateTime currentDate) {
    _currentDate = dateOnly(currentDate);
  }

  void resetAgenda() {
    _agenda = {};
    notifyListeners();
  }

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;
  List<Meeting> get eventsOfSelectedDate => _events;

  void setLocalEvent(List<Meeting> meetings) {
    _events == meetings;
  }

  Future updateEventMaker(String UID) async {
    _events = await DatabaseService(uid: UID).getMeetings() as List<Meeting>;

    //agenda 처리
    _agenda = {};
    _events.forEach((meetingElement) {
      if (meetingElement.MID.substring(0, 7) != 'pending') {
        if (_agenda[dateOnly(meetingElement.from)] == null) {
          _agenda[dateOnly(meetingElement.from)] = [meetingElement];
        } else if (_agenda[dateOnly(meetingElement.from)] != null) {
          //_agenda[dateOnly(meetingElement.from)]!.add(meetingElement);
          bool addToAgenda = true;
          _agenda[dateOnly(meetingElement.from)]!.forEach((agendaElement) {
            if (agendaElement.MID == meetingElement.MID) {
              addToAgenda = false;
            }
          });
          if (addToAgenda) {
            _agenda[dateOnly(meetingElement.from)]!.add(meetingElement);
          }
        }
      }
    });
    _agenda.forEach((key, value) {
      print(key);
      //각 날짜별 시간을 sort
      _agenda[key]!.sort(((a, b) => a.from.compareTo(b.from)));
      _agenda[key]!.forEach((element) {
        print(element.content);
      });
    });
    notifyListeners();
  }

  DateTime dateOnly(DateTime dateTimeForFilter) {
    DateTime date = DateTime(
        dateTimeForFilter.year, dateTimeForFilter.month, dateTimeForFilter.day);
    return date;
  }

  Future addEvent(Meeting event, String UID) async {
    bool addToEvent = true;
    _events.forEach((meetingElement) {
      if (meetingElement.MID == event.MID) {
        addToEvent = false;
      }
    });
    if (addToEvent) {
      _events.add(event);

      //agenda 처리
      if (_agenda[dateOnly(event.from)] == null) {
        _agenda[dateOnly(event.from)] = [event];
      } else if (_agenda[dateOnly(dateOnly(event.from))] != null) {
        _agenda[dateOnly(event.from)]!.add(event);
      }
      _agenda.forEach((key, value) {
        print(key);
        //각 날짜별 시간을 sort
        _agenda[key]!.sort(((a, b) => a.from.compareTo(b.from)));
      });
      notifyListeners();
      await DatabaseService(uid: UID).addMeetings(event);
      await updateEventMaker(UID);
      notifyListeners();
    }
  }

  Future acceptKakaoEvent(Meeting event, String myUid) async {
    bool addToEvent = true;
    event.involved.add(myUid);
    _events.forEach((meetingElement) {
      if (meetingElement.MID == event.MID) {
        addToEvent = false;
      }
    });
    if (addToEvent) {
      print(event.involved);
      _events.add(event);

      //agenda 처리
      if (_agenda[dateOnly(event.from)] == null) {
        _agenda[dateOnly(event.from)] = [event];
      } else if (_agenda[dateOnly(dateOnly(event.from))] != null) {
        _agenda[dateOnly(event.from)]!.add(event);
      }
      _agenda.forEach((key, value) {
        print(key);
        //각 날짜별 시간을 sort
        _agenda[key]!.sort(((a, b) => a.from.compareTo(b.from)));
      });
      notifyListeners();
      await DatabaseService(uid: myUid)
          .acceptMeetReq(myUid, event.owner, event.MID);
      await updateEventMaker(myUid);
      notifyListeners();
    }
  }

  Future editEvent(Meeting newEvent, Meeting oldEvent, String UID) async {
    // newEvent.MID = oldEvent.MID;
    final mid = oldEvent.MID;
    await DatabaseService(uid: UID).updateMeetings(newEvent, oldEvent);
    await updateEventMaker(UID);

    notifyListeners();
  }

  Future deleteEvent(Meeting event, String UID) async {
    _events.remove(event);

    //agenda 처리
    if (_agenda[dateOnly(event.from)] != null) {
      final indexAgenda = _agenda[dateOnly(event.from)]!
          .indexWhere((element) => element.MID == event.MID);
      try {
        _agenda[dateOnly(event.from)]!.removeAt(indexAgenda);
        if (_agenda[dateOnly(event.from)]!.isEmpty) {
          //if empty key, delete
          _agenda.remove(dateOnly(event.from));
        }
        notifyListeners();
      } catch (e) {
        print("Error on delete Event: ${e}");
      }
      print("agenda Removed");
    }
    await DatabaseService(uid: UID).deleteMeetings(event.MID);
    await updateEventMaker(UID);
    notifyListeners();
  }

  void resetEvent() {
    _events.clear();
    _agenda.clear();
    _currentDate = DateTime.now();
    notifyListeners();
  }
}

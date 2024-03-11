import "package:calendar/services/database.dart";
import "package:shared_preferences/shared_preferences.dart";

class SharedPreferencesFunctions {
  Future checkNotifications(String uid) async {
    final openProfilesData = await DatabaseService(uid: uid).getOpenProfilesData();

    Map<String, dynamic> notifications = {};
    final prefs = await SharedPreferences.getInstance();

    // await prefs.clear();

    final Set<String> localGroupUids = prefs.getKeys();

    for (var name in openProfilesData.keys) {
      var notificationData = openProfilesData[name];

      if (!localGroupUids.contains(name)) {
        if (notificationData[0] != 'true' || notificationData[0] != 'false') {
          notificationData.insert(0, 'true');
        }
        notifications[name] = notificationData;
        await prefs.setStringList(name, notifications[name] as List<String>);
        continue;
      }

      final List<String>? localGroupData = prefs.getStringList(name);

      if (localGroupData![0] == 'true') {
        if (notificationData[0] != 'true' || notificationData[0] != 'false') {
          notificationData.insert(0, 'true');
        }
        notifications[name] = notificationData;
        await prefs.setStringList(name, notifications[name] as List<String>);
        continue;
      }

      for (var meeting in openProfilesData[name]) {
        if (!localGroupData!.contains(meeting)) {
          if (notificationData[0] != 'true' || notificationData[0] != 'false') {
            notificationData.insert(0, 'true');
          }
          notifications[name] = notificationData;
          await prefs.setStringList(name, notifications[name] as List<String>);
          continue;
        }
      }

      if (notificationData[0] != 'true' || notificationData[0] != 'false') {
        notificationData.insert(0, 'false');
      }
      notifications[name] = notificationData;
    }

    return notifications;
  }

  Future notificationReset(List<String> groupData, String id) async {
    List<dynamic> resetGroupData = groupData;
    resetGroupData[0] = 'false';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(id, resetGroupData as List<String>);
  }
}
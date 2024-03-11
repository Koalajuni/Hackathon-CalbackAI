import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart' as http;

class GoogelCalendarServices {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        'calback-fdeeb@appspot.gserviceaccount.com',
    scopes: <String>[
      CalendarApi.calendarScope,
    ],
  );

  Future connectGoogleCalendar() async{
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    var httpClient = (await _googleSignIn.authenticatedClient())!;

    Event event = Event();
    CalendarApi calendarApi = CalendarApi(httpClient);
    var response = await calendarApi.events.list("primary");
    response.items!.forEach((element) { 
      print(element);
    });
  }
}
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseAuthRemoteDataSource{
  final String url = "https://us-central1-calback-fdeeb.cloudfunctions.net/createCustomToken";
  final String urlUpdate = "https://us-central1-calback-fdeeb.cloudfunctions.net/createToken";

  Future<Map<String, dynamic>> createCustomToken(Map<String, dynamic> user) async{
    final customTokenResponse = await http
      .post(Uri.parse(url), body: user);

    //final serverResponse = jsonDecode(customTokenResponse.body);
    Map<String, dynamic> tokenResponse = new Map<String, String>.from(jsonDecode(customTokenResponse.body));
    print(" asdasdasdasdassd ${tokenResponse}");
    return tokenResponse;
  }

  Future<Map<String, dynamic>> createToken(Map<String, dynamic> user) async{
    final customTokenResponse = await http
      .post(Uri.parse(urlUpdate), body: user);

    if(jsonDecode(customTokenResponse.body)['new'] == -1){
      throw Exception("Invalid registration data");
    }
    //final serverResponse = jsonDecode(customTokenResponse.body);
    Map<String, dynamic> tokenResponse = new Map<String, String>.from(jsonDecode(customTokenResponse.body));
    print(" asdasdasdasdassd ${tokenResponse}");
    return tokenResponse;
  }
}
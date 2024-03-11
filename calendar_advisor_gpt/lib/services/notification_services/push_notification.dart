import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PushNotification {
  PushNotification({
    this.title,
    this.body,
    this.dataTitle,
    this.dataBody,
  });

  String? title;
  String? body;
  String? dataTitle;
  String? dataBody;
}

// Use service account credentials to obtain oauth credentials.
Future<AccessCredentials> obtainCredentials() async {
  var accountCredentials = ServiceAccountCredentials.fromJson({
    "private_key_id": "ddce3249cc1b77c59e91b5833c4b3f92a91a604d",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC3ek8Krmqf9iPz\nWqHBZD78ERSbkwOhIRz/1q9brjGSIUh01saDt5KmCVtOKJ3u838U3mz8AbT6dJZD\n1yboKEVDC6/x5XaSuHkVRKpHCjCYRB/fdl/Umr4m5nJbTGZwl+EvyxYha0/hNKIM\nuNnoXHfDk+wiVuCEbXPqL3ZK2q65pDrm6Uj3di29MgmZVFMHZ07euVwiInHRtXFH\n9mpuSNkWEEaM2zXhfYm/QJ4CpOuQ5Y+i7AgITVSzeSL8jAxpEY8CbKyyt5JrPbHq\ngEp/xb37+h8/ueVqSDLndTqnM5nybHImtfMOntFNCesaUx702bHshe2VwyiX6B5w\n2kkbY1GRAgMBAAECggEABk4BoVBVAaInohkfLdIQCAFeP+pRWZwVrwTlibT2pxrV\nro4izCvmsiXoKUtkAe4EE+eAvzgfy+ttrm8aOygHGUKxjRJhfLEyF/UAFOjYuqK8\npaUfreKTXirVCyYY7w2JA2drH0Lcv9RbLSy88CsdQm820gdCN8q7DPUMj43sKxzW\nsKkP8xDzhMrtHYU+3fy+tBi7oqQ349b8rdLHIq6d8okr2foxRlNeQjHhXb4C8ZgN\nvHudpvhXHuu5B7K76e4p+uQPG341bP2AVm9I293QcNaPCIi1EY/MPAZRn2JMt4Wv\n292hNsgGMdIks/7jUY07CEZkHKbCORF8+6CApR6FsQKBgQDiYqjIR6CEDn+Yli7j\nPp2cD2v7HX4csJREu/LEWwXbk5GKPLiu61QQUc73XJGcOnq+nYdIYBmEAg1WHR7+\n9uXWNruRJkavV2NsinUkkx07lTCakvGmD035OfP8BdYl7Pqy2fmnB8u25VpMAhjF\nNMJIK+BANf7dcgww/aULggGXVwKBgQDPers0SA8d456sEsrn6gaM+TMJVK/d/VXc\nbSfqkez6poRgGrOp6kQ8UbDntvhne1zL9VM6IkrEf/1P5OjG5BDngrT5CrMrd44v\nGg/GiFGgHFQ37r6ENoCdR1w548LXZR09/ImzpzIGpJQNWGNaJ7PEEWxXFq/1rsI7\nFAFfhI9VVwKBgQCk0bOUbSGeQ3f+PYlRhSr2jfvNzcEdXin0iOnMr4BqRtv1SxQi\ntc50Ozt1uH2CwsjOsp3lwaGSDHRtN7JzaooXFa4llTptOjB2u69hu4HS+WFziHxK\nrGXWh6zs1cr9vbUgNbafNvvH4t+E6xnhqfGw3dDcrvMpgnkBygk5gaNq7QKBgAvC\nBs3lr4WgGqPhxMHzzz85+Bx1Qiowayc8wGBYuLdTrHjNypS8g/VvI7ld8yHaKd4d\nHwRSYS5VmoNmk5KB5jtYeu0KIDE8a0BcF7zGiOmr8VHiI8XWWN+Q5bcaIzaVslyK\n7TrTJNCfjwxaj/bR/SwFWMButrYTm0pBzfodxwmtAoGASTtNCsyBxgdF+HZC1MhZ\nRn3JnBTsNNenaqoanr/FWNaOcdYgIbxIJ8NdUbGNS5f+hFqX2hdpruKQ5gYJK4lW\nYE53KPvPn8WMnb8g0xh6S+tA5zdJ/ST71Ky7fW6HfMYDWGGvHCLB4vIeGEN0BfJN\n0dayS35nw7Ctgx0tScYs/6c=\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-4tqbw@calback-fdeeb.iam.gserviceaccount.com",
    "client_id": "113336904702156044379.apps.googleusercontent.com",
    "type": "service_account"
  });
  var scopes = ["https://www.googleapis.com/auth/cloud-platform"];

  var client = http.Client();
  AccessCredentials credentials =
    await obtainAccessCredentialsViaServiceAccount(accountCredentials, scopes, client);

  client.close();
  return credentials;
}

Future<void> sendPushNotification(String token, String title, String body) async {
  // Initialize the Firebase Messaging instance
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // Create a new message with notification and data payload
  final message = RemoteMessage(
    notification: RemoteNotification(
      title: title,
      body: body,
      
    ),
    data: {
      'key1': 'value1',
      'key2': 'value2',
    },
    senderId: token,
  );


// Get the access token using Google credentials
 final credentials = await obtainCredentials(); 
  final accessToken = await credentials.accessToken.data;

  // Add the authorization header
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json',
  };

  print('THis is the accessToken: $accessToken');

  // Set the target device for the message
  // Build the request body as JSON
  final requestBody = {
    'message': {
      'token': message.senderId,
      'notification': {
        'title': message.notification!.title!,
        'body': message.notification!.body!,
      },
      'data': message.data,
    },
    'validate_only': false,
  };
  final requestBodyJson = jsonEncode(requestBody);

  // Build the request URL
  final projectId = 'calback-fdeeb';
  final endpoint = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
  final Uri uri = Uri.parse(endpoint);

  // Send the HTTP request with headers and body
  final response = await http.post(
    uri,
    headers: headers,
    body: requestBodyJson,
  );

  print('Push notification sent with response: $response');
  print('FCM response: ${response.statusCode} ${response.body}');
}
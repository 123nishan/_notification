import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  String _message = '';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _register() {
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // getMessage();
  }

//  void getMessage(){
//    _firebaseMessaging.configure(
//        onMessage: (Map<String, dynamic> message) async {
//          print('on message $message');
//          setState(() => _message = message["notification"]["title"]);
//        }, onResume: (Map<String, dynamic> message) async {
//      print('on resume $message');
//      setState(() => _message = message["notification"]["title"]);
//    }, onLaunch: (Map<String, dynamic> message) async {
//      print('on launch $message');
//      setState(() => _message = message["notification"]["title"]);
//    });
//  }
  final String serverToken = 'AAAAisXqm5A:APA91bGW1R-GgDiPLMFjv6-mKZ8yLtvU1eoLdpp57nYnyMKiU90PUqAlywNFTSICbckxMP-HAKxFcYAWes13AevDV2upw0EMfN13BS6XqMEvibzbcegpYqZDcDfHha9l1CK44TD6UEWl';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, ),
    );

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'this is a body',
            'title': 'this is a title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': await firebaseMessaging.getToken(),
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
    Completer<Map<String, dynamic>>();

    firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print(message);
        completer.complete(message);
      },
    );

    return completer.future;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Message: $_message"),
                OutlineButton(
                  child: Text("Register My Device"),
                  onPressed: () {
                    _register();
                  },
                ),
                OutlineButton(
                  child: Text("trigger"),
                  onPressed: () {
                    sendAndRetrieveMessage();
                  },
                ),
                // Text("Message: $message")
              ]),
        ),
      ),
    );
  }
}
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}
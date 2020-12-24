import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_notifications/model/message_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<MessageNotification> messages = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initialPlatform() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        showNotification(
            message['notification']['title'], message['notification']['body']);
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        Navigator.pushNamed(context, '/notify');
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        showNotification(
            message['notification']['title'], message['notification']['body']);
      },
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  void showNotification(String title, String body) async {
    await _demoNotification(title, body);
  }

  Future<void> _demoNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.max,
        playSound: true,
        showProgress: true,
        priority: Priority.high,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'test');
  }

  @override
  void initState() {
    initialPlatform();
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false));
    _firebaseMessaging.onIosSettingsRegistered.listen((event) {
      print('2124: ios Setting registered');
    });
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print("onMessage $message");
      final notification = message['notification'];
      setState(() {
        showNotification(notification['title'], notification['body']);
        onSelectNotification(notification['body']);
        messages.add(MessageNotification(
            title: notification['title'], body: notification['body']));
      });
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch $message");
      final notification = message['data'];

      setState(() {
        messages.add(MessageNotification(
          title: '${notification['title']}',
          body: '${notification['body']}',
        ));

        showNotification(notification['title'], notification['body']);
      });
    }, onResume: (Map<String, dynamic> message) async {
      const IosNotificationSettings(sound: true, badge: true, alert: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
        ),
        body: ListView(
          children: messages.map(buildMessage).toList(),
        ));
  }

  Widget buildMessage(MessageNotification message) => ListTile(
        title: Text(message.title),
        subtitle: Text(message.body),
      );
}

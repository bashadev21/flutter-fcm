import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_notification_channel_id', // id
    'High Importance Notifications', // title
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Notfi.init();

  await Notfi.shownotification(
      title: message.notification!.title, body: message.notification!.body);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: false,
  );
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print("_messaging onMessageOpenedApp: ${message}");
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  print('User granted permission: ${settings.authorizationStatus}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    Notfi.init();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        Notfi.shownotification(
            title: message.notification!.title,
            body: message.notification!.body);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }

  void showNotification() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('This is Token: ' + token.toString());

    setState(() {
      _counter++;
    });
    flutterLocalNotificationsPlugin.show(
        0,
        "Testing $_counter",
        "How you doin ?",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // showNotification();
          // _showNotificationCustomSound();
          Notfi.shownotification(title: 'Helo', body: 'helo12');
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}

class Notfi {
  static final note = FlutterLocalNotificationsPlugin();
  static Future init() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('token:::: $token');
    var iniAndroindSettings =
        AndroidInitializationSettings('mipmap/ic_launcher');
    final settings = InitializationSettings(android: iniAndroindSettings);
    await note.initialize(settings);
  }

  static Future shownotification(
          {var id = 1, var title, var body, var payload}) async =>
      note.show(id, title, body, await notificationDetails());

  static notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('chanel 345', 'chanel name',
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound('sparesdosound')));
  }
}



//URL-https://fcm.googleapis.com/fcm/send
//API REQUEST PAYLOAD

// {
//     "registration_ids" : ["c6fovkvdRXe3kTInpMwXfe:APA91bERG1TPWTy6bUqafMHtupBjQ6-S7TmKOd-d-fl2q7VGphdCCQV12szw-kvgJATQSMAtC1We884Na02M5A_jvLufjYryRfwK6hx8mzMbGL95Cd2iQR39v05njcabyzNhv5gT43JF"],
//     "priority": "high",
//   "notification":
//       {
//           "title":"madhav 123",
//           "body":"hhhhh",
//           "sound": "sparesdosound.wav"
//       }
//   }


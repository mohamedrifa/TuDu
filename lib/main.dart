import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/settings.dart';
import 'notification_service/notification_service.dart';
import 'notification_service/alarm_screen.dart';
import 'data/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) {
    Hive.registerAdapter(SettingsAdapter());
  }
  await Hive.openBox<AppSettings>('settings');
  await AppDatabase.instance.database;
  await AndroidAlarmManager.initialize();
  await MediumNotification().initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fullscreen App',
      navigatorKey: navKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/lockscreen': (context) =>
            const AlarmScreen(title: 'testing', description: 'module'),
        '/': (context) => const FullScreenPage(),
      },
    );
  }
}

class FullScreenPage extends StatelessWidget {
  const FullScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: _BodyWrapper(),
      ),
    );
  }
}

class _BodyWrapper extends StatelessWidget {
  const _BodyWrapper();

  @override
  Widget build(BuildContext context) {
    // removes the top padding so your screen is truly fullscreen
    return MediaQuery.removeViewPadding(
      context: context,
      removeTop: true,
      child: const NotificationScreen(), // your existing screen
    );
  }
}

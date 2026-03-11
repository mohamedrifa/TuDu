import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'database/hive_service.dart';
import 'services/notification_service.dart'; 
import 'screens/alarm_screen.dart';
import './screens/onboarding_screen.dart';

// global nav key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
  runApp(MyApp());
  // ignore: deprecated_member_use
  HomeWidget.registerBackgroundCallback(backgroundCallback);
}
Future<void> backgroundCallback(Uri? uri) async {
  if (uri != null && uri.path == 'toggleTask') {
    // ignore: unused_local_variable
    String taskId = uri.queryParameters['id'] ?? '';
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // never null -> prevents MaterialApp assert
  Widget _startPage = const SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // init without context
    await FullScreenNotification().initNotification();

    // cold start?
    final details =
        await FullScreenNotification().notificationPlugin.getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp == true) {
      final payload = details!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        final parts = payload.split('|');
        final taskId = parts[0];
        final message = parts.length > 1 ? parts[1] : "";

        // 👉 set home directly to AlarmScreen, no push (prevents flicker)
        setState(() {
          _startPage = AlarmScreen(taskId: taskId, message: message);
        });
        return;
      }
    }
    else {
      setState(() {
        _startPage = FullScreenPage();
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Tudu',
      home: _startPage,
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
        backgroundColor: Colors.black, // Use a solid color
        body: MediaQuery.removeViewPadding(
          context: context,
          removeTop: true, // ✅ This removes the gap
          child: OnboardingScreen(), // or whatever your content is
        ),
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

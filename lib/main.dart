import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/waste_list_screen.dart';
import 'package:sentry/sentry.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

const DSN =
    'https://17cb03623aa64c46a1c672c6a257d995@o434118.ingest.sentry.io/5390600';

final SentryClient sentry = SentryClient(dsn: DSN);

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };
  runZoned(() {
    runApp(MyApp());
  }, onError: (error, stackTrace) {
    MyApp.reportError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static Future<void> reportError(dynamic error, dynamic stackTrace) async {
    // if (kDebugMode) {
    //   print(stackTrace);
    //   return;
    // }
    final SentryResponse response =
        await sentry.captureException(exception: error, stackTrace: stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wasteagram',
        theme: ThemeData.dark(),
        navigatorObservers: <NavigatorObserver>[observer],
        home: WasteListScreen(analytics: analytics, observer: observer));
  }
}

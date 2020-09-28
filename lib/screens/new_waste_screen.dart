import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:wasteagram/widgets/new_waste_form.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class NewWasteScreen extends StatelessWidget {
  static const routeKey = 'NewWasteScreen';

  File image;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  NewWasteScreen({this.image, this.analytics, this.observer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
        centerTitle: true,
      ),
      body:
          NewWasteForm(image: image, analytics: analytics, observer: observer),
    );
  }
}

import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wasteagram/models/NewWaste.dart';
import 'package:wasteagram/screens/waste_details_screen.dart';
import 'new_waste_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class WasteListScreen extends StatefulWidget {
  static const routeKey = '/';

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  WasteListScreen({this.analytics, this.observer});

  @override
  _WasteListScreenState createState() => _WasteListScreenState();
}

class _WasteListScreenState extends State<WasteListScreen> {
  File imageGallery;
  int totalWaste = 0;

  @override
  void initState() {
    super.initState();
    getTotalWaste();
    _currentScreen();
    _sendViewEvent();
  }

  void getImageGallery(BuildContext context) async {
    PickedFile _image =
        await ImagePicker().getImage(source: ImageSource.gallery);
    imageGallery = File(_image.path);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewWasteScreen(
                image: imageGallery,
                analytics: widget.analytics,
                observer: widget.observer),
            settings: RouteSettings(name: 'Waste_List_Screen')));
  }

  void getTotalWaste() async {
    await Firestore.instance.collection('posts').getDocuments().then((value) {
      value.documents.forEach((element) {
        totalWaste += element.data['quantity'];
      });
    });
    setState(() {});
  }

  Future<void> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Waste_List_Screen',
        screenClassOverride: 'WasteListScreen');
  }

  Future<void> _sendViewEvent() async {
    await widget.analytics
        .logEvent(name: 'Viewed_Waste_List_Screen', parameters: null);
  }

  Future<void> _sentViewDetailsEvent() async {
    await widget.analytics.logEvent(
        name: 'Viewed_Waste_Details_Screen',
        parameters: <String, dynamic>{'TotalWaste': totalWaste});
  }

  Future<void> _sendGetImage() async {
    await widget.analytics.logEvent(name: 'Opened_Gallery', parameters: null);
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarSet(),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('posts')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (content, snapshot) {
            if (snapshot.hasData &&
                snapshot.data.documents != null &&
                snapshot.data.documents.length > 0) {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  var post = snapshot.data.documents[index];

                  //Accesibility
                  return Semantics(
                      button: true,
                      enabled: true,
                      onTapHint: 'Tap to view details',
                      child: ListTile(
                        title: Text(
                            '${DateFormat.yMMMEd().format(post['date'].toDate())}'),
                        trailing: Text(post['quantity'].toString()),
                        onTap: () {
                          _sentViewDetailsEvent();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                WasteDetailsScreen(NewWaste(
                                    date: post['date'],
                                    imageURL: post['imageURL'],
                                    quantity: post['quantity'],
                                    latitude: post['latitude'],
                                    longitude: post['longitude'])),
                            settings: RouteSettings(name: 'Waste_List_Screen'),
                          ));
                        },
                      ));
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),

      //Accesibility
      floatingActionButton: Semantics(
          button: true,
          enabled: true,
          onTapHint: 'Select an image',
          child: Builder(builder: (context) {
            return FloatingActionButton(
                onPressed: () {
                  _sendGetImage();
                  getImageGallery(context);
                },
                child: Icon(Icons.camera_alt));
          })),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget appBarSet() {
    if (totalWaste == 0) {
      return AppBar(title: Text('Wasteagram'), centerTitle: true);
    } else {
      return AppBar(title: Text('Wasteagram - $totalWaste'), centerTitle: true);
    }
  }
}

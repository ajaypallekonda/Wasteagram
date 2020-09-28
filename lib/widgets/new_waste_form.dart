import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wasteagram/models/NewWaste.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wasteagram/screens/waste_list_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'dart:io';
import 'dart:async';

class NewWasteForm extends StatefulWidget {
  File image;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  NewWasteForm({this.image, this.analytics, this.observer});
  @override
  _NewWasteFormState createState() => _NewWasteFormState();
}

class _NewWasteFormState extends State<NewWasteForm> {
  LocationData locationData;
  Timestamp date;
  String url;

  final formKey = GlobalKey<FormState>();
  final newWaste = NewWaste();

  @override
  void initState() {
    super.initState();
    date = Timestamp.fromDate(DateTime.now());
    retrieveLocation();
    getImage();
    _sendViewEvent();
  }

  void retrieveLocation() async {
    var locationService = Location();
    locationData = await locationService.getLocation();
    setState(() {});
  }

  Future getImage() async {
    //Uploads image to the cloud
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateFormat.yMMMEd().format(date.toDate())}');
    StorageUploadTask uploadTask = storageReference.putFile(widget.image);
    await uploadTask.onComplete;
    url = await storageReference.getDownloadURL();
    setState(() {});
  }

  Future<void> _sendViewEvent() async {
    await widget.analytics
        .logEvent(name: "Viewed_New_Post_Screen", parameters: null);
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    return Form(
        key: formKey,
        child: CustomScrollView(slivers: <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(children: [
              Container(child: Image.file(widget.image)),
              Padding(padding: EdgeInsets.all(4)),
              textboxes(locale),
              Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                          width: double.infinity,
                          height: 100,

                          //Accessibility
                          child: Semantics(
                            button: true,
                            enabled: true,
                            onTapHint: 'Save and Upload',
                            child: RaisedButton(
                                key: Key("upload"),
                                onPressed: () {
                                  if (formKey.currentState.validate()) {
                                    formKey.currentState.save();
                                    //Uploads the post data to the cloud
                                    Firestore.instance.collection('posts').add({
                                      'date': newWaste.date,
                                      'imageURL': newWaste.imageURL,
                                      'latitude': newWaste.latitude,
                                      'longitude': newWaste.longitude,
                                      'quantity': newWaste.quantity
                                    });
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                WasteListScreen(
                                                    analytics: widget.analytics,
                                                    observer: widget.observer),
                                            settings: RouteSettings(
                                                name: 'New_Form Screen')),
                                        (route) => false);
                                  }
                                },
                                child: Icon(Icons.cloud_upload)),
                          )))),
            ]),
          )
        ]));
  }

  Widget textboxes(Locale locale) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
        child: TextFormField(
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: Translations(locale).getQuantityFieldHint(),
            border: OutlineInputBorder(),
          ),
          onSaved: (value) {
            newWaste.quantity = int.parse(value);
            newWaste.latitude = locationData.latitude;
            newWaste.longitude = locationData.longitude;
            newWaste.date = date;
            newWaste.imageURL = url;
          },
          validator: (value) {
            if (value.isNotEmpty && isNumericInt(value)) {
              // if (value.isNotEmpty) {
              return null;
            } else {
              return 'Please enter number of items (integer)';
            }
          },
        ));
  }

  //Referenced https://stackoverflow.com/questions/24085385/checking-if-string-is-numeric-in-dart
  bool isNumericInt(String s) {
    if (s == null) {
      return false;
    }
    return int.parse(s, onError: (e) => null) != null;
  }
}

//Internationalization
class Translations {
  Locale locale;
  Translations(this.locale);

  static Map<String, Map<String, String>> label = {
    'en': {'quantityFieldHint': 'Number of Wasted Items'},
    'es': {'quantityFieldHint': 'Número de artículos desperdiciados'},
    'hi': {'quantityFieldHint': 'व्यर्थ वस्तुओं की संख्या'},
  };

  String getQuantityFieldHint() {
    if (locale.languageCode != 'en' &&
        locale.languageCode != 'es' &&
        locale.languageCode != 'hi') {
      return label['en']['quantityFieldHint'];
    } else {
      return label[locale.languageCode]['quantityFieldHint'];
    }
  }
}

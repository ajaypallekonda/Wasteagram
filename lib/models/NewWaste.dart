import 'package:cloud_firestore/cloud_firestore.dart';

class NewWaste {
  Timestamp date;
  String imageURL;
  int quantity;
  double latitude;
  double longitude;

  NewWaste(
      {this.date, this.imageURL, this.quantity, this.latitude, this.longitude});

  String getLocation() {
    return 'Location: ($latitude, $longitude)';
  }
}

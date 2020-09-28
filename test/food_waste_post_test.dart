//Reference Exploration: Testing and Debugging for code
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteagram/models/NewWaste.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Testing constructor of NewWaste model class', () {
    final date = Timestamp.fromDate(DateTime.now());
    const url = 'Temp';
    const quantity = 1;
    const longitude = 5.0;
    const latitude = 10.0;

    NewWaste food_waste_post = NewWaste(
        date: date,
        imageURL: url,
        quantity: quantity,
        longitude: longitude,
        latitude: latitude);

    expect(food_waste_post.date, date);
    expect(food_waste_post.imageURL, url);
    expect(food_waste_post.quantity, quantity);
    expect(food_waste_post.longitude, longitude);
    expect(food_waste_post.latitude, latitude);
  });

  test("Testing the 'getLocation()' function of NewWaste model class", () {
    final date = Timestamp.fromDate(DateTime.now());
    const url = 'Temp';
    const quantity = 1;
    const longitude = -25.0;
    const latitude = 75.0;

    NewWaste food_waste_post = NewWaste(
        date: date,
        imageURL: url,
        quantity: quantity,
        longitude: longitude,
        latitude: latitude);

    expect(food_waste_post.getLocation(),
        'Location: (${food_waste_post.latitude}, ${food_waste_post.longitude})');
  });
}

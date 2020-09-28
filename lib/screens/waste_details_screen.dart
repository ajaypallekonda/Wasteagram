import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wasteagram/models/NewWaste.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WasteDetailsScreen extends StatelessWidget {
  NewWaste newWaste;
  WasteDetailsScreen(this.newWaste);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Wasteagram'),
          centerTitle: true,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      '${DateFormat.yMMMEd().format(newWaste.date.toDate())}',
                      style: TextStyle(fontSize: 30),
                    ),
                    CachedNetworkImage(
                      imageUrl: newWaste.imageURL,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    Text('Items wasted: ${newWaste.quantity}',
                        style: TextStyle(fontSize: 20)),
                    Text(newWaste.getLocation())
                  ],
                ))
          ],
        ));
  }
}

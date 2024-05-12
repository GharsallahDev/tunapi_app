import 'package:flutter/material.dart';

class GridImage extends StatelessWidget {
  final String uri;
  final String pre;

  GridImage({required this.uri, required this.pre});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Column(
          children: <Widget>[Image.network(uri), Text("Prediction: $pre")],
        ),
      ),
    );
  }
}

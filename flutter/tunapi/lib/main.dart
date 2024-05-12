import 'package:flutter/material.dart';
import 'screens/main_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primaryColor: Color(0xFFF9C901),
        primarySwatch: Colors.blue,
      ),
      home: Main(),
    );
  }

}
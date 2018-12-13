import 'package:flutter/material.dart';
import 'package:wetase/src/view/homeView.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(fontFamily: 'Raleway'),
      home: Builder(
        builder: (context) => new HomeView(context),
      ),
    );
  }
}



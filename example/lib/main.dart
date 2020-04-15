import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:imagealiastest/imagealiastest.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _textureID;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Imagealiastest.initialize().then((int textureID){
      setState(() {
        _textureID = textureID;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: MyWidget(),
      ),
    );
  }
}

class MyWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyWidgetState();
  }
}

class MyWidgetState extends State<MyWidget>{
  int _textureID;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Imagealiastest.initialize().then((int textureID){
      setState(() {
        _textureID = textureID;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double imageWidth = 720;
    double imageHeight = 233;
    double ratio = imageWidth / imageHeight;
    return Column(
      children: <Widget>[
        Container(
          width: scrWidth,
          height: scrWidth / ratio,
          child: _textureID == null?Container():Texture(textureId: _textureID,),
        ),
        Container(
          height: 20,
        ),
        Container(
          width: scrWidth,
          height: scrWidth / ratio,
          child: Image.asset('images/test.png',package: 'imagealiastest',),
        ),
      ],
    );
  }}
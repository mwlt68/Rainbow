import 'package:flutter/material.dart';
import 'package:rainbow/Views/Rainbow_main.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rainbow',
      theme: ThemeData(
        primaryColor: Color(0xff075e54),
        accentColor: Color(0xff25d336),
      ),
      home: RainbowMain(),
    );
  }
}
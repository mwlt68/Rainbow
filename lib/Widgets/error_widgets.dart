import 'package:flutter/material.dart';
Widget  BasicErrorWidget({String title,String message}) =>Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: [
      Text(title,textAlign: TextAlign.center,maxLines: 2,overflow: TextOverflow.fade,style: TextStyle(
        fontSize: 20,fontFamily: 'Roboto',color: Colors.red
      ),),
      Text(message,overflow: TextOverflow.visible,textAlign: TextAlign.start,style: TextStyle(
        fontSize: 20,fontFamily: 'Roboto',color: Colors.red
      ),)
    ],
  ),
);
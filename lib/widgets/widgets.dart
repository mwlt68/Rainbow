import 'package:flutter/material.dart';

class MyWidgets {
  static Container getCustomTextView(
      TextEditingController controller, String labelText, String initialValue) {
    return Container(
      padding: EdgeInsets.all(25),
      child: TextField(
          controller: controller..text = initialValue,
          decoration: InputDecoration(
            labelText: labelText,
          )),
    );
  }

  static RaisedButton getNormalRaisedButton(
      String btnText, Color textColor, Function function,
      {double padding = 10}) {
    return RaisedButton(
        padding: EdgeInsets.all(padding),
        onPressed: function,
        color: Colors.white,
        child: Text(
          btnText,
          style: TextStyle(color: textColor),
        ));
  }
  static get getDefaultDivider =>
    Divider(indent: 10,endIndent: 10, thickness:1 ,color: Colors.black,);
    
  static Container getHugeRaisedButton(
      String btnText, Color color, Function function,
      {Color textColor = Colors.white}) {
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        child: Text(
          btnText,
          style: TextStyle(
              color: textColor, fontSize: 22, fontWeight: FontWeight.w400),
        ),
        color: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        onPressed: function,
      ),
    );
  }

  static RaisedButton getRaisedButton(
      String text, Color color, Function function,
      {Color textColor = Colors.white}) {
    return RaisedButton(
      color: color,
      onPressed: function,
      textColor: textColor,
      child: Center(
        child: Text(text),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }

  static Container getPureText(String text) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  static Container getRoundText(String content, Color containerColor,
      {double radius = 25,
      Color textColor = Colors.white,
      double padding = 10}) {
    return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(
          content,
          style: TextStyle(color: textColor),
        ));
  }
}

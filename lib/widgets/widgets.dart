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

  static Container getFlatButton(
      BuildContext context, String btnText, Function function) {
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        child: Text(
          btnText,
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
        ),
        color: Theme.of(context).accentColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        onPressed: function,
      ),
    );
  }
  static Container getPureText(String text){
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(text
      ,
      style: TextStyle(fontSize: 16),),
    );
  }
}

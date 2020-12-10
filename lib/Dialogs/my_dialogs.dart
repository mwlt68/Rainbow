import 'package:flutter/material.dart';

ShowErrorDialog(@required BuildContext context,
    {String title, String message}) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.fade,
          style:
              TextStyle(fontSize: 20, fontFamily: 'Roboto', color: Colors.red),
        ),
        content: new Text(
          message,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 18, fontFamily: 'Roboto', color: Colors.black),
        ),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
// This method will return bool value.If user select yes return true else return false.

Widget BasicErrorWidget({String title, String message}) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: TextStyle(
                fontSize: 20, fontFamily: 'Roboto', color: Colors.red),
          ),
          Text(
            message,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 20, fontFamily: 'Roboto', color: Colors.red),
          )
        ],
      ),
    );

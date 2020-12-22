import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

showErrorDialog(@required BuildContext context,
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
// This method will work when pressed camera button.
showPicker(BuildContext context,Function function) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        function(ImageSource.gallery);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      function(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
showYesNoDialog(BuildContext context, Function function,String title,String content,{String yesBtnText="Yes",String noBtnText="No"}) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(noBtnText)),
        FlatButton(
            onPressed: () {
              function();
              Navigator.pop(context);
            },
            child: Text(
              yesBtnText,
              style: TextStyle(color: Colors.redAccent),
            )),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
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

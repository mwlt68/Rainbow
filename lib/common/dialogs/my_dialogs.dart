import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
enum PickerMode{
  ImageFromLibrary,
  ImageFromCamera,
  ImageRemove,
  None,
}
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
// This method will work when pressed camera button.This dialog pop method return valut that did image select.
Future showPicker(BuildContext context,Function function,{bool removeIsVisiable=false})  {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Kütüphane'),
                      onTap: () {
                        function(ImageSource.gallery,PickerMode.ImageFromLibrary);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Kamera'),
                    onTap: () {
                      function(ImageSource.camera,PickerMode.ImageFromCamera);
                      Navigator.of(context).pop();

                    },
                  ),
                  Visibility(
                    visible: removeIsVisiable,
                    child: new ListTile(
                      leading: new Icon(Icons.remove),
                      title: new Text('Fotografı Kaldır'),
                      onTap: () {
                        function(null,PickerMode.ImageRemove);
                        Navigator.of(context).pop();

                      },
                    ),
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

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rainbow/core/base/base_state.dart';

enum PickerMode {
  ImageFromLibrary,
  ImageFromCamera,
  ImageRemove,
  None,
}

class MyDialogs with BaseState {
  BuildContext _context;

  MyDialogs(this._context);

  set context(BuildContext context) {
    this._context = context;
  }

  showErrorDialog(String title, {String message}) {
    showDialog(
      context: this._context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: TextStyle(
                fontSize: 20,
                fontFamily: fontFamilyStrConsts.roboto,
                color: Colors.red),
          ),
          content: Text(
            message,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamilyStrConsts.roboto,
                color: Colors.black),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(stringConsts.close),
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
  Future showPicker(Function function, {bool removeIsVisiable = false}) {
    return showModalBottomSheet(
        context: this._context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text(stringConsts.pickerFromLibrary),
                      onTap: () {
                        function(
                            ImageSource.gallery, PickerMode.ImageFromLibrary);
                        Navigator.of(
                          this._context,
                        ).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text(stringConsts.pickerFromCamera),
                    onTap: () {
                      function(ImageSource.camera, PickerMode.ImageFromCamera);
                      Navigator.of(
                        this._context,
                      ).pop();
                    },
                  ),
                  Visibility(
                    visible: removeIsVisiable,
                    child: ListTile(
                      leading: Icon(Icons.remove),
                      title: Text(stringConsts.pickerRemove),
                      onTap: () {
                        function(null, PickerMode.ImageRemove);
                        Navigator.of(
                          this._context,
                        ).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  showYesNoDialog(Function function, String title, String content,
      {String yesBtnText = "Yes",
      String noBtnText = "No"}) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        FlatButton(
            onPressed: () {
              Navigator.pop(
                this._context,
              );
            },
            child: Text(noBtnText)),
        FlatButton(
            onPressed: () {
              function();
              Navigator.pop(
                this._context,
              );
            },
            child: Text(
              yesBtnText,
              style: TextStyle(color: Colors.redAccent),
            )),
      ],
    );
    showDialog(
      context: this._context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

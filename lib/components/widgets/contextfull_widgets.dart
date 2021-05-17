import 'package:flutter/material.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/constants/color_constants.dart';

class ContextfullWidgets {
  BuildContext _context;

  ContextfullWidgets(this._context);

  set context(BuildContext context) {
    this._context = context;
  }

  Widget StackImagePicker(
      ImageProvider imageProvider, Function function,
      {double circleRadius = 100,
      double verticalPadding = 20,
      removeIsVisiable = true}) {
        
    MyDialogs _myDialogs = new MyDialogs(_context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Stack(
        children: [
          CircleAvatar(
            radius: circleRadius,
            backgroundImage: imageProvider,
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
                onPressed: () {
                  _myDialogs.showPicker(function,
                      removeIsVisiable: removeIsVisiable);
                },
                backgroundColor:ColorConstants.instance.primaryColor,
              ))
        ],
      ),
    );
  }
}

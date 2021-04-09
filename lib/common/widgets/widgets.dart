import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/views/sub_pages/group_members_select_page.dart';
import '../../core/default_data.dart';

Container mTextView(
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

Container mNormalRaisedButton(
    String btnText, Color textColor, Function function,
    {double padding = 15}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 5),
    padding: EdgeInsets.symmetric(horizontal: 25),
    child: RaisedButton(
        padding: EdgeInsets.only(top: padding, bottom: padding),
        onPressed: function,
        color: Colors.white,
        child: Text(
          btnText,
          style: TextStyle(color: textColor),
        )),
  );
}

get mDivider => Divider(
      indent: 10,
      endIndent: 10,
      thickness: 0.7,
      color: Colors.black,
    );

Container mHugeRaisedButton(String btnText, Color color, Function function,
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

RaisedButton mRaisedButton(String text, Color color, Function function,
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

SnackBar mShortSnackBar(String message, Color backgroundColor) {
  return SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.black),
    ),
    backgroundColor: DefaultColors.Yellow,
    duration: const Duration(seconds: 1),
  );
}

Container mPureText(String text) {
  return Container(
    padding: EdgeInsets.all(12),
    child: Text(
      text,
      style: TextStyle(fontSize: 16),
    ),
  );
}

Container mRoundText(String content, Color containerColor,
    {double radius = 25, Color textColor = Colors.white, double padding = 10}) {
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

Widget UserVisualize(MyUser user, Function function) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    child: Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(user.imgSrc == null
                  ? DefaultData.UserDefaultImagePath
                  : user.imgSrc),
            ),
            Positioned(
                top: -20,
                right: -20,
                child: IconButton(
                  iconSize: 24,
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    function();
                  },
                ))
          ],
          clipBehavior: Clip.none,
        ),
        Container(
            margin: EdgeInsets.only(top: 5),
            child: Text(
              user.name.length > 7
                  ? user.name.substring(0, 7)
                  : user.name,
            ))
      ],
    ),
  );
}
Card InfoCard(BuildContext context,IconData icon,String title,String content) {
    return Card(
                  margin: EdgeInsets.all(15),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading:  Icon(
                      icon,
                      color: Theme.of(context).accentColor,
                      size: 48,
                    ),
                    title: Text(
                      title,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Container(
                      margin: EdgeInsets.only(top:5),
                      child: Text(content,
                      style: Theme.of(context).textTheme.subtitle1,),
                    ),
                  ),
                );
}
Widget StackImagePicker(BuildContext context, ImageProvider imageProvider,
    Function function,
    {double circleRadius = 100,
    double verticalPadding = 20,
    removeIsVisiable = true}) {
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
                showPicker(context, function,
                    removeIsVisiable: removeIsVisiable);
              },
              backgroundColor: Theme.of(context).primaryColor,
            ))
      ],
    ),
  );
}

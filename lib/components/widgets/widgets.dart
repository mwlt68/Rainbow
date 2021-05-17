import 'package:flutter/material.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/constants/color_constants.dart';
import 'package:rainbow/constants/font_family_string_constants.dart';


Container MyTextView(
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

IconButton MyIconButton(IconData icon,bool isActive,Function function){
  return IconButton(
        disabledColor: Colors.black,
        icon: Icon(
          icon,
          color:isActive ? null : Colors.white,
        ),
        iconSize: 30,
        onPressed:function,
      );
}
Container MyNormalRaisedButton(
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

get MyDivider => Divider(
      indent: 10,
      endIndent: 10,
      thickness: 0.7,
      color: Colors.black,
    );

Container MyHugeRaisedButton(String btnText, Color color, Function function,
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

RaisedButton MyRaisedButton(String text, Color color, Function function,
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

SnackBar MyShortSnackBar(String message, Color backgroundColor) {
  return SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.black),
    ),
    backgroundColor: ColorConstants.instance.yellow,
    duration: const Duration(seconds: 1),
  );
}

Container MyPureText(String text) {
  return Container(
    padding: EdgeInsets.all(12),
    child: Text(
      text,
      style: TextStyle(fontSize: 16),
    ),
  );
}

Container MyRoundText(String content, Color containerColor,
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

Widget MyUserModelVisualize(MyUserModel user, Function function) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    child: Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(user.imgSrcWithDefault),
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
              user.name.length > 7 ? user.name.substring(0, 7) : user.name,
            ))
      ],
    ),
  );
}

Card MyInfoCard(
    BuildContext context, IconData icon, String title, String content) {
  return Card(
    margin: EdgeInsets.all(15),
    child: ListTile(
      contentPadding: EdgeInsets.all(10),
      leading: Icon(
        icon,
        color:ColorConstants.instance.accentColor,
        size: 48,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline6,
      ),
      subtitle: Container(
        margin: EdgeInsets.only(top: 5),
        child: Text(
          content,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
    ),
  );
}


// This method will return bool value.If user select yes return true else return false.

Widget MyBasicErrorWidget({String title, String message}) => Center(
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
                fontSize: 20,
                fontFamily: FontFamilyStringConstants.instance.roboto,
                color: Colors.red),
          ),
          Text(
            message,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 20,
                fontFamily: FontFamilyStringConstants.instance.roboto,
                color: Colors.red),
          )
        ],
      ),
    );


  typedef Widget WidgetFunc();
  Widget MyNullable(dynamic object, WidgetFunc func){
    if(object == null){
      return Container();
    }
    else return func();
  }

  class MyConditionalWidget extends StatelessWidget {
    bool condition;
    Widget falseWidget,trueWidget;
    MyConditionalWidget({@required this.condition,@required this.trueWidget,@required this.falseWidget});
    @override
    Widget build(BuildContext context) {
      return condition ? trueWidget: falseWidget;
    }
  }
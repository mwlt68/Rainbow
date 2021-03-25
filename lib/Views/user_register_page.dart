import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Views/rainbow_main.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/viewmodels/user_model.dart';

class UserRegisterPage extends StatefulWidget {
  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
  UserRegisterPage({this.user});
  User user;
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  Color themeColor;
  TextEditingController visiableNameTEC;
  TextEditingController statusTEC;
  File _image;
  UserModel model;
  final picker = ImagePicker();
  @override
  void initState() {
    // TODO: implement initState
    visiableNameTEC = new TextEditingController();
    statusTEC = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeColor= Theme.of(context).primaryColor;
    model = getIt<UserModel>();
    return ChangeNotifierProvider(
        create: (BuildContext context) => model,
        child: StreamBuilder<MyUser>(
            stream: model.getMyUserFromUserId(widget.user.uid),
            builder: (context, AsyncSnapshot<MyUser> snapshot) {
              if (snapshot.hasData) {
                return RainbowMain(
                  user: widget.user,
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (!snapshot.hasData) {
                return _getPage;
              }
            }));
  }

  Widget get _getPage => Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title: Text(DefaultData.UserRegister),
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(
              height: 32,
            ),
            Center(
                child: Column(
              children: [
                getImagePicker,
                mTextView(
                    visiableNameTEC, DefaultData.VisiableName, "Nameless"),
                mTextView(statusTEC, DefaultData.Status,
                    DefaultData.UserDefaultStatus),
                mHugeRaisedButton("Continue", Theme.of(context).accentColor,
                    _continueBtnClick),
                Visibility(
                    visible: model.busy, child: CircularProgressIndicator())
              ],
            ))
          ],
        ),
      );
  Widget get getImagePicker => Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 100,
                  backgroundImage:_image== null ? NetworkImage(DefaultData.UserDefaultImagePath) : FileImage(_image) ,
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      onPressed: ()  {
                        showPicker(context, _getImage);
                      },
                      backgroundColor: themeColor,
                    ))
              ],
              
            ),
          );

  _getImage(ImageSource source, PickerMode pickerMode) async {
    if (pickerMode == PickerMode.ImageRemove) {
      setState(() {
        _image = null;
      });
    } else if (pickerMode != PickerMode.None) {
      final pickedFile =
          await picker.getImage(source: source, imageQuality: 50);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  void _continueBtnClick() {
    var check = _checkTECValidation();
    if (check && !model.busy) {
      registerUser();
    } else {}
  }

  void registerUser() {
    model.busy = true;
    FutureBuilder<DocumentReference>(
      future: model.registerUser(
          widget.user, _image, visiableNameTEC.text, statusTEC.text),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          model.busy = false;
          _navigatorService.navigateTo(
              RainbowMain(
                user: widget.user,
              ),
              isRemoveUntil: true);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          model.busy = false;
          showErrorDialog(context,
              title: "Save Error", message: snapshot.error);
        }
      },
    );
  }

  bool _checkTECValidation() {
    if (visiableNameTEC.text.length > 0 && statusTEC.text.length > 0) {
      return true;
    } else {
      _scaffoldkey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.orange,
        content: Text(
          DefaultData.TECInvalidText,
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 3),
      ));
      return false;
    }
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/my_dialogs.dart';
import 'package:rainbow/Views/rainbow_main.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/navigator_service.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/viewmodels/user_model.dart';
import 'package:rainbow/widgets/widgets.dart';

class UserRegisterPage extends StatefulWidget {
  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
  UserRegisterPage({this.user});
  User user;
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final NavigatorService _navigatorService = getIt<NavigatorService>();

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
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
                MyWidgets.getCustomTextView(
                    visiableNameTEC, DefaultData.VisiableName, "Nameless"),
                MyWidgets.getCustomTextView(statusTEC, DefaultData.Status,
                    DefaultData.UserDefaultStatus),
                MyWidgets.getFlatButton(context, "Continue", _continueBtnClick),
                Visibility(visible: model.busy,child: CircularProgressIndicator())
              ],
            ))
          ],
        ),
      );
  Widget get getImagePicker => GestureDetector(
        onTap: () {
          _showPicker(context);
        },
        child: CircleAvatar(
          radius: 55,
          backgroundColor: Color(0xffFDCF09),
          child: _image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.file(
                    _image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.fitHeight,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(50)),
                  width: 100,
                  height: 100,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.grey[800],
                  ),
                ),
        ),
      );
  void _showPicker(context) {
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
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _imgFromGallery() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _continueBtnClick() {
    var check = _checkTECValidation();
    if (check && !model.busy) {
      registerUser();
    } else {}
  }

  void registerUser() {
    model.busy=true;
    FutureBuilder<DocumentReference>(
      future: model.registerUser(
          widget.user, _image, visiableNameTEC.text, statusTEC.text),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          model.busy=false;
          _navigatorService.navigateTo(
              RainbowMain(
                user: widget.user,
              ),
              isRemoveUntil: true);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
        } else if (snapshot.hasError) {
            model.busy=false;
            ShowErrorDialog(context,
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

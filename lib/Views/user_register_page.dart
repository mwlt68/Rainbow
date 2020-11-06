import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rainbow/Dialogs/error_dialogs.dart';
import 'package:rainbow/Views/rainbow_main.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/services/user_info_service.dart';
import 'package:rainbow/models/user.dart';
import 'package:rainbow/widgets/widgets.dart';

class UserRegisterPage extends StatefulWidget {
  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
  UserRegisterPage({this.user});
  User user;
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  TextEditingController visiableNameTEC;
  TextEditingController statusTEC;
  File _image;
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
    return Scaffold(
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
                  visiableNameTEC, DefaultData.VisiableName,"Nameless"),
              MyWidgets.getCustomTextView(statusTEC, DefaultData.Status,DefaultData.UserDefaultStatus),
              MyWidgets.getFlatButton(context, "Continue", _continueBtnClick),
            ],
          ))
        ],
      ),
    );
  }

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
    if (check) {
      UserInfoService infoService = new UserInfoService();
      MyUser myUser = new MyUser(
          userId: widget.user.uid,
          phoneNumber: widget.user.phoneNumber,
          name: visiableNameTEC.text,
          status: statusTEC.text,);
      if (_image==null) {
        myUser.imgSrc= DefaultData.UserDefaultImagePath;
        saveUser(infoService, myUser);
      } else {
        infoService.uploadMedia(_image).then((value){
          myUser.imgSrc= value;
          saveUser(infoService, myUser);
          });
      }
      
    } else {}
     }
  void saveUser(UserInfoService infoService, MyUser myUser){
    FutureBuilder<bool>(
        future: infoService.registerUser(myUser),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            ShowErrorDialog(context,
                title: "Save Error", message: snapshot.error);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.data) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => RainbowMain(
                        user: widget.user,
                      )),
              (Route<dynamic> route) => false,
            );
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

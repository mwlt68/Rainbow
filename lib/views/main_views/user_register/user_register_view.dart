import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/views/main_views/home/home_view.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/components/widgets/widgets.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/core_view_models/core_user_view_model.dart';
import 'package:rainbow/views/main_views/user_register/user_register_view_model.dart';
import 'package:rainbow/core/base/base_state.dart';
part 'user_register_string_values.dart';

class UserRegisterPage extends StatefulWidget {
  User user;
  UserRegisterPage({this.user});
  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage>  with BaseState{
  _UserRegisterStringValues _values = new _UserRegisterStringValues();
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  TextEditingController visiableNameTEC;
  TextEditingController statusTEC;
  UserRegisterViewModel _viewModel;
  File _image;
  UserViewModel _userViewModel;
  MyDialogs _myDialogs;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _viewModel = new UserRegisterViewModel();
    visiableNameTEC = new TextEditingController();
    statusTEC = new TextEditingController();
    _myDialogs = new MyDialogs(context);
  }

  @override
  Widget build(BuildContext context) {
    _userViewModel = getIt<UserViewModel>();
    return ChangeNotifierProvider(
        create: (BuildContext context) => _userViewModel,
        child: StreamBuilder<MyUserModel>(
            stream: _userViewModel.getMyUserModelFromUserId(widget.user.uid),
            builder: (context, AsyncSnapshot<MyUserModel> snapshot) {
              if (snapshot.hasData) {
                return Home();
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (!snapshot.hasData) {
                return scaffold();
              }
            }));
  }

  Scaffold scaffold() {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text(_values.userRegisterText),
      ),
      body: scaffoldBody(),
    );
  }

  ListView scaffoldBody() {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 32,
        ),
        Center(
            child: Column(
          children: [
            bodyImagePicker(),
            MyTextView(visiableNameTEC, _values.visiableName, _values.nameless),
            MyTextView(statusTEC, _values.status, _values.userDefaultStatus),
            MyHugeRaisedButton(_values.continueText, colorConsts.accentColor,
                _continueClick),
            Visibility(visible: _userViewModel.busy, child: CircularProgressIndicator())
          ],
        ))
      ],
    );
  }

  Widget bodyImagePicker() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 100,
            backgroundImage: _image == null
                ? NetworkImage(stringConsts.userDefaultImagePath)
                : FileImage(_image),
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
                  _myDialogs.showPicker(_getImage);
                },
                backgroundColor: colorConsts.primaryColor,
              ))
        ],
      ),
    );
  }

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

  void _continueClick() {
    var check = _checkTECValidation();
    if (check && !_userViewModel.busy) {
      _userRegisterClick();
    } else {}
  }

  void _userRegisterClick() {
    _userViewModel.busy = true;
    FutureBuilder<DocumentReference>(
      future: _userViewModel.registerUser(
          widget.user, _image, visiableNameTEC.text, statusTEC.text),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _userViewModel.busy = false;
          _navigatorService.navigateTo(
              Home(),
              isRemoveUntil: true);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          _userViewModel.busy = false;
          _myDialogs.showErrorDialog(_values.saveError,
              message: snapshot.error);
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
          _values.tecInvalidText,
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 3),
      ));
      return false;
    }
  }
}

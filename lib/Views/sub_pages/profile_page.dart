import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/viewmodels/user_model.dart';

class ProfilePage extends StatefulWidget {
  User user;
  ProfilePage(this.user);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  MyUser _myUser;
  UserModel _model;
  final _picker = ImagePicker();
  File _selectedImage;
  bool _didChange = false;
  bool _didLoadUser = false;
  bool _removeUserImg=false;
  TextEditingController _nameTEC;
  String _profileImageSrc;
  String _statusText;

  @override
  void initState() {
    super.initState();
    _model = getIt<UserModel>();
  }

  @override
  Widget build(BuildContext context) {
    Color _themeColor = Theme.of(context).primaryColor;
    if (_didLoadUser) {
      return _getScaffold(_themeColor);
    }
    return ChangeNotifierProvider(
      create: (context) => _model,
      child: StreamBuilder<MyUser>(
        stream: _model.getMyUserFromUserId(this.widget.user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            showErrorDialog(context,
                title: "Data could not load !", message: snapshot.error);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          _myUser = snapshot.data;
          _didLoadUser = true;
          _statusText = snapshot.data.status;
          _nameTEC = new TextEditingController(text: snapshot.data.name);
          _profileImageSrc = snapshot.data.imgSrc;
          return _getScaffold(_themeColor);
        },
      ),
    );
  }

  Widget _getScaffold(Color themeColor) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: themeColor,
        actions: [
          Visibility(
              visible: _didChange,
              child: Container(
                margin: EdgeInsets.all(10),
                child: FlatButton(
                  color: Theme.of(context).accentColor,
                  onPressed: (){
                      _saveButton();
                    },
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ))
        ],
      ),
      body: _getBody(themeColor),
    );
  }

  Widget _getBody(Color themeColor) {
    return Container(
      color: Color.fromRGBO(238, 238, 238, 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StackImagePicker(
            context,
            _getBackgroundImage(),
            _getImage
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: TextField(
              onChanged: (val) {
                if (!_didChange && val != _myUser.name) {
                  setState(() {
                    _didChange = true;
                  });
                }
              },
              controller: _nameTEC,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  hintText: 'Enter a name'
                ),
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "This is not a username. This name will only be visible to people.",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.7,
                ),
              )),
          GestureDetector(
            onTap: () async {
              FocusManager.instance.primaryFocus.unfocus();
              String result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SetStatus(_statusText)),
              );
              if (result != null && result.length > 0) {
                setState(() {
                  _didChange = true;
                  _statusText = result;
                });
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Text(
                        _statusText,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.7,
                          wordSpacing: 0.7,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_right,
                    size: 32,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getImage(ImageSource imgSource,PickerMode pickerMode) async {
    if(pickerMode == PickerMode.ImageRemove){
      setState(() {
        _didChange = true;
        _removeUserImg=true;
        _selectedImage = null;
      });
    }
    else if(pickerMode != PickerMode.None){
      final pickedFile = await _picker.getImage(source: imgSource);
      if (pickedFile != null) {
        setState(() {
          _didChange = true;
          _removeUserImg=false;
          _selectedImage = File(pickedFile.path);
        });
      } else {}
    }
  }

  ImageProvider  _getBackgroundImage(){

    if(_selectedImage == null){
      if(_removeUserImg){
        return NetworkImage(DefaultData.UserDefaultImagePath);
      }
      else{
        if(_profileImageSrc == null){
          return NetworkImage(DefaultData.UserDefaultImagePath);
        }
        else{
          return NetworkImage(_profileImageSrc);
        }
      }
    }
    else{
      return FileImage(_selectedImage);
    }
    
  }
  void _saveButton() async {
    if (_model.busy) return;
    _model.busy = true;
    String response = await _model.updateUserTest(
        _myUser, _selectedImage, _nameTEC.value.text, _statusText,_removeUserImg);
    _model.busy = false;
    if (response != null) {
      showErrorDialog(context, title: "Update Error", message: response);
    } else {
      setState(() {
        _didChange = false;
        _didLoadUser = false;
        _removeUserImg=false;
      });
    }
  }
}

class SetStatus extends StatefulWidget {
  String statusText;
  SetStatus(this.statusText);

  @override
  _SetStatusState createState() => _SetStatusState();
}

class _SetStatusState extends State<SetStatus> {
  bool _didChange = false;
  TextEditingController _statusTEC;
  @override
  void initState() {
    super.initState();
    _statusTEC = new TextEditingController();
    _statusTEC.text = this.widget.statusText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Status"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Container(
            margin: EdgeInsets.all(10),
            child: Visibility(
              visible: _didChange,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(Icons.done,color: Colors.white,),
                onPressed: () {
                  Navigator.pop(context, _statusTEC.text);
                },
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Color.fromRGBO(238, 238, 238, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: TextField(
                onChanged: (val) {
                  if (!_didChange && val != widget.statusText) {
                    setState(() {
                      _didChange = true;
                    });
                  }
                },
                controller: _statusTEC,
                maxLines: 3,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(MyUser.StatusTextLength),
                ],
                maxLength: MyUser.StatusTextLength,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            _getStatusOption("Busy"),
            _getStatusOption("At Job"),
            _getStatusOption("At Home"),
            _getStatusOption("Write Code..."),
          ],
        ),
      ),
    );
  }

  Widget _getStatusOption(String optionName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _didChange = true;
          _statusTEC.text = optionName;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.only(left: 10),
        color: Colors.white,
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Text(
              optionName,
              overflow: TextOverflow.clip,
              maxLines: 3,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.7,
                wordSpacing: 0.7,
                height: 1.3,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

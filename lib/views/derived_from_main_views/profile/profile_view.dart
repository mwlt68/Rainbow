import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/components/widgets/contextfull_widgets.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/core_view_models/core_user_view_model.dart';
import 'package:rainbow/core/base/base_state.dart';
part 'profile_string_values.dart';

class ProfilePage extends StatefulWidget {
  bool connectivityActive;
  ProfilePage(this.connectivityActive);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>  with BaseState{
  final _ProfileStringValues _values= new _ProfileStringValues();
  final _picker = ImagePicker();
  MyUserModel _myUserModel;
  UserViewModel _model;
  File _selectedImage;
  bool _didChange = false;
  bool _didLoadUser = false;
  bool _removeUserImg=false;
  TextEditingController _nameTEC;
  String _profileImageSrc;
  String _statusText;
  MyDialogs _myDialogs;
  ContextfullWidgets  _contextfullWidgets;
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool connectivityActive; 
  
  @override
  void initState() {
    super.initState();
    _myDialogs=new MyDialogs(context);
    _contextfullWidgets= new ContextfullWidgets(context);
    _model = getIt<UserViewModel>();
    connectivityActive= widget.connectivityActive;
    connectivitySubscription = Connectivity()
    .onConnectivityChanged
    .listen((ConnectivityResult result) {
      setState(() {
        connectivityActive = result != ConnectivityResult.none;
        });
      });
  }

  @override
  dispose() {
    super.dispose();
    connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_didLoadUser) {
      return buildScaffold();
    }
    return ChangeNotifierProvider(
      create: (context) => _model,
      child: StreamBuilder<MyUserModel>(
        stream: _model.getMyUserModelFromUserId(MyUserModel.CurrentUserId),
        builder: (context,AsyncSnapshot<MyUserModel> snapshot) {
          if (snapshot.hasError) {
            _myDialogs.showErrorDialog(
                _values.DataLoadError, message: snapshot.error);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          _myUserModel = snapshot.data;
          _didLoadUser = true;
          _statusText = snapshot.data.status;
          _nameTEC = new TextEditingController(text: snapshot.data.name);
          _profileImageSrc = snapshot.data.imgSrcWithDefault;
          return buildScaffold();
        },
      ),
    );
  }

  Widget buildScaffold() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(),
      body: body(),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(_values.Profile),
      backgroundColor: colorConsts.primaryColor,
      actions: [
        appBarSaveAction()
      ],
    );
  }

  Visibility appBarSaveAction() {
    return Visibility(
          visible: _didChange,
          child: Container(
            margin: EdgeInsets.all(10),
            child: FlatButton(
              color: colorConsts.accentColor,
              onPressed: (){
                  _saveButton();
                },
              child: Text(
                _values.Save,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ));
  }

  Widget body() {
    return Container(
      color: colorConsts.perfectGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          imagePickerContainer(),
          nameInputContainer(),
          nameInfoContainer(),
          statusWidgetNavigatorContainer(),
        ],
      ),
    );
  }

  Widget imagePickerContainer(){
    
    return _contextfullWidgets.StackImagePicker(
            backgroundImage(),
            _getImage,
            isButtonActive: connectivityActive,
          );
  }
  GestureDetector statusWidgetNavigatorContainer() {
    return GestureDetector(
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
          child: statusContainer(),
        );
  }

  Container statusContainer() {
    return Container(
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
        );
  }

  Container nameInfoContainer() {
    return Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _values.NameInfo,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                letterSpacing: 0.7,
              ),
            ));
  }

  Container nameInputContainer() {
    return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: TextField(
            onChanged: (val) {
              if (!_didChange && val != _myUserModel.name) {
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
                hintText:_values.NameTEC
              ),
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

  ImageProvider  backgroundImage(){

    if(_selectedImage == null){
      if(_removeUserImg){
        return NetworkImage(stringConsts.userDefaultImagePath);
      }
      else{
        return CachedNetworkImageProvider(_profileImageSrc);
      }
    }
    else{
      return FileImage(_selectedImage);
    }
    
  }
  void _saveButton() async {
    if (_model.busy) return;
    _model.busy = true;
    String response = await _model.updateUser(
        _myUserModel, _selectedImage, _nameTEC.value.text, _statusText,_removeUserImg);
    _model.busy = false;
    if (response != null) {
      _myDialogs.showErrorDialog( _values.UpdateError, message: response);
    } else {
      setState(() {
        _didChange = false;
        _didLoadUser = false;
        _removeUserImg=false;
      });
    }
  }
}

class SetStatus extends StatefulWidget  {
  String statusText;
  SetStatus(this.statusText);

  @override
  _SetStatusState createState() => _SetStatusState();
}

class _SetStatusState extends State<SetStatus>  with BaseState{
  final _ProfileStringValues _values= new _ProfileStringValues();
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
      appBar: appBar(context),
      body: body(),
    );
  }


  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text(_values.Status),
      backgroundColor: colorConsts.primaryColor,
      actions: [
        appBarActionContainer(context),
      ],
    );
  }

  Container appBarActionContainer(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: Visibility(
          visible: _didChange,
          child: FloatingActionButton(
            backgroundColor: colorConsts.accentColor,
            child: Icon(Icons.done,color: Colors.white,),
            onPressed: () {
              Navigator.pop(context, _statusTEC.text);
            },
          ),
        ),
      );
  }

  Container body() {
    return Container(
      color: colorConsts.perfectGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          statusInputContainer(),
          statusOption(_values.BusySO),
          statusOption(_values.AtJobSO),
          statusOption(_values.AtHomeSO),
          statusOption(_values.WriteCodeSO),
        ],
      ),
    );
  }

  Container statusInputContainer() {
    return Container(
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
              LengthLimitingTextInputFormatter(MyUserModel.StatusTextLength),
            ],
            maxLength: MyUserModel.StatusTextLength,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        );
  }



  Widget statusOption(String optionName) {
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
          statusOptionTextContainer(optionName),
        ]),
      ),
    );
  }

  Container statusOptionTextContainer(String optionName) {
    return Container(
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
        );
  }
}

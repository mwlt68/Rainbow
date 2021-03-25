import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/viewmodels/conversation_model.dart';
import 'package:rainbow/views/message_page.dart';
import 'package:rainbow/views/sub_pages/group_members_select_page.dart';

class GroupCreate extends StatefulWidget {
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  List<MyUserSellect> _myUsersSellect;
  GroupCreate(this._myUsersSellect);
  @override
  _GroupCreateState createState() => _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
  TextEditingController _groupNameTEC = new TextEditingController();
  bool isActiveForCreate=false;
  int _selectedUserCount;
  final _picker = ImagePicker();
  File _selectedImage;
  @override
  Widget build(BuildContext context) {
    _selectedUserCount =
        widget._myUsersSellect.where((element) => element.select).toList().length;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          Visibility(
            visible: _groupNameTEC.text.trim().length > 0 && _selectedUserCount >= GroupConversationDTO.MinGroupMembers,
            child: Container(
              margin: EdgeInsets.all(10),
              child: TextButton(
                onPressed: () async {
                  var model = getIt<ConversationModel>();
                  List<String> selectedUsers = new List<String>.from(widget._myUsersSellect.where((element) => element.select).map((e) => e.user.userId));
                  selectedUsers.add(MyUser.CurrentUserId);
                  var conversation =await model.startGroupConversation(selectedUsers,_groupNameTEC.value.text,_selectedImage);
                  if(conversation != null){
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    widget._navigatorService.navigateTo(MessagePage(conversation: conversation));
                 }
                },
                child: Text("Create",style: TextStyle(color:Colors.white),),
                style: ButtonStyle(
                  backgroundColor:  MaterialStateProperty.all<Color>(Theme.of(context).accentColor),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          StackImagePicker(
            context,
            _selectedImage == null ? NetworkImage(DefaultData.UserDefaultImagePath):FileImage(_selectedImage),
            _getImage,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: TextField(
              controller: _groupNameTEC,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  hintText: 'Enter group name'
                ),
                onChanged: (val){
                  setState(() {
                    
                  });
                },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  color: Color.fromRGBO(238, 238, 238, 1),
                  child: Text("Members : "+ _selectedUserCount.toString()+"/"+GroupConversationDTO.MaxGroupMembers.toString()),
                ),
              ),
            ],
          ),
          _getUserVisualizes(),
        ],
      ),
    );
  }
  Container _getUserVisualizes(){
    
    List<Widget> userVisiableWidgets = new List<Widget>.empty(growable: true);
    for (var userSellect in widget._myUsersSellect) {
      if(userSellect.user != null && userSellect.select){
        Widget userVisualize=UserVisualize(userSellect.user, (){
          setState(() {
            userSellect.select=false;
          });
        });
        userVisiableWidgets.add(userVisualize);
      }
    }
    return Container(
      child: SingleChildScrollView(
        child: Wrap(
          direction: Axis.horizontal,
          children: userVisiableWidgets,
        ),
      ),
    );
  }
    _getImage(ImageSource imgSource,PickerMode pickerMode) async {
    if(pickerMode == PickerMode.ImageRemove){
      setState(() {
        _selectedImage = null;
      });
    }
    else if(pickerMode != PickerMode.None){
      final pickedFile = await _picker.getImage(source: imgSource);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }
}
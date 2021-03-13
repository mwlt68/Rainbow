import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/views/sub_pages/group_members_select_page.dart';

class GroupCreate extends StatefulWidget {
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
            visible: _groupNameTEC.text.trim().length >0 && _selectedUserCount > 0,
            child: TextButton(
              child: Text("Create",style: TextStyle(color:Colors.white),),
              style: ButtonStyle(
                backgroundColor:  MaterialStateProperty.all<Color>(Theme.of(context).accentColor),
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
                  child: Text("Members : "+ _selectedUserCount.toString()+"/"+Conversation.GroupMaxMember.toString()),
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
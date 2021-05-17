import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/components/widgets/contextfull_widgets.dart';
import 'package:rainbow/components/widgets/widgets.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_selection_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/core_view_models/core_conversation_view_model.dart';
import 'package:rainbow/views/derived_from_main_views/group_create/group_create_view_model.dart';
import 'package:rainbow/views/derived_from_main_views/message/message_view.dart';
import 'package:rainbow/core/base/base_state.dart';
part 'group_create_string_values.dart';


class GroupCreate extends StatefulWidget {
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  List<SelectionModel<MyUserModel>> _myUserModelsSellect;
  GroupCreate(this._myUserModelsSellect);
  @override
  _GroupCreateState createState() => _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> with BaseState{
  final _GroupCreateStringValues _values = new _GroupCreateStringValues();
  TextEditingController _groupNameTEC = new TextEditingController();
  GroupCreateViewModel _groupCreateViewModel;
  ContextfullWidgets _contextfullWidgets;
  bool isActiveForCreate = false;
  final _picker = ImagePicker();
  File _selectedImage;

  @override
  void initState() {
    super.initState();
    _groupCreateViewModel = new GroupCreateViewModel(widget._myUserModelsSellect);
    _contextfullWidgets = new ContextfullWidgets(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(context),
      body: buildBody(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      actions: [
        appBarActionCreateButton(),
      ],
    );
  }

  Visibility appBarActionCreateButton() {
    return Visibility(
        visible:
            _groupCreateViewModel.isCreateButtonActive(_groupNameTEC.text),
        child: Container(
          margin: EdgeInsets.all(10),
          child: TextButton(
            onPressed: _createClick,
            child: Text(
              _values.Create,
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(colorConsts.accentColor),
            ),
          ),
        ),
      );
  }

  Column buildBody() {
    return Column(
      children: [
        stackImagePicker(),
        groupNameContainer(),
        selectedUserCountText(),
        getUserVisualizes(),
      ],
    );
  }

  Widget stackImagePicker() {
    return _contextfullWidgets.StackImagePicker(
      _selectedImage == null
          ? NetworkImage(stringConsts.userDefaultImagePath)
          : FileImage(_selectedImage),
      _getImage,
    );
  }

  Container groupNameContainer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        controller: _groupNameTEC,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: _values.NameTEC,
        ),
        onChanged: (val) {
          setState(() {});
        },
      ),
    );
  }

  Row selectedUserCountText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: colorConsts.perfectGrey,
            child: Text(_groupCreateViewModel.selectedCountText()),
          ),
        ),
      ],
    );
  }

  

  Container getUserVisualizes() {
    List<Widget> userVisiableWidgets = userVisualizeWidgets();
    var container= userVisualizeContainer(userVisiableWidgets);
    return container;
  }

  List<Widget> userVisualizeWidgets(){
    List<Widget> userVisiableWidgets = new List<Widget>.empty(growable: true);
    for (var userSellect in widget._myUserModelsSellect) {
      if (userSellect.model != null && userSellect.select) {
        Widget userVisualize = MyUserModelVisualize(userSellect.model, () {
          setState(() {
            userSellect.select = false;
          });
        });
        userVisiableWidgets.add(userVisualize);
      }
    }
    return userVisiableWidgets;
  }
  Container userVisualizeContainer(List<Widget> userVisiableWidgets) {
    return Container(
    child: SingleChildScrollView(
      child: Wrap(
        direction: Axis.horizontal,
        children: userVisiableWidgets,
      ),
    ),
  );
  }

  _getImage(ImageSource imgSource, PickerMode pickerMode) async {
    if (pickerMode == PickerMode.ImageRemove) {
      setState(() {
        _selectedImage = null;
      });
    } else if (pickerMode != PickerMode.None) {
      final pickedFile = await _picker.getImage(source: imgSource);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  _createClick() async {
    var model = getIt<ConversationViewModel>();
    List<String> selectedUsers = _groupCreateViewModel.myUserModelsSellect.selectedModelsId;
    selectedUsers.add(MyUserModel.CurrentUserId);
    var conversation = await model.startGroupConversation(
        selectedUsers, _groupNameTEC.value.text, _selectedImage);
    if (conversation != null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      widget._navigatorService
          .navigateTo(MessagePage(conversation: conversation));
    }
  }

}

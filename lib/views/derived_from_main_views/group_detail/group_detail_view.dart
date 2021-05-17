import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/components/widgets/widgets.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/core_view_models/core_conversation_view_model.dart';
import 'package:rainbow/views/derived_from_main_views/group_detail/group_detail_view_mode.dart';
import 'package:rainbow/views/derived_from_main_views/group_member_select/group_ms_option.dart';
import 'package:rainbow/views/derived_from_main_views/group_member_select/group_ms_view.dart';
import 'package:rainbow/views/derived_from_main_views/user_detail/user_detail_view.dart';
import 'package:rainbow/views/derived_from_main_views/group_detail/user_popupmenu.dart';
import 'package:rainbow/core/base/base_state.dart';

part 'group_detail_string_values.dart';

class GroupDetailPage extends StatefulWidget {
  String conversationId;
  GroupDetailPage(this.conversationId);
  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> with BaseState{
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  final _GroupDetailStringValues _values = new _GroupDetailStringValues();
  GroupDetailViewModel _viewModel;
  ConversationViewModel _conversationModel;
  TextEditingController _nameTEC;
  final _picker = ImagePicker();
  File _selectedImage;
  bool _didChange = false;
  bool _didLoadConversation = false;
  bool _removeUserImg = false;
  MyDialogs _myDialogs;
  @override
  void initState() {
    super.initState();
    _myDialogs = new MyDialogs(context);
    _conversationModel = getIt<ConversationViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (_didLoadConversation) {
      return createPage();
    }
    return ChangeNotifierProvider(
      create: (BuildContext context) => _conversationModel,
      child: StreamBuilder<GroupConversationDTOModel>(
          stream:
              _conversationModel.getGroupConversation(widget.conversationId),
          builder: (context, AsyncSnapshot<GroupConversationDTOModel> snapshot) {
            if (snapshot.hasError) {
              return MyBasicErrorWidget(title: snapshot.error.toString());
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            _viewModel = new GroupDetailViewModel(snapshot.data);
            _didLoadConversation = true;
            _nameTEC = new TextEditingController(
                text: _viewModel.conversationCache.name);
            return createPage();
          }),
    );
  }

  Widget createPage() {
    return Container(
      color: colorConsts.perfectGrey,
      child: CustomScrollView(
        slivers: [
          sliverAppBar(),
          SliverToBoxAdapter(
            child: nameTEC(),
          ),
          SliverToBoxAdapter(
            child: membersText(),
          ),
          SliverList(delegate: new SliverChildListDelegate(membersListView())),
          SliverToBoxAdapter(
            child: leaveGroup(),
          ),
          SliverToBoxAdapter(
            child: addMemberToGroup(),
          ),
          SliverToBoxAdapter(
            child: MyInfoCard(context, Icons.date_range, _values.CreateDate,
                _viewModel.conversationDateWithFormat()),
          ),
        ],
      ),
    );
  }

  SliverAppBar sliverAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 200,
      actions: [sliverAppBarSaveAction()],
      flexibleSpace: FlexibleSpaceBar(
        background: flexibleSpaceBarBackground(),
      ),
    );
  }

  GestureDetector flexibleSpaceBarBackground() {
    return GestureDetector(
      onTap: () {
        _myDialogs.showPicker(_getImage, removeIsVisiable: true);
      },
      child: _getBackgroundImage(),
    );
  }

  Visibility sliverAppBarSaveAction() {
    return Visibility(
      visible: _didChange,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white)),
        child: Text(_values.Save),
        onPressed: () {
          _saveButton();
        },
      ),
    );
  }

  List membersListView() {
    return _viewModel.conversationCache.myUserModels
        .map<Widget>((e) => getTile(e))
        .toList();
  }

  _userRemove(String userId) {
    _conversationModel
        .removeGroupConversationUser(_viewModel.conversationCache, false,
            memberId: userId)
        .then((value) {
      Navigator.pop(context);
    });
  }

  Widget getTile(MyUserModel user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
            user?.imgSrcWithDefault,
            scale: 0.1),
      ),
      title: Text(user.name ?? _values.NotFound),
      subtitle: Text(user.status ?? _values.NotFound),
      trailing: getUserPopupMenu(user),
    );
  }

  Widget getUserPopupMenu(MyUserModel user) {
    return PopupMenuButton<UserPopUpMenuOptions>(
        child: Icon(
          Icons.more_vert,
          size: 36,
        ),
        onSelected: (choice) {
          popupChoice(choice, user.id);
        },
        itemBuilder: (context) {
          return UserPopUpMenuOptions.values.map((enumItem) {
            String menuOptonText = enumItem.toShortString();
            return PopupMenuItem<UserPopUpMenuOptions>(
              child: Text(menuOptonText),
              value: enumItem,
            );
          }).toList();
        });
  }

  Future<void> popupChoice(UserPopUpMenuOptions option, String userId) async {
    switch (option) {
      case UserPopUpMenuOptions.Detail:
        _navigatorService.navigateTo(UserDetailPage(
          userId: userId,
        ));
        break;
      case UserPopUpMenuOptions.Remove:
        _myDialogs.showYesNoDialog(() {
          _userRemove(userId);
        }, _values.RemoveDialogTitle, _values.RemoveDialogContent);
        break;
      default:
    }
  }

  Widget leaveGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            color: Colors.white,
            child: TextButton(
              child: Text(
                _values.LeaveGroup,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.red),
              ),
              onPressed: _leaveGroupClick,
            ),
          ),
        ),
      ],
    );
  }

  _leaveGroupClick() {
    _myDialogs.showYesNoDialog(() async {
      await _conversationModel.removeGroupConversationUser(
          _viewModel.conversationCache, true);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }, _values.LeaveGroupDialogTitle, _values.LeaveGroupDialogContent);
  }

  Widget addMemberToGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            color: Colors.white,
            child: TextButton(
              child: Text(
                _values.AddMember,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.blue),
              ),
              onPressed: _addMemberToGroupClick,
            ),
          ),
        ),
      ],
    );
  }

  _addMemberToGroupClick() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupMembersSelect(
          GroupMemberSelectOption.add,
          constSellectedUsers: _viewModel.selectedUsersId,
        ),
      ),
    ).then<List<String>>((selectedUserIds) {
      _addMemberToGroupClickThen(selectedUserIds);
    });
  }

  void _addMemberToGroupClickThen(List<String> selectedUserIds) async {
    if (selectedUserIds is List<String>) {
      if (selectedUserIds.length > 0) {
        await _conversationModel.addMemberToGroupConversation(
            _viewModel.conversationCache, selectedUserIds);
        Navigator.pop(context);
      }
    }
  }

  Widget membersText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: Colors.white,
            child: Text(_viewModel.selectedCountText()),
          ),
        ),
      ],
    );
  }

  Widget nameTEC() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        onChanged: _nameTECValueChange,
        controller: _nameTEC,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            hintText: _values.NameTEC),
      ),
    );
  }

  _nameTECValueChange(String val) {
    if (!_didChange && val != _viewModel.conversationCache.name) {
      setState(() {
        _didChange = true;
      });
    }
  }

  Widget _getBackgroundImage() {
    if (_selectedImage == null) {
      if (_removeUserImg) {
        return Image.network(
          stringConsts.userDefaultImagePath,
          fit: BoxFit.fill,
        );
      } else {
        if (_viewModel.conversationCache.profileImage == null) {
          return Image.network(
            stringConsts.userDefaultImagePath,
            fit: BoxFit.fill,
          );
        } else {
          return Image.network(
            _viewModel.conversationCache.profileImage,
            fit: BoxFit.fill,
          );
        }
      }
    } else {
      return Image.file(
        _selectedImage,
        fit: BoxFit.fill,
      );
    }
  }

  void _saveButton() async {
    if (_conversationModel.busy) return;
    _conversationModel.busy = true;
    String response = await _conversationModel.updateGroupConversation(
        _viewModel.conversationCache,
        _selectedImage,
        _nameTEC.text,
        _removeUserImg);

    _conversationModel.busy = false;
    if (response != null) {
      _myDialogs.showErrorDialog(_values.UpdateError, message: response);
    } else {
      setState(() {
        _didChange = false;
        _didLoadConversation = false;
        _removeUserImg = false;
      });
    }
  }

  _getImage(ImageSource imgSource, PickerMode pickerMode) async {
    if (pickerMode == PickerMode.ImageRemove) {
      setState(() {
        _didChange = true;
        _removeUserImg = true;
        _selectedImage = null;
      });
    } else if (pickerMode != PickerMode.None) {
      final pickedFile = await _picker.getImage(source: imgSource);
      if (pickedFile != null) {
        setState(() {
          _didChange = true;
          _removeUserImg = false;
          _selectedImage = File(pickedFile.path);
        });
      } else {}
    }
  }
}

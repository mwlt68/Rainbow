import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:intl/intl.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/viewmodels/conversation_model.dart';

class GroupDetailPage extends StatefulWidget {
  String conversationId;
  GroupDetailPage(this.conversationId);
  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  ConversationModel _conversationModel;
  TextEditingController _nameTEC;
  final _picker = ImagePicker();
  File _selectedImage;
  bool _didChange = false;
  bool _didLoadConversation = false;
  bool _removeUserImg = false;
  GroupConversationDTO _conversationCache;

  @override
  void initState() {
    super.initState();
    _conversationModel = getIt<ConversationModel>();
  }

  @override
  Widget build(BuildContext context) {
    if (_didLoadConversation) {
      return Scaffold(
        body: createPage(_conversationCache),
      );
    }
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (BuildContext context) => _conversationModel,
        child: StreamBuilder<GroupConversationDTO>(
            stream:
                _conversationModel.getGroupConversation(widget.conversationId),
            builder: (context, AsyncSnapshot<GroupConversationDTO> snapshot) {
              if (snapshot.hasError) {
                return BasicErrorWidget(title: snapshot.error.toString());
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              _conversationCache = snapshot.data;
              _didLoadConversation = true;
              return createPage(_conversationCache);
            }),
      ),
    );
  }

  Widget createPage(GroupConversationDTO conversation) {
    _nameTEC = new TextEditingController(text: conversation.name);
    var formatter = DateFormat.yMMMMd('en_US');
    var date = conversation.createDate.toDate();
    return Container(
      color: Color.fromRGBO(238, 238, 238, 1),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 200,
            actions: [
              Visibility(
                visible: _didChange,
                child: TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white)),
                  child: Text("Save"),
                  onPressed: () {
                    _saveButton();
                  },
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {
                  showPicker(context, _getImage, removeIsVisiable: true);
                },
                child: _getBackgroundImage(conversation),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: nameTEC(conversation),
          ),
          SliverToBoxAdapter(
            child: membersText(conversation),
          ),
          SliverList(
              delegate:
                  new SliverChildListDelegate(membersListView(conversation))),
          SliverToBoxAdapter(
            child: leaveGroup(),
          ),
          SliverToBoxAdapter(
            child: InfoCard(context, Icons.date_range, "Create Date",
                formatter.format(date)),
          ),
        ],
      ),
    );
  }

  List membersListView(GroupConversationDTO conversation) {
    return conversation.myUsers.map<Widget>((e) => getTile(e)).toList();
  }

  Widget getTile(MyUser user) {
    return ListTile(
      onTap: () {
        print("aaa");
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
            user?.imgSrc ?? DefaultData.UserDefaultImagePath,
            scale: 0.1),
      ),
      title: Text(user.name ?? "Not Found"),
      subtitle: Text(user.status ?? "Not Found"),
    );
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
                "Leave Group",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.red),
              ),
              onPressed: () async {
                await _conversationModel.removeGroupConversationUserTest(
                    _conversationCache, true);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget membersText(GroupConversationDTO conversation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: Colors.white,
            child: Text("Members : " +
                conversation.myUsers.length.toString() +
                "/" +
                GroupConversationDTO.MaxGroupMembers.toString()),
          ),
        ),
      ],
    );
  }

  Widget nameTEC(GroupConversationDTO conversation) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        onChanged: (val) {
          if (!_didChange && val != conversation.name) {
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
            hintText: 'Enter a name'),
      ),
    );
  }

  Widget _getBackgroundImage(GroupConversationDTO conversationDTO) {
    if (_selectedImage == null) {
      if (_removeUserImg) {
        return Image.network(
          DefaultData.UserDefaultImagePath,
          fit: BoxFit.fill,
        );
      } else {
        if (conversationDTO.profileImage == null) {
          return Image.network(
            DefaultData.UserDefaultImagePath,
            fit: BoxFit.fill,
          );
        } else {
          return Image.network(
            conversationDTO.profileImage,
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
    String response = await _conversationModel.updateGroupConversationTest(
        _conversationCache, _selectedImage, _nameTEC.text, _removeUserImg);

    _conversationModel.busy = false;
    if (response != null) {
      showErrorDialog(context, title: "Update Error", message: response);
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

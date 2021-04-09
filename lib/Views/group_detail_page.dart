/*
import 'package:flutter/material.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/viewmodels/conversation_model.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupId;
  GroupDetailPage(this.groupId);
  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  ConversationModel _conversationModel;

  @override
  void initState() {
    super.initState();
    _conversationModel = getIt<ConversationModel>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (BuildContext context) => _userModel,
        child: StreamBuilder<MyUser>(
            stream: _userModel.getMyUserFromUserId(widget.userId),
            builder: (context, AsyncSnapshot<MyUser> userSnapshot) {
              if (userSnapshot.hasError) {
                return BasicErrorWidget(title: userSnapshot.error.toString());
              } else if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return createPage(userSnapshot.data);
            }),
      ),
    );
  }
}
*/
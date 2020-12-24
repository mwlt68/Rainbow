import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Views/message_page.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/common/shared_functions.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/navigator_service.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/viewmodels/conversation_model.dart';
import 'package:rainbow/core/viewmodels/message_model.dart';

class ConversationPage extends StatefulWidget {
  ConversationPage({this.user});
  final User user;
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final NavigatorService _navigatorService = getIt<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: getMessages()),
    );
  }
  
  Widget getMessages() {
    var model = GetIt.instance<ConversationModel>();
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<List<Conversation>>(
          stream: model.conversations(widget.user.uid),
          builder: (context, AsyncSnapshot<List<Conversation>> snapshot) {
            if (snapshot.hasError) {
              showErrorDialog(context,
                  title: "Data could not load !", message: snapshot.error);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            return _getListView(snapshot.data);
          }),
    );
  }
  ListView _getListView(List<Conversation> conversations) {
    List<Widget> tiles = new List<Widget>();
    for (var conversation in conversations) {

      Widget tile = _getListTile(conversation);
      tiles.add(tile);
    }
    return ListView(
      children: tiles,
    );
  }


  Widget _getListTile(Conversation conversation) {
    var model = GetIt.instance<MessageModel>();
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<Message>(
          stream: model.getLastMessage(conversation.id),
          builder: (context, AsyncSnapshot<Message> snapshot) {
            if (snapshot.hasError) {
              return Container(child: Text("Error"),);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return  _creatListTile( conversation, snapshot.data);
          }),
    );
    
  }
  ListTile _creatListTile(Conversation conversation,Message lastMessage){
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(conversation.profileImage, scale: 0.1),
      ),
      title: Text(conversation.name),
      subtitle:  _getListTileSubtitle(lastMessage),
      trailing: lastMessage != null ? Column(
        children: [
          Text(StaticFunctions.getTimeStampV1(lastMessage.timeStamp)),
        ],
      ):SizedBox(),
      onTap: () {
        _navigatorService.navigateTo(MessagePage(
          userId: widget.user.uid,
          conversation: conversation,
        ));
      },
    );
  }
  Widget _getListTileSubtitle(Message lastMessage){
    if(lastMessage == null){
      SizedBox();
    }
    else{
      if(lastMessage.isMedia){
        return Text(DefaultData.AnImage,overflow: TextOverflow.ellipsis);
      }
      else{
        return Text(lastMessage.message,overflow: TextOverflow.ellipsis);
      }
    }

  }
}

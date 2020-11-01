import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/error_dialogs.dart';
import 'package:rainbow/Views/conversation_page.dart';
import 'package:rainbow/models/converstaion.dart';
import 'package:rainbow/viewmodels/chat_model.dart';

class ChatPage extends StatefulWidget {
  ChatPage({this.user});
  final User user;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: getMessages(),
    );
  }

  Widget getMessages() {
    var model = GetIt.instance<ChatModel>();
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<List<Conversation>>(
          stream: model.conversations(widget.user.uid),
          builder: (context, AsyncSnapshot<List<Conversation>> snapshot) {
            if (snapshot.hasError) {
              ShowErrorDialog(context,
                  title: "Data could not load !", message: snapshot.error);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            return ListView(
              children: snapshot.data
                  .map((conversation) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              conversation.profileImage,
                              scale: 0.1),
                        ),
                        title: Text(conversation.name),
                        subtitle: Text(conversation.displayMessage),
                        trailing: Column(
                          children: [
                            Text("19:34"),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              alignment: Alignment.center,
                              child: Text(
                                "12",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).accentColor),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (content) => ConversationPage(
                                        userId: widget.user.uid,
                                        conversationId: conversation.id,
                                      )));
                        },
                      ))
                  .toList(),
            );
          }),
    );
  }
}

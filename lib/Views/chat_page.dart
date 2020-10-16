
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Views/conversation_page.dart';
import 'package:rainbow/Widgets/error_widgets.dart';
import 'package:rainbow/models/converstaion.dart';
import 'package:rainbow/viewmodels/chat_model.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final String mevlutId="LpfLFzN0RsRU4lg2rot8ypyRw023";
  final String phoneId="mpGlKzhNc8ZpPtvxFC9lRNjx46I2";
  @override
  Widget build(BuildContext context) {
    return Container(
      child: getMessages(),
    );
  }

  Widget getMessages() {
    var model =GetIt.instance<ChatModel>();
    return ChangeNotifierProvider(
        create: (BuildContext context)=>model,
        child: StreamBuilder<List<Conversation>>(
          stream: model.conversations(mevlutId),
        builder: (context, AsyncSnapshot<List<Conversation>> snapshot) {
          if (snapshot.hasError) {
            return BasicErrorWidget(
                title: "Data could not load !", message: snapshot.error);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data
                .map((conversation) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(conversation.profileImage,scale: 0.1),
                      ),
                      title: Text(conversation.name),
                      subtitle: Text(conversation.displayMessage),
                      trailing: Column(
                        children: [
                          Text("19:34"),
                          Container(
                            margin: EdgeInsets.only(top:10),
                            alignment:Alignment.center ,
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
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute(
                          builder: (content)=>ConversationPage(userId: mevlutId,conversationId: conversation.id,))
                          );
                      },
                    ))
                .toList(),
          );
        }
        ),);
  }
}

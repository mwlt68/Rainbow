import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rainbow/Widgets/error_widgets.dart';

class ChatPage extends StatefulWidget {
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
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Chats').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return BasicErrorWidget(
                title: "Data could not load !", message: snapshot.error);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data.docs
                .map((e) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage("https://picsum.photos/200"),
                      ),
                      title: Text(e['name']),
                      subtitle: Text(e['message']),
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
                    ))
                .toList(),
          );
        });
  }
}

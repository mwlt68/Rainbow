import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rainbow/Widgets/error_widgets.dart';
class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context)  {
    return Container(
      child:  getMessages(),
    );
  }
  Widget getMessages()   {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Chats').snapshots() ,
      builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasError){
          return BasicErrorWidget(title: "Data could not load !",message: snapshot.error);
        }
        else if (snapshot.connectionState==ConnectionState.waiting)
        {
          return CircularProgressIndicator();
        }
        return ListView(
            children: snapshot.data.docs.map((e) => ListTile(
              title: Text(e['name']),
              subtitle: Text(e['message']),
            )).toList(),
          );
    });
  }
}
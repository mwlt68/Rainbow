import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConversationPage extends StatefulWidget {
  final String userId;
  final String conversationId;

  const ConversationPage({Key key, this.userId, this.conversationId}) : super(key: key);
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
    TextEditingController _textController;
  CollectionReference _ref;
  @override
  void initState() {
    final String  _collectionPath='Conversation/${widget.conversationId}/messages';
    _ref=FirebaseFirestore.instance.collection(_collectionPath); 
    _textController= new TextEditingController();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage("https://picsum.photos/200", scale: 0.1),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "Mevlüt Gür",
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.phone,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.video_call,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: null),
          IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: null),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                  "https://i.pinimg.com/originals/2b/82/95/2b829561dee9e42f1e39983ab023821a.png"),
              fit: BoxFit.fill),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _ref.orderBy('timeStamp').snapshots(),
                builder: (context, snapshot) {
                  return 
                  !snapshot.hasData ?
                     CircularProgressIndicator() :
                     ListView(
                    children: snapshot.data.docs.map((e) =>  ListTile(
                          title: Align(
                            alignment: e['senderId']  == widget.userId
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: e['senderId']  == widget.userId
                                      ? Theme.of(context).accentColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  e['message'],
                                  style: TextStyle(color: Colors.black),
                                )),
                          ),
                        )).toList(),
                  );
                  }
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25))),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: InkWell(
                          child: Icon(Icons.tag_faces),
                        ),
                      ),
                      Expanded(
                          child: TextField(
                            controller: _textController,
                        decoration: InputDecoration(
                            hintText: "Write a message",
                            border: InputBorder.none),
                      )),
                      InkWell(
                        child: Icon(Icons.attach_file),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: InkWell(
                          child: Icon(Icons.camera_alt),
                        ),
                      )
                    ],
                  ),
                )),
                Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () async {
                        await _ref.add({
                          'senderId':widget.userId,
                          'message':_textController.text,
                          'timeStamp':DateTime.now(),
                        });
                        _textController.text="";
                      },
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
  
}

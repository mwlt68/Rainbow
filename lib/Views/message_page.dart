import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/error_dialogs.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/message_service.dart';
import 'package:rainbow/models/conversation.dart';
import 'package:rainbow/viewmodels/message_model.dart';

class MessagePage extends StatefulWidget {
  final String userId;
  final String conversationId;

  const MessagePage({Key key, this.userId, this.conversationId})
      : super(key: key);
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textController;
  MessageModel _model;
  GetIt _getIt;
  @override
  void initState() {
    _textController = new TextEditingController();
    _model = getIt<MessageModel>();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _model,
      child: StreamBuilder<List<Message>>(
        stream: _model.messages(widget.conversationId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            ShowErrorDialog(context,
                title: "Data could not load !", message: snapshot.error);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return _getScaffold(snapshot.data);
        },
      ),
    );
  }

  Scaffold _getScaffold(List<Message> messages) {
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
      body: _getBodyContainer(messages),
    );
  }

  Container _getBodyContainer(List<Message> messages) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(
                "https://i.pinimg.com/originals/2b/82/95/2b829561dee9e42f1e39983ab023821a.png"),
            fit: BoxFit.fill),
      ),
      child: Column(children: [
        Expanded(
          child: _getListView(messages),
        ),
        Row(children: _getBodyContainerRow()),
      ]),
    );
  }

  ListView _getListView(List<Message> messages) {
    List<ListTile> tiles = new List<ListTile>();
    for (var message in messages) {
      ListTile tile = _getListTile(message);
      if (tile != null) tiles.add(tile);
    }
    return ListView(
      controller: _scrollController,
      shrinkWrap: true,
      children: tiles,
    );
  }

  ListTile _getListTile(Message message) {
    return ListTile(
        title: Align(
      alignment: message.senderId == widget.userId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: message.senderId == widget.userId
                ? Theme.of(context).accentColor
                : Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            message.message,
            style: TextStyle(color: Colors.black),
          )),
    ));
  }

  List<Widget> _getBodyContainerRow() {
    return [
      Expanded(
          child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.horizontal(
                left: Radius.circular(25), right: Radius.circular(25))),
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
                  hintText: "Write a message", border: InputBorder.none),
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
              color: Theme.of(context).primaryColor, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: () async {
              await _model.sendMessage(
                  widget.userId, _textController.text,widget.conversationId);
              _textController.text = "";
            },
          ))
    ];
  }

  void _scroolAnimateToEnd() {
    var scrollPosition = _scrollController.position;
    _scrollController.animateTo(
      scrollPosition.maxScrollExtent,
      duration: new Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }
}

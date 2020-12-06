import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/error_dialogs.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/viewmodels/message_model.dart';

class MessagePage extends StatefulWidget {
  final String userId;
  final Conversation conversation;

  const MessagePage({Key key, this.userId, this.conversation})
      : super(key: key);
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final picker = ImagePicker();
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
        stream: _model.messages(widget.conversation.id),
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
                  NetworkImage(widget.conversation.profileImage, scale: 0.1),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                widget.conversation.name,
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
            //Background Image
            image: NetworkImage(
                "https://i.pinimg.com/originals/2b/82/95/2b829561dee9e42f1e39983ab023821a.png"),
            fit: BoxFit.fill),
      ),
      child: Column(children: [
        Expanded(
          child: _getListView(messages),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _getBodyContainerRow()
           ),
      ]),
    );
  }

  ListView _getListView(List<Message> messages) {
    List<GestureDetector> tiles = new List<GestureDetector>();
    for (var message in messages) {
      GestureDetector gestureDetector = _getGestureDetector(message);
      if (gestureDetector != null) tiles.add(gestureDetector);
    }
    return ListView(
      controller: _scrollController,
      shrinkWrap: true,
      children: tiles,
    );
  }

  GestureDetector _getGestureDetector(Message message) {
    return GestureDetector(
      child: ListTile(
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
            child: _getMessageContentWidget(message)),
      )),
    );
  }

  Widget _getMessageContentWidget(Message message) {
    if (message.isMedia) {
      return Image.network(message.message, width: 250, height: 250);
    } else {
      return Text(
        message.message,
        style: TextStyle(color: Colors.black),
      );
    }
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
              padding: EdgeInsets.only(left:10,right: 10),
              child: InkWell(
                child: IconButton(
                  onPressed: () {
                    _showPicker(context);
                  },
                  icon: Icon(Icons.camera_alt),
                ),
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
                  false, widget.userId, widget.conversation.id,
                  message: _textController.text);
              _textController.text = "";
              _scroolAnimateToEnd();
            },
          ))
    ];
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _getImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _getImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _getImage(ImageSource imgSource) async {
    final pickedFile = await picker.getImage(source: imgSource);
    if (pickedFile != null) {
      var _image = File(pickedFile.path);
      await _model.sendMessage(true, widget.userId, widget.conversation.id,
          file: _image);
    } else {
    }
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

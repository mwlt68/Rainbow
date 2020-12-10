import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/error_dialogs.dart';
import 'package:rainbow/core/default_data.dart';
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

class MessageSellection {
  MessageSellection(this.message, {this.didSelect = false});
  Message message;
  bool didSelect;
}

class _MessagePageState extends State<MessagePage> {
  List<MessageSellection> cachedMessageSellections =
      new List<MessageSellection>();
  bool _selectionIsActive = false;
  final picker = ImagePicker();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textController;
  MessageModel _model;

  @override
  void initState() {
    _textController = new TextEditingController();
    _model = getIt<MessageModel>();
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
            if (cachedMessageSellections != null) {
              return _getScaffold();
            } else {
              return CircularProgressIndicator();
            }
          }

          cachedMessageSellections = _getCachedMessages(snapshot.data);
          return _getScaffold();
        },
      ),
    );
  }

  Scaffold _getScaffold() {
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
        actions: _getScaffoldActions(),
      ),
      body: _getBodyContainer(),
    );
  }

  /*
    This method compare to new messages condition and cached messages condition .
   */
  List<MessageSellection> _getCachedMessages(List<Message> newMessages) {
    List<MessageSellection> messageSellections = new List<MessageSellection>();
    for (var message in newMessages) {
      var didMatch = false;
      for (var cMessageS in cachedMessageSellections) {
        if (cMessageS.message.id == message.id) {
          MessageSellection messageSellection = new MessageSellection(
              cMessageS.message,
              didSelect: cMessageS.didSelect);
          messageSellections.add(messageSellection);
          didMatch = true;
          break;
        }
      }
      if (!didMatch) {
        MessageSellection messageSellection = new MessageSellection(message);
        if (messageSellection != null) {
          messageSellections.add(messageSellection);
        }
      }
    }
    return messageSellections;
  }

  Container _getBodyContainer() {
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
          child: _getListView(),
        ),
        Container(
          color: _selectionIsActive ?   DefaultColors.DarkBlue: null,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _selectionIsActive
                  ? _selectModeButtons()
                  : _getBodyContainerRow()),
        ),
      ]),
    );
  }

  List<Widget> _getScaffoldActions() {
    return [
      IconButton(
        disabledColor: Colors.black,
        icon: Icon(
          Icons.phone,
          color: _selectionIsActive ? null : Colors.white,
        ),
        iconSize: 30,
        onPressed: null,
      ),
      IconButton(
          disabledColor: Colors.black,
          icon: Icon(
            Icons.video_call,
            color: _selectionIsActive ? null : Colors.white,
          ),
          iconSize: 30,
          onPressed: null),
      IconButton(
          disabledColor: Colors.black,
          icon: Icon(
            Icons.select_all_sharp,
            color: _selectionIsActive ? null : Colors.white,
          ),
          iconSize: 30,
          onPressed: _selectionIsActive
              ? null
              : () {
                  setState(() {
                    _selectionIsActive = true;
                  });
                }),
    ];
  }

  /* When select mode active this buttons are visible.
    Cancel button: This button will be unsellect to sellected button.And turn old (_getBodyContainerRow) userinterface.
    Delete button: This button will delete messages in firebase messages collection.And turn old userinterface.
  */
  List<Widget> _selectModeButtons() {
    return [
      FlatButton(
          onPressed: () {
            setState(() {
              cachedMessageSellections.forEach((e) => e.didSelect = false);
              _selectionIsActive = false;
            });
          },
          child: Text("Cancel",style: TextStyle(color:DefaultColors.DarkBlue),),
          color: DefaultColors.BlueAndGrey),
      FlatButton(
          onPressed: () {}, child: Text("Delete",style: TextStyle(color:DefaultColors.DarkBlue),), color: DefaultColors.Yellow)
    ];
  }

  // ListView contain a lot of gestures.
  ListView _getListView() {
    List<GestureDetector> gestures = new List<GestureDetector>();
    for (var messageSellection in cachedMessageSellections) {
      var gesture = _getGestureDetector(messageSellection);
      if (gesture != null) {
        gestures.add(gesture);
      }
    }
    return ListView(
      controller: _scrollController,
      shrinkWrap: true,
      children: gestures,
    );
  }

  // GestureDetector contain  a ListTile for show a message content.
  GestureDetector _getGestureDetector(MessageSellection messageSellection) {
    var listTile = ListTile(
        selectedTileColor:DefaultColors.YellowLowOpacity, 
        selected: messageSellection.didSelect,
        title: Align(
          alignment: messageSellection.message.senderId == widget.userId
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: messageSellection.message.senderId == widget.userId
                    ? Theme.of(context).accentColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: _getMessageContentWidget(messageSellection.message)),
        ));

    return GestureDetector(
      child: listTile,
      onTap: () {
        if (_selectionIsActive) {
          setState(() {
            messageSellection.didSelect = !messageSellection.didSelect;
          });
        }
      },
    );
  }

  // This method check received message is text or image.
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
              padding: EdgeInsets.only(left: 10, right: 10),
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

  // This method will work when pressed camera button.
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

  /* This method will work when user get any image from gallery or camera.
  Later,This image upload to firebase and url of image save in message under the messages collection. */
  _getImage(ImageSource imgSource) async {
    final pickedFile = await picker.getImage(source: imgSource);
    if (pickedFile != null) {
      var _image = File(pickedFile.path);
      await _model.sendMessage(true, widget.userId, widget.conversation.id,
          file: _image);
    } else {}
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

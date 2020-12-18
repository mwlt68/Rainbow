import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/my_dialogs.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/services/download_service.dart';
import 'package:rainbow/core/viewmodels/message_model.dart';
import 'package:rainbow/static_shared_functions.dart';
import 'package:rainbow/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool _isDownloading=false;
  String downloadId;
  int downloadProgress = 0;
  bool get isDownload {
    return _isDownloading;
  }

  void set isDownload(bool val) {
    if (val == false) {
      downloadProgress = 0;
      downloadId = null;
    }
    _isDownloading = val;
    
  }
}

class _MessagePageState extends State<MessagePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Color themeAccentColor, themePrimaryColor;
  bool _isLoad = false;
  List<MessageSellection> cachedMessageSellections =
      new List<MessageSellection>();
  bool _selectionIsActive = false;
  final picker = ImagePicker();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textController;
  MessageModel _model;
  DownloadService _downloadService;

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController();
    _model = getIt<MessageModel>();
    _downloadService = DownloadService();
    ImageDownloader.callback(onProgressUpdate: (String imageId, int progress) {
      print("id: "+imageId.toString()+"   val: "+progress.toString());
      for (var messageSellection in cachedMessageSellections) {
        if (messageSellection.isDownload &&
            messageSellection.downloadId == imageId) {
          if (progress == 100) {
            print("snapshot");
            messageSellection._isDownloading=false;
            _scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text("Download completed.")));
          } else {
            setState(() {
            print("progress");
              messageSellection.downloadProgress = progress;
            });
            break;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    themeAccentColor = Theme.of(context).accentColor;
    themePrimaryColor = Theme.of(context).primaryColor;
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
      key: _scaffoldKey,
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
          color: _selectionIsActive ? DefaultColors.DarkBlue : null,
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
          onPressed: _selectionModeCancel,
          child: Text(
            "Cancel",
            style: TextStyle(color: DefaultColors.DarkBlue),
          ),
          color: DefaultColors.BlueAndGrey),
      FlatButton(
          onPressed: _deleteMessagePreCheckSure,
          child: Text(
            "Delete",
            style: TextStyle(color: DefaultColors.DarkBlue),
          ),
          color: DefaultColors.Yellow)
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
    _setListViewScrollment();
    return ListView(
      controller: _scrollController,
      shrinkWrap: true,
      children: gestures,
    );
  }

  // GestureDetector contain  a ListTile for show a message content.
  GestureDetector _getGestureDetector(MessageSellection messageSellection) {
    var listTile = ListTile(
        selectedTileColor: DefaultColors.YellowLowOpacity,
        selected: messageSellection.didSelect,
        title: Align(
          alignment: messageSellection.message.senderId == widget.userId
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: messageSellection.message.senderId == widget.userId
                    ? themeAccentColor
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
      onLongPressEnd: (detail) {
        if (!_selectionIsActive) {
          _getMessageDetailDialog(messageSellection);
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
          decoration:
              BoxDecoration(color: themeAccentColor, shape: BoxShape.circle),
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
      _scroolAnimateToEnd();
    } else {}
  }

  void _selectionModeCancel() {
    setState(() {
      cachedMessageSellections.forEach((e) => e.didSelect = false);
      _selectionIsActive = false;
    });
  }

  void _deleteMessagePreCheckSure() {
    AlertDialog alert = AlertDialog(
      title: Text("Deletion Transaction"),
      content: Text("Are you sure for delete this messages ?"),
      actions: [
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("No")),
        FlatButton(
            onPressed: () {
              _deleteMessages();
              Navigator.pop(context);
            },
            child: Text(
              "Yes",
              style: TextStyle(color: Colors.redAccent),
            )),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _deleteMessages() async {
    var selectedMessages = List<Message>();
    cachedMessageSellections.forEach((element) {
      if (element.didSelect) {
        selectedMessages.add(element.message);
      }
    });
    await _model.deleteMessages(selectedMessages, widget.conversation.id);
    setState(() {
      _selectionIsActive = false;
    });
  }

  _getMessageDetailDialog(MessageSellection messageSellection) {
    if (messageSellection.message == null) {
      return;
    }
    showDialog(
        context: this.context,
        builder: (buildContext) {
          return SimpleDialog(
            title: Card(
              child: Container(
                padding: EdgeInsets.all(15),
                child: _getMessageContentWidget(messageSellection.message),
              ),
              shadowColor: Colors.black,
            ),
            //Text("Message Detail"),
            children: _getMessageDetailDialogChildrens(messageSellection),
          );
        });
  }

  List<Widget> _getMessageDetailDialogChildrens(
      MessageSellection messageSellection) {
    List<Widget> childrens = [];
    if (messageSellection.message.timeStamp != null) {
      childrens.add(Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MyWidgets.getRoundText(
                StaticFunctions.getTimeStampV2(
                    messageSellection.message.timeStamp),
                Colors.blue),
            MyWidgets.getRoundText(
                StaticFunctions.getTimeStampV3(
                    messageSellection.message.timeStamp),
                Colors.blue),
          ],
        ),
      ));
    }
    childrens.add(MyWidgets.getDefaultDivider);
    if (messageSellection.message.isMedia) {
      childrens.add(Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: MyWidgets.getNormalRaisedButton(
            "Download to gallary", Colors.blue, () {
          _downloadToGalary(messageSellection);
        }),
      ));
      // childrens.add(MyWidgets.getRaisedButton("Download to gallary", Colors.blue, () {}) );
    }
    if (messageSellection.message.message != null) {
      childrens.add(Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: MyWidgets.getNormalRaisedButton(
            "Copy to clickboard", Colors.blue, () {
          _copyToClickBoard(messageSellection);
        }),
      ));
    }
    return childrens;
  }

  Future<void> _downloadToGalary(MessageSellection messageSellection) async {
    try {
      if (messageSellection.message.isMedia && !messageSellection.isDownload) {
        _downloadService
            .downloadImages(messageSellection.message.message)
            .then((imageId) {
          messageSellection.downloadId = imageId;
        });
        messageSellection.isDownload = true;
        Navigator.pop(context);
      }
    } catch (e) {
      ShowErrorDialog(context, title: "Download Error", message: e.toString());
    }
  }

  void _copyToClickBoard(MessageSellection messageSellection) {
    FlutterClipboard.copy(messageSellection.message.message).then((value) {
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Coppied : ' + messageSellection.message.message)));
    });
  }

  void _scroolAnimateToEnd() {
    var scrollPosition = _scrollController.position;
    _scrollController.animateTo(
      scrollPosition.maxScrollExtent,
      duration: new Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );
  }

  void _setListViewScrollment() {
    if (!_isLoad) {
      Timer(
        Duration(milliseconds: 300),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent),
      );
      _isLoad = true;
    }
  }
}

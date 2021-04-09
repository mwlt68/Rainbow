import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/common/shared_functions.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/message.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/services/other_services/download_service.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/viewmodels/message_model.dart';
import 'package:rainbow/core/viewmodels/user_model.dart';
import 'package:rainbow/views/sub_pages/group_detail.dart';
import 'package:rainbow/views/sub_pages/user_detail_page.dart';
import 'package:grouped_list/grouped_list.dart';


class MessagePage extends StatefulWidget {
  final ConversationDTO conversation;
  const MessagePage({this.conversation});
  @override
  _MessagePageState createState() => _MessagePageState();
}

class MessageSelectionGroup {
  MessageSellection messageSelection;
  String group;
  MessageSelectionGroup(this.messageSelection, this.group);
}

class MessageSellection {
  MessageSellection(this.message, {this.didSelect = false});
  Message message;
  bool didSelect;
  bool _isDownloading = false;
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
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Color themeAccentColor, themePrimaryColor;
  bool _isLoad = false;
  double _mediaSize = 250;
  List<MessageSellection> cachedMessageSellections =
      new List<MessageSellection>();
  bool _selectionIsActive = false;
  final picker = ImagePicker();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textController;
  UserModel _userModel;
  MessageModel _model;
  DownloadService _downloadService;

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController();
    _userModel = getIt<UserModel>();
    _model = getIt<MessageModel>();
    _downloadService = DownloadService();
    ImageDownloader.callback(onProgressUpdate: (String imageId, int progress) {
      if (progress == 100) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text("Download completed.")));
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
        stream: _model.messages(widget.conversation),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return BasicErrorWidget(title: snapshot.error.toString());
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
        title: GestureDetector(
          onTap: (){
            if(widget.conversation.conversationType ==ConversationType.Single){
              String otherUserID=(widget.conversation as SingleConversationDTO).otherUser.userId;
              print(otherUserID);
              _navigatorService.navigateTo(UserDetailPage(userId: otherUserID,));
            }
            else{
              _navigatorService.navigateTo(GroupDetailPage(widget.conversation.id));
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage(widget.conversation.imgSrc ?? DefaultData.UserDefaultImagePath, scale: 0.1),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  widget.conversation.visiableName,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
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
                "https://i.pinimg.com/originals/2b/82/95/2b829561dee9e42f1e39983ab023821a.png"
              ),
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
          onPressed: () {
            showYesNoDialog(context, _deleteMessages, "Deletion Transaction",
                "Are you sure for delete this messages ?");
          },
          child: Text(
            "Delete",
            style: TextStyle(color: DefaultColors.DarkBlue),
          ),
          color: DefaultColors.Yellow)
    ];
  }

  // ListView contain a lot of gestures.
  GroupedListView _getListView() {
    GroupedListView groupedListView = _getGroupListView();
    _setListViewScrollment();
    return groupedListView;

  }

  GroupedListView _getGroupListView(){
    return GroupedListView<MessageSellection, String>(
      controller:_scrollController ,
      shrinkWrap: true,
      elements: cachedMessageSellections,
      groupBy: (element) =>
          StaticFunctions.getDateFormatForCompare(element.message.timeStamp),
      groupComparator: (value1, value2) => DateTime.parse(value1).compareTo( DateTime.parse(value2)),
      groupSeparatorBuilder: (String groupByValue) =>
          _getDailySeparator(groupByValue),
      itemBuilder: (context, messageSellection) {
        var gesture = _getGestureDetector(messageSellection);
        if (gesture != null) {
          return gesture;
        }
      }, // optional
      useStickyGroupSeparators: true, // optional
      floatingHeader: true,
    );
  }
  Widget _getDailySeparator(String dateString) {
    var date=DateTime.parse(dateString);
    String newDateFormat=StaticFunctions.getDateTimeV1(date);
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
            color: Colors.lightBlue[200],
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Text(newDateFormat),
    );
  }

  // GestureDetector contain  a ListTile for show a message content.
  GestureDetector _getGestureDetector(MessageSellection messageSellection) {
    var listTile = ListTile(
        selectedTileColor: DefaultColors.YellowLowOpacity,
        selected: messageSellection.didSelect,
        title: Align(
            alignment: messageSellection.message.senderId == MyUser.CurrentUserId
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: messageSellection.message.senderId == MyUser.CurrentUserId
                    ? themeAccentColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(25).subtract(
                    messageSellection.message.senderId == MyUser.CurrentUserId
                        ? BorderRadius.only(bottomRight: Radius.circular(25))
                        : BorderRadius.only(bottomLeft: Radius.circular(25))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getOtherNameOnGroupTest(messageSellection.message),
                  _getMessageContentWidget(messageSellection.message),
                  _getMessageTime(messageSellection.message),
                ],
              ),
            )));

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
          FocusScope.of(context).unfocus();
          _getMessageDetailDialog(messageSellection);
        }
      },
    );
  }
  Widget _getOtherNameOnGroupTest(Message message)  {
    if(widget.conversation.conversationType == ConversationType.Single || message.isCurrentUser){
      return SizedBox(width: 1,height: 1,);
    }
    else {
      Color textColor=Colors.black;
      int index=_model.getIndexFromMessageSenderId(widget.conversation, message.senderId);
      if(index >= 0){
        textColor=index <= 15 ? Colors.primaries[index]:Colors.accents[index];
          return Text(widget.conversation.users[index].name,style: TextStyle(color: textColor),);

      }
      else{
        return StreamBuilder(
          stream: _userModel.getMyUserFromUserId(message.senderId),
          builder: (context,AsyncSnapshot<MyUser> snapshot) {
          if (snapshot.hasError) {
            return BasicErrorWidget(title: snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
           
              return CircularProgressIndicator();
            
          }
          return Text(snapshot.data.name,style: TextStyle(color: textColor),);
        },
        );
      }
    }
  }
  Widget _getMessageTime(Message message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(top: 10, right: 10),
          child: Text(
            StaticFunctions.getTimeStampV2(message.timeStamp),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        )
      ],
    );
  }

  // This method check received message is text or image.
  Widget _getMessageContentWidget(Message message) {
    if (message.isMedia) {
      return Image.network(message.message,
          width: _mediaSize, height: _mediaSize);
    } else {
      return Container(
        padding: EdgeInsets.all(10),
        child: Text(
          message.message,
          style: TextStyle(color: Colors.black),
        ),
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
                  onPressed: () async {
                    showPicker(context, _getImage);
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
                  false,MyUser.CurrentUserId, widget.conversation,
                  messageParam: _textController.text);
              _textController.text = "";
              _scroolAnimateToEnd();
            },
          ))
    ];
  }

  /* This method will work when user get any image from gallery or camera.
  Later,This image upload to firebase and url of image save in message under the messages collection. */
  

  _getImage(ImageSource imgSource,PickerMode pickerMode) async {
    if(pickerMode != PickerMode.None){
      final pickedFile = await picker.getImage(source: imgSource);
      if (pickedFile != null) {
        var _image = File(pickedFile.path);
        await _model.sendMessage(true, MyUser.CurrentUserId, widget.conversation,
            file: _image);
        _scroolAnimateToEnd();
      }
    }
  }

  void _selectionModeCancel() {
    setState(() {
      cachedMessageSellections.forEach((e) => e.didSelect = false);
      _selectionIsActive = false;
    });
  }

  Future<void> _deleteMessages() async {
    var selectedMessages = List<Message>();
    cachedMessageSellections.forEach((element) {
      if (element.didSelect) {
        selectedMessages.add(element.message);
      }
    });
    await _model.deleteMessages(selectedMessages, widget.conversation);
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
            mRoundText(
                StaticFunctions.getTimeStampV2(
                    messageSellection.message.timeStamp),
                Colors.blue),
            mRoundText(
                StaticFunctions.getTimeStampV3(
                    messageSellection.message.timeStamp),
                Colors.blue),
          ],
        ),
      ));
    }
    childrens.add(mDivider);
    if (messageSellection.message.isMedia) {
      childrens.add(
        mNormalRaisedButton("Download to gallary", Colors.blue, () {
          _downloadToGalary(messageSellection);
        }),
      );
      // childrens.add(MyWidgets.getRaisedButton("Download to gallary", Colors.blue, () {}) );
    }
    if (messageSellection.message.message != null) {
      childrens.add(
        mNormalRaisedButton("Copy to clickboard", Colors.blue, () {
          _copyToClickBoard(messageSellection);
        }),
      );
    }
    childrens.add(
      mNormalRaisedButton("Cancel", Colors.orangeAccent, () {
        Navigator.pop(context);
      }),
    );
    return childrens;
  }

  Future<void> _downloadToGalary(MessageSellection messageSellection) async {
    try {
      if (messageSellection.message.isMedia && !messageSellection.isDownload) {
        _downloadService.downloadImages(messageSellection.message.message);
        Navigator.pop(context);
      }
    } catch (e) {
      showErrorDialog(context, title: "Download Error", message: e.toString());
    }
  }

  void _copyToClickBoard(MessageSellection messageSellection) {
    FlutterClipboard.copy(messageSellection.message.message).then((value) {
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(mShortSnackBar(
          'Coppied : ' + messageSellection.message.message, themeAccentColor));
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

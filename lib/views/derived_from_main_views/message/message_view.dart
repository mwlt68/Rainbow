import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/components/widgets/widgets.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_message_model.dart';
import 'package:rainbow/core/core_models/core_selection_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/other_services/formatter_service.dart';
import 'package:rainbow/core/core_view_models/core_message_view_model.dart';
import 'package:rainbow/core/core_view_models/core_user_view_model.dart';
import 'package:rainbow/views/derived_from_main_views/message/message_view_model.dart';
import 'package:rainbow/core/base/base_state.dart';
part 'message_string_values.dart';

class MessagePage extends StatefulWidget {
  final ConversationDTO conversation;
  const MessagePage({this.conversation});
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with BaseState {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textController;
  MessageLocalViewModel _messageViewModel;
  UserViewModel _userModel;
  MessageViewModel _model;
  MyDialogs _myDialogs;
  FormatterService _formatterService = new FormatterService();
  _MessageStringValues _values = new _MessageStringValues();

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController();
    _userModel = getIt<UserViewModel>();
    _model = getIt<MessageViewModel>();
    _myDialogs = new MyDialogs(context);
    _messageViewModel = new MessageLocalViewModel(widget.conversation);
    ImageDownloader.callback(onProgressUpdate: (String imageId, int progress) {
      if (progress == 100) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text(_values.downloadCompleted)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _model,
      child: StreamBuilder<List<MessageModel>>(
        stream: _model.messages(widget.conversation),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return MyBasicErrorWidget(title: snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            if (_messageViewModel.cachedMessageSellections != null) {
              return _getScaffold();
            } else {
              return CircularProgressIndicator();
            }
          }

          _messageViewModel.cachedMessageSellections =
              _messageViewModel.getCachedMessages(snapshot.data);
          return _getScaffold();
        },
      ),
    );
  }

  Scaffold _getScaffold() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(),
      body: scaffoldBody(),
    );
  }

  AppBar appBar() {
    return AppBar(
      titleSpacing: 0,
      title: appBarTitle(),
      actions: scaffoldActions(),
    );
  }

  GestureDetector appBarTitle() {
    return GestureDetector(
      onTap: _messageViewModel.navigatToDetailPage,
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage(widget.conversation.imgSrc, scale: 0.1),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                widget.conversation.visiableName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container scaffoldBody() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(_values.pageBackgroudImg), fit: BoxFit.fill),
      ),
      child: Column(children: [
        Expanded(
          child: groupedListViewWithScrollment(),
        ),
        Container(
          color:
              _messageViewModel.selectionIsActive ? colorConsts.darkBlue : null,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _messageViewModel.selectionIsActive
                  ? selectModeButtons()
                  : bodyBottom()),
        ),
      ]),
    );
  }

  List<Widget> scaffoldActions() {
    return [
      MyIconButton(Icons.phone, _messageViewModel.selectionIsActive, null),
      MyIconButton(Icons.video_call, _messageViewModel.selectionIsActive, null),
      MyIconButton(Icons.select_all_sharp, _messageViewModel.selectionIsActive,
          setSelectionMode),
    ];
  }

  List<Widget> bodyBottom() {
    return [
      Expanded(child: bottomContainer()),
      Container(
          decoration: BoxDecoration(
              color: colorConsts.accentColor, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: messageSendClick,
          ))
    ];
  }

  Container bottomContainer() {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
              left: Radius.circular(25), right: Radius.circular(25))),
      child: Row(
        children: [
          bottomContainerFaceIcon(),
          bottomContainerTextField(),
          bottomContainerAttachIcon(),
          bottomContainerCameraIcon()
        ],
      ),
    );
  }

  Padding bottomContainerCameraIcon() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: InkWell(
        child: IconButton(
          onPressed: () async {
            _myDialogs.showPicker(_getImage);
          },
          icon: Icon(Icons.camera_alt),
        ),
      ),
    );
  }

  InkWell bottomContainerAttachIcon() {
    return InkWell(
      child: Icon(Icons.attach_file),
    );
  }

  Expanded bottomContainerTextField() {
    return Expanded(
        child: TextField(
      controller: _textController,
      decoration: InputDecoration(
          hintText: _values.writeMessage, border: InputBorder.none),
    ));
  }

  Padding bottomContainerFaceIcon() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        child: Icon(Icons.tag_faces),
      ),
    );
  }

  /* When select mode active this buttons are visible.
    Cancel button: This button will be unsellect to sellected button.And turn old (_getBodyContainerRow) userinterface.
    Delete button: This button will delete messages in firebase messages collection.And turn old userinterface.
  */
  List<Widget> selectModeButtons() {
    return [
      FlatButton(
          onPressed: _selectionModeCancelClick,
          child: Text(
            _values.cancelText,
            style: TextStyle(color: colorConsts.darkBlue),
          ),
          color: colorConsts.blueAndGrey),
      FlatButton(
          onPressed: () {
            _myDialogs.showYesNoDialog(_deleteMessages,
                _values.deleteDialogTitle, _values.deleteDialogContent);
          },
          child: Text(
            _values.deleteText,
            style: TextStyle(color: colorConsts.darkBlue),
          ),
          color: colorConsts.yellow)
    ];
  }

  // ListView contain a lot of gestures.
  Widget groupedListViewWithScrollment() {
    GroupedListView groupedListView = groupListView();
    _setListViewScrollment();
    return groupedListView;
  }

  GroupedListView groupListView() {
    return GroupedListView<SelectionModel<MessageModel>, String>(
      controller: _scrollController,
      shrinkWrap: true,
      elements: _messageViewModel.cachedMessageSellections,
      groupBy: (element) =>
          _formatterService.getDateFormatForCompare(element.model.timeStamp),
      groupComparator: (value1, value2) =>
          DateTime.parse(value1).compareTo(DateTime.parse(value2)),
      groupSeparatorBuilder: (String groupByValue) =>
          dailySeparator(groupByValue),
      itemBuilder: (context, messageSellection) {
        var gesture = gestureDetector(messageSellection);
        if (gesture != null) {
          return gesture;
        }
      }, // optional
      useStickyGroupSeparators: true, // optional
      floatingHeader: true,
    );
  }

  Widget dailySeparator(String dateString) {
    var date = DateTime.parse(dateString);
    String newDateFormat = _formatterService.getDateTime_yMMMd(date);
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
  GestureDetector gestureDetector(SelectionModel<MessageModel> messageSellection) {
    var listTile = ListTile(
        selectedTileColor: colorConsts.yellowLowOpacity,
        selected: messageSellection.select,
        title: listTileTitle(messageSellection));

    return listTileGestureDetector(listTile, messageSellection);
  }

  GestureDetector listTileGestureDetector(
      ListTile listTile, SelectionModel<MessageModel> messageSellection) {
    return GestureDetector(
      child: listTile,
      onTap: () {
        if (_messageViewModel.selectionIsActive) {
          setState(() {
            messageSellection.select = !messageSellection.select;
          });
        }
      },
      onLongPressEnd: (detail) {
        if (!_messageViewModel.selectionIsActive) {
          FocusScope.of(context).unfocus();
          messageDetailDialog(messageSellection);
        }
      },
    );
  }

  Align listTileTitle(SelectionModel<MessageModel> messageSellection) {
    return Align(
        alignment: messageSellection.model.senderId == MyUserModel.CurrentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: messageSellection.model.senderId == MyUserModel.CurrentUserId
                ? colorConsts.accentColor
                : Colors.white,
            borderRadius: BorderRadius.circular(25).subtract(
                messageSellection.model.senderId == MyUserModel.CurrentUserId
                    ? BorderRadius.only(bottomRight: Radius.circular(25))
                    : BorderRadius.only(bottomLeft: Radius.circular(25))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              otherUserNameOnGroup(messageSellection.model),
              messageContentWidget(messageSellection.model),
              messageTime(messageSellection.model),
            ],
          ),
        ));
  }

  Widget otherUserNameOnGroup(MessageModel message) {
    bool checkOtherUserInGroupConversation=_messageViewModel.isOtherUserInGroupConv(message);
    if (checkOtherUserInGroupConversation) {
      int index = _model.getIndexFromMessageSenderId(
          widget.conversation, message.senderId);

      Color textColor = _colorFromIndex(index);
      return index >= 0
          ? Text(
              widget.conversation.users[index].name,
              style: TextStyle(color: textColor),
            )
          : otherUserNameOnGroupStreamBuilder(message, textColor);
    }
    else return Container(width: 1,);
  }

  StreamBuilder<MyUserModel> otherUserNameOnGroupStreamBuilder(
      MessageModel message, Color textColor) {
    return StreamBuilder(
      stream: _userModel.getMyUserModelFromUserId(message.senderId),
      builder: (context, AsyncSnapshot<MyUserModel> snapshot) {
        if (snapshot.hasError) {
          return MyBasicErrorWidget(title: snapshot.error.toString());
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        return Text(
          snapshot.data.name,
          style: TextStyle(color: textColor),
        );
      },
    );
  }

  Widget messageTime(MessageModel message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(top: 10, right: 10),
          child: Text(
            _formatterService.getDateTime_Hm(message.timeStamp),
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
  Widget messageContentWidget(MessageModel message) {
    if (message.isMedia) {
      return Image.network(message.message,
          width: _messageViewModel.mediaSize,
          height: _messageViewModel.mediaSize);
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

  messageDetailDialog(SelectionModel<MessageModel> messageSellection) {
    showDialog(
        context: this.context,
        builder: (buildContext) {
          return SimpleDialog(
            title: Card(
              child: Container(
                padding: EdgeInsets.all(15),
                child: messageContentWidget(messageSellection.model),
              ),
              shadowColor: Colors.black,
            ),
            //Text("Message Detail"),
            children: messageDetailDialogChildrens(messageSellection),
          );
        });
  }

  List<Widget> messageDetailDialogChildrens(
      SelectionModel<MessageModel> messageSellection) {
    return [
      MyNullable(messageSellection.model.timeStamp, () {
        return messageDialogTimeContainer(messageSellection);
      }),
      MyDivider,
      Visibility(
          visible: messageSellection.model.isMedia,
          child:
              MyNormalRaisedButton(_values.downloadToGalary, Colors.blue, () {
            _downloadToGalary(messageSellection);
          })),
      MyNullable(messageSellection.model.message, () {
        return MyNormalRaisedButton(_values.copyToClickboard, Colors.blue, () {
          _copyToClickBoard(messageSellection);
        });
      }),
      MyNormalRaisedButton(_values.cancelText, Colors.orangeAccent, () {
        Navigator.pop(context);
      })
    ];
  }

  Container messageDialogTimeContainer(
      SelectionModel<MessageModel> messageSellection) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MyRoundText(
              _formatterService
                  .getDateTime_Hm(messageSellection.model.timeStamp),
              Colors.blue),
          MyRoundText(
              _formatterService
                  .getDateTime_ddMMyyyy(messageSellection.model.timeStamp),
              Colors.blue),
        ],
      ),
    );
  }

  /* This method will work when user get any image from gallery or camera.
  Later,This image upload to firebase and url of image save in message under the messages collection. */

  _getImage(ImageSource imgSource, PickerMode pickerMode) async {
    if (pickerMode != PickerMode.None) {
      final pickedFile =
          await _messageViewModel.picker.getImage(source: imgSource);
      if (pickedFile != null) {
        var _image = File(pickedFile.path);
        await _model.sendMessage(
            true, MyUserModel.CurrentUserId, widget.conversation,
            file: _image);
        _scroolAnimateToEnd();
      }
    }
  }

  Future<void> messageSendClick() async {
    await _model.sendMessage(
        false, MyUserModel.CurrentUserId, widget.conversation,
        messageParam: _textController.text);
    _textController.text = _values.empty;
    _scroolAnimateToEnd();
  }

  void _selectionModeCancelClick() {
    setState(() {
      _messageViewModel.cachedMessageSellections.setAllSelection(false);
      _messageViewModel.selectionIsActive = false;
    });
  }

  Future<void> _deleteMessages() async {
    List<MessageModel> selectedMessages =
        _messageViewModel.cachedMessageSellections.selectedModels;
    await _model.deleteMessages(selectedMessages, widget.conversation);
    setState(() {
      _messageViewModel.selectionIsActive = false;
    });
  }

  Future<void> _downloadToGalary(
      SelectionModel<MessageModel> messageSellection) async {
    try {
      // && !messageSellection.isDownload
      if (messageSellection.model.isMedia) {
        _messageViewModel.downloadService
            .downloadImages(messageSellection.model.message);
        Navigator.pop(context);
      }
    } catch (e) {
      _myDialogs.showErrorDialog(_values.downloadError, message: e.toString());
    }
  }

  void _copyToClickBoard(SelectionModel<MessageModel> messageSellection) {
    FlutterClipboard.copy(messageSellection.model.message).then((value) {
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(MyShortSnackBar(
          _values.coppied + messageSellection.model.message,
          colorConsts.accentColor));
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
    if (!_messageViewModel.isLoad) {
      Timer(
        Duration(milliseconds: 300),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent),
      );
      _messageViewModel.isLoad = true;
    }
  }

  setSelectionMode() {
    if (!_messageViewModel.selectionIsActive) {
      setState(() {
        _messageViewModel.selectionIsActive = true;
      });
    }
  }

  _colorFromIndex(int index) {
    Color color = Colors.black;
    if (index >= 0) {
      color = index <= 15 ? Colors.primaries[index] : Colors.accents[index];
    }
    return color;
  }
}

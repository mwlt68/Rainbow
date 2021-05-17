import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/components/widgets/widgets.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_message_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/other_services/formatter_service.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/core_view_models/core_conversation_view_model.dart';
import 'package:rainbow/core/core_view_models/core_message_view_model.dart';
import 'package:rainbow/views/derived_from_main_views/message/message_view.dart';
import 'package:rainbow/core/base/base_state.dart';
part 'conversation_string_values.dart';

class ConversationPage extends StatefulWidget {
  ConversationPage();
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage>  with BaseState{
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  FormatterService _formatterService = new FormatterService();
  MyDialogs _myDialogs;
  _ConversationStringValues _values;
  @override
  void initState() {
    super.initState();
    _values = _ConversationStringValues();
    _myDialogs = new MyDialogs(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: getMessages()),
    );
  }

  Widget getMessages() {
    var model = GetIt.instance<ConversationViewModel>();
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<List<ConversationDTO>>(
          stream: model.conversations(MyUserModel.CurrentUserId),
          builder: (context,
              AsyncSnapshot<List<ConversationDTO>> conversationsSnapshot) {
            if (conversationsSnapshot.hasError) {
              _myDialogs.showErrorDialog(_values.ErrorDialogTitle,
                  message: conversationsSnapshot.error.toString());
            } else if (conversationsSnapshot.connectionState ==
                ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            return _getListView(conversationsSnapshot.data);
          }),
    );
  }

  ListView _getListView(List<ConversationDTO> conversations) {
    List<Widget> tiles = new List<Widget>();
    for (var conversation in conversations) {
      Widget tile = _getListTile(conversation);
      tiles.add(tile);
    }
    return ListView(
      children: tiles,
    );
  }

  Widget _getListTile(ConversationDTO conversation) {
    var model = GetIt.instance<MessageViewModel>();
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<MessageModel>(
          stream: model.getLastMessage(conversation),
          builder: (context, AsyncSnapshot<MessageModel> snapshot) {
            if (snapshot.hasError) {
              return Container(
                child: Text(_values.Error),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return _creatListTile(conversation, snapshot.data);
          }),
    );
  }

  ListTile _creatListTile(ConversationDTO conversation, MessageModel lastMessage) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
            conversation?.imgSrc,
            scale: 0.1),
      ),
      title: Text(conversation.visiableName),
      subtitle: listTileSubtitle(lastMessage),
      trailing: lastMessage != null
          ? Column(
              children: [
                Text(_formatterService
                    .getDateTimeCompareToday_ddMMyyyy(lastMessage.timeStamp)),
              ],
            )
          : SizedBox(),
      onTap: () {
        _navigatorService.navigateTo(MessagePage(conversation: conversation));
      },
    );
  }

  Widget listTileSubtitle(MessageModel lastMessage) {
    return MyNullable(
        lastMessage,
        () => Text(
              lastMessage.isMedia ? _values.AnImage : lastMessage.message,
              overflow: TextOverflow.ellipsis,
            ));
  }
}
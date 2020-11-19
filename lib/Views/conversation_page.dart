import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/error_dialogs.dart';
import 'package:rainbow/Views/message_page.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/navigator_service.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/viewmodels/convertation_model.dart';

class ConversationPage extends StatefulWidget {
  ConversationPage({this.user});
  final User user;
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final   NavigatorService _navigatorService= getIt<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: getMessages()),
    );
  }
  Widget getMessages() {
    var model = GetIt.instance<ConversationModel>();
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<List<Conversation>>(
          stream: model.conversations(widget.user.uid),
          builder: (context, AsyncSnapshot<List<Conversation>> snapshot) {
            if (snapshot.hasError) {
              ShowErrorDialog(context,
                  title: "Data could not load !", message: snapshot.error);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            return ListView(
              children: snapshot.data
                  .map((conversation) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              conversation.profileImage,
                              scale: 0.1),
                        ),
                        title: Text(conversation.name),
                        subtitle: Text(conversation.displayMessage),
                        trailing: Column(
                          children: [
                            Text("19:34"),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              alignment: Alignment.center,
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
                        onTap: () {
                          _navigatorService.navigateTo( MessagePage(
                                        userId: widget.user.uid,
                                        conversationId: conversation.id,));
                        },
                      ))
                  .toList(),
            );
          }),
    );
  }
}

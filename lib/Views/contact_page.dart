import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/viewmodels/contact_model.dart';
import 'package:rainbow/core/viewmodels/conversation_model.dart';
import 'package:rainbow/views/message_page.dart';
import 'package:rainbow/views/sub_pages/group_members_select_page.dart';

class ContactPage extends StatelessWidget {
  final String _currentUserId;
  ContactPage(this._currentUserId);
  @override
  Widget build(BuildContext context) {
    var contactListWidget=ContactsList(_currentUserId,query: "");
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact"),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: ContactSearchDelegate(contactListWidget));
              }),
          IconButton(icon: Icon(Icons.more_vert), onPressed: null),
        ],
      ),
      body: Center(child: contactListWidget),
    );
  }
}

class ContactsList extends StatelessWidget {
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  BuildContext ctx;
  Color themeAccentColor;
  String currentUserId;
  String query;
  List<MyUser> myUsers;
  ContactsList(this.currentUserId,{ Key key,this.query,}) : super(key: key);

  Widget build(BuildContext context) {
    ctx=context;
    themeAccentColor=Theme.of(context).accentColor;
    var model = getIt<ContactModel>();
    return FutureBuilder(
        future: model.getContatcs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return getMessages(model);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return  CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Contact users get error !");
                      }
        });
  }

  Widget getMessages(ContactModel model) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<List<MyUser>>(
          stream: model.getMyUser(),
          builder: (context, AsyncSnapshot<List<MyUser>> snapshot) {
            if (snapshot.hasError) {
              showErrorDialog(context,
                  title: "Data could not load !", message: snapshot.error);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            var ownUser=snapshot.data.where((element) => element.userId== this.currentUserId);
            if(ownUser.isNotEmpty){
              snapshot.data.remove(ownUser.first);
            }
            myUsers=snapshot.data;
            myUsers.sort((a,b)=> a.name.toString().compareTo(b.name.toString()));
            return Center(child: getListView());
          }),
    );
  }
  ListView getListView(){
    List<Widget> tiles= new List<Widget>();
    var groupTile=_getGroupConversationButton();
    tiles.add(groupTile);
    for (var myUser in myUsers) {

      var tile = _getListTile(myUser);
      if(tile != null){
        tiles.add(tile);
      }
    }
    return ListView(
      children: tiles.length == 0 ? [ mPureText(DefaultData.ElementNotFound)] : tiles,
    );
  }
  ListTile _getListTile(MyUser myUser) {
    String name=myUser.name.toLowerCase();
    String query2=query== null ? "":query.toLowerCase();
    
    if(name.contains(query2)){
      return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(myUser.imgSrc != null ? myUser.imgSrc : DefaultData.UserDefaultImagePath),
      ),
      title: Text(myUser.name),
      subtitle: Text(myUser.status),
        onTap: () async {
          var model = getIt<ConversationModel>();
          var conversation =await model.startSingleConversation(currentUserId, myUser.userId);
          if(conversation != null){
            Navigator.of(ctx).popUntil((route) => route.isFirst);
            _navigatorService.navigateTo(MessagePage(conversation: conversation));
          }
        }, 
      );
    }
    return null;
  }

  Ink _getGroupConversationButton(){
    return 
    Ink(
      color: themeAccentColor,
      child:ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.group,color: Colors.black,),
        ),
        title: Text("Group Conversation",style: TextStyle(color: Colors.white),),
          onTap: () async {
            _navigatorService.navigateTo(GroupMembersSellect(myUsers));
        }, 
      ));
  }

}
class ContactSearchDelegate extends SearchDelegate {
  final ContactsList contactsList;
  ContactSearchDelegate(this.contactsList);
  @override
  ThemeData appBarTheme(BuildContext context) {
    var theme = Theme.of(context);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [];

  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        this.close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    contactsList.query=query;
    return contactsList.getListView();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    contactsList.query=query;
    return contactsList.getListView();
  }
}

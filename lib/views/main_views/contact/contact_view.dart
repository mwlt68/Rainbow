import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/components/widgets/widgets.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/core_view_models/core_contact_view_model.dart';
import 'package:rainbow/core/core_view_models/core_conversation_view_model.dart';
import 'package:rainbow/views/derived_from_main_views/group_member_select/group_ms_option.dart';
import 'package:rainbow/views/derived_from_main_views/message/message_view.dart';
import 'package:rainbow/views/derived_from_main_views/group_member_select/group_ms_view.dart';
import 'package:rainbow/core/base/base_state.dart';
part 'contact_string_values.dart';

class ContactPage extends StatelessWidget {
  final _ContactStringValues _values= new _ContactStringValues();
  ContactPage();
  @override
  Widget build(BuildContext context) {
    var contactListWidget=ContactsList(MyUserModel.CurrentUserId,query: _values.empty);
    return Scaffold(
      appBar: appBar(context, contactListWidget),
      body: Center(child: contactListWidget),
    );
  }

  AppBar appBar(BuildContext context, ContactsList contactListWidget) {
    return AppBar(
      title: Text(_values.Contact),
      actions: [
        searchDelegeteIconButton(context, contactListWidget),
        IconButton(icon: Icon(Icons.more_vert), onPressed: null),
      ],
    );
  }

  IconButton searchDelegeteIconButton(BuildContext context, ContactsList contactListWidget) {
    return IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: ContactSearchDelegate(contactListWidget));
          });
  }

  
}

class ContactsList extends StatelessWidget  with BaseState{
  final _ContactStringValues _values= new _ContactStringValues();
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  BuildContext ctx;
  String currentUserId;
  ContactViewModel _contactViewModel;
  String query;
  List<MyUserModel> myUserModels;
  ContactsList(this.currentUserId,{ Key key,this.query,}) : super(key: key);
  MyDialogs _myDialogs;


  Widget build(BuildContext context) {
    ctx=context;
    _myDialogs= new MyDialogs(context);
    var model = getIt<ContactViewModel>();
    return FutureBuilder(
        future: model.getContatcs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _contactViewModel=model;
            return getUsersWidget();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return  CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text(_values.UserGetError);
    }
  });
  }


  Widget getUsersWidget() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => _contactViewModel,
      child: StreamBuilder<List<MyUserModel>>(
          stream: _contactViewModel.getMyUserModels(),
          builder: (context, AsyncSnapshot<List<MyUserModel>> snapshot) {
            if (snapshot.hasError) {
              _myDialogs.showErrorDialog(
                  _values.DataLoadError, message: snapshot.error);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            var ownUser=snapshot.data.where((element) => element.id== this.currentUserId);
            if(ownUser.isNotEmpty){
              snapshot.data.remove(ownUser.first);
            }
            myUserModels=snapshot.data;
            myUserModels.sort((a,b)=> a.name.toString().compareTo(b.name.toString()));
            return Center(child: getListView());
          }),
    );
  }

  ListView getListView(){
    List<Widget> tiles= new List<Widget>();
    var groupTile=_getGroupConversationButton();
    tiles.add(groupTile);
    for (var myUserModel in myUserModels) {
      var tile = _getListTile(myUserModel);
      if(tile != null){
        tiles.add(tile);
      }
    }
    return ListView(
      children: tiles.length == 0 ? [ MyPureText(_values.ElementNotFound)] : tiles,
    );
  }


  ListTile _getListTile(MyUserModel myUserModel) {
    String name=myUserModel.name.toLowerCase();
    String query2=query== null ? _values.empty:query.toLowerCase();
    
    if(name.contains(query2)){
      return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(myUserModel.imgSrcWithDefault),
      ),
      title: Text(myUserModel.name),
      subtitle: Text(myUserModel.status),
        onTap: () async {
          var model = getIt<ConversationViewModel>();
          var conversation =await model.startSingleConversation(currentUserId, myUserModel.id);
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
    return Ink(
      color: colorConsts.accentColor,
      child:ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.group,color: Colors.black,),
        ),
        title: Text(_values.GroupConversation,style: TextStyle(color: Colors.white),),
          onTap: () async {
            _navigatorService.navigateTo(GroupMembersSelect(GroupMemberSelectOption.create,contactModel: _contactViewModel));
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

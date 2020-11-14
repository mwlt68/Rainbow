import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/error_dialogs.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/models/user.dart';
import 'package:rainbow/viewmodels/contact_model.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact"),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: ContactSearchDelegate());
              }),
          IconButton(icon: Icon(Icons.more_vert), onPressed: null),
        ],
      ),
      body: ContactsList(),
    );
  }
}
class ContactsList extends StatelessWidget {
  final String query;
  ContactsList({
    Key key,
    this.query,
  }) : super(key: key);
  List<MyUser> users = new List<MyUser>();

  Widget build(BuildContext context) {
    var model = getIt<ContactModel>();
    return FutureBuilder(
        future: model.getContatcs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _getNotifier(model, query: query);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Contact users get error !"),
            );
          }
        });
  }
  ChangeNotifierProvider _getNotifier(ContactModel model, {String query}) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<MyUser>(
          stream: model.getMyUsersFromContact(),
          builder: (context, AsyncSnapshot<MyUser> snapshot) {
            if (snapshot.hasData) {
              users.add(snapshot.data);
              return _getListView(users, query);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Contact users get error !"),
              );
            }
          }),
    );
  }

}

ListView _getListView(List<MyUser> contactUsers, String query) {
  if (query != null) {
    List<MyUser> tempUsers= new List<MyUser>();
    for (var user in contactUsers) {
      if (!user.name.contains(query)) {
        tempUsers.add(user);
      }
    }
    contactUsers=tempUsers;
  }
  List<ListTile> tiles = new List<ListTile>();
  for (var user in contactUsers) {
    ListTile tile = new ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.imgSrc),
      ),
      title: Text(user.name),
      subtitle: Text(user.status),
      //              onTap: () => model.startConversation(user, profile),
    );
    tiles.add(tile);
  }
  return ListView(
    children: tiles,
  );
}

class ContactSearchDelegate extends SearchDelegate {
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
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ContactsList(query:query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text(DefaultData.buildSuggestionText);
  }
}

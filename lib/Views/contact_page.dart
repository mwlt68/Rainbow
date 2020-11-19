import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/error_dialogs.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/viewmodels/contact_model.dart';
import 'package:rainbow/widgets/widgets.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var contactListWidget=ContactsList(query: "",);
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
  String query;
  List<MyUser> myUsers;
  ContactsList({
    Key key,
    this.query,
  }) : super(key: key);

  Widget build(BuildContext context) {
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
              ShowErrorDialog(context,
                  title: "Data could not load !", message: snapshot.error);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            myUsers=snapshot.data;
            myUsers.sort((a,b)=> a.name.toString().compareTo(b.name.toString()));
            return Center(child: getListView());
          }),
    );
  }
  ListView getListView(){
    List<ListTile> tiles= new List<ListTile>();
    for (var myUser in myUsers) {
      var tile = _getListTile(myUser);
      if(tile != null){
        tiles.add(tile);
      }
    }
    return ListView(
      children: tiles.length == 0 ? [ MyWidgets.getPureText(DefaultData.ElementNotFound)] : tiles,
    );
  }
  ListTile _getListTile(MyUser myUser) {
    String name=myUser.name.toLowerCase();
    String query2=query== null ? "":query.toLowerCase(); 
    if(name.contains(query2)){
      return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(myUser.imgSrc),
      ),
      title: Text(myUser.name),
      subtitle: Text(myUser.status),
        onTap: () {},
      );
    }
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

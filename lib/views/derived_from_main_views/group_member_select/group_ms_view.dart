import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/components/widgets/widgets.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_selection_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/core_view_models/core_contact_view_model.dart';
import 'package:rainbow/views/derived_from_main_views/group_create/group_create_view.dart';
import 'package:rainbow/views/derived_from_main_views/group_member_select/group_ms_option.dart';
import 'package:rainbow/views/derived_from_main_views/group_member_select/group_ms_view_model.dart';
import 'package:rainbow/core/base/base_state.dart';
part 'group_ms_string_values.dart';

class GroupMembersSelect extends StatefulWidget {
  List<String> constSellectedUsers;
  ContactViewModel contactModel;
  GroupMemberSelectOption _groupMembersSellectFor;
  GroupMembersSelect(this._groupMembersSellectFor,
      {this.contactModel, this.constSellectedUsers});

  @override
  _GroupMembersSelectState createState() => _GroupMembersSelectState();
}

class _GroupMembersSelectState extends State<GroupMembersSelect>
    with BaseState {
  TextEditingController searchTEC = new TextEditingController();
  GroupMemberSelectViewModel _viewModel;
  _GroupMemberSelectStringValues _values;
  @override
  void initState() {
    super.initState();
    _viewModel = new GroupMemberSelectViewModel(widget.constSellectedUsers);
    _values = new _GroupMemberSelectStringValues();
  }

  @override
  Widget build(BuildContext context) {
    return getContacts();
  }

  Widget getContacts() {
    if (widget.contactModel == null) {
      widget.contactModel = getIt<ContactViewModel>();
      return FutureBuilder(
          future: widget.contactModel.getContatcs(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return getUsersStream();
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(_values.userGetError);
            }
          });
    } else
      return getUsersStream();
  }

  Widget getUsersStream() {
    return ChangeNotifierProvider(
        create: (BuildContext context) => widget.contactModel,
        child: StreamBuilder<List<MyUserModel>>(
            stream: widget.contactModel.getMyUserModels(),
            builder: (context, AsyncSnapshot<List<MyUserModel>> snapshot) {
              if (snapshot.hasError) {
                return MyBasicErrorWidget(
                    title: _values.dataNotLoad, message: snapshot.error);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                if (_viewModel.cachedUserSellections == null) {
                  return CircularProgressIndicator();
                } else {
                  return getScaffold();
                }
              }
              List<MyUserModel> MyUserModels =
                  _viewModel.getMyUserModelsFromSnapshot(snapshot.data);
              _viewModel.cachedUserSellections =
                  _viewModel.updateCachedUsers(MyUserModels);
              return getScaffold();
            }));
  }

  Widget getScaffold() {
    return Scaffold(
      appBar: scaffoldPrefferedSize(),
      body: scaffoldBody(),
    );
  }

  Container scaffoldBody() {
    return Container(
      child: Column(
        children: [
          Visibility(
              visible: _viewModel.cachedUserSellections.selectedModelCount > 0,
              child: selectedUsersWidget()),
          Visibility(
              visible: _viewModel.cachedUserSellections.selectedModelCount > 0,
              child: Divider(
                thickness: 3.0,
                color: Colors.black,
              )),
          getGroupListView(),
        ],
      ),
    );
  }

  PreferredSize scaffoldPrefferedSize() {
    return PreferredSize(
      preferredSize: Size.fromHeight(120.0),
      child: Column(
        children: [appBar(), searchFieldContainer()],
      ),
    );
  }

  Container searchFieldContainer() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(horizontal: 30),
      height: 40,
      child: TextField(
        controller: searchTEC,
        onChanged: (val) {
          setState(() {});
        },
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          labelText: _values.search,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      centerTitle: true,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(_values.addMember),
          Text(
            _viewModel.selectedCountText(),
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        appBarContinueAction(),
      ],
    );
  }

  Visibility appBarContinueAction() {
    return Visibility(
        visible: _viewModel.cachedUserSellections.selectedModelCount > 0,
        child: IconButton(
          icon: Icon(
            Icons.navigate_next_sharp,
            size: 40,
          ),
          onPressed: _continueButton,
        ));
  }

  Widget getGroupListView() {
    String searchVal = searchTEC.text.toLowerCase();
    var users = _viewModel.searchUserNameContain(searchVal);

    if (users == null || users.length == 0) {
      return Text(_values.matchingUserNotFound);
    } else {
      return Expanded(
        child: groupedListView(users),
      );
    }
  }

  GroupedListView<SelectionModel<MyUserModel>, String> groupedListView(
      List<SelectionModel<MyUserModel>> users) {
    return GroupedListView<SelectionModel<MyUserModel>, String>(
      elements: users,
      groupBy: _viewModel.MyUserModelSellectGroupBy,
      groupComparator: (value1, value2) => value1.compareTo(value2),
      groupSeparatorBuilder: (String groupByValue) =>
          groupSeparator(groupByValue),
      itemBuilder: (context, userSellect) {
        var listTile = listViewListTile(userSellect);
        if (listTile != null) {
          return listTile;
        }
      }, // optional
      useStickyGroupSeparators: true, // optional
      floatingHeader: true,
    );
  }

  ListTile listViewListTile(SelectionModel<MyUserModel> userSellect) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          userSellect.model.imgSrcWithDefault,
        ),
      ),
      trailing: userSellect.select
          ? Icon(
              Icons.stacked_line_chart,
              color: colorConsts.accentColor,
            )
          : SizedBox(
              width: 5,
            ),
      title: Text(userSellect.model.name),
      subtitle: Text(userSellect.model.status),
      onTap: () async {
        if (_viewModel.isSelectedUserCountValidRange) {
          setState(() {
            userSellect.select = !userSellect.select;
          });
        }
      },
    );
  }

  Widget groupSeparator(String val) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.lightBlue[200],
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Text(val),
    );
  }

  Widget selectedUsersWidget() {
    var userVisualizeWidgets = new List<Widget>.empty(growable: true);
    for (var userSelect in _viewModel.cachedUserSellections) {
      if (userSelect.select) {
        var userVisualizeWidget = MyUserModelVisualize(userSelect.model, () {
          setState(() {
            userSelect.select = !userSelect.select;
          });
        });
        userVisualizeWidgets.add(userVisualizeWidget);
      }
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: userVisualizeWidgets,
        ),
      ),
    );
  }

  _continueButton() async {
    switch (widget._groupMembersSellectFor) {
      case GroupMemberSelectOption.create:
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (content) =>
                    GroupCreate(_viewModel.cachedUserSellections)));
        setState(() {});
        break;
      case GroupMemberSelectOption.add:
        Navigator.pop(
            context, _viewModel.cachedUserSellections.selectedModelsId);
        break;
      default:
    }
  }
}

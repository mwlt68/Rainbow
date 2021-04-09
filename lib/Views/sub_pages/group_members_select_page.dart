import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/views/sub_pages/group_create_page.dart';

class MyUserSellect {
  MyUser user;
  bool select;
  MyUserSellect(this.user, {this.select = false});
}

enum GroupMemberSellectFor {
  create,
  add,
}

class GroupMembersSellect extends StatefulWidget {
  List<MyUserSellect> usersSelect;
  GroupMemberSellectFor _groupMembersSellectFor;
  GroupMembersSellect(List<MyUser> users, this._groupMembersSellectFor) {
    this.usersSelect = new List<MyUserSellect>.empty(growable: true);
    for (var user in users) {
      usersSelect.add(new MyUserSellect(user));
    }
  }

  @override
  _GroupMembersSellectState createState() => _GroupMembersSellectState();
}

class _GroupMembersSellectState extends State<GroupMembersSellect> {
  TextEditingController searchTEC = new TextEditingController();
  Color themeAccentColor;
  int selectedUserCount = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeAccentColor = Theme.of(context).accentColor;
    selectedUserCount =
        widget.usersSelect.where((element) => element.select).toList().length;
    return _getScaffold();
  }
  
  Widget _getScaffold(){
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: Column(
          children: [
            AppBar(
              centerTitle: true,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Add Member"),
                  Text(
                    selectedUserCount.toString() +
                        " / " +
                        GroupConversationDTO.MaxGroupMembers.toString(),
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                Visibility(
                    visible: selectedUserCount > 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.navigate_next_sharp,
                        size: 40,
                      ),
                      onPressed: _continueButton,
                    )),
              ],
            ),
            Container(
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
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                ),
              ),
            )
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            selectedUserCount > 0 ? _getSelectedUsersWidget() : Container(),
            selectedUserCount > 0
                ? Divider(
                    thickness: 3.0,
                    color: Colors.black,
                  )
                : Container(),
            _getGroupListView(),
          ],
        ),
      ),
    );
  }

  Widget _getGroupListView() {
    var users = widget.usersSelect
        .where((element) => element.user.name
            .toLowerCase()
            .contains(searchTEC.text.toLowerCase()))
        .toList();
    if (users == null || users.length == 0) {
      return Text("There is no user account !");
    }

    return Expanded(
      child: GroupedListView<MyUserSellect, String>(
        elements: users,
        groupBy: (element) {
          if (element.user.name != null && element.user.name.length > 0) {
            var firstChar = element.user.name[0];
            return firstChar.toString();
          } else {
            return "#";
          }
        },
        groupComparator: (value1, value2) => value1.compareTo(value2),
        groupSeparatorBuilder: (String groupByValue) =>
            _getGroupSeparator(groupByValue),
        itemBuilder: (context, userSellect) {
          var listTile = _getListTile(userSellect);
          if (listTile != null) {
            return listTile;
          }
        }, // optional
        useStickyGroupSeparators: true, // optional
        floatingHeader: true,
      ),
    );
  }

  ListTile _getListTile(MyUserSellect userSellect) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userSellect.user.imgSrc != null
            ? userSellect.user.imgSrc
            : DefaultData.UserDefaultImagePath),
      ),
      trailing: userSellect.select
          ? Icon(
              Icons.stacked_line_chart,
              color: themeAccentColor,
            )
          : SizedBox(
              width: 5,
            ),
      title: Text(userSellect.user.name),
      subtitle: Text(userSellect.user.status),
      onTap: () async {
        if (selectedUserCount < GroupConversationDTO.MaxGroupMembers) {
          setState(() {
            userSellect.select = !userSellect.select;
          });
        }
      },
    );
  }

  Widget _getGroupSeparator(String val) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.lightBlue[200],
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Text(val),
    );
  }

  Widget _getSelectedUsersWidget() {
    var userVisualizeWidgets = new List<Widget>.empty(growable: true);
    for (var userSelect in widget.usersSelect) {
      if (userSelect.select) {
        var userVisualizeWidget = UserVisualize(userSelect.user, () {
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
      case GroupMemberSellectFor.create:
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (content) => GroupCreate(widget.usersSelect)));
        setState(() {});
        break;
      case GroupMemberSellectFor.add:
        print("add");
        break;
      default:
    }
  }
}

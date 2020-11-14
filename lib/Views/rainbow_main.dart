import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/Dialogs/error_dialogs.dart';
import 'package:rainbow/Views/calls_page.dart';
import 'package:rainbow/Views/camera_page.dart';
import 'package:rainbow/Views/chat_page.dart';
import 'package:rainbow/Views/contact_page.dart';
import 'package:rainbow/Views/login_page.dart';
import 'package:rainbow/Views/status_page.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/auth_service.dart';
import 'package:rainbow/viewmodels/contact_model.dart';

class RainbowMain extends StatefulWidget {
  final User user;
  RainbowMain({this.user});
  @override
  _RainbowMainState createState() => _RainbowMainState();
}

class _RainbowMainState extends State<RainbowMain>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool isVisibleMessageFAB = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.user.uid.toString());
    _tabController = new TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      isVisibleMessageFAB = _tabController.index != 0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
        future: getIt<ContactModel>().getPermission(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == PermissionStatus.granted) {
              return getMainWidget;
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text('Permissions error'),
                        content: Text('Please enable contacts access '
                            'permission in system settings'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ));
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ShowErrorDialog(context,
                title: "Permission Check Error", message: snapshot.error);
          }
        });
  }

  Widget get getMainWidget => Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: SafeArea(
            child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxScrool) {
                  return [
                    SliverAppBar(
                      floating: true,
                      title: Text("Rainbow"),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {},
                        ),
                        _selectPopup(),
                      ],
                    )
                  ];
                },
                body: Column(
                  children: [
                    TabBar(controller: _tabController, tabs: [
                      Tab(
                        icon: Icon(Icons.camera),
                      ),
                      Tab(
                        text: "Chat",
                      ),
                      Tab(
                        text: "Status",
                      ),
                      Tab(
                        text: "Calls",
                      ),
                    ]),
                    Expanded(
                        child: Container(
                      color: Colors.white,
                      child: TabBarView(controller: _tabController, children: [
                        CameraPage(),
                        ChatPage(user: widget.user),
                        StatusPage(),
                        CallsPage(),
                      ]),
                    ))
                  ],
                ))),
      ),
      floatingActionButton: Visibility(
        visible: isVisibleMessageFAB,
        child: FloatingActionButton(
          child: Icon(Icons.message),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactPage()),
            );
          },
        ),
      ));
  Widget _selectPopup() => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("Sign Out"),
          ),
        ],
        onSelected: (value) {
          _popupSelect(value);
        },
        icon: Icon(Icons.more_vert),
      );

  void _popupSelect(int value) {
    switch (value) {
      case 1:
        _singOut();
        break;
      default:
    }
  }

  void _singOut() {
    MyAuth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}

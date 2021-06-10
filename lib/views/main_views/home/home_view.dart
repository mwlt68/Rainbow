import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/views/main_views/settings/settings_view.dart';
import 'package:rainbow/views/main_views/status/status_view.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/firebase_services/auth_service.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/core_view_models/core_contact_view_model.dart';
import 'package:rainbow/views/main_views/contact/contact_view.dart';
import 'package:rainbow/views/main_views/camera/camera_view.dart';
import 'package:rainbow/views/main_views/conversation/conversation_view.dart';
import 'package:rainbow/views/main_views/login/login_view.dart';
import 'package:rainbow/core/base/base_state.dart';
part 'home_string_values.dart';

class Home extends StatefulWidget {
  Home();
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, BaseState {
  final _HomeStringValues _values = _HomeStringValues();
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  ContactViewModel _contactViewModel;
  TabController _tabController;
  bool isVisibleMessageFAB = true;
  MyDialogs _myDialogs;
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool connectivityActive = false;

  @override
  void initState() {
    super.initState();

    print(MyUserModel.CurrentUserId);

    _myDialogs = new MyDialogs(context);
    _tabController = new TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      setState(() {
        isVisibleMessageFAB = !(_tabController.index == 0 || _tabController.index == 2);
      });
    });

    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        connectivityActive = result != ConnectivityResult.none;
      });
    });
  }

  @override
  dispose() {
    super.dispose();
    connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
        future: getIt<ContactViewModel>().getPermission(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == PermissionStatus.granted) {
              return getContact();
            } else {
              permissionShowDialog(context);
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _myDialogs.showErrorDialog(_values.permissionErrorCheck,
                message: snapshot.error);
          }
        });
  }

  Future permissionShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(_values.permissionError),
              content: Text(_values.permissionErrorContent),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(stringConsts.okey),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }

  Widget getContact(){
    if(_contactViewModel != null){
      return buildScaffold();
    }
    var model = getIt<ContactViewModel>();
      return FutureBuilder(
        future: model.getContatcs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _contactViewModel = model;
            return buildScaffold();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text(_values.contactsGetError);
          }
        });
  }
  Widget buildScaffold() {
    return Scaffold(
        body: scaffoldBody(), floatingActionButton: floatingActionButton());
  }

  Visibility floatingActionButton() {
    return Visibility(
      visible: isVisibleMessageFAB && connectivityActive,
      child: FloatingActionButton(
        child: Icon(
          Icons.message,
          color: Colors.white,
        ),
        onPressed: () {
          _navigatorService.navigateTo(ContactPage(_contactViewModel));
        },
      ),
    );
  }

  Container scaffoldBody() {
    return Container(
      color: colorConsts.primaryColor,
      child: SafeArea(
          child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrool) {
                return [nestedScrollViewSliverAppBar()];
              },
              body: nestedScrollViewBody())),
    );
  }

  Column nestedScrollViewBody() {
    return Column(
      children: [bodyTabBar(), bodyTabBarViewExpanded()],
    );
  }

  Expanded bodyTabBarViewExpanded() {
    return Expanded(
        child: Container(
      color: Colors.white,
      child: TabBarView(controller: _tabController, children: [
        CameraPage(),
        ConversationPage(),
        StatusPage(_contactViewModel),
        SettingsPage(),
      ]),
    ));
  }

  TabBar bodyTabBar() {
    return TabBar(controller: _tabController, tabs: [
      Tab(
        icon: Icon(Icons.camera),
      ),
      Tab(
        text: stringConsts.chat,
      ),
      Tab(
        text: stringConsts.status,
      ),
      Tab(
        text: stringConsts.settings,
      ),
    ]);
  }

  SliverAppBar nestedScrollViewSliverAppBar() {
    return SliverAppBar(
      floating: true,
      title: Text(stringConsts.appName),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
        _selectPopup(),
      ],
    );
  }

  Widget _selectPopup() => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text(_values.signOut),
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
    _navigatorService.navigateTo(LoginPage(), isRemoveUntil: true);
  }
}

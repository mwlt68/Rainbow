import 'package:flutter/material.dart';
import 'package:rainbow/Views/calls_page.dart';
import 'package:rainbow/Views/camera_page.dart';
import 'package:rainbow/Views/chat_page.dart';
import 'package:rainbow/Views/status_page.dart';

class RainbowMain extends StatefulWidget {
  @override
  _RainbowMainState createState() => _RainbowMainState();
}

class _RainbowMainState extends State<RainbowMain>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool isVisibleMessageFAB=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      isVisibleMessageFAB=_tabController.index !=0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Rainbow"),
        bottom: TabBar(controller: _tabController, tabs: [
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
      ),
      body: TabBarView(controller: _tabController, children: [
        CameraPage(),
        ChatPage(),
        StatusPage(),
        CallsPage(),
      ]),
      floatingActionButton:Visibility(
        visible: isVisibleMessageFAB,
        child: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {},
      ),) 
    );
  }
}

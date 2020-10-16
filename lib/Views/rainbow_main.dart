import 'package:firebase_auth/firebase_auth.dart';
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
  bool isVisibleMessageFAB = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      isVisibleMessageFAB = _tabController.index != 0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          IconButton(icon:Icon(Icons.search),onPressed: (){},),
                          IconButton(icon:Icon(Icons.more_vert),onPressed: (){},),
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
                        child:
                            TabBarView(controller: _tabController, children: [
                          CameraPage(),
                          ChatPage(),
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
            onPressed: () {},
          ),
        ));
  }
}

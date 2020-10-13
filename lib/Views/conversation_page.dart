import 'package:flutter/material.dart';

class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage("https://picsum.photos/200", scale: 0.1),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "Mevlüt Gür",
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.phone,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.video_call,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: null),
          IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: null),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                  "https://i.pinimg.com/originals/2b/82/95/2b829561dee9e42f1e39983ab023821a.png"),
              fit: BoxFit.fill),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Align(
                        alignment: index % 2 == 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              "Merhaba",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    );
                  }),
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25))),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: InkWell(
                          child: Icon(Icons.tag_faces),
                        ),
                      ),
                      Expanded(
                          child: TextField(
                        decoration: InputDecoration(
                            hintText: "Write a message",
                            border: InputBorder.none),
                      )),
                      InkWell(
                        child: Icon(Icons.attach_file),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: InkWell(
                          child: Icon(Icons.camera_alt),
                        ),
                      )
                    ],
                  ),
                )
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    shape: BoxShape.circle
                  ),
                  child: IconButton(icon: Icon(Icons.mic,color: Colors.white), onPressed: null,))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

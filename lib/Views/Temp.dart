import 'package:flutter/material.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/models/user.dart';
import 'package:rainbow/core/services/user_info_service.dart';
class temp2widget extends StatefulWidget {
  @override
  _temp2widgetState createState() => _temp2widgetState();
}

class _temp2widgetState extends State<temp2widget> {
  UserInfoService infoService= new UserInfoService();
  User user = new User(
    userId:"TA7ctTq6TohulbhQW0gNNOm1l3A3",
    imgSrc: DefaultData.UserDefaultImagePath,
    name: "Mahmut Atak",
    phoneNumber: "+905435435454",
    status: DefaultData.UserDefaultStatus
  );
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: infoService.registerUser(user),
      builder: (context,snapshot){
        if (snapshot.hasError) {
            Text("Error  :"+snapshot.error);
          } 
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          else if(snapshot.data){
            return Text("okey");
          }
      },
    );
  }
}
/*
class tempWidget extends StatefulWidget {
  @override
  _tempWidgetState createState() => _tempWidgetState();
}

class _tempWidgetState extends State<tempWidget> {
  @override
  Widget build(BuildContext context) {
    UserInfoService infoService= new UserInfoService();
    return StreamBuilder<User>(
      stream: infoService.getUserFromUserId("LpfLFzN0RsRU4lg2rot8ypyRw023"),
      builder:(context,snapshot){
         if (snapshot.hasError) {
            Text("Error  :"+snapshot.error);
          } 
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return Text(snapshot.data.name);
      },
    );
  }
}*/
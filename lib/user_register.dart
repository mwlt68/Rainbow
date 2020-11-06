import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rainbow/Views/user_register_page.dart';
import 'Views/rainbow_main.dart';
import 'core/services/user_info_service.dart';

class UserRegister {
  static checkUserRegisterS(context, User user){
    UserInfoService infoService = new UserInfoService();
    var userStream = infoService.getUserFromUserId(user.uid);
    userStream.listen((event) {
      
      if (event == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => UserRegisterPage(
                    user: user,
                  )),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => RainbowMain(
                    user: user,
                  )),
          (Route<dynamic> route) => false,
        );
      }
    }).cancel();
  }
  static checkUserRegisterSB(context, User user) {
    UserInfoService infoService = new UserInfoService();
    return StreamBuilder(
        stream: infoService.getUserFromUserId(user.uid),
        builder: (builder, snapshot) {
          if (snapshot.hasData) {
                          return RainbowMain(
                user: user,
              );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (!snapshot.hasData) {
              return UserRegisterPage(user:user);
          }
        });
  }
}

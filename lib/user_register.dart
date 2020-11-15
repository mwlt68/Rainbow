import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rainbow/Views/user_register_page.dart';
import 'package:rainbow/core/services/navigator_service.dart';
import 'package:rainbow/core/services/user_service.dart';
import 'Views/rainbow_main.dart';
import 'core/locator.dart';

class UserRegister {
  static final   NavigatorService _navigatorService= getIt<NavigatorService>();
  static checkUserRegisterS(context, User user){
    UserService infoService = new UserService();
    var userStream = infoService.getUserFromUserId(user.uid);
    userStream.listen((event) {
      
      if (event == null) {
        _navigatorService.navigateTo(UserRegisterPage(user: user),isRemoveUntil: true);

      } else {
        _navigatorService.navigateTo(RainbowMain(user: user),isRemoveUntil: true);

        
      }
    }).cancel();
  }
  static checkUserRegisterSB(context, User user) {
    UserService infoService = new UserService();
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

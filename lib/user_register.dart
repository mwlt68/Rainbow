import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Dialogs/error_dialogs.dart';
import 'Views/rainbow_main.dart';
import 'core/services/user_info_service.dart';

class UserRegister {
  static checkUserRegisterS(context, User user){
    UserInfoService infoService = new UserInfoService();
    var a = infoService.getUserFromUserId(user.uid);
    return a.listen((event) {
      if (event == null) {
        Text("register");
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
    });
  }
  static checkUserRegisterSB(context, User user) {
    UserInfoService infoService = new UserInfoService();
    return StreamBuilder(
        stream: infoService.getUserFromUserId(user.uid),
        builder: (builder, snapshot) {
          if (snapshot.hasError) {
            ShowErrorDialog(builder,
                title: "User Access Error", message: snapshot.error);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            if (snapshot.data == null) {
              //User register
              return Text("register");
            } else {
              //Continue
              return RainbowMain(
                user: user,
              );
            }
          }
        });
  }
}

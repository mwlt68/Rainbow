import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rainbow/views/main_views/login/login_view.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/firebase_services/auth_service.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/views/main_views/user_register/user_register_view.dart';
import 'package:rainbow/constants/string_constants.dart';
import 'package:rainbow/constants/color_constants.dart';

import 'core/locator.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: StringConstants.instance.appName,
      navigatorKey: getIt<NavigatorService>().navigatorKey,
      theme: ThemeData(
        accentColor: ColorConstants.instance.accentColor,
        primaryColor: ColorConstants.instance.primaryColor,
      ),
      home: checkLoginWidget(),
    );
  }

  checkLoginWidget() {
    return FutureBuilder(
      future: MyAuth.getCurrentUser(),
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            MyUserModel.CurrentUserId=snapshot.data.uid;
            return UserRegisterPage(
              user: snapshot.data,
            );
          } else {
            return LoginPage();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

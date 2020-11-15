import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rainbow/Views/login_page.dart';
import 'package:rainbow/core/services/auth_service.dart';
import 'package:rainbow/core/services/navigator_service.dart';
import 'package:rainbow/user_register.dart';

import 'Views/user_register_page.dart';
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
      title: 'Rainbow',
      navigatorKey: getIt<NavigatorService>().navigatorKey,
      theme: ThemeData(
        primaryColor: Color(0xff075e54),
        accentColor: Color(0xff25d336),
        
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

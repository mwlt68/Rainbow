import 'package:flutter/material.dart';

class NavigatorService {
  final GlobalKey<NavigatorState> _navigatorKey =
      new GlobalKey<NavigatorState>();

  get navigatorKey => _navigatorKey;
  
  navigateTo(Widget route, {bool isRemoveUntil = false}) {
    if (isRemoveUntil) {
      _navigatorKey.currentState.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => route),
        (Route<dynamic> route) => false,
      );
    } else {
      _navigatorKey.currentState
          .push(MaterialPageRoute(builder: (content) => route));
    }
  }
}

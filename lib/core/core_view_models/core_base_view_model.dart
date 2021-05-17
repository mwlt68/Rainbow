import 'package:flutter/cupertino.dart';

abstract class BaseViewModel with ChangeNotifier {
  bool _busy = false;
  bool get busy => _busy;
  set busy(bool state) {
    _busy = state;
    notifyListeners();
  }
}

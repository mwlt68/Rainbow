
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:rainbow/core/services/user_info_service.dart';
import 'package:rainbow/models/user.dart';

class ChatModel with ChangeNotifier{
  final UserInfoService _db=GetIt.instance<UserInfoService>();
  Stream<MyUser> conversations (String userId){
    return _db.getUserFromUserId(userId);
  }/*
  Stream<User> conversations (String userId){
    return _db.getUserFromUserId(userId);
  }*/
}
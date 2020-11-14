import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/storage_service.dart';
import 'package:rainbow/core/services/user_service.dart';
import 'package:rainbow/models/user.dart';
import 'package:rainbow/viewmodels/base_model.dart';

class UserModel extends BaseModel {
  final UserService _userService = getIt<UserService>();
  final StorageService _storageService = getIt<StorageService>();
  
  Stream<MyUser> getMyUserFromUserId(String userId) {
    return _userService.getUserFromUserId(userId);
  }
  Future<DocumentReference> registerUser(
      User user, File imgFile, String visiableName, String status) async {
    MyUser myUser = new MyUser(
      userId: user.uid,
      phoneNumber: user.phoneNumber,
      name: visiableName,
      status: status,
    );
    myUser.imgSrc=await _uploadUserImg(imgFile);
    var docRef=_userService.registerUser(myUser);
    return docRef;
  }

  Future<String> _uploadUserImg(File imgFile) async {
    if (imgFile == null) {
      return DefaultData.UserDefaultImagePath;
    } else {
      var url =
          await _storageService.uploadMedia(DefaultData.ProfileImage, imgFile);
      return url;
    }
  }
}

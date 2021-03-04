import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/storage_service.dart';
import 'package:rainbow/core/services/user_service.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/viewmodels/base_model.dart';

class UserModel extends BaseModel {
  final UserService _userService = getIt<UserService>();
  final StorageService _storageService = getIt<StorageService>();
  
  Stream<MyUser> getMyUserFromUserId(String userId) {
    return _userService.getUserFromUserId(userId);
  }
  Stream<MyUser> getMyUserFromPhoneNumber(String number) {
    return _userService.getUserFromUserPhoneNumber(number);
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

  Future<String> updateUserTest(MyUser user,File image,String name,String status,bool removeImage) async {
    String oldImageUrl;
    if(removeImage ){
      oldImageUrl=user.imgSrc;
      user.imgSrc=null;
    }
    else if(image != null){
      var imageSrc= await _uploadUserImg(image);
      if(user.imgSrc != null){
        oldImageUrl=user.imgSrc;
      }
      user.imgSrc=imageSrc;
    }
    
    if(name == null || name.isEmpty ||status == null||status.isEmpty ||status.length > MyUser.StatusTextLength){
      return "Girilen isim yada hakkında hatalı !";
    }
    else{
      user.name=name;
      user.status=status;
      await _userService.updateUserTest(user);
      if(oldImageUrl != null && !oldImageUrl.isEmpty){
        await _storageService.deleteMedia(oldImageUrl);
        return null;
      }
    }
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

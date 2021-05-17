import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/firebase_services/storage_service.dart';
import 'package:rainbow/core/services/firebase_services/user_service.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/core_view_models/core_base_view_model.dart';
import 'package:rainbow/core/base/base_state.dart';


class UserViewModel extends BaseViewModel with BaseState{
  final UserService _userService = getIt<UserService>();
  final StorageService _storageService = getIt<StorageService>();
  
  Stream<MyUserModel> getMyUserModelFromUserId(String userId) {
    return _userService.getUserFromUserId(userId);
  }

  Stream<MyUserModel> getMyUserModelFromPhoneNumber(String number) {
    return _userService.getUserFromUserPhoneNumber(number);
  }

  Future<DocumentReference> registerUser(
      User user, File imgFile, String visiableName, String status) async {
    MyUserModel myUserModel = new MyUserModel(
      id: user.uid,
      phoneNumber: user.phoneNumber,
      name: visiableName,
      status: status,
    );
    myUserModel.imgSrc=await _uploadUserImg(imgFile);
    var docRef=_userService.registerUser(myUserModel);
    return docRef;
  }

  Future<List<MyUserModel>> getMyUserModelsFromIds(List<String> userIds) {
    return _userService.getUsersFromIdsFuture(userIds);
  }

  Future<String> updateUser(MyUserModel user,File image,String name,String status,bool removeImage) async {
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
    
    if(name == null || name.isEmpty ||status == null||status.isEmpty ||status.length > MyUserModel.StatusTextLength){
      return "Name or status have an error !";
    }
    else{
      user.name=name;
      user.status=status;
      await _userService.updateUser(user);
      if(oldImageUrl != null && !oldImageUrl.isEmpty){
        await _storageService.deleteMedia(oldImageUrl);
        return null;
      }
    }
  }

  Future<String> _uploadUserImg(File imgFile) async {
    if (imgFile == null) {
      return stringConsts.userDefaultImagePath;
    } else {
      var url =
          await _storageService.uploadMedia(stringConsts.profileImage, imgFile);
      return url;
    }
  }


}

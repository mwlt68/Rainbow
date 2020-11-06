import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/storage_service.dart';
import 'package:rainbow/models/user.dart';

class UserInfoService{
  final StorageService _storageService = getIt<StorageService>();
  final FirebaseFirestore _fBaseFireStore=FirebaseFirestore.instance;
  Stream<MyUser> getUserFromUserId(String userId){
    var ref=_fBaseFireStore.collection('Users').where('userId',isEqualTo:userId);
    return ref.snapshots().map((event) => MyUser.fromSnaphot(event.docs[0]));
  }
  Stream<MyUser> getUserFromUserPhoneNumber(String phoneNumber){
    var ref=_fBaseFireStore.collection('Users').where('phoneNumber',isEqualTo:phoneNumber);
    return ref.snapshots().map((event) => MyUser.fromSnaphot(event.docs[0]));
  }
  Future<bool> registerUser(MyUser user) async {
    var ref=_fBaseFireStore.collection('Users');
    return await ref.add(
    {
      'imgSrc':user.imgSrc,
      'name':user.name,
      'phoneNumber':user.phoneNumber,
      'status':user.status,
      'userId':user.userId
    }
    )
    .then((value) => true)
    .catchError((error){
      false;
    });

  }
  Future<String>uploadMedia(File imgFile) async {
    var url = await _storageService.uploadMedia(DefaultData.ProfileImage,imgFile);
    return url;
  }
}
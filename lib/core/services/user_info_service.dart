import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rainbow/models/user.dart';

class UserInfoService{
  final FirebaseFirestore _fBaseFireStore=FirebaseFirestore.instance;
  Stream<User> getUserFromUserId(String userId){
    var ref=_fBaseFireStore.collection('Users').where('userId',isEqualTo:userId);
    return ref.snapshots().map((event) => User.fromSnaphot(event.docs[0]));
  }
  Stream<User> getUserFromUserPhoneNumber(String phoneNumber){
    var ref=_fBaseFireStore.collection('Users').where('phoneNumber',isEqualTo:phoneNumber);
    return ref.snapshots().map((event) => User.fromSnaphot(event.docs[0]));
  }
  Future<bool> registerUser(User user) async {
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
}
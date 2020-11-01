import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  String snapshotId;
  String userId;
  String name;
  String phoneNumber;
  String imgSrc;
  String status;
  User({this.userId,this.snapshotId,this.name,this.imgSrc,this.phoneNumber,this.status});
  factory User.fromSnaphot(DocumentSnapshot snapshot){
    return User(
      snapshotId:snapshot.id,
      userId:snapshot.data()['userId'],
      name:snapshot.data()['name'],
      phoneNumber:snapshot.data()['phoneNumber'],
      imgSrc:snapshot.data()['imgSrc'],
      status:snapshot.data()['status'],
      );
  }
}
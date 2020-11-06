import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser{
  String snapshotId;
  String userId;
  String name;
  String phoneNumber;
  String imgSrc;
  String status;
  MyUser({this.userId,this.snapshotId,this.name,this.imgSrc,this.phoneNumber,this.status});
  factory MyUser.fromSnaphot(DocumentSnapshot snapshot){
    return MyUser(
      snapshotId:snapshot.id,
      userId:snapshot.data()['userId'],
      name:snapshot.data()['name'],
      phoneNumber:snapshot.data()['phoneNumber'],
      imgSrc:snapshot.data()['imgSrc'],
      status:snapshot.data()['status'],
      );
  }
}
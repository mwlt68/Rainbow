import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/core_models/core_base_model.dart';
import 'package:rainbow/constants/string_constants.dart';

class MyUserModel extends CoreBaseModel {
  
  static String CurrentUserId;
  static final int StatusTextLength=150;
  
  String snapshotId;
  String name;
  String phoneNumber;
  String imgSrc;
  String status;
  
  String get imgSrcWithDefault => imgSrc ?? StringConstants.instance.userDefaultImagePath;

  MyUserModel({String id,this.snapshotId,this.name,this.imgSrc,this.phoneNumber,this.status}):super(id);
  factory MyUserModel.fromSnaphot(DocumentSnapshot snapshot){
    return MyUserModel(
      snapshotId:snapshot.id,
      id:snapshot.data()['userId'],
      name:snapshot.data()['name'],
      phoneNumber:snapshot.data()['phoneNumber'],
      imgSrc:snapshot.data()['imgSrc'],
      status:snapshot.data()['status'],
      );
  }
   Map<String, dynamic> toJson() =>{
     'imgSrc':imgSrc,
      'name':name,
      'phoneNumber':phoneNumber,
      'status':status,
      'userId':id,
   };

}
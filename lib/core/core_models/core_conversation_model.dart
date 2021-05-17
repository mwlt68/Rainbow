import 'package:cloud_firestore/cloud_firestore.dart';

class SingleConversationModel{
  String id;
  List<String> members;
  SingleConversationModel({this.id,this.members});
  factory SingleConversationModel.fromSnapshot(DocumentSnapshot snapshot){
    return SingleConversationModel(
      id:snapshot.id,
      members: List.from(snapshot.data()['members']),
      );
  }
  Map<String, dynamic> toJson() =>
  {
    'members': members,
  };
}

class GroupConversationModel{
  String id;
  String name;
  String profileImage;
  Timestamp createDate;
  List<String> members;
  GroupConversationModel({this.id,this.name,this.profileImage,this.members,this.createDate});
  factory GroupConversationModel.fromSnapshot(DocumentSnapshot snapshot){
    return GroupConversationModel(
      id:snapshot.id,
      name:snapshot.data()['name'],
      profileImage: snapshot.data()['profileImage'],
      createDate: snapshot.data()['createDate'],
      members: List.from(snapshot.data()['members']),
    );
  }
  Map<String, dynamic> toJson() =>
  {
    'name': name,
    'profileImage': profileImage,
    'members': members,
    'createDate': createDate,
  };
}
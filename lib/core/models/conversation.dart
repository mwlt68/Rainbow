import 'package:cloud_firestore/cloud_firestore.dart';

class SingleConversation{
  String id;
  List<String> members;
  SingleConversation({this.id,this.members});
  factory SingleConversation.fromSnapshot(DocumentSnapshot snapshot){
    return SingleConversation(
      id:snapshot.id,
      members: List.from(snapshot.data()['members']),
      );
  }
  Map<String, dynamic> toJson() =>
  {
    'members': members,
  };
}

class GroupConversation{
  String id;
  String name;
  String profileImage;
  Timestamp createDate;
  List<String> members;
  GroupConversation({this.id,this.name,this.profileImage,this.members,this.createDate});
  factory GroupConversation.fromSnapshot(DocumentSnapshot snapshot){
    return GroupConversation(
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
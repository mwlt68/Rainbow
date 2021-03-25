import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/models/user.dart';
enum ConversationType{
  Single,
  Group,
}
abstract class  ConversationDTO{
  String id;
  ConversationDTO(this.id);
  ConversationType _conversationType;
  ConversationType get conversationType => _conversationType;
  String get imgSrc;
  String get visiableName;
  List<MyUser> get users;
}

class SingleConversationDTO extends ConversationDTO{
  MyUser currentUser;
  MyUser otherUser;
  SingleConversationDTO(String id,List<MyUser> users):super(id){
    this._conversationType=ConversationType.Single;
    if(users != null && users.length == 2){
      if(users.first.userId== MyUser.CurrentUserId){
        currentUser=users.first;
        otherUser=users[1];
      }
      else if(users[1].userId == MyUser.CurrentUserId){
        currentUser=users[1];
        otherUser=users.first;
      }
    }
  }

  @override
  String get imgSrc => otherUser.imgSrc;
  
  @override
  String get visiableName => otherUser.name;
  @override
  List<MyUser> get users => [currentUser,otherUser];
}

class GroupConversationDTO extends ConversationDTO{
  static final int MinGroupMembers=2;
  static final int MaxGroupMembers=25;
  String name;
  String profileImage;
  List<MyUser> myUsers;
  Timestamp createDate;
  GroupConversationDTO(String id,{this.name,this.profileImage,this.myUsers,this.createDate}):super(id){
    this._conversationType=ConversationType.Group;
  }
  
  @override
  String get imgSrc => profileImage;
  @override
  String get visiableName => name;
  @override
  List<MyUser> get users => myUsers;
}
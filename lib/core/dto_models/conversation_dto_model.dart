import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/constants/string_constants.dart';

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
  List<MyUserModel> get users;
}

class SingleConversationDTO extends ConversationDTO{
  MyUserModel currentUser;
  MyUserModel otherUser;
  SingleConversationDTO(String id,List<MyUserModel> users):super(id){
    this._conversationType=ConversationType.Single;
    if(users != null && users.length == 2){
      if(users.first.id== MyUserModel.CurrentUserId){
        currentUser=users.first;
        otherUser=users[1];
      }
      else if(users[1].id == MyUserModel.CurrentUserId){
        currentUser=users[1];
        otherUser=users.first;
      }
    }
  }

  @override
  String get imgSrc => otherUser.imgSrc ?? StringConstants.instance.userDefaultImagePath;
  
  @override
  String get visiableName => otherUser.name ;
  @override
  List<MyUserModel> get users => [currentUser,otherUser];
}

class GroupConversationDTOModel extends ConversationDTO{
  static final int MinGroupMembers=2;
  static final int MaxGroupMembers=25;
  String name;
  String profileImage;
  List<MyUserModel> myUserModels;
  Timestamp createDate;
  GroupConversationDTOModel(String id,{this.name,this.profileImage,this.myUserModels,this.createDate}):super(id){
    this._conversationType=ConversationType.Group;
  }
  
  @override
  String get imgSrc => profileImage ??  StringConstants.instance.userDefaultImagePath ;
  @override
  String get visiableName => name;
  @override
  List<MyUserModel> get users => myUserModels;
}
import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/model_converter/conversation_model_converter.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/services/firebase_services/conversation_service.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/viewmodels/base_model.dart';
import 'package:rainbow/core/services/firebase_services/storage_service.dart';
import 'package:rainbow/core/services/firebase_services/user_service.dart';

class ConversationModel extends BaseModel  {
  ConversationService _conversationService;
  UserService _userService;
  ConversationModelConverter _conversationModelConverter;
  StorageService _storageService;

  ConversationModel() {
    _conversationService = getIt<ConversationService>();
    _userService = getIt<UserService>();
    _storageService = getIt<StorageService>();
    _conversationModelConverter = new ConversationModelConverter(_userService);
  }

  Stream<GroupConversationDTO> getGroupConversation(
      String conversationId) async* {
    var conversationStream =
        _conversationService.getGroupConversation(conversationId);
    await for (var conversation in conversationStream) {
      GroupConversationDTO conversationDTO =
          await _conversationModelConverter.GroupConversationToDTO(
              conversation);
      yield conversationDTO;
    }
  }

  Stream<List<ConversationDTO>> conversations(String userId) async* {
    final Stream<List<SingleConversation>> singleStream =
        _conversationService.getSingleConversations(userId);
    final Stream<List<GroupConversation>> groupStream =
        _conversationService.getGroupConversations(userId);
    var bothStreams =
        StreamZip([singleStream, groupStream]).asBroadcastStream();
    List<ConversationDTO> resultConversations = [];
    await for (var stream in bothStreams) {
      for (var conversations in stream) {
        for (var conversation in conversations) {
          if (conversation is SingleConversation) {
            SingleConversationDTO conversationDTO =
                await _conversationModelConverter.SingleConversationToDTO(
                    conversation);
            if (conversationDTO != null) {
              resultConversations.add(conversationDTO);
            }
          } else if (conversation is GroupConversation) {
            GroupConversationDTO conversationDTO =
                await _conversationModelConverter.GroupConversationToDTO(
                    conversation);
            if (conversationDTO != null) {
              resultConversations.add(conversationDTO);
            }
          }
        }
      }
      yield resultConversations;
    }
  }

  Future<GroupConversationDTO> startGroupConversation(List<String> groupUsersId,
      String groupName, File profileImageFile) async {
    String path = await _uploadMedia(profileImageFile);
    GroupConversation conversation = new GroupConversation(
      members: groupUsersId,
      name: groupName,
      profileImage: path,
      createDate: Timestamp.fromDate(DateTime.now()),
    );
    var conversationAddResult =
        await _conversationService.startGroupConversation(conversation);
    return _conversationModelConverter.GroupConversationToDTO(
        conversationAddResult);
  }

  Future<SingleConversationDTO> startSingleConversation(
      String currentUserId, String targetUserId) async {
    var checkSingleConversation = await _conversationService
        .checkSingleConversation(currentUserId, targetUserId);
    SingleConversationDTO singleConversationDTO;
    if (checkSingleConversation != null) {
      singleConversationDTO =
          await _conversationModelConverter.SingleConversationToDTO(
              checkSingleConversation);
    } else {
      SingleConversation conversation =
          new SingleConversation(members: [currentUserId, targetUserId]);
      var singleConversation =
          await _conversationService.startSingleConversation(conversation);
      singleConversationDTO =
          await _conversationModelConverter.SingleConversationToDTO(
              singleConversation);
    }
    return singleConversationDTO;
  }


Future<String> updateGroupConversationTest(GroupConversationDTO conversation,File image,String name,bool removeImage) async {
    String oldImageUrl;
    if(removeImage ){
      oldImageUrl=conversation.imgSrc;
      conversation.profileImage=null;
    }
    else if(image != null){
      var imageSrc= await _uploadMedia(image);
      if(conversation.profileImage != null){
        oldImageUrl=conversation.profileImage;
      }
      conversation.profileImage=imageSrc;
    }
    
    if(name == null || name.isEmpty ){
      return "Name have an error !";
    }
    else{
      conversation.name=name;
      var conversationDBModel=await  _conversationModelConverter.DTOToGroupConversation(conversation);
      await _conversationService.updateGroupConversationTest(conversationDBModel);
      if(oldImageUrl != null && !oldImageUrl.isEmpty){
        await _storageService.deleteMedia(oldImageUrl);
        return null;
      }
    }
  }

  // If member id is null this method will remove current user
  Future<void> removeGroupConversationUserTest(GroupConversationDTO conversationDTO,bool currentUser,{String memberId}) async {
    if(currentUser && memberId == null){
      return await _conversationService.removeGroupConversationUserTest(conversationDTO.id, MyUser.CurrentUserId);
    }
    else if(memberId != null){
      return await _conversationService.removeGroupConversationUserTest(conversationDTO.id, memberId);
    }
  }

  Future<String> _uploadMedia(File imgFile) async {
    if (imgFile == null) {
      return null;
    }
    var url =
        await _storageService.uploadMedia(DefaultData.MessageMedia, imgFile);
    return url;
  }
}

import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/model_converter/conversation_model_converter.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/firebase_services/conversation_service.dart';
import 'package:rainbow/core/core_models/core_conversation_model.dart';
import 'package:rainbow/core/core_view_models/core_base_view_model.dart';
import 'package:rainbow/core/services/firebase_services/storage_service.dart';
import 'package:rainbow/core/services/firebase_services/user_service.dart';
import 'package:rainbow/core/base/base_state.dart';


class ConversationViewModel extends BaseViewModel with BaseState {
  ConversationService _conversationService;
  UserService _userService;
  ConversationModelConverter _conversationModelConverter;
  StorageService _storageService;

  ConversationViewModel() {
    _conversationService = getIt<ConversationService>();
    _userService = getIt<UserService>();
    _storageService = getIt<StorageService>();
    _conversationModelConverter = new ConversationModelConverter(_userService);
  }
  Stream<GroupConversationDTOModel> getGroupConversation(
      String conversationId) async* {
    var conversationStream =
        _conversationService.getGroupConversation(conversationId);
    await for (var conversation in conversationStream) {
      GroupConversationDTOModel conversationDTO =
          await _conversationModelConverter.GroupConversationToDTO(
              conversation);
      yield conversationDTO;
    }
  }

  Stream<List<ConversationDTO>> conversations(String userId) async* {
    final Stream<List<SingleConversationModel>> singleStream =
        _conversationService.getSingleConversations(userId);
    final Stream<List<GroupConversationModel>> groupStream =
        _conversationService.getGroupConversations(userId);
    var bothStreams =
        StreamZip([singleStream, groupStream]).asBroadcastStream();
    List<ConversationDTO> resultConversations = [];
    await for (var stream in bothStreams) {
      for (var conversations in stream) {
        for (var conversation in conversations) {
          if (conversation is SingleConversationModel) {
            SingleConversationDTO conversationDTO =
                await _conversationModelConverter.SingleConversationToDTO(
                    conversation);
            if (conversationDTO != null) {
              resultConversations.add(conversationDTO);
            }
          } else if (conversation is GroupConversationModel) {
            GroupConversationDTOModel conversationDTO =
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

  Future<GroupConversationDTOModel> startGroupConversation(List<String> groupUsersId,
      String groupName, File profileImageFile) async {
    String path = await _uploadMedia(profileImageFile);
    GroupConversationModel conversation = new GroupConversationModel(
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
      SingleConversationModel conversation =
          new SingleConversationModel(members: [currentUserId, targetUserId]);
      var singleConversation =
          await _conversationService.startSingleConversation(conversation);
      singleConversationDTO =
          await _conversationModelConverter.SingleConversationToDTO(
              singleConversation);
    }
    return singleConversationDTO;
  }


Future<String> updateGroupConversation(GroupConversationDTOModel conversation,File image,String name,bool removeImage) async {
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
      await _conversationService.updateGroupConversation(conversationDBModel);
      if(oldImageUrl != null && !oldImageUrl.isEmpty){
        await _storageService.deleteMedia(oldImageUrl);
        return null;
      }
    }
  }

  Future<void> addMemberToGroupConversation(GroupConversationDTOModel conversationDTO,List<String> userIds) async {
    if(userIds != null && userIds.length>0){
      return await _conversationService.addMemberToGroupConversation(conversationDTO.id, userIds);
    }
  }
  // If member id is null this method will remove current user
  Future<void> removeGroupConversationUser(GroupConversationDTOModel conversationDTO,bool currentUser,{String memberId}) async {
    if(currentUser && memberId == null){
      return await _conversationService.removeGroupConversationUser(conversationDTO.id, MyUserModel.CurrentUserId);
    }
    else if(memberId != null){
      return await _conversationService.removeGroupConversationUser(conversationDTO.id, memberId);
    }
  }

  Future<String> _uploadMedia(File imgFile) async {
    if (imgFile == null) {
      return null;
    }
    var url =
        await _storageService.uploadMedia(stringConsts.messageMedia, imgFile);
    return url;
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_message_model.dart';
import 'package:rainbow/core/services/firebase_services/message_service.dart';
import 'package:rainbow/core/services/firebase_services/storage_service.dart';
import 'package:rainbow/core/base/base_state.dart';


class MessageViewModel with ChangeNotifier , BaseState{
  final MessageService _messageService=getIt<MessageService>();
  final StorageService _storageService=getIt<StorageService>();

  Stream<List<MessageModel>> messages (ConversationDTO conversationDTO){
    return _messageService.getMessages(conversationDTO.id,conversationDTO.conversationType);
  }
  
  Stream<MessageModel> getLastMessage (ConversationDTO conversationDTO){
    return _messageService.getLastMessage(conversationDTO.id,conversationDTO.conversationType);
  }
  
  Future<void> deleteMessages(List<MessageModel> messages,ConversationDTO conversationDTO) async {
    if(messages == null || messages.length ==0){
      return;
    }else{
      for (var message in messages) {
         _messageService.deleteMessage(message, conversationDTO.conversationType,conversationDTO.id);
      }
    }
    
  }
  Future<void> sendMessage(bool isMedia,String senderId,ConversationDTO conversationDTO,{String messageParam,File file}) async {
    MessageModel message = new MessageModel(
      senderId: senderId,
      isMedia: isMedia,
      timeStamp: Timestamp.fromDate(DateTime.now()),
      usersRead: [],
    );
    if(isMedia){
      if(file != null){
        File compressedFile=await _compressFile(file);
        String  mediaUrl=await _uploadMedia(compressedFile);
        message.message=mediaUrl;
        await _messageService.sendMessage(message, conversationDTO.conversationType,conversationDTO.id);
      }
      else{
        return;
      }
    }
    else{
      message.message= messageParam;
      _messageService.sendMessage(message, conversationDTO.conversationType,conversationDTO.id);
    }
  }

  Future<File> _compressFile(File file) async{
    var fileSize=await file.length();
    int quality = _calculateQualityFromFileSize(fileSize);
    File compressedFile = await FlutterNativeImage.compressImage(file.path,
        quality: quality,);
    return compressedFile;
  }

  // If sender id in conversation users function return index else return -1
  int getIndexFromMessageSenderId(GroupConversationDTOModel conversationDTO,String senderId){
    
    for(int i =0 ;i<conversationDTO.users.length;i++){
      if(senderId == conversationDTO.users[i].id){
        return i;
      }
    }
    return -1;
  }

  int _calculateQualityFromFileSize(int sizeByte){
    int sizeKByte=(sizeByte/intConstants.coefficient).round();
    
    if(sizeKByte >= intConstants.highQualitySize){
      return intConstants.minPlusQualitySize;
    }
    else if(sizeKByte <= intConstants.lowQualitySize ){
      return intConstants.maxQualitySize;
    }
    else if(sizeKByte <= intConstants.mediumQualitySize){
      var val=(sizeKByte-intConstants.lowQualitySize)/(intConstants.mediumQualitySize-intConstants.lowQualitySize);
      var res =val *(intConstants.maxQualitySize - intConstants.averageQualitySize )+ intConstants.averageQualitySize;
      return intConstants.maxQualitySize -(res.round()- intConstants.averageQualitySize);
    }
    else if(sizeKByte <= intConstants.highQualitySize){
      var val=(sizeKByte-intConstants.mediumQualitySize)/(intConstants.highQualitySize-intConstants.mediumQualitySize);
      var res =val *(intConstants.averageQualitySize- intConstants.minQualitySize)+intConstants.minQualitySize;
      return intConstants.averageQualitySize-(res.round());
    }

  }
  Future<String> _uploadMedia(File imgFile) async {
    var url =
          await _storageService.uploadMedia(stringConsts.messageMedia, imgFile);
      return url;
  }
}
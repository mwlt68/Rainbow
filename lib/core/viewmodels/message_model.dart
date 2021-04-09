import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/message.dart';
import 'package:rainbow/core/services/firebase_services/message_service.dart';
import 'package:rainbow/core/services/firebase_services/storage_service.dart';

class MessageModel with ChangeNotifier{
  final MessageService _messageService=getIt<MessageService>();
  final StorageService _storageService=getIt<StorageService>();

  Stream<List<Message>> messages (ConversationDTO conversationDTO){
    return _messageService.getMessages(conversationDTO.id,conversationDTO.conversationType);
  }
  
  Stream<Message> getLastMessage (ConversationDTO conversationDTO){
    return _messageService.getLastMessageTest(conversationDTO.id,conversationDTO.conversationType);
  }
  
  Future<void> deleteMessages(List<Message> messages,ConversationDTO conversationDTO) async {
    if(messages == null || messages.length ==0){
      return;
    }else{
      for (var message in messages) {
        await _messageService.deleteMessage(message, conversationDTO.conversationType,conversationDTO.id);
      }
    }
    
  }
  Future<void> sendMessage(bool isMedia,String senderId,ConversationDTO conversationDTO,{String messageParam,File file}) async {
    Message message = new Message(
      senderId: senderId,
      isMedia: isMedia,
      usersRead: [],
      timeStamp:Timestamp.fromDate(DateTime.now()),
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
      await _messageService.sendMessage(message, conversationDTO.conversationType,conversationDTO.id);
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
  int getIndexFromMessageSenderId(GroupConversationDTO conversationDTO,String senderId){
    
    for(int i =0 ;i<conversationDTO.users.length;i++){
      if(senderId == conversationDTO.users[i].userId){
        return i;
      }
    }
    return -1;
  }

  int _calculateQualityFromFileSize(int sizeByte){
    int sizeKByte=(sizeByte/1024).round();
    int low=100,medium=500,high=4000;
    if(sizeKByte >= high){
      return 1;
    }
    else if(sizeKByte <= low ){
      return 100;
    }
    else if(sizeKByte <=500){
      var val=(sizeKByte-low)/(medium-low);
      var res =val *(100-50)+50;
      return 100-(res.round()-50);
    }
    else if(sizeKByte <=high){
      var val=(sizeKByte-medium)/(high-medium);
      var res =val *(50-0)+0;
      return 50-(res.round());
    }

  }
  Future<String> _uploadMedia(File imgFile) async {
    var url =
          await _storageService.uploadMedia(DefaultData.MessageMedia, imgFile);
      return url;
  }
}
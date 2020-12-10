import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/message_service.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/services/storage_service.dart';

class MessageModel with ChangeNotifier{
  final MessageService _messageService=getIt<MessageService>();
  final StorageService _storageService=getIt<StorageService>();

  Stream<List<Message>> messages (String _conversationId){
    return _messageService.getMessages(_conversationId);
  }
  
  Stream<Message> getLastMessage (String _conversationId){
    return _messageService.getLastMessageTest(_conversationId);
  }
  
  Future<void> deleteMessages(List<Message> messages,String conversationId) async {
    if(messages == null || messages.length ==0){
      return;
    }else{
      for (var message in messages) {
        await _messageService.deleteMessage(message, conversationId);
      }
    }
    
  }
  Future<void> sendMessage(bool isMedia,String senderId,String _conversationId,{String message,File file}) async {
    if(isMedia){
      if(file != null){
        String  mediaUrl=await _uploadMedia(file);
        await _messageService.sendMessage(new Message(senderId: senderId,message: mediaUrl,isMedia: isMedia), _conversationId);
      }
      else{
        return ;
      }
    }
    else{
      await _messageService.sendMessage(new Message(senderId: senderId,message: message,isMedia: isMedia), _conversationId);
    }
  }
  Future<String> _uploadMedia(File imgFile) async {
    var url =
          await _storageService.uploadMedia(DefaultData.MessageMedia, imgFile);
      return url;
  }
}
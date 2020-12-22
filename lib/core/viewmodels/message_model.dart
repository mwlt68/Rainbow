import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
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
        File compressedFile=await _compressFile(file);
        String  mediaUrl=await _uploadMedia(compressedFile);
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
  Future<File> _compressFile(File file) async{
    var fileSize=await file.length();
    int quality = _calculateQualityFromFileSize(fileSize);
    File compressedFile = await FlutterNativeImage.compressImage(file.path,
        quality: quality,);
    return compressedFile;
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
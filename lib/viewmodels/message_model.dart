import 'package:flutter/cupertino.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/message_service.dart';
import 'package:rainbow/models/conversation.dart';

class MessageModel with ChangeNotifier{
  final MessageService _messageService=getIt<MessageService>();

  Stream<List<Message>> messages (String _conversationId){
    return _messageService.getMessages(_conversationId);
  }
  
  Future<void> sendMessage(String senderId,String message,String _conversationId) async {
    await _messageService.sendMessage(new Message(senderId: senderId,message: message), _conversationId);
  }
}
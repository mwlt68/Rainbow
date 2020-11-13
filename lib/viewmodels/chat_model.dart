import 'package:flutter/cupertino.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/chat_service.dart';
import 'package:rainbow/models/converstaion.dart';

class ChatModel with ChangeNotifier{
  final ChatService _chatService=getIt<ChatService>();
  Stream<List<Conversation>> conversations (String userId){
    return _chatService.getConversation(userId);
  }
}
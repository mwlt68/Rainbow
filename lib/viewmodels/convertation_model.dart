import 'package:flutter/cupertino.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/conversation_service.dart';
import 'package:rainbow/models/conversation.dart';

class ConversationModel with ChangeNotifier{
  final ConversationService _chatService=getIt<ConversationService>();
  
  Stream<List<Conversation>> conversations (String userId){
    return _chatService.getConversations(userId);
  }
}
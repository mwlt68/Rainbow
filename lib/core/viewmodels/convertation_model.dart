import 'package:flutter/cupertino.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/conversation_service.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/services/user_service.dart';

class ConversationModel with ChangeNotifier{
  final ConversationService _chatService=getIt<ConversationService>();
  final UserService _userService=getIt<UserService>();
  
  Stream<List<Conversation>> conversations (String userId){
    return _chatService.getConversations(userId);
  }
  
}
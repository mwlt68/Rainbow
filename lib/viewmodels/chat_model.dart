import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:rainbow/core/services/chat_service.dart';
import 'package:rainbow/models/converstaion.dart';

class ChatModel with ChangeNotifier{
  final ChatService _db=GetIt.instance<ChatService>();
  Stream<List<Conversation>> conversations (String userId){
    return _db.getConversation(userId);
  }
}
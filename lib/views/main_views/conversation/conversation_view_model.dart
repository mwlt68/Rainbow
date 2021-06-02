import 'package:rainbow/core/core_models/core_message_model.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';

class ConversationViewModel{
  List<ConversationDTO> cacheConversations=[];
  List<MessageModel> cacheLastMessages=[];

  
  MessageModel getCachedMessageModel(String conversationId){
    MessageModel messageModel= cacheLastMessages.firstWhere(
            (element) => element.conversationId == conversationId,
            orElse: () => null);
    return messageModel;
  }
  void addLastMessageToCache(MessageModel lastMessage){
    if(lastMessage == null){
      return ;
    }
    bool chechCacheLastMessage=false;
    cacheLastMessages.forEach((cachelastMessage) {
      if(cachelastMessage.conversationId == lastMessage.conversationId){
        chechCacheLastMessage=true;
      }
     });
    if(!chechCacheLastMessage){
      cacheLastMessages.add(lastMessage);
    }
  }
}
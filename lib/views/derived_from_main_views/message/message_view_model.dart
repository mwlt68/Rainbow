import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/core_models/core_message_model.dart';
import 'package:rainbow/core/core_models/core_selection_model.dart';

class MessageLocalViewModel{
  final ConversationDTO conversation;
  MessageLocalViewModel(this.conversation);
  List<SelectionModel<MessageModel>> cachedMessageSellections =[];





  List<SelectionModel> getCachedMessages(List<MessageModel> newMessages){
    var newCache =cachedMessageSellections.updateCachedModels(newMessages);
    return newCache;
  }

  //This method will check is other user in group conversation.
  bool isOtherUserInGroupConv(MessageModel message){
    if(conversation.conversationType == ConversationType.Single ||
        message.isCurrentUser){
      return false;
    }
    else return true;
  }

}





class MessageSellection {
  MessageSellection(this.message, {this.didSelect = false});
  MessageModel message;
  bool didSelect;
  bool _isDownloading = false;
  String downloadId;
  int downloadProgress = 0;
  bool get isDownload {
    return _isDownloading;
  }

  set isDownload(bool val) {
    if (val == false) {
      downloadProgress = 0;
      downloadId = null;
    }
    _isDownloading = val;
  }
}
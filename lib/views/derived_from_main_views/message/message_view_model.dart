import 'package:image_picker/image_picker.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_message_model.dart';
import 'package:rainbow/core/core_models/core_selection_model.dart';
import 'package:rainbow/core/services/other_services/download_service.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/views/derived_from_main_views/group_detail/group_detail_view.dart';
import 'package:rainbow/views/derived_from_main_views/user_detail/user_detail_view.dart';

class MessageLocalViewModel{
  final ConversationDTO conversation;
  MessageLocalViewModel(this.conversation);
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  DownloadService downloadService= new DownloadService();
  bool isLoad = false;
  double mediaSize = 250;
  List<SelectionModel<MessageModel>> cachedMessageSellections =[];
  bool selectionIsActive = false;
  final picker = ImagePicker();


  void navigatToDetailPage(){
    if (conversation.conversationType ==
                ConversationType.Single) {
              String otherUserID =
                  (conversation as SingleConversationDTO)
                      .otherUser
                      .id;
              _navigatorService.navigateTo(UserDetailPage(
                userId: otherUserID,
              ));
            } else {
              _navigatorService
                  .navigateTo(GroupDetailPage(conversation.id));
            }
  }


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
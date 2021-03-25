import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/services/firebase_services/user_service.dart';

class ConversationModelConverter {

  UserService _userService;
  ConversationModelConverter(this._userService);

  SingleConversation DTOToSingleConversation(
      SingleConversationDTO singleConversationDTO) {
    if (singleConversationDTO != null) {
      return new SingleConversation(
        id: singleConversationDTO.id,
        members: singleConversationDTO.users.map<String>((e) => e.userId),
      );
    }
    return null;
  }

  Future<SingleConversationDTO> SingleConversationToDTO(
      SingleConversation singleConversation) async {
    if (singleConversation != null) {
      List<MyUser> myUsers =
          await _userService.getUsersFromIdsFuture(singleConversation.members);
      if (myUsers != null) {
        return new SingleConversationDTO(
          singleConversation.id,
          myUsers,
        );
      }
    }
    return null;
  }

  GroupConversation DTOToGroupConversation(
      GroupConversationDTO groupConversationDTO) {
    if (groupConversationDTO != null) {
      return new GroupConversation(
        id: groupConversationDTO.id,
        name: groupConversationDTO.name,
        members: groupConversationDTO.myUsers.map<String>((e) => e.userId),
        profileImage: groupConversationDTO.profileImage,
        createDate: groupConversationDTO.createDate,
      );
    }
    return null;
  }

  Future<GroupConversationDTO> GroupConversationToDTO(
      GroupConversation groupConversation) async {
    if (groupConversation != null) {
      List<MyUser> myUsers =
          await _userService.getUsersFromIdsFuture(groupConversation.members);
      if (myUsers != null) {
        return new GroupConversationDTO(
            groupConversation.id,
            name: groupConversation.name,
            profileImage: groupConversation.profileImage,
            myUsers: myUsers,
            createDate: groupConversation.createDate);
      }
    }
    return null;
  }
}

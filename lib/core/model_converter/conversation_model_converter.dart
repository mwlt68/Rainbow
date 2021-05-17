import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/core_models/core_conversation_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/firebase_services/user_service.dart';

class ConversationModelConverter {

  UserService _userService;
  ConversationModelConverter(this._userService);

  SingleConversationModel DTOToSingleConversation(
      SingleConversationDTO singleConversationDTO) {
    if (singleConversationDTO != null) {
      return new SingleConversationModel(
        id: singleConversationDTO.id,
        members: singleConversationDTO.users.map<String>((e) => e.id).toList(),
      );
    }
    return null;
  }

  Future<SingleConversationDTO> SingleConversationToDTO(
      SingleConversationModel singleConversation) async {
    if (singleConversation != null) {
      List<MyUserModel> myUserModels =
          await _userService.getUsersFromIdsFuture(singleConversation.members);
      if (myUserModels != null) {
        return new SingleConversationDTO(
          singleConversation.id,
          myUserModels,
        );
      }
    }
    return null;
  }

  GroupConversationModel DTOToGroupConversation(
      GroupConversationDTOModel groupConversationDTO) {
    if (groupConversationDTO != null) {
      return new GroupConversationModel(
        id: groupConversationDTO.id,
        name: groupConversationDTO.name,
        members: groupConversationDTO.myUserModels.map<String>((e) => e.id).toList(),
        profileImage: groupConversationDTO.profileImage,
        createDate: groupConversationDTO.createDate,
      );
    }
    return null;
  }

  Future<GroupConversationDTOModel> GroupConversationToDTO(
      GroupConversationModel groupConversation) async {
    if (groupConversation != null) {
      List<MyUserModel> myUserModels =
          await _userService.getUsersFromIdsFuture(groupConversation.members);
      if (myUserModels != null) {
        return new GroupConversationDTOModel(
            groupConversation.id,
            name: groupConversation.name,
            profileImage: groupConversation.profileImage,
            myUserModels: myUserModels,
            createDate: groupConversation.createDate);
      }
    }
    return null;
  }
}

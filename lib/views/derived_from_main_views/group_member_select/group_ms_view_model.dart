import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/core_models/core_selection_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/views/derived_from_main_views/group_member_select/group_ms_view.dart';

class GroupMemberSelectViewModel {
  String _seperator = " / ";
  String _otherChar = "#";
  List<String> constSellectedUsers;
  List<SelectionModel<MyUserModel>> cachedUserSellections;

  GroupMemberSelectViewModel(this.constSellectedUsers);

  bool get isSelectedUserCountValidRange =>
      cachedUserSellections.selectedModelCount < GroupConversationDTOModel.MaxGroupMembers;

  List<SelectionModel<MyUserModel>> searchUserNameContain(String searchValue) {
    return cachedUserSellections
        .where(
            (element) => element.model.name.toLowerCase().contains(searchValue))
        .toList();
  }

  String selectedCountText() {
    int constSelectedSize = constSellectedUsers?.length ?? 0;
    String membersCount = (cachedUserSellections.selectedModelCount + constSelectedSize).toString();
    String groupMemberCount = GroupConversationDTOModel.MaxGroupMembers.toString();
    String result = membersCount + _seperator + groupMemberCount;
    return result;
  }

  List<MyUserModel> getMyUserModelsFromSnapshot(List<MyUserModel> snapshot) {
    var currentUser = snapshot.firstWhere(
        (element) => element.id == MyUserModel.CurrentUserId,
        orElse: () => null);
    snapshot.remove(currentUser);
    if (constSellectedUsers != null) {
      constSellectedUsers.forEach((constUserId) {
        var user = snapshot.firstWhere((element) => element.id == constUserId,
            orElse: () => null);
        if (user != null) {
          snapshot.remove(user);
        }
      });
    }
    snapshot.sort((a, b) => a.name.toString().compareTo(b.name.toString()));
    return snapshot;
  }

  List<SelectionModel<MyUserModel>> updateCachedUsers(List<MyUserModel> users) {
    List<SelectionModel<MyUserModel>> updateCacheUsers= cachedUserSellections.updateCachedModels(users);
    return updateCacheUsers;
  }

  String MyUserModelSellectGroupBy(SelectionModel<MyUserModel> element) {
    if (element.model.name != null && element.model.name.length > 0) {
      var firstChar = element.model.name[0];
      return firstChar.toString();
    } else {
      return _otherChar;
    }
  }
}

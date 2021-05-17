

import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/core_models/core_selection_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';

class GroupCreateViewModel{

  List<SelectionModel<MyUserModel>> myUserModelsSellect;
  
  String _memberText="Members :";
  String _seperator="/";

  GroupCreateViewModel(this.myUserModelsSellect);

  bool isCreateButtonActive(String groupName){
    if(  groupName.trim().length > 0 && myUserModelsSellect.selectedModelCount >= GroupConversationDTOModel.MinGroupMembers){
      return true;
    }
    else return false;
  }


  String selectedCountText(){
    String membersCount=myUserModelsSellect.selectedModelCount.toString();
    String groupMemberCount=GroupConversationDTOModel.MaxGroupMembers.toString();
    String result= _memberText+membersCount +_seperator +groupMemberCount;
    return result;
  }
}
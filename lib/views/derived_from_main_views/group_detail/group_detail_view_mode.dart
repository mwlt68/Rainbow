
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:intl/intl.dart';
import 'package:rainbow/core/base/base_state.dart';

class GroupDetailViewModel  with BaseState{


  GroupConversationDTOModel conversationCache;
  String _memberText="Members :";
  String _seperator="/";
  
  GroupDetailViewModel( this.conversationCache);
    
    
  List<String> get selectedUsersId=>conversationCache.myUserModels
              .map<String>((e) => e.id)
              .toList();


  String conversationDateWithFormat(){
    var formatter = DateFormat.yMMMMd(formatLanguageStrConsts.englishUS);
    var date = conversationCache.createDate.toDate();
    return formatter.format(date);
  }
  
  String selectedCountText(){
    String userLength = conversationCache.myUserModels.length.toString();
    String groupMemberCount=GroupConversationDTOModel.MaxGroupMembers.toString();
    String result= _memberText+userLength +_seperator +groupMemberCount;
    return result;
  }
}

import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/services/firebase_services/firebase_base_service.dart';
import 'package:rainbow/core/services/services_constants/firebase_service_constant.dart';

class ConversationService extends FirebaseBaseService {
  ConversationService();

  Stream<List<SingleConversation>> getSingleConversations(String userId) {
    var ref = singleCollectionRef.where(
        FirebaseServiceStringConstant.instance.Members,
        arrayContains: userId);
    return ref.snapshots().map((event) =>
        event.docs.map((e) => SingleConversation.fromSnapshot(e)).toList());
  }

  Stream<List<GroupConversation>> getGroupConversations(String userId) {
    var ref = groupCollectionRef.where(
        FirebaseServiceStringConstant.instance.Members,
        arrayContains: userId);
    return ref.snapshots().map((event) =>
        event.docs.map((e) => GroupConversation.fromSnapshot(e)).toList());
  }

  Future<SingleConversation> checkSingleConversation(
      String currentUserId, String targetUserId) async {
    return await singleCollectionRef
        .where(FirebaseServiceStringConstant.instance.Members,
            arrayContains: currentUserId)
        .get()
        .then((result) {
          for (var item in result.docs) {
            var conversation = SingleConversation.fromSnapshot(item);
            if (conversation != null && conversation.members.contains(targetUserId)) {
              return conversation;
            }
          }
          return null;
        });
  }

  Future<SingleConversation> startSingleConversation(
      SingleConversation conversation) async {
    return singleCollectionRef.add(conversation.toJson()).then((value) {
      conversation.id = value.id;
      _createMessageCollection(conversation.id);
      return conversation;
    });
  }

  Future<GroupConversation> startGroupConversation(
      GroupConversation conversation) async {
    return groupCollectionRef.add(conversation.toJson()).then((value) {
      conversation.id = value.id;
      _createMessageCollection(conversation.id);
      return conversation;
    });
  }

  Future<void> _createMessageCollection(String conversationId) {
    var messageCollection = singleCollectionRef
        .doc(conversationId)
        .collection(FirebaseServiceStringConstant.instance.Messages);
    messageCollection.doc().set({}).then((value) {});
  }
}

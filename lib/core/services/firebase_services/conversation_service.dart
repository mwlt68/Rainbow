import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
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

  Stream<GroupConversation> getGroupConversation(String conversationId) {
    var ref =
        getCollectionReferance(ConversationType.Group).doc(conversationId);
    return ref
        .snapshots()
        .map((event) => GroupConversation.fromSnapshot(event));
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
        if (conversation != null &&
            conversation.members.contains(targetUserId)) {
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

  Future<void> removeGroupConversationUserTest(String groupConversationId,String memberId) async {
    var conversationDoc = getCollectionReferance(ConversationType.Group).doc(groupConversationId);
    return await conversationDoc.update(
      {FirebaseServiceStringConstant.instance.Members:FieldValue.arrayRemove([memberId])}
      
    );
  }

  Future<void> updateGroupConversationTest(GroupConversation conversation) async{
    var conversationDoc = getCollectionReferance(ConversationType.Group).doc(conversation.id.toString());
    return await conversationDoc.update(conversation.toJson());
  }
  Future<void> _createMessageCollection(String conversationId) {
    var messageCollection = singleCollectionRef
        .doc(conversationId)
        .collection(FirebaseServiceStringConstant.instance.Messages);
    messageCollection.doc().set({}).then((value) {});
  }
}

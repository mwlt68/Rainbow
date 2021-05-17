import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/core_models/core_conversation_model.dart';
import 'package:rainbow/core/services/firebase_services/firebase_base_service.dart';
import 'package:rainbow/core/services/services_constants/firebase_service_constant.dart';

class ConversationService extends FirebaseBaseService {
  ConversationService();

  Stream<List<SingleConversationModel>> getSingleConversations(String userId) {
    var ref = singleCollectionRef.where(
        FirebaseServiceStringConstant.instance.Members,
        arrayContains: userId);
    return ref.snapshots().map((event) =>
        event.docs.map((e) => SingleConversationModel.fromSnapshot(e)).toList());
  }

  Stream<GroupConversationModel> getGroupConversation(String conversationId) {
    var ref =
        getCollectionReferance(ConversationType.Group).doc(conversationId);
    return ref
        .snapshots()
        .map((event) => GroupConversationModel.fromSnapshot(event));
  }

  Stream<List<GroupConversationModel>> getGroupConversations(String userId) {
    var ref = groupCollectionRef.where(
        FirebaseServiceStringConstant.instance.Members,
        arrayContains: userId);
    return ref.snapshots().map((event) =>
        event.docs.map((e) => GroupConversationModel.fromSnapshot(e)).toList());
  }

  Future<SingleConversationModel> checkSingleConversation(
      String currentUserId, String targetUserId) async {
    return await singleCollectionRef
        .where(FirebaseServiceStringConstant.instance.Members,
            arrayContains: currentUserId)
        .get()
        .then((result) {
      for (var item in result.docs) {
        var conversation = SingleConversationModel.fromSnapshot(item);
        if (conversation != null &&
            conversation.members.contains(targetUserId)) {
          return conversation;
        }
      }
      return null;
    });
  }

  Future<SingleConversationModel> startSingleConversation(
      SingleConversationModel conversation) async {
    return singleCollectionRef.add(conversation.toJson()).then((value) {
      conversation.id = value.id;
      _createMessageCollection(conversation.id);
      return conversation;
    });
  }

  Future<GroupConversationModel> startGroupConversation(
      GroupConversationModel conversation) async {
    return groupCollectionRef.add(conversation.toJson()).then((value) {
      conversation.id = value.id;
      _createMessageCollection(conversation.id);
      return conversation;
    });
  }
  Future<void> addMemberToGroupConversation(String groupConversationId,List<String> userIds) async {
    var conversationDoc = getCollectionReferance(ConversationType.Group).doc(groupConversationId);
    return await conversationDoc.update(
      {FirebaseServiceStringConstant.instance.Members:FieldValue.arrayUnion(userIds)}
    );
  }
  Future<void> removeGroupConversationUser(String groupConversationId,String memberId) async {
    var conversationDoc = getCollectionReferance(ConversationType.Group).doc(groupConversationId);
    return await conversationDoc.update(
      {FirebaseServiceStringConstant.instance.Members:FieldValue.arrayRemove([memberId])}
      
    );
  }

  Future<void> updateGroupConversation(GroupConversationModel conversation) async{
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

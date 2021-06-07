import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/core_models/core_message_model.dart';
import 'package:rainbow/core/services/firebase_services/firebase_base_service.dart';
import 'package:rainbow/core/services/services_constants/firebase_service_constant.dart';

class MessageService extends FirebaseBaseService{

  MessageService();
  
  Stream<List<MessageModel>> getMessages(String conversationId, ConversationType conversationType) {
    var collectionRef=getCollectionReferance(conversationType);
    var ref = collectionRef
        .doc(conversationId)
        .collection(FirebaseServiceStringConstant.instance.Messages)
        .orderBy(FirebaseServiceStringConstant.instance.ServerTimeStamp);
    return ref.snapshots().map(
        (event) => event.docs.map((e) => MessageModel.fromSnapshot(conversationId,e)).toList());
  }

  Stream<MessageModel> getLastMessage(String conversationId, ConversationType conversationType){
    var collectionRef=getCollectionReferance(conversationType);
      var ref = collectionRef
        .doc(conversationId)
        .collection(FirebaseServiceStringConstant.instance.Messages)
        .orderBy(FirebaseServiceStringConstant.instance.ServerTimeStamp);
      return ref.snapshots().map(
        (event){
          if(event.docs == null || event.docs.length==0){
            return null;
          }
          else{
            return MessageModel.fromSnapshot(conversationId,event.docs.last);
          }
        });
  }

  Future<void> sendMessage(MessageModel message, ConversationType conversationType,String conversationId) async {
    var ref = getCollectionReferance(conversationType).doc(conversationId).collection(FirebaseServiceStringConstant.instance.Messages);
    var messageJson=message.toJson();
    ref.add(messageJson);
  }
  
  Future<void> deleteMessage(MessageModel message, ConversationType conversationType, String conversationId) async {
    CollectionReference collectionReference= getCollectionReferance(conversationType).doc(conversationId).collection(FirebaseServiceStringConstant.instance.Messages);
    collectionReference.doc(message.id).delete();
  }


}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/models/conversation.dart';

class MessageService {
  final FirebaseFirestore _fBaseFireStore = FirebaseFirestore.instance;
  CollectionReference _collectionRef;
  MessageService() {
    _collectionRef = _fBaseFireStore.collection('Conversation');
  }
  
    Stream<List<Message>> getMessages(String conversationId) {
    var ref = _collectionRef
        .doc(conversationId)
        .collection('messages')
        .orderBy('timeStamp');
    return ref.snapshots().map(
        (event) => event.docs.map((e) => Message.fromSnapshot(e)).toList());
  }
  Stream<Message> getLastMessageTest(String conversationId ){
      var ref = _collectionRef
        .doc(conversationId)
        .collection('messages')
        .orderBy('timeStamp');
      return ref.snapshots().map(
        (event){
          if(event.docs == null || event.docs.length==0){
            return null;
          }
          else{
            return Message.fromSnapshot(event.docs.last);
          }
        });
  }
  Future<void> sendMessage(Message message, String conversationId) async {
    var ref = _collectionRef.doc(conversationId).collection('messages');
    await ref.add(message.toJson());
  }
}
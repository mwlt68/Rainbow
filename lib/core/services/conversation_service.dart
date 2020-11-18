import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/models/conversation.dart';

class ConversationService {
  final FirebaseFirestore _fBaseFireStore = FirebaseFirestore.instance;
  CollectionReference _collectionRef;
  ConversationService() {
    _collectionRef = _fBaseFireStore.collection('Conversation');
  }
  Stream<List<Conversation>> getConversations(String userId) {
    var ref = _collectionRef.where('members', arrayContains: userId);
    return ref.snapshots().map((event) =>
      event.docs.map((e) => Conversation.fromSnapshot(e)).toList());
  }


}

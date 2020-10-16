import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/models/converstaion.dart';

class FirestoreDb{
  final FirebaseFirestore _fBaseFireStore=FirebaseFirestore.instance;
  Stream<List<Conversation>> getConversation(String userId){
    var ref=_fBaseFireStore.collection('Conversation').where('members',arrayContains: userId);
    return ref.snapshots().map((event) => event.docs
    .map((e) => Conversation.fromSnaphot(e))
    .toList());
  }

}
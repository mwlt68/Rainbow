import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/models/conversation.dart';

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

  Future<Conversation> getSingleConversation(String currentUserId,String targetUserId) async {
    List<String> members=new List<String>();
    members.add(currentUserId);
    members.add(targetUserId);
    return await _collectionRef.where('isGroup',isEqualTo: false).where('members',
				arrayContains: currentUserId).get().then((result){
          for (var item in result.docs) {
            var conversation=Conversation.fromSnapshot(item);
            if(conversation.members.first==targetUserId ||conversation.members[1]==targetUserId){
              return conversation;
            }
          }
          return null;
    });
  }
  Future<Conversation> startSingleConversation(String currentUserId,String targetUserId) async {
    Conversation conversation = new Conversation(isGroup: false,members: [currentUserId,targetUserId]);
    return _collectionRef.add(conversation.toJson()).then((value) {
      conversation.id=value.id;
      var messageCollection=_collectionRef.doc(conversation.id).collection('messages');
        messageCollection
        .doc()
        .set({})
        .then((value) {
            print("okey");
        })
        .catchError( (error) {
            print('Error adding document: '+ error);
        });
      return conversation;
    });
  }
  
}

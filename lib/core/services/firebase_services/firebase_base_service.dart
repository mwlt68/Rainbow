import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/dto_models/conversation_dto_model.dart';
import 'package:rainbow/core/services/services_constants/firebase_service_constant.dart';

class FirebaseBaseService {
  final FirebaseFirestore _fBaseFireStore = FirebaseFirestore.instance;
  CollectionReference _singleCollectionRef;
  CollectionReference _groupCollectionRef;
  CollectionReference _userCollectionRef;

  FirebaseFirestore get fBaseFireStore => fBaseFireStore;
  CollectionReference get singleCollectionRef => _singleCollectionRef;
  CollectionReference get groupCollectionRef => _groupCollectionRef;
  CollectionReference get userCollectionRef => _userCollectionRef;

  FirebaseBaseService() {
    _singleCollectionRef = _fBaseFireStore
        .collection(FirebaseServiceStringConstant.instance.SingleConversation);
    _groupCollectionRef = _fBaseFireStore
        .collection(FirebaseServiceStringConstant.instance.GroupConversation);
    _userCollectionRef = _fBaseFireStore
        .collection(FirebaseServiceStringConstant.instance.Users);
  }

  CollectionReference getCollectionReferance(ConversationType conversationType){
    switch(conversationType){
      case ConversationType.Single:
        return singleCollectionRef;
      case ConversationType.Group:
        return groupCollectionRef;
      default:
        return null;
    }
  }
}

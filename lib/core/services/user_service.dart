import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/models/user.dart';

class UserService{
  
  final FirebaseFirestore _fBaseFireStore=FirebaseFirestore.instance;
  CollectionReference _collectionRef;
  UserService(){
    _collectionRef=_fBaseFireStore.collection('Users');
  }
  Stream<MyUser> getUserFromUserId(String userId){
    var ref=_collectionRef.where('userId',isEqualTo:userId);
    return ref.snapshots().map((event) => MyUser.fromSnaphot(event.docs[0]));
  }
  Stream<List<MyUser>> getUserFromUserIds(List<String> userIds)  {
    var ref=_collectionRef.where('userId',whereIn: userIds);
    var res= ref.snapshots().map((event) => event.docs.map((e) => MyUser.fromSnaphot(e)).toList());
    return res;
  }
  Stream<MyUser> getUserFromUserPhoneNumber(String phoneNumber)  {
    var ref=_collectionRef.where('phoneNumber',isEqualTo:phoneNumber);
    var res= ref.snapshots().map((event) => MyUser.fromSnaphot(event.docs[0]));
    return res;
  }
  Stream<List<MyUser>> getUserFromUserPhoneNumbers(List<String> phoneNumbers)  {
    var ref=_collectionRef.where('phoneNumber',whereIn: phoneNumbers);
    var res= ref.snapshots().map((event) => event.docs.map((e) => MyUser.fromSnaphot(e)).toList());
    return res;
  }
  Future<DocumentReference> registerUser(MyUser user) async {
    var ref=_fBaseFireStore.collection('Users');
    return await ref.add(user.toJson());
  }

}
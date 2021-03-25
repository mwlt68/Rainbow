import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/services/services_constants/firebase_service_constant.dart';

import 'firebase_base_service.dart';

class UserService  extends FirebaseBaseService{
  UserService();

  Stream<MyUser> getUserFromUserId(String userId){
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.UserId,isEqualTo:userId);
    return ref.snapshots().map((event) => MyUser.fromSnaphot(event.docs[0]));
  }

  Stream<List<MyUser>> getUsersFromIdsStream(List<String> userIds)  {
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.UserId,whereIn: userIds);
    var res= ref.snapshots().map((event) => event.docs.map((e) => MyUser.fromSnaphot(e)).toList());
    return res;
  }
  Future<List<MyUser>> getUsersFromIdsFuture(List<String> userIds)  {
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.UserId,whereIn: userIds);
    var res= ref.get().then((value) => 
      value.docs.map((e) => MyUser.fromSnaphot(e)).toList()
    );
    return res;
  }
  Stream<MyUser> getUserFromUserPhoneNumber(String phoneNumber)  {
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.PhoneNumber,isEqualTo:phoneNumber);
    var res= ref.snapshots().map((event) => MyUser.fromSnaphot(event.docs[0]));
    return res;
  }

  Stream<List<MyUser>> getUserFromUserPhoneNumbers(List<String> phoneNumbers)  {
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.PhoneNumber,whereIn: phoneNumbers);
    var res= ref.snapshots().map((event) => event.docs.map((e) => MyUser.fromSnaphot(e)).toList());
    return res;
  }

  Future<DocumentReference> registerUser(MyUser user) async {
    return await userCollectionRef.add(user.toJson());
  }

  Future<void> updateUserTest(MyUser user) async{
    var userDoc = userCollectionRef.doc(user.snapshotId.toString());
    return await userDoc.update(user.toJson());
  }

}
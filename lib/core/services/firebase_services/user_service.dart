import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/services_constants/firebase_service_constant.dart';

import 'firebase_base_service.dart';

class UserService  extends FirebaseBaseService{
  UserService();

  Stream<MyUserModel> getUserFromUserId(String userId){
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.UserId,isEqualTo:userId);
    return ref.snapshots().map((event) => MyUserModel.fromSnaphot(event.docs[0]));
  }

  Stream<List<MyUserModel>> getUsersFromIdsStream(List<String> userIds)  {
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.UserId,whereIn: userIds);
    var res= ref.snapshots().map((event) => event.docs.map((e) => MyUserModel.fromSnaphot(e)).toList());
    return res;
  }
  Future<List<MyUserModel>> getUsersFromIdsFuture(List<String> userIds)  {
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.UserId,whereIn: userIds);
    var res= ref.get().then((value) => 
      value.docs.map((e) => MyUserModel.fromSnaphot(e)).toList()
    );
    return res;
  }
  Stream<MyUserModel> getUserFromUserPhoneNumber(String phoneNumber)  {
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.PhoneNumber,isEqualTo:phoneNumber);
    var res= ref.snapshots().map((event) => MyUserModel.fromSnaphot(event.docs[0]));
    return res;
  }

  Stream<List<MyUserModel>> getUserFromUserPhoneNumbers(List<String> phoneNumbers)  {
    var ref=userCollectionRef.where(FirebaseServiceStringConstant.instance.PhoneNumber,whereIn: phoneNumbers);
  //    .orderBy(FirebaseServiceStringConstant.instance.Name);
    var res= ref.snapshots().map((event) => event.docs.map((e) => MyUserModel.fromSnaphot(e)).toList());
    return res;
  }

  Future<DocumentReference> registerUser(MyUserModel user) async {
    return await userCollectionRef.add(user.toJson());
  }

  Future<void> updateUser(MyUserModel user) async{
    var userDoc = userCollectionRef.doc(user.snapshotId.toString());
    return await userDoc.update(user.toJson());
  }

}
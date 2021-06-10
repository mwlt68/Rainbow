import 'package:rainbow/core/core_models/core_status_model.dart';
import 'package:rainbow/core/services/firebase_services/firebase_base_service.dart';
import 'package:rainbow/core/services/services_constants/firebase_service_constant.dart';

class StatusService extends FirebaseBaseService {

  Stream<List<StatusModel>> getUsersStatuses(List<String> userIds){

    var ref = statusCollectionRef.where(
        FirebaseServiceStringConstant.instance.UserId,
        whereIn: userIds);
  //      .orderBy(FirebaseServiceStringConstant.instance.ServerTimeStamp,descending: false);
    return ref.snapshots().map((event) =>
      
        event.docs.map((e){
          var model = StatusModel.fromSnapshot(e);
          int difference=model.serverTimeStamp.toDate().difference(DateTime.now()).inMinutes;
          model.timeDifferenceInMinutes=difference.abs();
          if(model.timeDifferenceInMinutes <= StatusModel.StatusValidInMinutes){
            return model;
          }
        }).toList());
  }

  void addStatus(StatusModel statusModel){
    var statusModelJSON=statusModel.toJson();
    statusCollectionRef.add(statusModelJSON);
  }
  
 
}
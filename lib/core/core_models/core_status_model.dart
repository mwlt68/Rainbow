import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/core_models/core_base_model.dart';
enum StatusMediaType {
  Image,
  Text,
  Video,
}
class StatusModel extends CoreBaseModel{

  static int StatusValidInMinutes=60*24;
  String src;
  String caption;
  int mediaType;
  String userId;
  Timestamp serverTimeStamp;
  int timeDifferenceInMinutes;

  StatusModel({String id,this.mediaType,this.caption,this.src, this.userId, this.serverTimeStamp}):super(id);

  factory StatusModel.fromSnapshot(DocumentSnapshot snapshot) {
    return StatusModel(
      id: snapshot.id,
      src: snapshot.data()['src'],
      serverTimeStamp: snapshot.data()['serverTimeStamp'],
      userId: snapshot.data()['userId'],
      caption: snapshot.data()['caption'],
      mediaType: snapshot.data()['mediaType'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['src'] = this.src;
    data['userId'] = this.userId;
    data['caption'] = this.caption;
    data['mediaType'] = this.mediaType;
    data['serverTimeStamp'] = FieldValue.serverTimestamp();
    return data;
  }
}
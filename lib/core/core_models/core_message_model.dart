import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/core_models/core_base_model.dart';
import 'package:rainbow/core/services/other_services/aes_encryption_service.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';

class MessageModel extends CoreBaseModel{

  String conversationId;
  String message;
  String senderId;
  Timestamp timeStamp;
  Timestamp serverTimeStamp;
  bool isMedia;
  List<String> usersRead;
  
  MessageModel({String conversationId,String id,this.message,this.senderId,this.serverTimeStamp,this.timeStamp,this.isMedia,this.usersRead}):super(id);

  factory MessageModel.fromSnapshot(String conversationId,DocumentSnapshot snapshot){
    return MessageModel(
      conversationId: conversationId,
      id:snapshot.id,
      message: AESEncryption.getDecryptedMessage(snapshot.data()['message']) ,
      senderId: snapshot.data()['senderId'],
      timeStamp: snapshot.data()['timeStamp'],
      serverTimeStamp: snapshot.data()['serverTimeStamp'],
      isMedia: snapshot.data()['isMedia'],
      usersRead: List.from(snapshot.data()['usersRead']),
    );
  }
  
  Map<String, dynamic> toJson() =>
  {
    'message': AESEncryption.getEncryptedMessage(message),
    'senderId': senderId,
    'isMedia': isMedia,
    'usersRead': usersRead,
    'timeStamp': timeStamp,
    'serverTimeStamp': FieldValue.serverTimestamp(),
  };

  Timestamp get getPosibleTimeStamp=> senderId ==  MyUserModel.CurrentUserId ? timeStamp:serverTimeStamp;

  bool get isCurrentUser => senderId == MyUserModel.CurrentUserId ;
}

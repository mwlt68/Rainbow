import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/core/core_models/core_base_model.dart';
import 'package:rainbow/core/services/other_services/aes_encryption_service.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';

class MessageModel extends CoreBaseModel{

  String message;
  String senderId;
  Timestamp timeStamp;
  bool isMedia;
  List<String> usersRead;
  
  MessageModel({String id,this.message,this.senderId,this.timeStamp,this.isMedia,this.usersRead}):super(id);

  factory MessageModel.fromSnapshot(DocumentSnapshot snapshot){
    return MessageModel(
      id:snapshot.id,
      message: AESEncryption.getDecryptedMessage(snapshot.data()['message']) ,
      senderId: snapshot.data()['senderId'],
      timeStamp: snapshot.data()['timeStamp'],
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
  };

  bool get isCurrentUser => senderId == MyUserModel.CurrentUserId ;
}

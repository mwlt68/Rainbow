import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/common/aes_encryption.dart';

class Message{
  String id;
  String message;
  String senderId;
  Timestamp timeStamp;
  bool isMedia;
  List<String> usersRead;
  
  Message({this.id,this.message,this.senderId,this.timeStamp,this.isMedia,this.usersRead});
  factory Message.fromSnapshot(DocumentSnapshot snapshot){
    return Message(
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
}
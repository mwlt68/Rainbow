import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation{
  String id;
  String name;
  String profileImage;
  String displayMessage;
  bool isGroup;
  Conversation({this.id,this.name,this.profileImage,this.displayMessage,this.isGroup});
  factory Conversation.fromSnapshot(DocumentSnapshot snapshot){
    return Conversation(
      id:snapshot.id,
      name: 'Mevlut Test',
      displayMessage:snapshot.data()['displayMessage'],
      profileImage:"https://picsum.photos/200",
      isGroup:snapshot.data()['isGroup'],
      );
  }
}
class Message{
  String id;
  String message;
  String senderId;
  Timestamp timeStamp;
  Message({this.id,this.message,this.senderId,this.timeStamp});
  factory Message.fromSnapshot(DocumentSnapshot snapshot){
    return Message(
      id:snapshot.id,
      message: snapshot.data()['message'],
      senderId: snapshot.data()['senderId'],
      timeStamp: snapshot.data()['timeStamp'],
    );
  }
}
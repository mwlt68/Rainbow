import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation{
  String id;
  String name;
  String profileImage;
  String displayMessage;
  Conversation({this.id,this.name,this.profileImage,this.displayMessage});
  factory Conversation.fromSnaphot(DocumentSnapshot snapshot){
    return Conversation(
      id:snapshot.id,
      name: 'Mevlut Test',
      displayMessage:snapshot.data()['displayMessage'],
      profileImage:"https://picsum.photos/200"
      );
  }
}
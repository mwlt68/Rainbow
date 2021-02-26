import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rainbow/common/aes_encryption.dart';
import 'package:rainbow/core/models/user.dart';

class Conversation{
  String id;
  String name;
  String profileImage;
  List<String> members;
  bool isGroup;
  List<MyUser> myUsers;
  Conversation({this.id,this.name,this.profileImage,this.isGroup,this.members});
  factory Conversation.fromSnapshot(DocumentSnapshot snapshot){
    return Conversation(
      id:snapshot.id,
      name: 'Group Test',
      profileImage:"https://picsum.photos/200",
      isGroup:snapshot.data()['isGroup'],
      members: List.from(snapshot.data()['members']),
      );
  }
  Map<String, dynamic> toJson() =>
  {
    'name': name,
    'profileImage': profileImage,
    'isGroup': isGroup,
    'members': members,
  };
  MyUser getOtherUser(String currentUserId){
    if(myUsers != null && !isGroup){
      if(myUsers[0].userId != currentUserId){
        return myUsers.elementAt(0);
      }
      else{
        return myUsers.elementAt(1);
      }
    }
    return null;
  }
}
class Message{
  String id;
  String message;
  String senderId;
  Timestamp timeStamp;
  bool isMedia;
  
  Message({this.id,this.message,this.senderId,this.timeStamp,this.isMedia});
  factory Message.fromSnapshot(DocumentSnapshot snapshot){
    return Message(
      id:snapshot.id,
      message: AESEncryption.getDecryptedMessage(snapshot.data()['message']) ,
      senderId: snapshot.data()['senderId'],
      timeStamp: snapshot.data()['timeStamp'],
      isMedia: snapshot.data()['isMedia'],
    );
  }
  Map<String, dynamic> toJson() =>
  {
    'message': AESEncryption.getEncryptedMessage(message),
    'senderId': senderId,
    'isMedia': isMedia,
    'timeStamp': DateTime.now(),
  };
}
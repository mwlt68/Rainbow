import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:rainbow/core/services/firestore_db.dart';
import 'package:rainbow/models/converstaion.dart';

class ChatModel with ChangeNotifier{
  final FirestoreDb _db=GetIt.instance<FirestoreDb>();
  Stream<List<Conversation>> conversations (String userId){
    return _db.getConversation(userId);
  }
}
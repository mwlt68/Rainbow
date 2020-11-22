import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/services/conversation_service.dart';
import 'package:rainbow/core/models/conversation.dart';
import 'package:rainbow/core/services/user_service.dart';

class ConversationModel with ChangeNotifier {
  final ConversationService _conversationService = getIt<ConversationService>();
  final UserService _userService = getIt<UserService>();

  Stream<List<Conversation>> conversations(String userId) {
    return _conversationService.getConversations(userId);
  }

  Stream<List<Conversation>> conversationsTest(String userId) async* {
    final stream = _conversationService.getConversations(userId);
    await for (var conversationList in stream) {
      for (var conversation in conversationList) {
        if (!conversation.isGroup) {
          final user = await _getOtherUser(conversation, userId);
          if (user != null) {
            conversation.profileImage = user.imgSrc;
            conversation.name = user.name;
          }
        }
      }
      yield conversationList;
    }
  }

  Future<MyUser> _getOtherUser(Conversation conversation, String userId) async {
    Stream<MyUser> stream;
    if (conversation.members.first == userId) {
      stream =
          _userService.getUserFromUserId(conversation.members.elementAt(1));
    } else {
      stream =
          _userService.getUserFromUserId(conversation.members.elementAt(0));
    }
    await for (var user in stream) {
      return user;
    }
  }
}

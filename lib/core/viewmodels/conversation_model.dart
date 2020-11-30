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

  Stream<List<Conversation>> conversations(String userId) async* {
    final stream = _conversationService.getConversations(userId);
    List<Conversation> resultConversations = [];
    await for (var conversationList in stream) {
      for (var conversation in conversationList) {
        var conversationComplete =
            await _getConversationUsers(conversation, userId);
        if (conversationComplete != null) {
          resultConversations.add(conversationComplete);
        }
      }
      yield resultConversations;
    }
  }

  Future<Conversation> _getConversationUsers(
      Conversation conversation, String currentUserId) async {
    List<String> userIdList = new List<String>();
    for (var member in conversation.members) {
      userIdList.add(member);
    }
    userIdList = userIdList.toSet().toList();
    var myUsersStream = _userService.getUserFromUserIds(userIdList);
    await for (var users in myUsersStream) {
      conversation.myUsers = users;
      var otherUser = conversation.getOtherUser(currentUserId);
      if (otherUser != null) {
        conversation.profileImage = otherUser.imgSrc;
        conversation.name = otherUser.name;
      }
      return conversation;
    }
  }

  Future<Conversation> startSingleConversation(
      String currentUserId, String targetUserId) async {
    var checkConversation = await _conversationService
        .getSingleConversation(currentUserId, targetUserId);
    if (checkConversation == null) {
      var conversation = await _conversationService.startSingleConversation(
          currentUserId, targetUserId);
      return _getConversationUsers(conversation, currentUserId);
    } else
      return _getConversationUsers(checkConversation, currentUserId);
  }
}

import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rainbow/core/services/user_service.dart';
import 'package:rainbow/models/user.dart';
import 'package:rainbow/viewmodels/base_model.dart';
import 'package:async/async.dart' show StreamGroup;

class ContactModel extends BaseModel {
  UserService _userService = new UserService();
  Iterable<Contact> contacts;
  Future<bool> getContatcs() async {
    contacts=await ContactsService.getContacts();
    return true;
  }
  Stream<MyUser> getMyUsersFromContact() {
    final streams = new List<Stream<MyUser>>();
    for (var contact in contacts) {
      String number = getPhoneNumberBeaty(contact.phones.elementAt(0));
      Stream<MyUser> stream = _userService.getUserFromUserPhoneNumber(number);
      streams.add(stream);
    }
    final stream = StreamGroup.merge(streams);
    return stream;
  }

  String getPhoneNumberBeaty(Item contact) {
    String number = contact.value.replaceAll(' ', '').replaceAll('-', '');
    return number;
  }

  Future<PermissionStatus> getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }
}

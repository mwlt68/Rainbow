import 'dart:async';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rainbow/core/services/firebase_services/user_service.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/core_view_models/core_base_view_model.dart';

class ContactViewModel extends BaseViewModel {
  UserService _userService;
  Iterable<Contact> contacts;

  ContactViewModel() {
    _userService = new UserService();
  }

  Future<bool> getContatcs() async {
    contacts = await ContactsService.getContacts();
    return true;
  }


  Stream<List<MyUserModel>> getMyUserModels() {
    List<String> phoneNumbers = [];
    if (contacts != null) {
      for (var contact in contacts) {
        String number = _getPhoneNumberBeaty(contact.phones.elementAt(0));
        phoneNumbers.add(number);
      }
    }
    return _userService.getUserFromUserPhoneNumbers(phoneNumbers);
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

  String _getPhoneNumberBeaty(Item contact) {
    String number = contact.value.replaceAll(' ', '').replaceAll('-', '');
    return number;
  }
}

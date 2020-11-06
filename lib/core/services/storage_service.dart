import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  Future<String> uploadMedia(String rootFolder,File file) async {
    String _newFilePath="${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}";
    var uploadTask = _firebaseStorage
        .ref()
        .child(rootFolder)
        .child(_newFilePath)
        .putFile(file);

    uploadTask.snapshotEvents.listen((event) {});

    var storageRef = await uploadTask;

    return await storageRef.ref.getDownloadURL();
  }
}
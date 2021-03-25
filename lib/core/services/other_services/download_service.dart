import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rainbow/core/default_data.dart';

class DownloadService {
  String _path;
  DownloadService() {
    _getPath();
  }
  Future<String> downloadImages(String url) async {
    await _requestPermissions().then((result) {
      if (!result) {
        throw "Permission exception";
      }
    });
    return  await ImageDownloader.downloadImage(
      url,
      destination: AndroidDestinationType.custom(directory: _path),
    );
    
  }

  _getPath() async {
    String targetFolder;
    await getExternalStorageDirectory().then((dir) =>
        targetFolder = dir.path + "/" + DefaultData.AppName.toString());
    await Directory(targetFolder)
        .create(recursive: true)
        .then((dir) => _path = dir.path);
  }

  Future<bool> _requestPermissions() async {
    var permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) {
      await [Permission.storage].request();
      permission = await Permission.storage.status;
    }

    return permission == PermissionStatus.granted;
  }
}

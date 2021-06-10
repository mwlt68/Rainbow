import 'dart:io';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:rainbow/core/base/base_state.dart';
import 'package:rainbow/core/core_models/core_status_model.dart';
import 'package:rainbow/core/core_view_models/core_base_view_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/firebase_services/status_service.dart';
import 'package:rainbow/core/services/firebase_services/storage_service.dart';

class StatusViewModel extends BaseViewModel with BaseState{

  final StatusService _statusService = getIt<StatusService>();
  final StorageService _storageService = getIt<StorageService>();

  Stream<List<StatusModel>> getUsersStatuses(List<String> userIds){
    return _statusService.getUsersStatuses(userIds);
  }

  Future<String> addStatus(StatusMediaType mediaType,String userId,{String caption,File file}) async {
    StatusModel statusModel= new StatusModel(
      caption: caption,
      mediaType: mediaType.index,
      userId: userId,
    );
    switch (mediaType) {
      case StatusMediaType.Text:
        _statusService.addStatus(statusModel);
        return null;
        break;
      case StatusMediaType.Image:
        if(file != null){
          File compressedFile=await _compressFile(file);
          String  mediaUrl=await _uploadMedia(compressedFile);
          statusModel.src=mediaUrl;
          _statusService.addStatus(statusModel);
        }
        else{
          return "File is null !";
        }
        break;
      default:
        return "Unexpected condition happend !";
    }

  }
  Future<File> _compressFile(File file) async{
    var fileSize=await file.length();
    int quality = _calculateQualityFromFileSize(fileSize);
    File compressedFile = await FlutterNativeImage.compressImage(file.path,
        quality: quality,);
    return compressedFile;
  }

  int _calculateQualityFromFileSize(int sizeByte){
    int sizeKByte=(sizeByte/intConstants.coefficient).round();
    
    if(sizeKByte >= intConstants.highQualitySize){
      return intConstants.minPlusQualitySize;
    }
    else if(sizeKByte <= intConstants.lowQualitySize ){
      return intConstants.maxQualitySize;
    }
    else if(sizeKByte <= intConstants.mediumQualitySize){
      var val=(sizeKByte-intConstants.lowQualitySize)/(intConstants.mediumQualitySize-intConstants.lowQualitySize);
      var res =val *(intConstants.maxQualitySize - intConstants.averageQualitySize )+ intConstants.averageQualitySize;
      return intConstants.maxQualitySize -(res.round()- intConstants.averageQualitySize);
    }
    else if(sizeKByte <= intConstants.highQualitySize){
      var val=(sizeKByte-intConstants.mediumQualitySize)/(intConstants.highQualitySize-intConstants.mediumQualitySize);
      var res =val *(intConstants.averageQualitySize- intConstants.minQualitySize)+intConstants.minQualitySize;
      return intConstants.averageQualitySize-(res.round());
    }

  }
  Future<String> _uploadMedia(File imgFile) async {
    var url =
          await _storageService.uploadMedia(stringConsts.statusMedia, imgFile);
      return url;
  }
}
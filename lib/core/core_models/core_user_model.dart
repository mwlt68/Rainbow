import 'package:rainbow/core/core_models/core_base_model.dart';
import 'package:rainbow/constants/string_constants.dart';

class MyUserModel extends CoreBaseModel {
  static String CurrentUserId;
  static final int StatusTextLength = 150;

  String snapshotId;
  String name;
  String phoneNumber;
  String imgSrc;
  String status;
  String get imgSrcWithDefault =>
      imgSrc ?? StringConstants.instance.userDefaultImagePath;

  MyUserModel({
    String id,
    this.snapshotId,
    this.name,
    this.imgSrc,
    this.phoneNumber,
    this.status,
  }) : super(id);

  factory MyUserModel.fromSnapshot(
      Map<String, dynamic> data, String snapshotId) {
    return MyUserModel(
      snapshotId: snapshotId,
      id: data['userId'],
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      imgSrc: data['imgSrc'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'imgSrc': imgSrc,
        'name': name,
        'phoneNumber': phoneNumber,
        'status': status,
        'userId': id,
      };
}

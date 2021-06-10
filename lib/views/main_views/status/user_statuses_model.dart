import 'package:rainbow/core/core_models/core_status_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';

class UserStatusesModel {
  MyUserModel user;
  List<StatusModel> statuses;

  UserStatusesModel({
    this.user,
    this.statuses,
  });

  bool get checkValid =>
      this != null &&
      this.user != null &&
      this.statuses != null &&
      this.statuses.length > 0;

  bool get checkStatusValid => this != null && this.statuses.length > 0;
}

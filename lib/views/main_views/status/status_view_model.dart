import 'package:rainbow/core/core_models/core_status_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/views/main_views/status/user_statuses_model.dart';

class StatusViewModel {
  List<UserStatusesModel> cacheUserStatusesList;
  List<MyUserModel> cacheMyUsers;
  List<StatusModel> cacheStatuses;
  UserStatusesModel cacheCurrentuserStatuses;

  final String hoursText = " hours";
  final String minutesText = " minutes";

  void updateCacheUserStatusesModelList() {
    sortCacheStatuses();
    cacheUserStatusesList = [];
    cacheCurrentuserStatuses = null;
    cacheStatuses.forEach((status) {
      if (status != null) {
        var statusUser = cacheMyUsers
            .firstWhere((user) => user.id == status.userId, orElse: () => null);
        if (statusUser != null) {
          if (statusUser.id == MyUserModel.CurrentUserId) {
            if (cacheCurrentuserStatuses == null) {
              cacheCurrentuserStatuses =
                  new UserStatusesModel(user: statusUser, statuses: [status]);
            } else {
              cacheCurrentuserStatuses.statuses.add(status);
            }
          } else {
            var checkUserStatusList = cacheUserStatusesList.firstWhere(
                (element) => element.user.id == status.userId,
                orElse: () => null);
            if (checkUserStatusList != null) {
              checkUserStatusList.statuses.add(status);
            } else {
              var newUserStatusesModel =
                  new UserStatusesModel(user: statusUser, statuses: [status]);
              cacheUserStatusesList.add(newUserStatusesModel);
            }
          }
        }
      }
    });
  }

  List<String> get myUserIds=>cacheMyUsers.map<String>((e) => e.id).toList();

  void sortCacheStatuses() {
    cacheStatuses.sort((a, b) {
      int result;
      if (a == null) {
        result = 1;
      } else if (b == null) {
        result = -1;
      } else {
        // Ascending Order
        result = a.serverTimeStamp.compareTo(b.serverTimeStamp);
      }
      return result;
    });
  }

  String timeDifferenceText(int minutes) {
    if (minutes >= 60) {
      double hours = minutes / 60;
      return hours.toInt().toString() + hoursText;
    } else {
      return minutes.toInt().toString() + minutesText;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rainbow/core/locator.dart';

import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/views/derived_from_main_views/profile/profile_view.dart';

class SettingsViewModel{

  SettingsViewModel();
  final NavigatorService _navigatorService = getIt<NavigatorService>();

  void navigateProfilePage() {
    _navigatorService.navigateTo(ProfilePage());
  }
}
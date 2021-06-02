
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:rainbow/components/widgets/widgets.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/views/derived_from_main_views/profile/profile_view.dart';
import 'package:rainbow/views/main_views/settings/settings_view_model.dart';
part 'settings_string_values.dart';

class SettingsPage extends StatelessWidget {
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  _SettingsStringValues _values = _SettingsStringValues();
  SettingsPage();
  SettingsViewModel settingsViewModel;
  @override
  Widget build(BuildContext context) {
    settingsViewModel=new SettingsViewModel();
    var gestures = [
      createGestureDetector(Icons.help,_values.HelpPage, null),
      createGestureDetector(Icons.info_outline, _values.AboutPage, null),
      createGestureDetector(
          Icons.account_circle,_values.ProfilePage, navigateProfilePage),
      createGestureDetector(Icons.notifications, _values.NotificationsPage, null),
      createGestureDetector(Icons.vpn_key, _values.AcoountPage, null),
    ];
    var column = createColumn(gestures);
    return column;
  }

  Column createColumn(List<GestureDetector> gestures) {
    List<Widget> widgets = new List<Widget>.empty(growable: true);
    for (var gesture in gestures) {
      widgets.add(gesture);
      widgets.add(MyDivider);
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.start, children: widgets);
  }

  GestureDetector createGestureDetector(
      IconData icon, String label, Function function) {
    return GestureDetector(
      onTap: function,
      child: Container(
        padding: EdgeInsets.only(left: 20),
        child: ListTile(
            leading: Icon(
              icon,
              size: 25,
            ),
            title: gestureText(label)),
      ),
    );
  }

  Text gestureText(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Future<void> navigateProfilePage() async {
    bool connectivityActive=(await Connectivity().checkConnectivity()) != ConnectivityResult.none;
    _navigatorService.navigateTo(ProfilePage(connectivityActive));
  }
}

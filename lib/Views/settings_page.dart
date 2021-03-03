import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/navigator_service.dart';
import 'package:rainbow/views/sub_pages/profile_page.dart';


class SettingsPage extends StatelessWidget {
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  SettingsPage({this.user});
  final User user;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _getRow(
          Icons.help,
          "Help",
          () {},
        ),
        mDivider,
        _getRow(Icons.info_outline, "About", () {
          
        }),
        mDivider,
        _getRow(Icons.account_circle, "Profile", () {
          _navigatorService.navigateTo(ProfilePage());
        }),
        mDivider,
        _getRow(Icons.notifications, "Notifications", () {}),
        mDivider,
        _getRow(Icons.vpn_key, "Acoount", () {}),
        mDivider,
      ],
    );
  }

  Widget _getRow(IconData icon, String label, Function function) {
    return GestureDetector(
      onTap: (){
        function();
      },
      child: Container(
        padding: EdgeInsets.only(left: 20),
        child: ListTile(
            leading: Icon(
              icon,
              size: 25,
            ),
            title: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            )),
      ),
    );
  }
}

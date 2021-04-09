import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/common/widgets/widgets.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/models/user.dart';
import 'package:rainbow/core/viewmodels/user_model.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  UserDetailPage({this.userId});
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  UserModel _userModel;

  @override
  void initState() {
    super.initState();
    _userModel = getIt<UserModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (BuildContext context) => _userModel,
        child: StreamBuilder<MyUser>(
            stream: _userModel.getMyUserFromUserId(widget.userId),
            builder: (context, AsyncSnapshot<MyUser> userSnapshot) {
              if (userSnapshot.hasError) {
                return BasicErrorWidget(title: userSnapshot.error.toString());
              } else if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return createPage(userSnapshot.data);
            }),
      ),
    );
  }

  Widget createPage(MyUser user) {
    return Container(
      color: Color.fromRGBO(238, 238, 238, 1),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  user.imgSrc ?? DefaultData.UserDefaultImagePath,
                  fit: BoxFit.fill,
                )),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  InfoCard(context,Icons.person_rounded,DefaultData.Name,user.name),
                  InfoCard(context,Icons.comment,DefaultData.Status,user.status),
                  InfoCard(context,Icons.phone,DefaultData.Phone,user.phoneNumber),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
}

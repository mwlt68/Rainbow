import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/components/widgets/widgets.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/core_view_models/core_user_view_model.dart';
import 'package:rainbow/core/base/base_state.dart';

part 'user_detail_string_values.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  UserDetailPage({this.userId});
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage>  with BaseState{
  UserViewModel _userViewModel;
  final _UserDetailStringValues _values= new _UserDetailStringValues();
  @override
  void initState() {
    super.initState();
    _userViewModel = getIt<UserViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (BuildContext context) => _userViewModel,
        child: StreamBuilder<MyUserModel>(
            stream: _userViewModel.getMyUserModelFromUserId(widget.userId),
            builder: (context, AsyncSnapshot<MyUserModel> userSnapshot) {
              if (userSnapshot.hasError) {
                return MyBasicErrorWidget(title: userSnapshot.error.toString());
              } else if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return createPage(userSnapshot.data);
            }),
      ),
    );
  }

  Widget createPage(MyUserModel user) {
    return Container(
      color: colorConsts.perfectGrey,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  user.imgSrcWithDefault,
                  fit: BoxFit.fill,
                )),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  MyInfoCard(context,Icons.person_rounded,_values.Name,user.name),
                  MyInfoCard(context,Icons.comment,_values.Status,user.status),
                  MyInfoCard(context,Icons.phone,_values.Phone,user.phoneNumber),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
}

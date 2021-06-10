import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:rainbow/core/base/base_state.dart';
import 'package:rainbow/core/core_models/core_status_model.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/core_view_models/core_contact_view_model.dart';
import 'package:rainbow/core/core_view_models/core_status_view_model.dart';
import 'package:rainbow/core/core_view_models/core_user_view_model.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/views/main_views/status/state_view_delegate.dart';
import 'package:rainbow/views/main_views/status/user_statuses_model.dart';
import 'package:rainbow/views/main_views/status/status_view_model.dart' as svm;
part 'status_string_values.dart';

class StatusPage extends StatefulWidget {
  ContactViewModel contactViewModel;
  StatusPage(this.contactViewModel);
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> with BaseState {
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  final picker = ImagePicker();
  _StatusStringValues _values= new _StatusStringValues();
  MyDialogs _myDialogs;
  StatusViewModel _statusViewModel;
  svm.StatusViewModel _viewModel;
  MyUserModel currentUser;

  @override
  void initState() {
    super.initState();
    _myDialogs = new MyDialogs(context);
    _statusViewModel = GetIt.instance<StatusViewModel>();
    _viewModel= new svm.StatusViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: scaffoldBody(),
        floatingActionButton: buildFloatingActionButton(),
      ),
    );
  }

  FloatingActionButton buildFloatingActionButton() {
    return FloatingActionButton(
        onPressed: () {
          _myDialogs.showPicker(_getImage);
        },
        backgroundColor: colorConsts.accentColor,
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
      );
  }

  Center scaffoldBody() => Center(child: getMyUsers());

  Widget getMyUsers() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => widget.contactViewModel,
      child: StreamBuilder<List<MyUserModel>>(
          stream: widget.contactViewModel.getMyUserModels(),
          builder: (context, AsyncSnapshot<List<MyUserModel>> snapshot) {
            if (snapshot.hasError) {
              return Text(_values.serverGetError);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              if (_viewModel.cacheMyUsers != null) {
                return getUsersStatuses();
              } else {
                return CircularProgressIndicator();
              }
            }
            _viewModel.cacheMyUsers = snapshot.data;
            currentUser = _viewModel.cacheMyUsers.firstWhere(
                (element) => element.id == MyUserModel.CurrentUserId,
                orElse: () => null);
            // If current user did not save own contact number.
            if (currentUser == null) {
              return getCurrentUser();
            }
            return getUsersStatuses();
          }),
    );
  }

  Widget getCurrentUser() {
    var userModel = GetIt.instance<UserViewModel>();
    return ChangeNotifierProvider(
      create: (BuildContext context) => userModel,
      child: StreamBuilder<MyUserModel>(
          stream: userModel.getMyUserModelFromUserId(MyUserModel.CurrentUserId),
          builder: (context, AsyncSnapshot<MyUserModel> snapshot) {
            if (snapshot.hasError) {
              return Text(_values.serverGetError);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              if (currentUser != null) {
                return getUsersStatuses();
              } else {
                return CircularProgressIndicator();
              }
            }
            currentUser = snapshot.data;
            _viewModel.cacheMyUsers.add(currentUser);
            return getUsersStatuses();
          }),
    );
  }

  Widget getUsersStatuses() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => _statusViewModel,
      child: StreamBuilder<List<StatusModel>>(
          stream: _statusViewModel.getUsersStatuses(_viewModel.myUserIds),
          builder: (context, AsyncSnapshot<List<StatusModel>> snapshot) {
            if (snapshot.hasError) {
              return Text(_values.serverGetError);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              if (_viewModel.cacheStatuses != null ) {
                return ListView(
                  children: listViewChildren(),
                );
              }
              else{
                return CircularProgressIndicator();
              }
            }
            _viewModel.cacheStatuses = snapshot.data;
            _viewModel.updateCacheUserStatusesModelList();
            return ListView(
              children: listViewChildren(),
            );
          }),
    );
  }

  List<Widget> listViewChildren() {
    var listViewChildren = <Widget>[
      SizedBox(height: 12.0),
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage:
              CachedNetworkImageProvider(currentUser?.imgSrcWithDefault),
          radius: 32.0,
        ),
        title: Text(
          _values.myStatus,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(_values.statusUpdate),
        onTap: () {
          if (_viewModel.cacheCurrentuserStatuses.checkStatusValid) {
            _navigatorService
                .navigateTo(StateViewDelegate(_viewModel.cacheCurrentuserStatuses));
          }
        },
      ),
      SizedBox(
        height: 32,
        child: Container(
            alignment: Alignment.centerLeft,
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                _values.contactsStatus,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            )),
      ),
    ];
    listViewChildren.addAll(_viewModel.cacheUserStatusesList.map<Widget>((e) {
      if (e.checkValid) {
        return _statusDetails(e, e.user.name,
            e.statuses.last.timeDifferenceInMinutes, e.user.imgSrcWithDefault);
      }
    }));
    return listViewChildren;
  }

  

  _getImage(ImageSource imgSource, PickerMode pickerMode) async {
    if (pickerMode != PickerMode.None) {
      final pickedFile = await picker.getImage(source: imgSource);
      if (pickedFile != null) {
        var _image = File(pickedFile.path);
        String addResult = await _statusViewModel.addStatus(
            StatusMediaType.Image, MyUserModel.CurrentUserId,
            file: _image);
        if (addResult != null) {
          _myDialogs.showErrorDialog(_values.addError, message: addResult);
        }
      }
    }
  }

  Widget _statusDetails(
      UserStatusesModel e, String userName, int time, String imgUrl) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(0XFF128c7e),
        backgroundImage: CachedNetworkImageProvider(imgUrl),
        radius: 32.0,
      ),
      title: Wrap(
        children: <Widget>[
          Text(
            userName,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      subtitle: Text(
        _viewModel.timeDifferenceText(time),
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        _navigatorService.navigateTo(StateViewDelegate(e));
      },
    );
  }


}

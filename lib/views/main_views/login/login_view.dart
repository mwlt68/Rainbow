import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rainbow/views/main_views/home/home_view.dart';
import 'package:rainbow/views/main_views/user_register/user_register_view.dart';
import 'package:rainbow/components/dialogs/my_dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/core_models/core_user_model.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/base/base_state.dart';
part 'login_string_values.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>  with BaseState{
  _LoginStringValues _values;
  final NavigatorService _navigatorService = getIt<NavigatorService>();
  String countryCode;
  final int _verifyDuration = 60;
  bool _didVeriftFinish = true;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _codeController = TextEditingController();
  TextEditingController _phoneController = new TextEditingController();

  MyDialogs _myDialogs;
  @override
  void initState() {
    super.initState();
    _myDialogs = new MyDialogs(context);
    _values = new _LoginStringValues();
    countryCode=stringConsts.initialCountryCode;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(),
      body: Center(child: buildBody()),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: colorConsts.primaryColor,
      title: Text(
        _values.VerifyTitle,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget buildBody() {
    return ListView(
      children: [
        titleTextContainer(),
        countryCodePickerContainer(),
        phoneNumberContainer(),
      ],
    );
  }

  Padding titleTextContainer() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
      child: Text(
        stringConsts.appName + _values.VerifyMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Container phoneNumberContainer() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
            child: Icon(
              Icons.phone,
              size: 40,
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: phoneNumberTextField(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: loginFAB(),
          ),
        ],
      ),
    );
  }

  FloatingActionButton loginFAB() {
    return FloatingActionButton(
      backgroundColor: colorConsts.primaryColor,
      onPressed: _takeCodeClick,
      child: Icon(
        Icons.send,
        color: Colors.white,
      ),
    );
  }

  TextFormField phoneNumberTextField() {
    return TextFormField(
        controller: _phoneController,
        validator: _checkPhoneValid,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(10),
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        decoration: InputDecoration(
          labelText: _values.PhoneNumber,
        ));
  }

  Container countryCodePickerContainer() {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorConsts.primaryColor)),
      child: countryCodePicker(),
    );
  }

  CountryCodePicker countryCodePicker() {
    return CountryCodePicker(
      onChanged: (CountryCode code) {
        countryCode = code.dialCode.toString();
      },
      initialSelection: _values.InitialCountryCode,
      favorite: [_values.FavoriteCountryCode],
      showCountryOnly: false,
      showOnlyCountryWhenClosed: false,
      alignLeft: false,
    );
  }

  void _takeCodeClick() {
    FocusManager.instance.primaryFocus.unfocus();
    if (_formKey.currentState.validate()) {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text(_values.SendPhoneNumber)));
      String phoneNumber = countryCode + _phoneController.text.toString();
      _verifyPhoneNumber(phoneNumber, context);
    }
  }

  Future<bool> _verifyPhoneNumber(String phone, BuildContext context) async {
    _didVeriftFinish = false;
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();
          var result = await _auth.signInWithCredential(credential);

          User user = result.user;

          if (user != null) {
            _navigatorService.navigateTo(Home());
          } else {}
        },
        verificationFailed: (FirebaseAuthException exception) {
          _scaffoldKey.currentState.hideCurrentSnackBar();
          _myDialogs.showErrorDialog(_values.VerificationFailedTitle,
              message: _values.VerificationFailedMessage);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          showVerifyDialog(context, verificationId, _auth);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (_didVeriftFinish) {
            _scaffoldKey.currentState.hideCurrentSnackBar();
            Navigator.of(context).pop();
          }
        });
  }

  showVerifyDialog(
      BuildContext context, String verificationId, FirebaseAuth _auth) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            content: Column(
              children: <Widget>[
                verifyDialogCountDownTimer(context),
                TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: _values.VerifyCode,
                    )),
              ],
            ),
            actions: verifyDialogActions(verificationId, _auth),
          );
        });
  }

  CircularCountDownTimer verifyDialogCountDownTimer(BuildContext context) {
    return CircularCountDownTimer(
      duration: _verifyDuration,
      width: MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).size.height / 4,
      color: Colors.white,
      fillColor: Colors.red,
      backgroundColor: Colors.blue,
      strokeWidth: 5.0,
      textStyle: TextStyle(
          fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.bold),
      isReverse: true,
      isReverseAnimation: true,
      isTimerTextShown: true,
      onComplete: () {},
    );
  }

  List<Widget> verifyDialogActions(String verificationId, FirebaseAuth _auth) {
    return [
      FlatButton(
          child: Text(_values.Confirm),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            _verificationClick(verificationId, _auth);
          })
    ];
  }

  _verificationClick(String verificationId, FirebaseAuth _auth) async {
    _didVeriftFinish = true;
    final code = _codeController.text.trim();
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: code);
    var result = await _auth.signInWithCredential(credential);

    User user = result.user;
    if (user != null) {
      MyUserModel.CurrentUserId = user.uid;
      _navigatorService.navigateTo(UserRegisterPage(user: user),
          isRemoveUntil: true);
    } else {
      print(_values.VerificationCodeError);
    }
  }

  String _checkPhoneValid(String value) {
    if (value.isEmpty || value.length != 10) {
      return _values.ValPhoNumChar;
    }
    return null;
  }
  
}

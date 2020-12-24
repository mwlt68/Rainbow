import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rainbow/Views/rainbow_main.dart';
import 'package:rainbow/Views/user_register_page.dart';
import 'package:rainbow/common/dialogs/my_dialogs.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rainbow/core/locator.dart';
import 'package:rainbow/core/services/navigator_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final   NavigatorService _navigatorService= getIt<NavigatorService>();

  final int _verifyDuration = 60;
  bool _didVeriftFinish = true;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _codeController = TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  String countryCode = DefaultData.InitialCountryCode;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          DefaultData.VerifyTitle,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(child: getLoginWidget(context)),
    );
  }

  Widget getLoginWidget(context) {
    return ListView(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
          child: Text(
            DefaultData.VerifyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).primaryColor)),
          child: CountryCodePicker(
            onChanged: (CountryCode code) {
              countryCode = code.dialCode.toString();
            },
            initialSelection: DefaultData.InitialCountryCode,
            favorite: ['+1'],
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
          ),
        ),
        Container(
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
                  child: TextFormField(
                      controller: _phoneController,
                      validator: (value) {
                        if (value.isEmpty || value.length != 10) {
                          return DefaultData.ValPhoNumChar;
                        }
                        return null;
                      },
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
                        labelText: DefaultData.PhoneNumber,
                      )),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _takeCodeClick();
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _takeCodeClick() {
    FocusManager.instance.primaryFocus.unfocus();
    if (_formKey.currentState.validate()) {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Sending Phone Code')));
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
            _navigatorService.navigateTo( RainbowMain(
                          user: user,
                        ));
          } else {
            print("object");
          }
        },
        verificationFailed: (FirebaseAuthException exception) {
          _scaffoldKey.currentState.hideCurrentSnackBar();
          showErrorDialog(context,
              title: "Invalid Phone Number",
              message:
                  "You may selected wrong country code or entered wrong number !");
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
//                  title: Text("Give the code?"),
                  content: Column(
                    children: <Widget>[
                      CircularCountDownTimer(
                        duration: _verifyDuration,
                        width: MediaQuery.of(context).size.width / 4,
                        height: MediaQuery.of(context).size.height / 4,
                        color: Colors.white,
                        fillColor: Colors.red,
                        backgroundColor: Colors.blue,
                        strokeWidth: 5.0,
                        textStyle: TextStyle(
                            fontSize: 22.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        isReverse: true,
                        isReverseAnimation: true,
                        isTimerTextShown: true,
                        onComplete: () {},
                      ),
                      TextField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: "Verify Code",
                          )),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                        child: Text("Confirm"),
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: () async {
                          _didVeriftFinish = true;
                          final code = _codeController.text.trim();
                          AuthCredential credential =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: code);
                          var result =
                              await _auth.signInWithCredential(credential);

                          User user = result.user;
                          if (user != null) {
                                    _navigatorService.navigateTo(UserRegisterPage(user: user),isRemoveUntil: true);
                          } else {
                            print("Verify code error");
                          }
                        })
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (_didVeriftFinish) {
            _scaffoldKey.currentState.hideCurrentSnackBar();
            Navigator.of(context).pop();
          }
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

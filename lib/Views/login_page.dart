import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rainbow/Views/rainbow_main.dart';
import 'package:rainbow/core/default_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
class LoginPage extends StatelessWidget {
  final _codeController = TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  String countryCode="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          DefaultData.VerifyTitle,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:      Center(
          child: ListView(
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
              padding:
                  EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor)),
            child: CountryCodePicker(
              onChanged: (CountryCode code){ countryCode=code.dialCode.toString();},
              initialSelection: 'TR',
              favorite: ['USA'],
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
                  padding: const EdgeInsets.only(left:15,right:15,bottom: 5),
                  child: Icon(Icons.phone,size: 40,),
                ),
                Expanded(
                  child: TextFormField(
                      controller: _phoneController,
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
                Container(
                  margin: EdgeInsets.only(left: 15,right:15),
                  child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        String phoneNumber=countryCode+_phoneController.text.toString();
                        print(phoneNumber);
                        loginUser(phoneNumber,context);
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
      )),
    );
  }
  Future<bool> loginUser(String phone, BuildContext context) async{

    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async{
          Navigator.of(context).pop();

          var  result = await _auth.signInWithCredential(credential);

          User user = result.user;

          if(user != null){
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => RainbowMain()
            ));
          }else{
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (FirebaseAuthException exception){
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]){
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Give the code?"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _codeController,
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Confirm"),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () async{
                      final code = _codeController.text.trim();
                      AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);

                      var  result = await _auth.signInWithCredential(credential);

                      User user = result.user;

                      if(user != null){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => RainbowMain()
                        ));
                      }else{
                        print("Error");
                      }
                    },
                  )
                ],
              );
            }
          );
        },
        codeAutoRetrievalTimeout: (String verificationId){}
    );
  }
}

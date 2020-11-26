import 'package:firebase_auth/firebase_auth.dart';

class MyAuth {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  static Future<User>  getCurrentUser() async {
    User user =  _firebaseAuth.currentUser;
    return user;
  }

  static Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

}
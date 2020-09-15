import 'package:chatty/model/users.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Users _usersFromFirebaseUser(User user){
    return user !=null ? Users(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<Users> get userAuthChangeStream {
    return _auth.authStateChanges().map(_usersFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      return _usersFromFirebaseUser(user);
    }catch(e){
      print("sign in error $e");
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User firebaseUser = result.user;
      return _usersFromFirebaseUser(firebaseUser);
    }catch(e){
      print(e);
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e);
    }
  }

  // Future<User> signInWithGoogle(BuildContext context) async {
//   //   final GoogleAuthCredential _googleSignIn = new GoogleAuthCredential();
//   //
//   //   final GoogleSignInAccount googleSignInAccount =
//   //   await _googleSignIn.signIn();
//   //   final GoogleSignInAuthentication googleSignInAuthentication =
//   //   await googleSignInAccount.authentication;
//   //
//   //   final AuthCredential credential = GoogleAuthProvider.getCredential(
//   //       idToken: googleSignInAuthentication.idToken,
//   //       accessToken: googleSignInAuthentication.accessToken);
//   //
//   //   AuthResult result = await _auth.signInWithCredential(credential);
//   //   FirebaseUser userDetails = result.user;
//   //
//   //   if (result == null) {
//   //   } else {
//   //     Navigator.push(context, MaterialPageRoute(builder: (context) => Chat()));
//   //   }
//   // }
//   //
//   // Future signUpWithEmailAndPassword(String email, String password) async {
//   //   try {
//   //     AuthResult result = await _auth.createUserWithEmailAndPassword(
//   //         email: email, password: password);
//   //     FirebaseUser user = result.user;
//   //     return _userFromFirebaseUser(user);
//   //   } catch (e) {
//   //     print(e.toString());
//   //     return null;
//   //   }
//   // }

}
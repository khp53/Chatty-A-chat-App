import 'package:chatty/screens/chat_room_screen.dart';
import 'package:chatty/services/auth.dart';
import 'package:chatty/services/database.dart';
import 'package:chatty/widgets/widget.dart';
import 'package:chatty/wrapper/state_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  const SignIn({Key key, this.toggle}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final String googleIcon = 'assets/google.svg';

  AuthMethods authMethods = AuthMethods();
  Database database = Database();

  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  
  QuerySnapshot snapshotUserInfo;

  signIn() async {
    if(formKey.currentState.validate()) {

      setState(() {
        isLoading = true;
      });

      await authMethods
          .signInWithEmailAndPassword(
          emailTextEditingController.text, passwordTextEditingController.text)
          .then((result) async {
        if (result != null)  {
          QuerySnapshot userInfoSnapshot =
          await database.getUsersByEmail(emailTextEditingController.text);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.docs[0].data()["name"]);
          HelperFunctions.saveUserEmailSharedPreference(
              userInfoSnapshot.docs[0].data()["email"]);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        } else {
          setState(() {
            isLoading = false;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Color(0xff121212),
                    title: Text("Oops!", style: textStyle(23),),
                    content: Text("Invalid Email or Password! Enter correct Email & Password and try again!",
                      style: textStyle(16),
                    ),
                    actions: [
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(builder: (context) => MyApp()),
                          );
                        },
                      )
                    ],
                  );
                });
          });
        }
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading ? Container(
          child: Center(child: loading())
      ) : SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 50,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (val){
                          return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val)
                              ? null : "Provide a valid email";
                        },
                        controller: emailTextEditingController,
                        style: textStyle(16),
                        decoration: textInputDecoration("Email"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (val){
                          return val.length > 6 ? null : "Password should be 6+ chars";
                        },
                        controller: passwordTextEditingController,
                        obscureText: true,
                        style: textStyle(16),
                        decoration: textInputDecoration("Password"),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: (){
                          authMethods.resetPassword(FirebaseAuth.instance.currentUser.email);
                        },
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            "Forgot Password?",
                            style: textStyle(17),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: (){
                          signIn();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: buttonSignInUP(),
                          child: Text(
                            "Sign In",
                            style: textStyle(17),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: buttonGSignInUP(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(googleIcon),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Sign In With Google",
                              style: TextStyle(
                                fontFamily: "ProductSans",
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don\'t have an account? ",
                            style: textStyle(17),
                          ),
                          GestureDetector(
                            onTap: (){
                              widget.toggle();
                            },
                            child: Text(
                              "Register Now!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "ProductSans",
                                  fontSize: 17,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

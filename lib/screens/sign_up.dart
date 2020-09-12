import 'package:chatty/services/auth.dart';
import 'package:chatty/services/database.dart';
import 'package:chatty/widgets/widget.dart';
import 'package:chatty/wrapper/state_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'chat_room_screen.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  const SignUp({Key key, this.toggle}) : super(key: key);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  AuthMethods authMethods = AuthMethods();
  Database database = Database();

  final String googleIcon = 'assets/google.svg';
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  signUp() {
    if(formKey.currentState.validate()) {

      setState(() {
        isLoading = true;
      });

      authMethods.signUpWithEmailAndPassword(emailTextEditingController.text, passwordTextEditingController.text)
          .then((val){
            if (val != null){
              Map<String, String> userInfoMap = {
                "name" : userNameTextEditingController.text,
                "email" : emailTextEditingController.text,
              };
              database.uploadUserInfo(userInfoMap);

              HelperFunctions.saveUserLoggedInSharedPreference(true);
              HelperFunctions.saveUserNameSharedPreference(userNameTextEditingController.text);
              HelperFunctions.saveUserEmailSharedPreference(emailTextEditingController.text);
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => ChatRoom()
              ));
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
                          return val.isEmpty || val.length < 4 ? "Username should be at least 4 chars" : null;
                        },
                        controller: userNameTextEditingController,
                        style: textStyle(16),
                        decoration: textInputDecoration("Username"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
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
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "Forgot Password?",
                          style: textStyle(17),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: (){
                          signUp();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: buttonSignInUP(),
                          child: Text(
                            "Sign Up",
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
                              "Sign Up With Google",
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
                            "Already have an account? ",
                            style: textStyle(17),
                          ),
                          GestureDetector(
                            onTap: (){
                              widget.toggle();
                            },
                            child: Text(
                              "Sign In Now!",
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
                        height: 50,
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

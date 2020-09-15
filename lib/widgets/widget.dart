import 'package:chatty/main.dart';
import 'package:chatty/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AuthMethods _authMethods = AuthMethods();

Widget appBarMain(BuildContext context){
  return AppBar(
    centerTitle: true,
    elevation: 0,
    title: Text(
      "Chatty!",
      style: TextStyle(
        letterSpacing: 2,
        fontFamily: "Athene",
        color: Colors.white,
      ),
    ),
  );
}

Widget appBarChat(BuildContext context){
  return AppBar(
    centerTitle: true,
    elevation: 0,
    title: Text(
      "Chatty!",
      style: TextStyle(
        letterSpacing: 2,
        fontFamily: "Athene",
        color: Colors.white,
      ),
    ),
    actions: [
      GestureDetector(
        onTap: (){
          _authMethods.signOut();
          Navigator.pushReplacement(context, CupertinoPageRoute(
              builder: (context) => MyApp()
          ));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Icon(
            Icons.exit_to_app,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

InputDecoration textInputDecoration(String labelText){
  return InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white)
      ),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54)
      ),
    labelText: labelText,
    labelStyle: TextStyle(
      color: Colors.white54,
    ),
  );
}

InputDecoration textInputDecorationProfile(String text){
  return InputDecoration(
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white)
    ),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white54)
    ),
    hintText: text,
    hintStyle: TextStyle(
      color: Colors.white54,
    ),
  );
}

TextStyle textStyle(double fs){
  return TextStyle(
    color: Colors.white,
    fontFamily: "ProductSans",
    fontSize: fs,
  );
}

TextStyle textStyleTime(double fs){
  return TextStyle(
    color: Colors.white54,
    fontFamily: "ProductSans",
    fontSize: fs,
  );
}

BoxDecoration buttonSignInUP(){
  return BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xff5600E8),
        Color(0xff6200EE),
      ]
    ),
    borderRadius: BorderRadius.circular(5),
  );
}

BoxDecoration buttonGSignInUP(){
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(5),
  );
}

CircularProgressIndicator loading(){
  return CircularProgressIndicator(
    strokeWidth: 5,
  );
}
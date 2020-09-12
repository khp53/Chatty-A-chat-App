import 'package:chatty/screens/search.dart';
import 'package:chatty/services/auth.dart';
import 'package:chatty/widgets/widget.dart';
import 'package:chatty/wrapper/constants.dart';
import 'package:chatty/wrapper/state_management.dart';
import 'package:chatty/wrapper/wrapper.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

import '../main.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FlareControls controls = FlareControls();
  AuthMethods _authMethods = AuthMethods();

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => Wrapper()
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff5600E8),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => SearchScreen()
          ));
        },
        child: FlareActor(
            "assets/Search1.flr",
            alignment:Alignment.center,
            fit:BoxFit.scaleDown,
            animation:"Search",
            controller: controls,
        ),
      ),
    );
  }
}

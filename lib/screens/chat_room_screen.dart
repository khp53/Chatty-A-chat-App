import 'package:chatty/screens/conversation_screen.dart';
import 'package:chatty/screens/profile.dart';
import 'package:chatty/screens/search.dart';
import 'package:chatty/services/auth.dart';
import 'package:chatty/services/database.dart';
import 'package:chatty/widgets/widget.dart';
import 'package:chatty/wrapper/constants.dart';
import 'package:chatty/wrapper/state_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../main.dart';

class ChatRoom extends StatefulWidget {
  final String img;
  ChatRoom({this.img});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FlareControls controls = FlareControls();
  AuthMethods _authMethods = AuthMethods();
  Database database = Database();
  
  Stream chatRoomStream;
  Stream profileStream;

  @override
  void initState() {
    getUserInfo();
    getUserProfileInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myImg = await HelperFunctions.getUserImgSharedPreference();
    database.getChatRooms(Constants.myName, Constants.myImg).then((value){
      setState(() {
        chatRoomStream = value;
      });
    });
  }

  getUserProfileInfo() async {
    database.getUserProfile().then((value){
      setState(() {
        profileStream = value;
      });
    });
  }
  
  Widget chatRoomList(){
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index){
                  return ChatRoomHomeTiles(
                      userName: snapshot.data.docs[index].data()["chatRoomId"]
                    .toString().replaceAll("_", "")
                    .replaceAll(Constants.myName, ""),
                      chatRoomId: snapshot.data.docs[index].data()["chatRoomId"],
                    img: Constants.myImg == snapshot.data.docs[index].data()["img"] ? snapshot.data.docs[index].data()["img2"] : snapshot.data.docs[index].data()["img"],
                    img2: snapshot.data.docs[index].data()["img2"],
                  );
          }
        ) : Center(child: loading());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
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
            StreamBuilder(
              stream: profileStream,
              builder: (context, snapshot) {
                return snapshot.hasData ? GestureDetector(
                  onTap: (){
                    bottomSheet(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(snapshot.data.data()["img"]),
                      backgroundColor: Colors.grey[900],
                    )
                  )
                ) : GestureDetector(
                    onTap: (){
                      bottomSheet(context);
                    },
                    child: Center(child: loading(),)
                );
              }
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff5600E8),
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(
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
      body: chatRoomList(),
    );
  }

  dynamic bottomSheet(BuildContext context){
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (context, scrollController) => Container(
        color: Color(0xFF3A3A3A),
        height: MediaQuery.of(context).size.height /4,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: FlatButton.icon(
                  icon: Icon(Icons.exit_to_app, color: Colors.white, size: 25,),
                  label: Text("Log Out", style: textStyle(20)),
                  onPressed: (){
                    HelperFunctions.saveUserLoggedInSharedPreference(false);
                    _authMethods.signOut();
                    Navigator.pushReplacement(context, CupertinoPageRoute(
                        builder: (context) => MyApp()
                    ));
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: FlatButton.icon(
                  icon: Icon(Icons.people, color: Colors.white, size: 25,),
                  label: Text("View Profile" ,style: textStyle(20),),
                  onPressed: (){
                    Navigator.push(context, CupertinoPageRoute(
                        builder: (context) => Profile()
                    ));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class ChatRoomHomeTiles extends StatefulWidget {
  final String userName;
  final String chatRoomId;
  final String img;
  final String img2;
  ChatRoomHomeTiles({Key key, this.userName,this.chatRoomId, this.img, this.img2}) : super(key: key);

  @override
  _ChatRoomHomeTilesState createState() => _ChatRoomHomeTilesState();
}

class _ChatRoomHomeTilesState extends State<ChatRoomHomeTiles> {

  // Widget profileImg(){
  //   return StreamBuilder(
  //     stream: FirebaseFirestore.instance.collection("users")
  //         .doc(FirebaseAuth.instance.currentUser.uid)
  //         .snapshots(),
  //     builder: (context, snapshot){
  //       return widget.profileImage = snapshot.data.data()["img"];
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: GestureDetector(
            onTap: (){
              Navigator.push(context, CupertinoPageRoute(
                builder: (context) => ConversationScreen(chatRoomId: widget.chatRoomId, userName: widget.userName, img: widget.img, img2: widget.img2,)
              ));
            },
            child: Card(
              elevation: 0,
              color: Color(0xff222222),
              child: Padding(
                padding: const EdgeInsets.all(10),
                 child: ListTile(
                   title: Text(
                        widget.userName,
                        style: textStyle(20),
                      ),
                   leading: CircleAvatar(
                         backgroundColor: Colors.grey[900],
                         backgroundImage: NetworkImage(widget.img),
                       ),
                 ),
              ),
            ),
          ),
        );
        } else {
          return Container();
        }
      }
    );
  }
}
// NetworkImage(img)


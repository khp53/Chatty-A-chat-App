import 'package:chatty/services/database.dart';
import 'package:chatty/widgets/widget.dart';
import 'package:chatty/wrapper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final String img;
  final String img2;
  ConversationScreen({this.chatRoomId,this.userName,this.img, this.img2});
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  Database database = Database();
  TextEditingController messageEditingController = TextEditingController();

  Stream<QuerySnapshot> chattyStream;

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chattyStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
            reverse: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index){
              return ChatTile(
                  message: snapshot.data.docs[index].data()["message"],
                  sendByMe: snapshot.data.docs[index].data()["sendBy"] == Constants.myName,
                time: DateFormat.MMMd().add_jm().format(DateTime.parse(snapshot.data.docs[index].data()['time'].toDate().toString())
              ));
            }
        ) : Container();
      },
    );
  }


  sendMessage(){
    if (messageEditingController.text.isNotEmpty){
      Map<String, dynamic> messageMap = {
        "message" : messageEditingController.text,
        "sendBy" : Constants.myName,
        "time" : DateTime.now()
      };
      database.addConversationMessage(widget.chatRoomId, messageMap);
    }
  }

  @override
  void initState() {
    database.getConversationMessage(widget.chatRoomId).then((value){
      setState(() {
        chattyStream = value;
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey[900],
              backgroundImage: widget.img == Constants.myImg ? NetworkImage(widget.img2) : NetworkImage(widget.img),
            ),
            SizedBox(width: 8,),
            Text(
              widget.userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "ProductSans",
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(flex: 6, child: chatMessageList()),
            Expanded(
              child: Container(
                // alignment: Alignment.bottomCenter,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 3),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          textInputAction: TextInputAction.send,
                          onEditingComplete: (){
                            sendMessage();
                            messageEditingController.clear();
                          },
                          textAlignVertical: TextAlignVertical.center,
                          controller: messageEditingController,
                          style: textStyle(18),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xff121212),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54)
                            ),
                            hintText: "Type a message...",
                            hintStyle: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          height: 63,
                          decoration: BoxDecoration(
                            color: Color(0xff222222),
                            border: Border.all(color: Colors.white54),
                            borderRadius: BorderRadius.circular(5),
                            ),
                          child: IconButton(
                            icon: Icon(Icons.send, color: Color(0xffffffff)),
                            onPressed: (){
                              sendMessage();
                              messageEditingController.clear();
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String time;
  const ChatTile({Key key, this.message, this.sendByMe, this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
              bottom: 5,
              left: sendByMe ? 0 : 20,
              right: sendByMe ? 20 : 0),
          width: MediaQuery.of(context).size.width,
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: sendByMe
                ? EdgeInsets.only(left: 80)
                : EdgeInsets.only(right: 80),
            padding: EdgeInsets.only(
                top: 10, bottom: 10, left: 25, right: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: sendByMe ? [
                    const Color(0xff5600E8),
                    const Color(0xff6F17C8)
                  ]
                      : [
                    const Color(0xff464646),
                    const Color(0xff464646)
                  ],
              ),
                borderRadius: sendByMe ? BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ) : BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )
            ),
            child: Text(message , style: textStyle(18),),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              bottom: 5,
              left: sendByMe ? 0 : 22,
              right: sendByMe ? 22 : 0),
          width: MediaQuery.of(context).size.width,
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: sendByMe
                ? EdgeInsets.only(left: 50)
                : EdgeInsets.only(right: 50),
            padding: EdgeInsets.only(
                top: 0, bottom: 10, left: 1, right: 3),
            child: Text(time , style: textStyleTime(10),),
          ),
        ),
      ],
    );
  }
}


import 'package:chatty/screens/conversation_screen.dart';
import 'package:chatty/services/database.dart';
import 'package:chatty/widgets/widget.dart';
import 'package:chatty/wrapper/constants.dart';
import 'package:chatty/wrapper/state_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenScreenState createState() => _SearchScreenScreenState();
}

class _SearchScreenScreenState extends State<SearchScreen> {

  TextEditingController searchController = TextEditingController();
  Database database = Database();
  QuerySnapshot searchSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      await database
          .getUsersByUsername(searchController.text)
          .then((val) {
        searchSnapshot = val;
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget searchList(){
    return searchSnapshot != null ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapshot.docs.length,
      itemBuilder: (context, index){
        return searchTile(
          searchSnapshot.docs[index].data()["img"],
          searchSnapshot.docs[index].data()["img2"],
          searchSnapshot.docs[index].data()["name"],
          searchSnapshot.docs[index].data()["email"],
        );
      },
    ) : Center(child: Text("Searched Users Will Show Here", style: textStyle(16),));
  }

  createChatRoomAndStartChat(String userName, String img, String img2){

      List<String> users = [Constants.myName, userName];
      String chatRoomId = getChatRoomId(Constants.myName, userName);

      Map<String, dynamic> chatRoomMap = {
        "users" : users,
        "chatRoomId" : chatRoomId,
        "img" : img,
        "img2" : Constants.myImg,
      };
      database.createChatRoom(chatRoomMap, chatRoomId);
      Navigator.push(context, CupertinoPageRoute(
          builder: (context) => ConversationScreen(chatRoomId: chatRoomId, userName: userName, img: img, img2: img2)
      ));

  }


  Widget searchTile(String img, String img2, String userName, String userEmail){
    return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 20),
          color: Color(0xff222222),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(img),
                backgroundColor: Colors.grey[900],
              ),
              title: Text(userName, style: textStyle(17),),
              subtitle: Text(userEmail, style: textStyle(12),),
              trailing: GestureDetector(
                onTap: (){
                  if (userName != Constants.myName){
                    createChatRoomAndStartChat(userName, img, img2);
                  }else{
                    return showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: Text("Opps!", style: textStyle(20),),
                            content: Text("You cannot send message to yourself!", style: textStyle(16),),
                            actions: [
                              FlatButton(
                                child: Text("Close"),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        }
                    );
                  }
                  searchController.clear();
                },
                child: Container(
                  decoration: buttonSignInUP(),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Chat!", style: textStyle(16),),
                ),
              ),
            ),
          ),
        ),
    );
  }

  getChatRoomId(String a, String b) {
    if(a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }
  // (a.compareTo(b)>0)


  @override
  void initState() {
    getUserInfo();
    super.initState();
  }
  getUserInfo() async{
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myImg = await HelperFunctions.getUserImgSharedPreference();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              child: TextFormField(
                textInputAction: TextInputAction.search,
                onEditingComplete: (){
                  initiateSearch();
                },
                controller: searchController,
                style: textStyle(16),
                decoration: InputDecoration(
                  suffixIcon: Container(
                    width: MediaQuery.of(context).size.width / 6,
                    height: MediaQuery.of(context).size.height / 12.5,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                      color: Color(0xFF222222),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(2),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(2),
                      )
                    ),
                    child: IconButton(
                        onPressed: (){
                          initiateSearch();
                        },
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54)
                  ),
                  hintText: "Search any user...",
                  hintStyle: TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            searchList(),
          ],
        ),
      ),
    );
  }
}



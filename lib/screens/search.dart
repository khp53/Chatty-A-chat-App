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

  createChatRoomAndStartChat(String userName){
    if (userName != Constants.myName){
      String chatRoomId = getChatRoomId(userName, Constants.myName);
      List<String> users = [userName, Constants.myName];

      Map<String, dynamic> chatRoomMap = {
        "users" : users,
        "chatRoomId" : chatRoomId,
      };
      database.createChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ConversationScreen()
      ));
    }else{
      return null;
    }
  }

  
  Widget searchList(){
    return searchSnapshot != null ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapshot.docs.length,
      itemBuilder: (context, index){
        return searchTile(
          searchSnapshot.docs[index].data()["name"],
          searchSnapshot.docs[index].data()["email"],
        );
      },
    ) : Center(child: Text("Searched Users Will Show Here", style: textStyle(16),));
  }

  Widget searchTile(String userName, String userEmail){
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20),
      color: Color(0xff222222),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: textStyle(17),),
                  SizedBox(height: 5,),
                  Text(userEmail, style: textStyle(12),),
                ],
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                createChatRoomAndStartChat(userName);
              },
              child: Container(
                decoration: buttonSignInUP(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Chat!", style: textStyle(16),),
              ),
            )
          ],
        ),
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if(a.compareTo(b)>0) {
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
                controller: searchController,
                style: textStyle(16),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: (){
                      initiateSearch();
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.white54,
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



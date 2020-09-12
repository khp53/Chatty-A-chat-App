import 'package:cloud_firestore/cloud_firestore.dart';

class Database{
  Future getUsersByUsername(String name) async{
    return await FirebaseFirestore.instance.collection("users")
        .where("name", isEqualTo: name).get();
  }

  Future getUsersByEmail(String email) async{
    return await FirebaseFirestore.instance.collection("users")
        .where("email", isEqualTo: email).get();
  }

  uploadUserInfo(userMap){
    FirebaseFirestore.instance.collection("users").add(userMap);
  }

  createChatRoom(chatRoomId, chatRoomMap) async {
    return await FirebaseFirestore.instance.collection("ChatRoom")
        .doc(chatRoomId).set(chatRoomMap).catchError((e){
          print(e);
    });
  }
}
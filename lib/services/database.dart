import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Database{
  Future getUsersByUsername(String name) async{
    return await FirebaseFirestore.instance.collection("users")
        .where("name", isEqualTo: name).get();
  }

  Future getUsersByEmail(String email) async{
    return await FirebaseFirestore.instance.collection("users")
        .where("email", isEqualTo: email).get();
  }

  Future uploadUserInfo(userMap) async{
    return await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid).set(userMap);
  }

  Future createChatRoom(chatRoomMap,chatRoomId) async {
    return await FirebaseFirestore.instance.collection("ChatRoom")
        .doc(chatRoomId).set(chatRoomMap).catchError((e){
          print(e);
    });
  }

  Future addConversationMessage(String chatRoomId, messageMap) async{
    return await FirebaseFirestore.instance.collection("ChatRoom")
        .doc(chatRoomId).collection("chats").add(messageMap).catchError((e){
      print(e);
    });
  }

  Future getConversationMessage(String chatRoomId) async{
    return FirebaseFirestore.instance.collection("ChatRoom")
        .doc(chatRoomId).collection("chats").orderBy("time",descending: true).snapshots();
  }

  getChatRooms (String userName, String img) async{
    return FirebaseFirestore.instance.collection("ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }

  getUserProfile () async{
    return FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots();
  }

  Future<void> updateProfile(Map data) async {
    return FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update(data);
  }

  uploadUserImage(File img) async{
    return await FirebaseStorage.instance.ref().child("user_image")
        .child(FirebaseAuth.instance.currentUser.email + '.jpg')
        .putFile(img).onComplete;
  }

}
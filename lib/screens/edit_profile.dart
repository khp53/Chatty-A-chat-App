import 'dart:io';
import 'package:chatty/services/auth.dart';
import 'package:chatty/services/database.dart';
import 'package:chatty/widgets/widget.dart';
import 'package:chatty/wrapper/state_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  Database database = Database();
  Stream profileStream;
  bool isLoading = false;
  AuthMethods authMethods = AuthMethods();

  @override
  void initState() {
    getUserProfileInfo();
    super.initState();
  }

  getUserProfileInfo() async {
    database.getUserProfile().then((value){
      setState(() {
        profileStream = value;
      });
    });
  }

  File _image;
  final picker = ImagePicker();


  Future getImage() async{
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        _image = File(pickedFile.path);
      });
  }


  updateProfile(url) async{

      Map<String, String> data = {
        "img" : url,
      };
      database.updateProfile(data);

  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(child: loading(),)
    : Scaffold(
      appBar: appBarMain(context),
      body: StreamBuilder(
        stream: profileStream,
        builder: (context, snapshot) {
          return snapshot.hasData ? Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'pic',
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: _image != null ? FileImage(_image) : NetworkImage(snapshot.data.data()["img"]),
                            backgroundColor: Colors.cyan,
                            child: IconButton(onPressed: (){getImage();}, icon: Icon(Icons.edit, color: Colors.white,)),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          readOnly: true,
                          decoration: textInputDecorationProfile(snapshot.data.data()["name"]),
                          validator: (val){
                            return val.isEmpty || val.length < 4 ? "Username should be at least 4 chars" : null;
                          },
                          controller: userNameTextEditingController,
                          style: textStyle(16),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          readOnly: true,
                          style: textStyle(16),
                          decoration: textInputDecorationProfile(snapshot.data.data()["email"]),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: (){
                            authMethods.resetPassword(FirebaseAuth.instance.currentUser.email);
                            Scaffold.of(context)
                                .showSnackBar(
                                SnackBar(
                                  content: Text("Password Reset link has been sent to your email!"),
                                )
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              "Update Password?",
                              style: textStyle(17),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Hero(
                          tag: 'edit',
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: Colors.white
                                ),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: FlatButton.icon(
                              onPressed: () async {
                                if (_image != null){
                                  await database.uploadUserImage(_image);
                                  final ref = FirebaseStorage.instance.ref().child(
                                      "user_image")
                                      .child(
                                      FirebaseAuth.instance.currentUser.email + '.jpg');
                                  final url = await ref.getDownloadURL();
                                  HelperFunctions.saveUserImgSharedPreference(url);
                                  updateProfile(url);
                                  userNameTextEditingController.clear();
                                  Scaffold.of(context)
                                      .showSnackBar(
                                      SnackBar(
                                        content: Text("Profile Updated"),
                                      )
                                  );
                                }else{
                                  Scaffold.of(context)
                                      .showSnackBar(
                                      SnackBar(
                                        content: Text("You have to select an image"),
                                      )
                                  );
                                }
                              },
                              icon: Icon(Icons.update, color: Colors.white, size: 20,),
                              label: Text("Edit Profile" ,style: textStyle(15),),),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ) : Center(child: loading());
        }
      ),
    );
  }
}

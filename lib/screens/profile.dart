import 'package:chatty/screens/edit_profile.dart';
import 'package:chatty/services/database.dart';
import 'package:chatty/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String name;
  final String email;

  const Profile({Key key, this.name, this.email}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Database database = Database();
  Stream profileStream;

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

  Widget profileList(){
    return StreamBuilder(
      stream: profileStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ProfileTiles(
                name: snapshot.data.data()["name"],
                email: snapshot.data.data()["email"],
                img: snapshot.data.data()["img"],
              ) : Center(child: loading());
            }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: profileList()
    );
  }
}

class ProfileTiles extends StatelessWidget {
  final String name;
  final String email;
  final String img;

  const ProfileTiles({Key key, this.name, this.email, this.img}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'pic',
              child: CircleAvatar(
                backgroundColor: Colors.grey[900],
                backgroundImage: NetworkImage('$img'),
                radius: 60,
              )
            ),
            SizedBox(height: 20,),
            Text(
              "Name: $name",
              textAlign: TextAlign.left,
              style: textStyle(20),
            ),
            SizedBox(height: 10,),
            Text(
              "Email:  $email",
              textAlign: TextAlign.left,
              style: textStyle(20),
            ),
            SizedBox(height: 30,),
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
                  onPressed: (){
                    Navigator.push(context, CupertinoPageRoute(
                      builder: (context) => EditProfile()
                    ));
                  },
                  icon: Icon(Icons.edit, color: Colors.white, size: 20,),
                  label: Text("Edit Profile" ,style: textStyle(15),),),
              ),
            )
          ],
        ),
      ),
    );
  }
}


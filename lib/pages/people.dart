import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

import 'dashboard.dart';

class People extends StatefulWidget {
  const People({Key? key}) : super(key: key);

  @override
  _PeopleState createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  List allUsers=[];
  bool isLoading=true;
  var likes;
  bool isBlogLike=false;
  @override
  void initState() {
    getWholeBlogs();
    super.initState();
  }
  getWholeBlogs()async{
    dynamic sessionUid= await FlutterSession().get("userId");
    await get(Uri.parse("https://blogger-mobile.herokuapp.com/get-all-unfollow/$sessionUid"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        }
    ).then((result) => {
      setState((){
        allUsers=jsonDecode(result.body);
      })
    });
    print("all blogs on dash are $allUsers");
    setState(() {
      allUsers=allUsers;
      isLoading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('People'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading ?SpinKitFadingCircle(color: Colors.blueAccent[400],size: 70.0,)
          :SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            child: ListView.builder(
                primary: false,
                reverse: true,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: allUsers.length,
                itemBuilder: (BuildContext context, int index){
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10,10,10,10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                                allUsers[index]["profilePic"] == null ?  CircleAvatar(backgroundImage: AssetImage('assets/nodp.png'),): CircleAvatar(backgroundImage: FileImage(File(allUsers[index]["profilePic"])),radius: 20,),
                                // Expanded(flex:4 , child: Text(allUsers[index]["fullName"].toString(),style: TextStyle(fontSize: 18))),

                                Expanded(flex:4 , child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Text(allUsers[index]["fullName"].toString(),style: TextStyle(fontSize: 18)),
                                )),

                                  Expanded(flex:4 , child: Text(allUsers[index]["companyName"].toString(),style: TextStyle(fontSize: 15))),

                                  ElevatedButton(
                                    onPressed: () {
                                      followUser(allUsers[index]["userId"]);
                                    },
                                  child: Text("Follow",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w800,color:Colors.white),),),

                            // Divider( color: Colors.grey[800],),
                          ]
                      ),
                    ),
                  );

                }
            ),

          )
      ),


    );
  }
  followUser(id)async{
    dynamic sessionUid= await FlutterSession().get("userId");
    await post(Uri.parse(
        "https://blogger-mobile.herokuapp.com/follow"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: jsonEncode({
          "user1": {
            "userId": sessionUid
          },
          "user2": {
            "userId": id
          },
        })
    ).then((result)=>{
      print("result"),
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(
          builder: (context) => Dashboard()),
          ModalRoute.withName("/dashboard")
      )
    });
  }
}

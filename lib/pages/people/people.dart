import 'dart:convert';
import 'dart:io';
import 'package:bloggers/utils/apis.dart';
import 'package:bloggers/utils/local.dart';
import 'package:bloggers/utils/styles/fonts.dart';
import 'package:bloggers/utils/styles/icons.dart';
import 'package:bloggers/utils/styles/sizes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/dashboard.dart';

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
  String currentUser='';
  late SharedPreferences loginData;
  @override
  void initState() {
    getAllPeople();
    super.initState();
  }
  getAllPeople()async{
    //By passing logged in userId take all un follow users
    loginData = await SharedPreferences.getInstance();
    currentUser = loginData.getString('userId');
    // dynamic sessionUid= await FlutterSession().get("userId");
    await get(Uri.parse("$peopleApi/$currentUser"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        }
    ).then((result) => {
      setState((){
        allUsers=jsonDecode(result.body);
      })
    });
    setState(() {
      allUsers=allUsers;
      isLoading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Text('People',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle,color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading ?SpinKitFadingCircle(color: Color(0xffd81b60),size: fadingCircleSize,)
          :allUsers.isEmpty ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(followedAll,height: 150,width:200),
          SizedBox(height: 30,),
          Center(child:Text("$followedAllUsers",style: TextStyle(fontSize: normalFontSize, color: Colors.white),)),
        ],
      ) :SingleChildScrollView(
          child: Container(
            color: Colors.black,
            margin: const EdgeInsets.all(10.0),
            child: ListView.builder(
                primary: false,
                reverse: true,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: allUsers.length,
                itemBuilder: (BuildContext context, int index){
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.white, width: 1),
                    ),
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10,10,10,10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                                allUsers[index]["profilePic"] == null ?  CircleAvatar(backgroundImage: AssetImage('assets/nodp.png'),): CircleAvatar(backgroundImage: FileImage(File(allUsers[index]["profilePic"])),radius: normalFontSize,),
                                // Expanded(flex:4 , child: Text(allUsers[index]["fullName"].toString(),style: TextStyle(fontSize: 18))),

                                Expanded(flex:4 , child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Text(allUsers[index]["fullName"].toString(),style: TextStyle(fontSize: 18,color: Colors.white,fontFamily: fontFamily)),
                                )),

                                  Expanded(flex:4 , child: Text(allUsers[index]["companyName"].toString(),style: TextStyle(fontSize: 15,color:Colors.white,fontFamily: fontFamily))),
                                  RaisedButton(
                                    onPressed: () {  followUser(allUsers[index]["userId"]); },
                                 textColor: Colors.black,
                                 elevation: 0,
                                 padding: const EdgeInsets.all(0.0),
                                 shape:RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(sizedHeightMinHeight)
                                 ),
                                 child: Container(
                                   decoration: const BoxDecoration(
                                       gradient: LinearGradient(
                                         colors: <Color>[
                                           Color(0xffd81b60),
                                           Color(0xffff4081),
                                         ],
                                       ),
                                       borderRadius: BorderRadius.all(Radius.circular(10.0))
                                   ),
                                   padding: const EdgeInsets.fromLTRB(23.5,10,23,10),
                                   //padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                   child: const Text(
                                       'Follow',
                                       style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white,fontFamily: 'Source Sans 3')
                                   ),
                                 ),
                                  )
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
    setState(() {
      isLoading=true;
    });
    //if click on follow button then simply add the user into logged in user list
    loginData = await SharedPreferences.getInstance();
    currentUser = loginData.getString('userId');
    // dynamic sessionUid= await FlutterSession().get("userId");
    await post(Uri.parse(
        "$doFollowApi"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: jsonEncode({
          "user1": {
            "userId": currentUser
          },
          "user2": {
            "userId": id
          },
        })
    ).then((result)=>{
      Fluttertoast.showToast(
        msg: "$followed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      ).then((value) => {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(
            builder: (context) => Dashboard()),
            ModalRoute.withName("/dashboard")
        )
      })

    });
  }
}

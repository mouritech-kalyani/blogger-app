import 'dart:convert';
import 'dart:io';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
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
  @override
  void initState() {
    getAllPeople();
    super.initState();
  }
  getAllPeople()async{
    //By passing logged in userId take all un follow users

    dynamic sessionUid= await FlutterSession().get("userId");
    await get(Uri.parse("$peopleApi/$sessionUid"),
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
      appBar: AppBar(
        title: Row(
          children: [
            Text('People',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
            IconButton(onPressed: (){}, icon: Icon(Icons.article_sharp,color: Colors.white,)),
          ],
        ),
        backgroundColor:Colors.deepOrangeAccent,
      ),
      body: isLoading ?SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: fadingCircleSize,)
          :allUsers.isEmpty ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(followedAll,height: 150,width:200),
          SizedBox(height: 30,),
          Center(child:Text("$followedAllUsers",style: TextStyle(fontSize: normalFontSize),)),
        ],
      ) :SingleChildScrollView(
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
                                allUsers[index]["profilePic"] == null ?  CircleAvatar(backgroundImage: AssetImage('assets/nodp.png'),): CircleAvatar(backgroundImage: FileImage(File(allUsers[index]["profilePic"])),radius: normalFontSize,),
                                // Expanded(flex:4 , child: Text(allUsers[index]["fullName"].toString(),style: TextStyle(fontSize: 18))),

                                Expanded(flex:4 , child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Text(allUsers[index]["fullName"].toString(),style: TextStyle(fontSize: 18)),
                                )),

                                  Expanded(flex:4 , child: Text(allUsers[index]["companyName"].toString(),style: TextStyle(fontSize: 15))),
                                  Expanded(
                                    flex:4,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        followUser(allUsers[index]["userId"]);
                                      },
                                    style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(sizedHeightMinHeight)
                                    )
                                    )
                                    ),
                                    child: Text("Follow",style: TextStyle(fontSize: blogTimeAndCompany,fontWeight: FontWeight.w800,color:Colors.white),),),
                                  ),

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
    dynamic sessionUid= await FlutterSession().get("userId");
    await post(Uri.parse(
        "$doFollowApi"),
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

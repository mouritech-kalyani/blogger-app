import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
// import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

import 'AddComments.dart';
import 'addblog.dart';
import 'dashboard.dart';

class MyBlogs extends StatefulWidget {
  MyBlogs();
  @override
  _MyBlogsState createState() => _MyBlogsState();
}

class _MyBlogsState extends State<MyBlogs> {
List userBlogs=[];
bool checkNoBlog=false;
bool isLoading=true;
var userIdFromSession;
var likes;
@override
  void initState() {
    getMyBlogs();
    super.initState();
  }
getMyBlogs()async{
  dynamic sessionUid= await FlutterSession().get("userId");
  print("user is on my blogs is $sessionUid");
  setState(() {
    userIdFromSession=sessionUid;
  });
  await get(Uri.parse("https://blogger-mobile.herokuapp.com/users/$sessionUid"),
      headers: {
      "content-type": "application/json",
      "accept": "application/json",
      }
  ).then((result) => {
    print("res of my blogs ${result.body}"),
    if(result.body.isEmpty){
      setState((){
        userBlogs= [];
      })
    }else{
      setState((){
        userBlogs=jsonDecode(result.body);
      })
    }
  });
  print("user blogs on my blog are $userBlogs");
  if(userBlogs.isEmpty){
    print("No blogs yet");
    setState(() {
      checkNoBlog=true;
      isLoading=false;
    });
  }else{
    setState(() {
      isLoading=false;
    });
    print("my blogs are  $userBlogs");
  }
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Blogs'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
          child: isLoading ? SpinKitRotatingCircle(color: Colors.blueAccent[400],size: 70.0,):
          checkNoBlog ? Center(child: Text("No Blogs Yet Please Add Your Blogs Here..",
            style:TextStyle(fontSize: 20) ,)) :
          Container(
            margin: const EdgeInsets.all(10.0),

            child: ListView.builder(
                primary: false,
                reverse: true,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: userBlogs.length,
                itemBuilder: (BuildContext context, int index){
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(flex:4 , child: Text(userBlogs[index]["blogTime"].toString(),style: TextStyle(fontSize: 18))),
                                SizedBox(width:20),
                                Expanded(flex:1, child: IconButton(icon:Icon(Icons.edit), onPressed: () { editBlog(userBlogs[index]["blogId"],userBlogs[index]["description"],userBlogs[index]["likes"]); })),
                                Expanded(flex:1,child: IconButton(icon:Icon(Icons.delete), onPressed: () { deleteBlog(userBlogs[index]["blogId"]); },),),
                              ],
                            ),
                            SizedBox(height:20),
                            Row(
                                children:<Widget>[
                                  Flexible(child: Text(userBlogs[index]["description"],style: TextStyle(fontSize: 20),overflow: TextOverflow.ellipsis,maxLines: 10,)),
                                ]
                            ),
                            SizedBox(height: 10,),
                            Row(
                                children:<Widget>[
                                  IconButton(onPressed: null, icon: Icon(Icons.favorite,color: Colors.red,size: 30,)),
                                  Text('Likes  ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                  Expanded(flex:2,child: Text(userBlogs[index]["likes"].toString(),style: TextStyle(fontSize: 20))),
                                  Text('Comments'),
                                  IconButton(icon: Icon(Icons.comment,size: 30,), onPressed: () { showComments(userBlogs[index]["blogId"]); },)

                                ]
                            ),
                          ]
                      ),
                    ),
                  );
                }
            ),

          )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> AddBlog(userId:userIdFromSession)));
            },
        child: Text("+",style: TextStyle(fontSize: 40),),
            )
            );
  }
  editBlog(blogId,description,likes){
    print("blog edited $blogId, with descripton is $description");

    Navigator.push(context, MaterialPageRoute(builder: (context) => AddBlog(userId:userIdFromSession,description:description,blogId:blogId,likes:likes)));

  }
  deleteBlog(blogId)async{
    print("blog deleted $blogId");
    await delete(Uri.parse(
        "https://blogger-mobile.herokuapp.com/blogs/$blogId"),
        headers: {
        "content-type": "application/json",
        "accept": "application/json",
        }
    ).then((value) => {
      print(value.body),
    Navigator.pushAndRemoveUntil(
    context, MaterialPageRoute(
    builder: (context) => Dashboard()),
    ModalRoute.withName("/dashboard")
    )
    });
  }
  showComments(id){
    print('selected comment id is $id');
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddComments(blogId:id)));
  }
}

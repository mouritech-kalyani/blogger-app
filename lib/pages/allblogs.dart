import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:flutter_session/flutter_session.dart';
import 'AddComments.dart';
import 'dashboard.dart';

class AllBlogs extends StatefulWidget {
  const AllBlogs({Key? key}) : super(key: key);

  @override
  _AllBlogsState createState() => _AllBlogsState();
}

class _AllBlogsState extends State<AllBlogs> {
  List allBlogs=[];
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
    await get(Uri.parse("https://blogger-mobile.herokuapp.com/blogs/$sessionUid"),
        headers: {
        "content-type": "application/json",
        "accept": "application/json",
        }
    ).then((result) => {
      setState((){
        allBlogs=jsonDecode(result.body);
      })
    });
    print("all blogs on dash are $allBlogs");
    setState(() {
      allBlogs=allBlogs;
      isLoading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All blogs'),
        backgroundColor: Colors.blueAccent,
      ),
          body: isLoading ?Center(child: SpinKitFadingCircle(color: Colors.blueAccent[400],size: 70.0))
          :allBlogs.isEmpty ? Center(child:Text("Follow the bloggers to see blogs",style: TextStyle(fontSize: 20),)) :  SingleChildScrollView(
            child: Container(
                  margin: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                      primary: false,
                      reverse: true,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: allBlogs.length,
                      itemBuilder: (BuildContext context, int index){
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10,10,10,10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                         Expanded(flex:4 , child: Text(allBlogs[index]["user"]["fullName"].toString(),style: TextStyle(fontSize: 18))),
                                         SizedBox(width:20),
                                         Expanded(flex:2,child: Text(allBlogs[index]["blogTime"],style: TextStyle(fontSize: 15))),
                                       ],
                                ),
                                Row(
                                  children: <Widget>[
                                  Expanded(flex:4 , child: Text(allBlogs[index]["user"]["companyName"].toString(),style: TextStyle(fontSize: 15))),
                                  ]
                                ),
                                SizedBox(height:20),
                                Row(
                                   children:<Widget>[
                                     Flexible(child: Text(allBlogs[index]["description"],style: TextStyle(fontSize: 20),overflow: TextOverflow.ellipsis,maxLines: 10,)),
                                  ]
                                ),
                                SizedBox(height:10),
                                // Divider( color: Colors.grey[800],),
                                Row(
                                    children:<Widget>[
                                     Text(allBlogs[index]["likes"].toString() ,style: TextStyle(fontSize: 15)),
                                      IconButton(icon: Icon(Icons.favorite,size: 30,color: Colors.red,), onPressed: () {
                                        blogLikeFunction(allBlogs[index]["likes"],allBlogs[index]["description"],allBlogs[index]["blogId"],allBlogs[index]["user"]["userId"],allBlogs[index]["blogTime"]);
                                      },),
                                      SizedBox(width: 120,),
                                      Text('Comments'),
                                      IconButton(icon: Icon(Icons.comment,size: 30,), onPressed: () { showComments(allBlogs[index]["blogId"]); },)
                                      ]
                                )
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
  blogLikeFunction(likes,description,blogId,userId,blogTime)async{
    print("previous like is $likes");
    setState(() {
      likes= likes+1;
    });
    print("after increment like is $likes");
    print('clicked to like blog id,userid,desc,blog time and like is $blogId, $userId, $description,$blogTime, $likes');
    await put(Uri.parse(
        "https://blogger-mobile.herokuapp.com/blogs"),
        headers: {
        "content-type": "application/json",
        "accept": "application/json",
        },
        body: jsonEncode({
        "user": {
        "userId": userId
        },
        "description": description,
        "blogTime": blogTime,
        "likes":likes,
        "blogId":blogId
        }
    )
    ).then((value) => {
      print("data after like is ${value.body}"),
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

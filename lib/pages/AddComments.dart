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

class AddComments extends StatefulWidget {
  final blogId;
  AddComments({this.blogId});

  @override
  _AddCommentsState createState() => _AddCommentsState();
}

class _AddCommentsState extends State<AddComments> {
  var blogId;
  var userId;
  bool noComments=false;
  bool isLoading=true;
  String commentDescription='';
  String commentError='';
  var allComments=[];
  var profilePic;
  @override
  void initState() {
    getComments();
    super.initState();
  }
  getComments()async{
    setState(() {
      blogId=widget.blogId;
      isLoading=true;
    });
    await get(Uri.parse("https://blogger-mobile.herokuapp.com/comments/$blogId"),
        headers: {
        "content-type": "application/json",
        "accept": "application/json",
        }
    ).then((result) => {
      print("data on comments page is ${result.body}"),
      if(result.body.isEmpty){
        setState((){
          noComments=true;
          isLoading=false;
        }),
        print("No Comments YET"),

      }else{
    setState((){
    allComments=jsonDecode(result.body);
    isLoading=false;
    }),
    print("all comments res is $allComments"),
    }
    });
    dynamic sessionUid= await FlutterSession().get("userId");
    setState(() {
      userId=sessionUid;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Comments'),
      ),
      body: SingleChildScrollView(
        child: isLoading ? Center(child: SpinKitRotatingCircle(color: Colors.blueAccent[400],size: 70.0,)):
        noComments ? Padding(
          padding: const EdgeInsets.fromLTRB(10, 250, 10, 0),
          child: Column(
            children: [
              Center(child: Text("No Comments Yet ...",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold))),
              SizedBox(height: 30,),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Start writing your comment here..",
                ),
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 40,
                onChanged: (e){
                  if(e.length <4){
                    setState(() {
                      commentError="Comment should be descriptive";
                    });
                  }else{
                    setState(() {
                      commentDescription=e;
                      commentError='';
                    });
                  }
                },
              ),
              SizedBox(width: 30,),
              ElevatedButton(onPressed: (){ addCommentFunction(blogId,userId);}, child: Text('Comment')),
              Text(commentError,style: TextStyle(fontSize: 20,color:Colors.red,fontWeight: FontWeight.bold,),),

            ],
          ),
        ):
         Column(
           children: [
             ListView.builder(
              primary: false,
              reverse: true,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: allComments.length,
              itemBuilder: (BuildContext context, int index){
                return SizedBox(
                  width: double.infinity,
                  child: Card(

                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10,10,10,10),
                      child: Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  allComments[index]["user"]["profilePic"] == null ?  CircleAvatar(backgroundImage: AssetImage('assets/nodp.png'),): CircleAvatar(backgroundImage: FileImage(File(allComments[index]["user"]["profilePic"])),radius: 20,),
                                  SizedBox(width:10),
                                  Text(allComments[index]["user"]["fullName"].toString(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                  SizedBox(width:50),
                                  Text(allComments[index]["commentTime"],style: TextStyle(fontSize: 15)),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(50,0,0,0),
                                      child: Text(allComments[index]["user"]["companyName"].toString(),style: TextStyle(fontSize: 15)),
                                    ),
                                  ]
                              ),
                              SizedBox(height:20),
                              Row(

                                  children:<Widget>[
                                    Text("Comment : "),
                                    Flexible(child: Text(allComments[index]["commentDescription"],style: TextStyle(fontSize: 18),overflow: TextOverflow.ellipsis,maxLines: 10,)),
                                  ]
                              ),
                              SizedBox(height:10),
                              ],
                              ),
                      ),

                      ),
                    ),
                );

              }
      ),

             Divider( color: Colors.grey[800],),
             TextFormField(
               decoration: InputDecoration(
                 border: OutlineInputBorder(),
                 hintText: "Start writing your comment here..",
               ),
               keyboardType: TextInputType.multiline,
               minLines: 2,
               maxLines: 40,
               onChanged: (e){
                 if(e.length <4){
                   setState(() {
                     commentError="Comment should be descriptive";
                   });
                 }else{
                   setState(() {
                     commentDescription=e;
                     commentError='';
                   });
                 }
               },
             ),
             SizedBox(width: 30,),
             ElevatedButton(onPressed: (){ addCommentFunction(blogId,userId);}, child: Text('Comment')),
             Text(commentError,style: TextStyle(fontSize: 20,color:Colors.red,fontWeight: FontWeight.bold,),),

           ],
         ),

    ),
    );
  }
  addCommentFunction(blogId,userId)async{
    if (commentDescription == '') {
      setState(() {
        commentError = "Please Enter Your Comment..";
      });
    }
    else {

          DateTime now = DateTime.now();
          String commentTime = DateFormat('yyyy-MM-dd').format(now);
          print(
              "userid,description and commenttime,blog id to edit  is $commentDescription,$userId,$commentTime,$blogId");
          await post(Uri.parse(
              "https://blogger-mobile.herokuapp.com/comments"),
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
              },
              body: jsonEncode({
                "user": {
                  "userId": userId
                },
                "blogs":{
                  "blogId":blogId
                },
                "commentDescription": commentDescription,
                "commentTime": commentTime
              }
              )
          ).then((result) =>
          {
            print('blod added is ${result.body}'),
            Fluttertoast.showToast(
              msg: "Comment Uploaded Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
            ).then((value) =>
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    Dashboard()))
            )
          });
        }
      }
    }

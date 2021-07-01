import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:bloggers/pages/dashboard.dart';
import 'package:bloggers/pages/myblogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
class AddBlog extends StatefulWidget {
  final userId;
  final blogId;
  final description;
  final username;
  final  password;
  const AddBlog({this.userId,this.description,this.password,this.username,this.blogId});

  @override
  _AddBlogState createState() => _AddBlogState();
}

class _AddBlogState extends State<AddBlog> {
  String description='';
  String blogError='';
  String blogTime='';
  String editDescription='';
  String username='';
  String password='';
  var blogId;
  var likes=0;
  var userId;
  bool isLoading=false;
  @override
  void initState() {
    if(widget.blogId == null && widget.description == null){
      blogId=0;
      userId=widget.userId;
      editDescription='';
    }
    else{
      userId=widget.userId;
      blogId=widget.blogId;
      editDescription=widget.description;
    }
   print("user id,blog id,edit description ${userId} ${widget.blogId} ${widget.description}");
    print("blog id,editdesc is $blogId, $editDescription");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Your Blog'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
          children: [
            Center(child: Text("Add Blog Description Here..",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
            SizedBox(height:30),
            blogId == 0 ? TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Start writing your new blog..",
              ),
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 40,
              onChanged: (e){
                setState(() {
                  description=e;
                });
                if(e.length < 15){
                  setState(() {
                    blogError="Enter Your Descriptive Content";
                  });
                }else{
                  setState(() {
                    blogError='';
                  });
                }
              },
            ):TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Start writing your new blog..",
              ),
              keyboardType: TextInputType.multiline,
              initialValue: editDescription,
              minLines: 2,
              maxLines: 40,
              onChanged: (e){
                setState(() {
                  description=e;
                });
                if(e.length < 15){
                  setState(() {
                    blogError="Enter Your Descriptive Content";
                  });
                }else{
                  setState(() {
                    blogError='';
                  });
                }
              },
            ),
            Text('$blogError',style: TextStyle(fontSize: 20,color:Colors.red,fontWeight: FontWeight.bold),),
            isLoading? SpinKitFadingCircle(color: Colors.blueAccent[400],size: 40.0,) :ElevatedButton(onPressed: (){
              addMyBlog();
            },
            style: ElevatedButton.styleFrom(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10)
            ),
            child: blogId == 0 ? Text("Add") : Text("Edit")),
          ],
          ),
        ),
      ),
    );
  }
  addMyBlog()async {
    if (description == '') {
      setState(() {
        blogError = "Please add the content here..";
      });
    }
    else {
      if (blogError == '') {
        if(blogId != 0) {
          setState(() {
            isLoading = true;
          });
          DateTime now = DateTime.now();
          String blogTime = DateFormat('yyyy-MM-dd').format(now);
          print(
              "userid,description and blogtime is $description,$userId,$blogTime");
          await put(Uri.parse(
              "https://blogger-mobile.herokuapp.com/blogs"),
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
              },
              body: jsonEncode({
                "blogId":blogId,
                "user": {
                  "userId": userId
                },
                "description": description,
                "blogTime": blogTime
              }
              )
          ).then((result) =>
          {
            print('blog edited is ${result.body}'),
            Fluttertoast.showToast(
              msg: "Blog Updated",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
            ).then((value) =>
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    Dashboard(userId: userId,username:username,password:password)))
            )
          });
        }else{
          setState(() {
            isLoading = true;
          });
          DateTime now = DateTime.now();
          String blogTime = DateFormat('yyyy-MM-dd').format(now);
          print(
              "userid,description and blogtime,blog id to edit  is $description,$userId,$blogTime,$blogId");
          await post(Uri.parse(
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
                "likes":likes
              }
              )
          ).then((result) =>
          {
            print('blod added is ${result.body}'),
            Fluttertoast.showToast(
              msg: "Blog Added",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
            ).then((value) =>
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    Dashboard(userId: userId,username:username,password:password)))
            )
          });
        }
      }
    }
  }
}

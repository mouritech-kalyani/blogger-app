import 'dart:convert';
import 'package:bloggers/pages/dashboard/dashboard.dart';
import 'package:bloggers/pages/profile/myblogs/myblogs.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

class AddBlog extends StatefulWidget {
  final userId;
  final blogId;
  final description;
  final likes;
  const AddBlog({this.userId,this.description,this.blogId,this.likes});

  @override
  _AddBlogState createState() => _AddBlogState();
}

class _AddBlogState extends State<AddBlog> {
  String description='';
  String blogError='';
  String blogTime='';
  String editDescription='';
  var blogId;
  var likes;
  var userId;
  bool isLoading=false;
  @override
  void initState() {
    super.initState();
    if(widget.blogId == null && widget.description == null){
      blogId=0;
      userId=widget.userId;
      editDescription='';
      likes=0;
    }
    else{
      userId=widget.userId;
      blogId=widget.blogId;
      likes=widget.likes;
      editDescription=widget.description;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //App bar description
      appBar: AppBar(
        title: Text('Add Your Blogs',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
        backgroundColor:Colors.deepOrangeAccent,
        elevation: 0.0,
        shadowColor: Colors.orangeAccent,
        leading: GestureDetector(
          child: Image.asset(appIcon,color: Colors.white,),
        ),
      ),
      //Body of add blog page
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
          children: [
            Center(child: Text("$blogDesc",style: TextStyle(fontSize: normalFontSize,fontWeight: FontWeight.bold),)),
            SizedBox(height:30),

            //Check whether user is adding or editing the blog
            //code for adding new blog
            blogId == 0 ? TextFormField(
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: blogError == "" ? Colors.black12 : Colors.red)
                  ),
                border:OutlineInputBorder(),
                  hintText: '$startBlog',
                  labelStyle: TextStyle(fontSize: normalFontSize,color: Colors.black54),
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
                    blogError="$enterDescriptive";
                  });
                }else{
                  setState(() {
                    blogError='';
                  });
                }
              },
            ):TextFormField(

              //code for editing the blog
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: blogError == "" ? Colors.black12 : Colors.red)
                ),
                border:OutlineInputBorder(),
                hintText: "$startBlog",
              ),
              keyboardType: TextInputType.multiline,
              initialValue: editDescription,
              minLines: 2,
              maxLines: 40,
              onChanged: (e){
                setState(() {
                  description=e;
                });
                //Check for vaidation
                if(e.length < 15){
                  setState(() {
                    blogError="$enterDescriptive";
                  });
                }else{
                  setState(() {
                    blogError='';
                  });
                }
              },
            ),
            SizedBox(height:normalFontSize),
            Text('$blogError',style: TextStyle(fontSize: normalFontSize,color:Colors.red),),
            SizedBox(height:10),
            // if data is in progess then show loader or else show button
            isLoading? SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: 40.0,) :ElevatedButton(onPressed: (){
              addMyBlog();
            },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50,15,50,15)),
                    backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        )
                    )
                ),

                //Check user is adding or updating blog
            child: blogId == 0 ? Text("Add",style: TextStyle(fontSize: normalFontSize,fontWeight: FontWeight.bold),) : Text("Edit",style: TextStyle(fontSize: normalFontSize,fontWeight: FontWeight.bold))),
          ],
          ),
        ),
      ),
    );
  }
  addMyBlog()async {
    if (description == '') {
      setState(() {
        blogError = blogErrorMessage;
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

          //Integrate edit blog api
          await put(Uri.parse(allBlogsApi),
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
                "blogTime": blogTime,
                "likes":likes
              }
              )
          ).then((result) =>
          {
            //Show toast message for edit blog
            Fluttertoast.showToast(
              msg: "$blogUpdted",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
            ).then((value) =>
            {
              //Navigate to my blogs page
              Navigator.pop(context),
              Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(
                  builder: (context) => MyBlogs()),
                  ModalRoute.withName("/myblogs")
              )
            } )
          });
        }else{
          setState(() {
            isLoading = true;
          });
          DateTime now = DateTime.now();
          String blogTime = DateFormat('yyyy-MM-dd').format(now);

          //Integrate add blog api
           await post(Uri.parse(allBlogsApi),
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
            //Show toast message for add blog

            Fluttertoast.showToast(
              msg: "$blogAdded",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
            ).then((value) =>

           {
           //Navigate to my blogs page
           Navigator.pop(context),
           Navigator.pushAndRemoveUntil(
           context, MaterialPageRoute(
           builder: (context) => MyBlogs()),
           ModalRoute.withName("/myblogs")
           )
           }
           )
          });
        }
      }
    }
  }
}

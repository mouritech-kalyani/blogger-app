import 'dart:convert';
import 'package:bloggers/pages/profile/myblogs/myblogs.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/styles/fonts/fonts.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:flutter_summernote/flutter_summernote.dart';
// import 'package:html_editor_enhanced/html_editor.dart';
// import 'package:html_editor/html_editor.dart';

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
  // final HtmlEditorController controller = HtmlEditorController();
  GlobalKey<FlutterSummernoteState> _keyEditor = GlobalKey();
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
    print('description is ${widget.description}');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      //App bar description
      appBar: AppBar(
        title: Row(
          children: [
            Text(blogId == 0 ? 'Add Blogs' : 'Edit Blog',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle,fontFamily: fontFamily)),
          ],
        ),
        backgroundColor:Colors.black,
        elevation: 0.0,

      ),
      //Body of add blog page
      body: Container(
        child: Column(
        children: [
          //Check whether user is adding or editing the blog
          //code for adding new blog
          blogId == 0 ?
          Expanded(
            flex: 3,
            child:
            FlutterSummernote(
                hint: "Start writing your blog here...",
                key: _keyEditor
            ),
          ) :
          Expanded(
            flex: 3,
            child:
            FlutterSummernote(
                value: editDescription,
                key: _keyEditor
            ),
          ),
          // if data is in progess then show loader or else show button
          SizedBox(height:10),
          isLoading? SpinKitFadingCircle(color: Color(0xffd81b60),size: 40.0,) :
          RaisedButton(onPressed: (){
            addMyBlog();
          },
              textColor: Colors.white,
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
                padding: const EdgeInsets.fromLTRB(50,10,50,10),
                  //Check user is adding or updating blog
                  child: blogId == 0 ? Text("Add",style: TextStyle(fontSize: normalFontSize,fontWeight: FontWeight.bold,color: Colors.white,fontFamily: fontFamily)) : Text("Edit",style: TextStyle(fontSize: normalFontSize,fontWeight: FontWeight.bold,color: Colors.white,fontFamily: fontFamily,))),
              ),
        ],
        ),
      ),
    );
  }
  addMyBlog()async {
        setState(() {
          isLoading = true;
        });

        if(blogId != 0) {
          final _etEditor = await _keyEditor.currentState!.getText();
          setState(() {
            editDescription = _etEditor;
          });
          print('edit desc ${editDescription}');
          if (editDescription == '') {
            setState(() {
              blogError = blogErrorMessage;
              isLoading = false;
            });
            Fluttertoast.showToast(
              msg: "$blogError",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
            );
          }
          else{
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
                "description": editDescription,
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
        }
        }
        else {
          final _etEditor1 = await _keyEditor.currentState!.getText();
          setState(() {
            description = _etEditor1;
          });
          print('desc ${description}');
          if (description == '') {
            setState(() {
              blogError = blogErrorMessage;
              isLoading = false;
            });
            Fluttertoast.showToast(
              msg: "$blogError",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
            );
          }
          else {
            DateTime now = DateTime.now();
            String blogTime = DateFormat('yyyy-MM-dd').format(now);
            //print('getting from html editor ${_etEditor}');
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
                  "likes": likes
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

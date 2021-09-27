import 'dart:convert';
import 'dart:io';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

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
  bool isLoadingComment=false;
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
    await get(Uri.parse("$commentApi/$blogId"),
        headers: {
        "content-type": "application/json",
        "accept": "application/json",
        }
    ).then((result) => {
      if(result.body.isEmpty){
        setState((){
          noComments=true;
          isLoading=false;
        }),
      }else{
    setState((){
    allComments=jsonDecode(result.body);
    isLoading=false;
    }),
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
        title: Text('All Comments',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
        backgroundColor:Colors.deepOrangeAccent,
        leading: GestureDetector(
          child: Image.asset("$appIcon",color: Colors.white,),
        ),
      ),
      //Check whether comments are present or not
      //if there are more than 1 comment for the blog then show comments or else show no comments message
      body: isLoading ? SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: fadingCircleSize,):
        noComments ? SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 200, 10, 0),
          child: Column(
            children: [
              Image.asset("$noBlogsIcon",height: 100,width:100),
              SizedBox(height: sizedBoxNormalHeight,),
              Center(child: Text("$noCommentsYet",style: TextStyle(fontSize: sizedBoxNormalHeight,fontWeight: FontWeight.bold))),
              SizedBox(height: sizedBoxNormalHeight,),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: commentError == "" ? Colors.black12 : Colors.red)
                  ),
                  hintText: "$commentHintText",
                ),
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 40,
                onChanged: (e){
                  if(e.length <4){
                    setState(() {
                      commentError="$commentStatus";
                    });
                  }else{
                    setState(() {
                      commentDescription=e;
                      commentError='';
                    });
                  }
                },
              ),
              SizedBox(height: normalFontSize,),
              Text(commentError,style: TextStyle(fontSize: normalFontSize,color:Colors.red,),),
              SizedBox(height: normalFontSize,),
              ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50,20,50,20)),
                      backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          )
                      )
                  ),
                onPressed: (){
                  commentError == '' ?
                  addCommentFunction(blogId,userId)
                  :
                  Fluttertoast.showToast(
                    msg: commentError,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                  );
              },
                child: Text('Comment',style: TextStyle(fontSize: normalFontSize),)
              ),


            ],
          ),
        )):
        SingleChildScrollView(
           child: Column(
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
                                    allComments[index]["user"]["profilePic"] == null ?  CircleAvatar(backgroundImage: AssetImage('assets/nodp.png'),): CircleAvatar(backgroundImage: FileImage(File(allComments[index]["user"]["profilePic"])),radius: normalFontSize,),
                                    SizedBox(width:sizedHeightMinHeight),
                                    Text(allComments[index]["user"]["fullName"].toString(),style: TextStyle(fontSize: fullNameSize,fontWeight: FontWeight.bold)),
                                    SizedBox(width:sizeWidth),
                                    Text(allComments[index]["commentTime"],style: TextStyle(fontSize: blogTimeAndCompany)),
                                  ],
                                ),
                                SizedBox(height: sizedHeightMinHeight,),
                                Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(50,0,0,0),
                                        child: Text(allComments[index]["user"]["companyName"].toString(),style: TextStyle(fontSize: blogTimeAndCompany)),
                                      ),
                                    ]
                                ),
                                SizedBox(height:normalFontSize),
                                Row(

                                    children:<Widget>[
                                      Text("Comment : "),
                                      Flexible(child: Text(allComments[index]["commentDescription"],style: TextStyle(fontSize: fullNameSize,color: Colors.black54),overflow: TextOverflow.ellipsis,maxLines: 10,)),
                                    ]
                                ),
                                SizedBox(height:sizedHeightMinHeight),
                                ],
                                ),
                        ),

                        ),
                      ),
                  );

                }
      ),
              SizedBox(height: normalFontSize,),
               //Divider( color: Colors.grey[800],),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: TextFormField(
                   decoration: InputDecoration(
                     focusedBorder: OutlineInputBorder(
                         borderSide: new BorderSide(color: commentError == "" ? Colors.black12 : Colors.red)
                     ),
                     border: OutlineInputBorder(),
                     hintText: "$commentHintText",
                   ),
                   keyboardType: TextInputType.multiline,
                   minLines: 2,
                   maxLines: 40,
                   onChanged: (e){
                     if(e.length <4){
                       setState(() {
                         commentError="$commentStatus";
                       });
                     }else{
                       setState(() {
                         commentDescription=e;
                         commentError='';
                       });
                     }
                   },
                 ),
               ),
               SizedBox(height: sizedHeightMinHeight,),
               Text(commentError,style: TextStyle(
                 fontSize: normalFontSize,color:Colors.red,
               )),
               SizedBox(height: normalFontSize,),
               Center(
                   child: isLoadingComment? SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: radiusCircle,) :
                   ElevatedButton(
                       style: ButtonStyle(
                           padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50,20,50,20)),
                           backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                               RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(sizedHeightMinHeight)
                               )
                           )
                       ),
                       onPressed: (){ addCommentFunction(blogId,userId);}, child: Text('Comment',style: TextStyle(fontSize: normalFontSize),))),

             ],
           ),
         ),


    );
  }
  addCommentFunction(blogId,userId)async{
    setState(() {
      isLoadingComment=true;
    });
    if (commentDescription == '') {
      setState(() {
        commentError = "$commentPlaceholder";
        isLoadingComment=false;
      });
    }
    else {
         //Take current time and date to maintain date and time for the comment
          DateTime now = DateTime.now();
          String commentTime = DateFormat('yyyy-MM-dd').format(now);
          await post(Uri.parse("$commentApi"),
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
          setState(() {
          isLoadingComment=false;
          }),
            Fluttertoast.showToast(
              msg: "$commentUpdated",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
            ).then((value) =>
                Navigator.pop(context)
            )
          });
        }
      }
    }

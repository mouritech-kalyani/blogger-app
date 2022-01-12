import 'dart:convert';
import 'dart:io';
import 'package:bloggers/utils/apis.dart';
import 'package:bloggers/utils/local.dart';
import 'package:bloggers/utils/styles/fonts.dart';
import 'package:bloggers/utils/styles/icons.dart';
import 'package:bloggers/utils/styles/sizes.dart';
import 'package:bloggers/utils/validatefields.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    super.initState();
    getComments();
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
    String currentUser='';
    SharedPreferences loginData;
    loginData = await SharedPreferences.getInstance();
    currentUser = loginData.getString('userId');
    setState(() {
      userId=currentUser;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Text('Add Comments',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle,color: Colors.white)),
          ],
        ),
        backgroundColor:Colors.black,

      ),
      //Check whether comments are present or not
      //if there are more than 1 comment for the blog then show comments or else show no comments message
      body: isLoading ? SpinKitFadingCircle(color: Color(0xffd81b60),size: fadingCircleSize,):
        noComments ? SingleChildScrollView(
            child: Container(
              color: Colors.black,
              child: SizedBox(
                height: MediaQuery.of(context).size.height*0.90,
                child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
            child: Column(
                children: [
                  Image.asset("$noBlogsIcon",height: 100,width:100),
                  SizedBox(height: sizedBoxNormalHeight,),
                  Center(child: Text("$noCommentsYet",style: TextStyle(fontSize: sizedBoxNormalHeight,fontWeight: FontWeight.bold,color: Colors.white,fontFamily: fontFamily))),
                  SizedBox(height: sizedBoxNormalHeight,),
                  TextFormField(
                    style: TextStyle(color: Colors.white,fontFamily: fontFamily),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: commentError == "" ? Colors.white : Color(0xffd81b60))
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:commentError == ""  ? Colors.white : Color(0xffd81b60)),
                      ),
                      hintText: "$commentHintText",
                      hintStyle: TextStyle(color: Colors.white,fontFamily: fontFamily),
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 2,
                    maxLines: 40,
                    onChanged: (e){
                      validateCommentField(e);
                    },
                  ),
                  SizedBox(height: normalFontSize,),
                  Text(commentError,style: TextStyle(fontSize: normalFontSize,color:Color(0xffd81b60),fontFamily: fontFamily),),
                  SizedBox(height: normalFontSize,),
                  Center(
                    child: isLoadingComment? SpinKitFadingCircle(color: Color(0xffd81b60),size: radiusCircle,) :
                    RaisedButton(
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
                        padding: const EdgeInsets.fromLTRB(50,20,50,20),
                        //padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: const Text(
                            'Comment',
                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white,fontFamily: 'Source Sans 3')
                        ),
                      ),
                    onPressed: (){
                      checkComments();
                  },
                  )),

                ],
          ),
        ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.white, width: 1),
                      ),
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10,10,10,10),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  allComments[index]["user"]["profilePic"] == null ?  CircleAvatar(backgroundImage: AssetImage('assets/nodp.png'),): CircleAvatar(backgroundImage: FileImage(File(allComments[index]["user"]["profilePic"])),radius: normalFontSize,),
                                  SizedBox(width:sizedHeightMinHeight),
                                  Expanded(flex:4,child: Text(allComments[index]["user"]["fullName"].toString(),style: TextStyle(fontSize: fullNameSize,fontWeight: FontWeight.w800,color:Colors.white,fontFamily: fontFamily))),
                                  // SizedBox(width:sizeWidth),
                                  Expanded(flex:2,child: Text(allComments[index]["commentTime"],style: TextStyle(fontSize: blogTimeAndCompany,color: Colors.white,fontFamily: fontFamily))),
                                ],
                              ),
                              SizedBox(height: sizedHeightMinHeight,),
                              Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(50,0,0,0),
                                      child: Text('@ '+ allComments[index]["user"]["companyName"].toString(),style: TextStyle(fontSize: blogTimeAndCompany,color:Colors.white,fontFamily: fontFamily)),
                                    ),
                                  ]
                              ),
                              SizedBox(height:normalFontSize),
                              Row(

                                  children:<Widget>[
                                    Text("Comment : ",style: TextStyle(fontFamily: fontFamily, color:Colors.white,),),
                                    Flexible(child: Text(allComments[index]["commentDescription"],style: TextStyle(fontSize: fullNameSize,color: Colors.white,fontFamily: fontFamily),overflow: TextOverflow.ellipsis,maxLines: 10,)),
                                  ]
                              ),
                              SizedBox(height:sizedHeightMinHeight),
                              ],
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
                   style: TextStyle(color: Colors.white,fontFamily: fontFamily),
                   decoration: InputDecoration(
                     focusedBorder: OutlineInputBorder(
                         borderSide: new BorderSide(color: commentError == "" ? Colors.white : Color(0xffd81b60))
                     ),
                     enabledBorder: OutlineInputBorder(
                       borderSide: BorderSide(color:commentError == ""  ? Colors.white : Color(0xffd81b60)),
                     ),
                     border: OutlineInputBorder(),
                     hintText: "$commentHintText",
                     hintStyle: TextStyle(color: Colors.white,fontFamily: fontFamily),

                 ),
                   keyboardType: TextInputType.multiline,
                   minLines: 2,
                   maxLines: 40,
                   onChanged: (e){
                     validateCommentField(e);
                   },
                 ),
               ),
               SizedBox(height: sizedHeightMinHeight,),
               Text(commentError,style: TextStyle(
                 fontSize: normalFontSize,color:Color(0xffd81b60),fontFamily: fontFamily
               )),
               SizedBox(height: normalFontSize,),
               Center(
                   child: isLoadingComment? SpinKitFadingCircle(color: Color(0xffd81b60),size: radiusCircle,) :
                   RaisedButton(
                       textColor: Colors.black,
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
                         padding: const EdgeInsets.fromLTRB(50,20,50,20),
                         //padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                         child: const Text(
                             'Comment',
                             style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white,fontFamily: 'Source Sans 3')
                         ),
                       ),
                       onPressed: (){ addCommentFunction(blogId,userId);},
                   ),
               )
             ],
           ),
         ),


    );
  }
  validateCommentField(txt){
    String commentValidate = validateFields(txt, staticComment);
    if(commentValidate == validatePassword){
      setState(() {
        commentError = commentValidate;
      });
    }
    else{
      setState(() {
        commentDescription = commentValidate;
        commentError = '';
      });
    }
  }
  checkComments(){
    commentError == '' ?
    addCommentFunction(blogId,userId)
        :
    callToast(commentError);
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
          callToast(commentUpdated).then((value) =>
                Navigator.pop(context)
            )
          });
        }
      }
    }

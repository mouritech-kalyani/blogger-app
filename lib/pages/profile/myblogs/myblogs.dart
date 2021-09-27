import 'dart:convert';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import '../../comments/AddComments.dart';
import '../../blogs/addblog/addblog.dart';

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
    super.initState();
    getMyBlogs();
  }
getMyBlogs()async{
  dynamic sessionUid= await FlutterSession().get("userId");
  setState(() {
    userIdFromSession=sessionUid;
  });
  //By passing current user id get all blogs of current user
  await get(Uri.parse("$allUsers/$sessionUid"),
      headers: {
      "content-type": "application/json",
      "accept": "application/json",
      }
  ).then((result) => {
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
  if(userBlogs.isEmpty){
    setState(() {
      checkNoBlog=true;
      isLoading=false;
    });
  }else{
    setState(() {
      isLoading=false;
    });
  }
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Blogs',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
          backgroundColor:Colors.deepOrangeAccent,
          leading: GestureDetector(
            child: Image.asset("$appIcon",color: Colors.white,),
          ),
        ),
      body: Container(
          child: isLoading ? SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: fadingCircleSize,):
          //Check whether current user having blogs or not
          checkNoBlog ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("$noBlogsIcon",height: fixedHeight,width:fixedHeight),
              SizedBox(height: sizedBoxNormalHeight,),
              Center(child: Text("$noBlogs",
                style:TextStyle(fontSize: normalFontSize) ,)),
            ],
          ) :
          SingleChildScrollView(
            child: Container(
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
                                  SizedBox(width:normalFontSize),
                                  Expanded(flex:1, child: IconButton(icon:Icon(Icons.edit), onPressed: () { editBlog(userBlogs[index]["blogId"],userBlogs[index]["description"],userBlogs[index]["likes"]); })),
                                  Expanded(flex:1,child: IconButton(icon:Icon(Icons.delete), onPressed: () { deleteBlog(userBlogs[index]["blogId"]); },),),
                                ],
                              ),
                              SizedBox(height:normalFontSize),
                              Row(
                                  children:<Widget>[
                                    Flexible(child: Text(userBlogs[index]["description"],style: TextStyle(fontSize: normalFontSize),overflow: TextOverflow.ellipsis,maxLines: 10,)),
                                  ]
                              ),
                              SizedBox(height: sizedHeightMinHeight,),
                              Row(
                                  children:<Widget>[
                                    Text(userBlogs[index]["likes"].toString(),style: TextStyle(fontSize: normalFontSize)),
                                    IconButton(onPressed: null, icon: Icon(userBlogs[index]["likes"] == 0 ? Icons.favorite_outline_rounded : Icons.favorite,color: Colors.red,size: sizedBoxNormalHeight,)),
                                    SizedBox(width: 190,),
                                    Text('Comments'),
                                    IconButton(icon: Icon(Icons.comment,size: sizedBoxNormalHeight,), onPressed: () { showComments(userBlogs[index]["blogId"]); },)
                                  ]
                              ),
                            ]
                        ),
                      ),
                    );
                  }
              ),

            ),
          )
      ),

      //If user want tp add the blog then simply click on Floating action page which
        // will navigate to add blog page

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrangeAccent,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> AddBlog(userId:userIdFromSession)));
            },
        child: Text("+",style: TextStyle(fontSize: radiusCircle),),
            )
            );
  }
  editBlog(blogId,description,likes){
//to edit the blog pass blogId to the add blog page so than we can recognize whether user is updating or adding the blog on add blog page
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddBlog(userId:userIdFromSession,description:description,blogId:blogId,likes:likes)));

  }
  deleteBlog(blogId)async{

//Confirmation for deleting blog
      // set up the buttons
      Widget cancelButton = TextButton(
        child: Text("No"),
        onPressed:  () {
          Navigator.pop(context);
        },
      );
      Widget continueButton = TextButton(
        child: Text("Yes"),
        onPressed:  ()  {
          //Delete blog by passing blogId
          Navigator.pop(context);
          setState(() {
            isLoading=true;
          });
           delete(Uri.parse(
               "$allBlogsApi/$blogId"),
               headers: {
             "content-type": "application/json",
               "accept": "application/json",
               }
           ).then((value) => {
             Navigator.pop(context),
            Navigator.pushNamed(context, '/myblogs').then((_)=>setState((){}))
           });
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Delete Blog"),
        content: Text("$deleteBlogMessage"),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
  }
  showComments(id){
  //To see comments navigate to all comments page
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddComments(blogId:id)));
  }
}

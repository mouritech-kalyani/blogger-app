import 'dart:convert';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:flutter_session/flutter_session.dart';
import '../../comments/AddComments.dart';
import '../../dashboard/dashboard.dart';

class AllBlogs extends StatefulWidget {
  const AllBlogs({Key? key}) : super(key: key);

  @override
  _AllBlogsState createState() => _AllBlogsState();
}

class _AllBlogsState extends State<AllBlogs> {
  var allBlogs=[];
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
    await get(Uri.parse("$allBlogsApi/$sessionUid"),
        headers: {
        "content-type": "application/json",
        "accept": "application/json",
        }
    ).then((result) => {
      setState((){
        allBlogs=jsonDecode(result.body);
      })
    });
    setState(() {
      allBlogs=allBlogs;
      isLoading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Blogs',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
            IconButton(onPressed: (){}, icon: Icon(Icons.article_sharp,color: Colors.white,)),
          ],
        ),
        backgroundColor:Colors.deepOrangeAccent,
      ),
          //Check whether data is in progress or not and blogs are empty or not
         // if user is not followed yet to blogger then there is no blog text
          body: isLoading ?Center(child: SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: fadingCircleSize))
          :allBlogs.isEmpty ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("$noBlogsIcon",height: 100,width:100),
              SizedBox(height: 30,),
              Center(child:Text("$followBlogger",style: TextStyle(fontSize: normalFontSize),)),
            ],
          ) :  SingleChildScrollView(
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
                                         Expanded(flex:4 , child: Text(allBlogs[index]["user"]["fullName"].toString(),style: TextStyle(fontSize: fullNameSize,color: Colors.black54,fontWeight: FontWeight.w800))),
                                         SizedBox(width:normalFontSize),
                                         Expanded(flex:2,child: Text(allBlogs[index]["blogTime"],style: TextStyle(fontSize: blogTimeAndCompany))),
                                       ],
                                ),
                                Row(
                                  children: <Widget>[
                                  Expanded(flex:4 , child: Text(allBlogs[index]["user"]["companyName"].toString(),style: TextStyle(fontSize: blogTimeAndCompany))),
                                  ]
                                ),
                                SizedBox(height:normalFontSize),
                                Row(
                                   children:<Widget>[
                                     Flexible(child: Text(allBlogs[index]["description"],style: TextStyle(fontSize: normalFontSize,color: Colors.black54),overflow: TextOverflow.ellipsis,maxLines: 10,)),
                                  ]
                                ),
                                SizedBox(height:sizedHeightMinHeight),
                                // Divider( color: Colors.grey[800],),
                                Row(
                                    children:<Widget>[
                                     Expanded(flex: 3, child: Text(allBlogs[index]["likes"].toString() ,style: TextStyle(fontSize: blogTimeAndCompany))),
                                      Expanded(
                                        flex:1,
                                        child: IconButton(icon: Icon(allBlogs[index]["likes"] == 0 ? Icons.favorite_border : Icons.favorite,size: sizedBoxNormalHeight,color: Colors.red,), onPressed: () {
                                          blogLikeFunction(allBlogs[index]["likes"],allBlogs[index]["description"],allBlogs[index]["blogId"],allBlogs[index]["user"]["userId"],allBlogs[index]["blogTime"]);
                                        },),
                                      ),
                                      SizedBox(width: sizedBoxWidthMAx,),
                                      Expanded(flex:8,child: Text('Comments')),
                                      Expanded(flex:5,child: IconButton(icon: Icon(Icons.comment,size: sizedBoxNormalHeight,), onPressed: () { showComments(allBlogs[index]["blogId"]); },))
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

    setState(() {
      likes= likes+1;
    });
    //Implementing Like functionality by updating count value of Like
     await put(Uri.parse(
        "https://bloggers-mobile.herokuapp.com/blogs"),
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
      //Navigate to dashboard
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(
          builder: (context) => Dashboard()),
          ModalRoute.withName("/dashboard")
      )
    });

  }
  showComments(id){
    //open show comment page to see all comments
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddComments(blogId:id)));
  }
}

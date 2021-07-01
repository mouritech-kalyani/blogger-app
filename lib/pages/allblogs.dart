import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
class AllBlogs extends StatefulWidget {
  const AllBlogs({Key? key}) : super(key: key);

  @override
  _AllBlogsState createState() => _AllBlogsState();
}

class _AllBlogsState extends State<AllBlogs> {
  List allBlogs=[];
  bool isLoading=true;
  var likes;
  bool isLike=false;
  @override
  void initState() {
    getWholeBlogs();
    super.initState();
  }
  getWholeBlogs()async{
    await get(Uri.parse("https://blogger-mobile.herokuapp.com/blogs"),
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
    // allBlogs.forEach((element) {
    //   print("blog name is ${element["description"]}");
    //   print("blog time is ${element["blogTime"]}");
    // });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All blogs'),
        backgroundColor: Colors.blueAccent,
      ),
          body: SingleChildScrollView(
            child: Container(
                child: isLoading ? Center(
                  child: SpinKitRotatingCircle(color: Colors.blueAccent[400],size: 70.0,),
                ) :
                Container(
                  margin: const EdgeInsets.all(10.0),

                  child: ListView.builder(
                      primary: false,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: allBlogs.length,
                      itemBuilder: (BuildContext context, int index){
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
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
                                     Expanded(flex:2,child: Text(allBlogs[index]["description"],style: TextStyle(fontSize: 20))),
                                  ]
                                ),
                                SizedBox(height:5),
                                Row(
                                    children:<Widget>[
                                      Expanded(flex:2,child: Text(likes=allBlogs[index]["likes"].toString(),style: TextStyle(fontSize: 15))),
                                      isLike?
                                      IconButton(icon: Icon(Icons.thumb_up_alt_outlined,size: 20,color: Colors.blue,), onPressed: () {
                                        likeFunction(index);
                                      },)
                                          :IconButton(icon: Icon(Icons.thumb_up_alt_outlined,size: 20,), onPressed: () {
                                        likeFunction(index);
                                         },)

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
          ),

    );
  }
  likeFunction(index){
    setState(() {
      isLike=true;
      likes[index]= int.parse(likes)+1;
    });print('Like count is $likes');
  }
}

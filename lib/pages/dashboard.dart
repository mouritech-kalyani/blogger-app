import 'dart:convert';
import 'package:bloggers/pages/profile.dart';
import 'package:flutter/material.dart';
import 'allblogs.dart';
import 'myblogs.dart';

class Dashboard extends StatefulWidget {
  final userId;
  final username;
  final password;
  Dashboard({required this.userId,this.password,this.username});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List allBlogs=[];
  int userId=0;
  String username="";
  String password="";
  bool isLoading=true;
 @override
  void initState() {
   getUserId();
    super.initState();
  }
  getUserId(){
   setState(() {
    userId=widget.userId;
    username=widget.username;
    password=widget.password;
   });

   print("uid  dash is $userId");
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: new Material(
          color:Colors.blueAccent,
          child: TabBar(
            tabs:<Widget> [
              Tab(
                text: "All Blogs",
              ),
              Tab(
                  text: "My Blogs",
              ),
              Tab(
                text: "My Profile",
              )
            ],

          ),
        ),
        body: TabBarView(
          children: <Widget>[
            AllBlogs(),
            MyBlogs(userId=userId,username=username,password=password),
            MyProfile(userId=userId,username=username,password=password)
          ],
        ),
      ),
    );
  }
}


import 'dart:convert';
import 'package:bloggers/pages/people.dart';
import 'package:bloggers/pages/profile.dart';
import 'package:flutter/material.dart';
import 'allblogs.dart';
import 'myblogs.dart';
import 'package:flutter_session/flutter_session.dart';

class Dashboard extends StatefulWidget {
  Dashboard();

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List allBlogs=[];
  // dynamic sessionUid;
  bool isLoading=true;
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
                  text: "People",
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
            People(),
            MyProfile()
          ],
        ),
      ),
    );
  }
}


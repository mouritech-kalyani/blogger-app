import 'package:bloggers/pages/people/people.dart';
import 'package:bloggers/pages/profile/myprofile/profile.dart';
import 'package:flutter/material.dart';
import '../blogs/allblogs/allblogs.dart';

class Dashboard extends StatefulWidget {
  Dashboard();

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List allBlogs=[];
  bool isLoading=true;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: new Material(
          color:Colors.black,
          elevation: 0,
          //Show tab bar for Blogs,Users and My Profile
          child: TabBar(
            indicatorColor: Colors.white,
            tabs:<Widget> [
              Tab(
                icon:Icon(Icons.file_copy,color: Colors.white,),
                text: "All Blogs",
              ),
              Tab(
                icon:Icon(Icons.people,color: Colors.white,),
                  text: "People",
              ),
              Tab(
                icon:Icon(Icons.account_circle,color: Colors.white),
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


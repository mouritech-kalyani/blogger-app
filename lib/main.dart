// @dart=2.9
import 'package:bloggers/pages/dashboard/dashboard.dart';
import 'package:bloggers/pages/profile/myblogs/myblogs.dart';
import 'package:bloggers/pages/signin/signin.dart';
import 'package:bloggers/pages/signup/signup.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/signin',
    routes: {
      '/signup':(context)=>SignUp(),
      '/signin':(context)=>SignIn(),
      '/dashboard':(context)=>Dashboard(),
      '/myblogs':(context)=> MyBlogs()
    },
  ));
}

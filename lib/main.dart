import 'package:bloggers/pages/addblog.dart';
import 'package:bloggers/pages/dashboard.dart';
import 'package:bloggers/pages/profile.dart';
import 'package:bloggers/pages/signin.dart';
import 'package:bloggers/pages/signup.dart';
import 'package:flutter/material.dart';

void main() {
  int userId;
  runApp(MaterialApp(
    initialRoute: '/signin',
    routes: {
      '/signup':(context)=>SignUp(),
      '/signin':(context)=>SignIn(),
      '/dashboard':(context)=>Dashboard(userId: 0),
    },
  ));
}


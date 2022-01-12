// @dart=2.9
import 'package:bloggers/pages/Activate%20Account/activateaccount.dart';
import 'package:bloggers/pages/Forgot%20Password/forgotpassword.dart';
import 'package:bloggers/pages/Forgot%20Password/resetpassword.dart';
import 'package:bloggers/pages/dashboard/dashboard.dart';
import 'package:bloggers/pages/profile/myblogs/myblogs.dart';
import 'package:bloggers/pages/signin/signin.dart';
import 'package:bloggers/pages/signup/signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  String currentUser = '';
  print('before data is $currentUser');
  SharedPreferences loginData;
  WidgetsFlutterBinding.ensureInitialized();
  loginData = await SharedPreferences.getInstance();
  currentUser = loginData.getString('userId');
  print('after data is $currentUser');

  runApp(new MaterialApp(
    initialRoute: currentUser == null ? '/signin' : '/dashboard' ,
    routes: {
      '/signup':(context)=>SignUp(),
      '/signin':(context)=>SignIn(),
      '/dashboard':(context)=>Dashboard(),
      '/myblogs':(context)=> MyBlogs(),
      '/forgotpassword':(context)=>ForgotPassword(),
      '/resetpassword':(context)=>ResetPassword(currentUser:[]),
      '/activateaccount':(context)=>ActivateAccount()
    },
  ));
}



// void main() async{
//   runApp(MaterialApp(
//
//     initialRoute: currentUser == 0 ? '/signin' : '/dashboard' ,
//     routes: {
//       '/signup':(context)=>SignUp(),
//       '/signin':(context)=>SignIn(),
//       '/dashboard':(context)=>Dashboard(),
//       '/myblogs':(context)=> MyBlogs(),
//       '/forgotpassword':(context)=>ForgotPassword(),
//       '/resetpassword':(context)=>ResetPassword(currentUser:[]),
//       '/activateaccount':(context)=>ActivateAccount()
//     },
//   ));
// }

import 'dart:convert';
import 'dart:ui';
import 'package:bloggers/pages/signin/signin.dart';
import 'package:bloggers/utils/apis.dart';
import 'package:bloggers/utils/local.dart';
import 'package:bloggers/utils/styles/fonts.dart';
import 'package:bloggers/utils/styles/sizes.dart';
import 'package:bloggers/utils/validatefields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

class ResetPassword extends StatefulWidget {
  final currentUser;
  const ResetPassword({this.currentUser});

  @override
  _ResetPasswordState createState() => _ResetPasswordState(currentUser);
}

class _ResetPasswordState extends State<ResetPassword> {

  String password = '';
  String confirmPassword = '';
  String passwordError = '';
  String confirmPasswordError = '';
  String logError = '';
  bool _showPassword = false;
  bool _showPassword1 = false;
  bool isLoading = false;

  _ResetPasswordState(currentUser);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),

      //body of reset password

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.black,
              child: Column(
                children: [
                  Text('Reset Password',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: appBarTitle,fontFamily: fontFamily),),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.80,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60)
                            )),

                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: normalFontSize),
                              TextField(
                                style: TextStyle(color: Colors.black,fontFamily: fontFamily),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: (passwordError == requiredCurrentField ||
                                            passwordError == validatePassword) ? Color(0xffd81b60) : Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: (passwordError == requiredCurrentField ||
                                            passwordError == validatePassword) ? Color(0xffd81b60) : Colors.black),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.vpn_key,
                                    color: Colors.black,
                                  ),
                                  hintText: '$passwordPlaceholder',
                                  hintStyle:TextStyle(color:Colors.black,fontFamily: fontFamily),
                                  labelText: "Password",
                                  labelStyle: TextStyle(
                                      fontSize: normalFontSize, color: Colors.black),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() =>
                                      this._showPassword = !this._showPassword);
                                    },
                                  ),
                                ),
                                obscureText: !this._showPassword,
                                onChanged: (txt) {
                                  validatePasswordField(txt);
                                },
                              ),
                              //show password error if it is invalid
                              Text('$passwordError', style: TextStyle(
                                  color: Color(0xffff4081), fontSize: blogTimeAndCompany)),

                              SizedBox(height: normalFontSize),
                              TextField(
                                style: TextStyle(color: Colors.black,fontFamily: fontFamily),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: (confirmPasswordError ==
                                        requiredCurrentField ||
                                        confirmPasswordError == validatePassword || confirmPasswordError == passwordDoesNotMatches) ? Color(0xffd81b60) : Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: (confirmPasswordError ==
                                        requiredCurrentField ||
                                        confirmPasswordError == validatePassword || confirmPasswordError == passwordDoesNotMatches) ? Color(0xffd81b60) : Colors.black),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.vpn_key,
                                    color: Colors.black,
                                  ),
                                  hintText: '$confirmPassPlaceholder',
                                  hintStyle:TextStyle(color:Colors.black,fontFamily: fontFamily),
                                  labelText: "Confirm Password",
                                  labelStyle: TextStyle(
                                      fontSize: normalFontSize, color: Colors.black,fontFamily: fontFamily),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword1 ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() =>
                                      this._showPassword1 = !this._showPassword1);
                                    },
                                  ),
                                ),
                                obscureText: !this._showPassword1,
                                onChanged: (txt) {
                                  validateConfirmPasswordField(txt);
                                },
                              ),
                              //show password error if it is invalid
                              Text('$confirmPasswordError', style: TextStyle(
                                  color: Color(0xffff4081), fontSize: blogTimeAndCompany,fontFamily: fontFamily)),
                              SizedBox(height:normalFontSize),
                              Center(
                                child: isLoading ? SpinKitFadingCircle(
                                  color: Color(0xffff4081), size: radiusCircle,) :
                                RaisedButton(
                                    onPressed: () {
                                      changePassword();
                                    },
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
                                        'Reset Password',
                                        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Source Sans 3')
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  validatePasswordField(txt){
    String passwordValidate = validateFields(txt, staticPassword);
    if(passwordValidate == validatePassword){
      setState(() {
        passwordError = passwordValidate;
      });
    }
    else{
      setState(() {
        password = passwordValidate;
        passwordError = '';
      });
    }
  }
  validateConfirmPasswordField(txt){
    String passwordValidate = validateFields(txt, staticPassword);
    if(passwordValidate == validatePassword){
      setState(() {
        confirmPasswordError = passwordValidate;
      });
    }
    else{
      setState(() {
        confirmPassword = passwordValidate;
        confirmPasswordError = '';
      });
    }
  }
  changePassword() async {
    //if form error the show on toast
    if (password == '' && confirmPassword == '') {
      setState(() {
        logError = "$requiredField";
        passwordError = "$requiredCurrentField";
        confirmPasswordError = "$requiredCurrentField";
      });
      callToast(logError);
    }
    else if (password == '') {
      setState(() {
        logError = "$requiredField";
        passwordError = "$requiredCurrentField";
      });
      callToast(logError);
    }
    else if (confirmPassword == '') {
      setState(() {
        logError = "$requiredField";
        confirmPasswordError = "$requiredCurrentField";
      });
      callToast(logError);
    }

    else {
      setState(() {
        isLoading = true;
      });
      if (password == confirmPassword) {
        //reset password for current user
        await put(Uri.parse(
            "$usersData"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: jsonEncode({
              "userId": widget.currentUser["userId"],
              "fullName": widget.currentUser["fullName"],
              "username": widget.currentUser["username"],
              "password": confirmPassword,
              "companyName": widget.currentUser["companyName"],
              "profilePic": widget.currentUser["profilePic"],
              "accountStatus":"activate"

            })
        ).then((result) =>
        {
          if(result.statusCode == 200) {
            setState(() {
              isLoading = false;
              logError=passwordUpdated;
            }),
            callToast(logError),
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(
                builder: (context) => SignIn()),
                ModalRoute.withName("/signin")
            )
          }else{
            setState(() {
              isLoading = false;
              logError = apiError;
            }),
            callToast(logError)
          }
        });
      }
      else {
        setState(() {
          isLoading = false;
          logError = passwordDoesNotMatches;
          confirmPasswordError = passwordDoesNotMatches;
        });
        callToast(logError);
      }
    }
  }
}

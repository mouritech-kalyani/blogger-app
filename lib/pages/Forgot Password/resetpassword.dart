import 'dart:convert';
import 'dart:ui';
import 'package:bloggers/pages/dashboard/dashboard.dart';
import 'package:bloggers/pages/signin/signin.dart';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      appBar: AppBar(
        title: Row(
          children: [
            Text('Reset Password', style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: appBarTitle)),
            IconButton(onPressed: () {},
                icon: Icon(Icons.article_sharp, color: Colors.white,)),
          ],
        ),
        backgroundColor: Colors.deepOrangeAccent,
        // leading: GestureDetector(
        //   child: Image.asset("$appIcon",color: Colors.white,),
        // ),
      ),

      //body of reset password

      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(sizedHeightMinHeight),
                      topRight: Radius.circular(sizedHeightMinHeight),
                      topLeft: Radius.circular(sizedHeightMinHeight),
                      bottomLeft: Radius.circular(sizedHeightMinHeight)
                  ),
                  side: BorderSide(width: 1, color: Colors.orangeAccent)),

              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: normalFontSize),
                    TextField(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: (passwordError == requiredCurrentField ||
                                  passwordError == validatePassword) ? Colors
                                  .red : Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: (passwordError == requiredCurrentField ||
                                  passwordError == validatePassword) ? Colors
                                  .red : Colors.black12),
                        ),
                        hintText: '$passwordPlaceholder',
                        labelText: "Password",
                        labelStyle: TextStyle(
                            fontSize: normalFontSize, color: Colors.black54),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: this._showPassword ? Colors.blue : Colors
                                .grey,
                          ),
                          onPressed: () {
                            setState(() =>
                            this._showPassword = !this._showPassword);
                          },
                        ),
                      ),
                      obscureText: !this._showPassword,
                      onChanged: (txt) {
                        if (txt.length != 8) {
                          setState(() {
                            passwordError = "$validatePassword";
                          });
                        } else {
                          setState(() {
                            password = txt;
                            passwordError = '';
                          });
                          FocusScope.of(context).requestFocus(FocusNode());
                        }
                      },
                    ),
                    //show password error if it is invalid
                    Text('$passwordError', style: TextStyle(
                        color: Colors.red, fontSize: blogTimeAndCompany)),

                    SizedBox(height: normalFontSize),
                    TextField(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: (confirmPasswordError ==
                              requiredCurrentField ||
                              confirmPasswordError == validatePassword) ? Colors
                              .red : Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: (confirmPasswordError ==
                              requiredCurrentField ||
                              confirmPasswordError == validatePassword) ? Colors
                              .red : Colors.black12),
                        ),
                        hintText: '$confirmPassPlaceholder',
                        labelText: "Confirm Password",
                        labelStyle: TextStyle(
                            fontSize: normalFontSize, color: Colors.black54),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: this._showPassword1 ? Colors.blue : Colors
                                .grey,
                          ),
                          onPressed: () {
                            setState(() =>
                            this._showPassword1 = !this._showPassword1);
                          },
                        ),
                      ),
                      obscureText: !this._showPassword1,
                      onChanged: (txt) {
                        if (txt.length != 8) {
                          setState(() {
                            confirmPasswordError = "$validatePassword";
                          });
                        } else {
                          setState(() {
                            confirmPassword = txt;
                            confirmPasswordError = '';
                          });
                          FocusScope.of(context).requestFocus(FocusNode());
                        }
                      },
                    ),
                    //show password error if it is invalid
                    Text('$confirmPasswordError', style: TextStyle(
                        color: Colors.red, fontSize: blogTimeAndCompany)),

                    Center(
                      child: isLoading ? SpinKitFadingCircle(
                        color: Colors.deepOrangeAccent, size: radiusCircle,) :
                      ElevatedButton(
                          onPressed: () {
                            //if form error the show on toast
                            if (password == '' && confirmPassword == '') {
                              setState(() {
                                logError = "$requiredField";
                                passwordError = "$requiredCurrentField";
                                confirmPasswordError = "$requiredCurrentField";
                              });
                              Fluttertoast.showToast(
                                msg: logError,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                              );
                            }
                            else if (password == '') {
                              setState(() {
                                logError = "$requiredField";
                                passwordError = "$requiredCurrentField";
                              });
                              Fluttertoast.showToast(
                                msg: logError,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                              );
                            }
                            else if (confirmPassword == '') {
                              setState(() {
                                logError = "$requiredField";
                                confirmPasswordError = "$requiredCurrentField";
                              });
                              Fluttertoast.showToast(
                                msg: logError,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                              );
                            }

                            else {
                              setState(() {
                                isLoading = true;
                              });
                              changePassword();
                            }
                          },
                          child: Text('Reset Password', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: normalFontSize),),
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.fromLTRB(50, 20, 50, 20)),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.deepOrangeAccent),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          sizedHeightMinHeight)
                                  )
                              )
                          )
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  changePassword() async {
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
          Fluttertoast.showToast(
            msg: logError,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
          ),
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
        Fluttertoast.showToast(
        msg: logError,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        )
        }
      });
    }
    else {
      setState(() {
        isLoading = false;
        logError = passwordDoesNotMatches;
        confirmPasswordError = passwordDoesNotMatches;
      });
      Fluttertoast.showToast(
        msg: logError,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
    }
  }
}

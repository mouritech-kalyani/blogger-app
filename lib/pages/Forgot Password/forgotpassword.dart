import 'dart:convert';
import 'dart:ui';
import 'package:bloggers/pages/Forgot%20Password/resetpassword.dart';
import 'package:bloggers/utils/apis.dart';
import 'package:bloggers/utils/local.dart';
import 'package:bloggers/utils/styles/fonts.dart';
import 'package:bloggers/utils/styles/sizes.dart';
import 'package:bloggers/utils/validatefields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var currentUser={};
  List allBlogs=[];
  String email='';
  String password='';
  RegExp emailValid = RegExp(emailRegEx);
  String emailError='';
  String passwordError='';
  String logError='';
  int userId=0;
  String username="";
  bool isLoading=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),

      //body of forgot password

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.black,
              child: Column(
                children: [
                  Text('Forgot Password',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: appBarTitle,fontFamily: fontFamily),),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.80,
                      child: Card(
                        elevation: 0,
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
                                decoration: new InputDecoration(
                                  focusedBorder : OutlineInputBorder(
                                    borderSide: BorderSide(color:(emailError == requiredCurrentField || emailError == validateError) ? Color(0xffd81b60) : Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:(emailError == requiredCurrentField || emailError == validateError) ? Color(0xffd81b60) : Colors.black),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.black,
                                  ),
                                  hintText: '$userNamePlaceholder',
                                  hintStyle:TextStyle(color:Colors.black,fontFamily: fontFamily),
                                  labelText: "Email/Username",
                                  labelStyle: TextStyle(fontSize: normalFontSize,color:Colors.black,fontFamily: fontFamily),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (txt){
                                  validateEmailField(txt);
                                },
                              ),
                              //show email error if it is invalid
                              Text('$emailError',style: TextStyle(color: Color(0xffff4081),fontSize: blogTimeAndCompany)),
                              SizedBox(height: normalFontSize),
                              Center(
                                child: isLoading? SpinKitFadingCircle(color: Color(0xffff4081),size: radiusCircle,) :
                                RaisedButton(
                                    onPressed: (){
                                      //if form error the show on toast
                                      searchEmail();
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
                                            'Confirm Email',
                                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Source Sans 3')
                                        ),
                                      ),
                                    )
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
  validateEmailField(txt){
    String emailValidate = validateFields(txt, staticEmail);
    if(emailValidate == validateError){
      setState(() {
        emailError = emailValidate;
      });
    }
    else{
      setState(() {
        email = emailValidate;
        emailError = '';
      });
    }
  }
  searchEmail()async{
    if(email == '' ){
      setState(() {
        emailError="$requiredCurrentField";
      });
      callToast(emailError);
    }
    else {
      setState(() {
        isLoading = true;
      });
      if(emailError.length <1){
        //Check username & password is correct or not
        await post(Uri.parse(
            "$checkEmailApi"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: jsonEncode({
              "username": email
            })
        ).then((result) =>{
          if(result.body != '') {
            setState((){
              currentUser=jsonDecode(result.body);
            }),
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(
                builder: (context) => ResetPassword(currentUser:currentUser)),
                ModalRoute.withName("/resetpassword")
            )
          }
          else{

            setState(() {
              isLoading = false;
              logError = "$emailNotFound";
              emailError="$emailNotFound";
            }),
            callToast(logError)
          }
        });
      }
    }

  }
}

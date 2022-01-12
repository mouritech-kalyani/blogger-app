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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

class ActivateAccount extends StatefulWidget {
  const ActivateAccount({Key? key}) : super(key: key);

  @override
  _ActivateAccountState createState() => _ActivateAccountState();
}

class _ActivateAccountState extends State<ActivateAccount> {
  var currentUser={};
  String email='';
  RegExp emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  String emailError='';
  String logError='';
  bool isLoading=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor:Colors.black,
      ),

      //body of forgot password

      body: SingleChildScrollView(

        child: Column(
          children: [
            Container(
              color: Colors.black,
              child: Column(
                children: [
                  Text('Activate Account',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: appBarTitle,fontFamily: fontFamily),),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.80,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60),
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
                                  hintStyle:TextStyle(color:Colors.black,fontFamily: fontFamily),
                                  hintText: '$userNamePlaceholder',
                                  labelText: "Email/Username",
                                  labelStyle: TextStyle(fontSize: normalFontSize,color: Colors.black,fontFamily: fontFamily),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (txt){
                                  validateEmailField(txt);
                                },
                              ),
                              //show email error if it is invalid
                              Text('$emailError',style: TextStyle(color: Color(0xffd81b60),fontSize: blogTimeAndCompany,fontFamily: fontFamily)),
                              SizedBox(height: normalFontSize),
                              Center(
                                child: isLoading? SpinKitFadingCircle(color: Color(0xffd81b60),size: radiusCircle,) :
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
                                        'Activate Account',
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
      Fluttertoast.showToast(
        msg: emailError,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
    }
    else {
      if(emailError.length <1){
        setState(() {
          isLoading = true;
        });
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
        ).then((result) async =>{
          if(result.body != '') {
            setState((){
              currentUser=jsonDecode(result.body);
            }),

            //Activate account here
            //reset password for current user
            await put(Uri.parse(
                "$usersData"),
                headers: {
                  "content-type": "application/json",
                  "accept": "application/json",
                },
                body: jsonEncode({
                  "userId": currentUser["userId"],
                  "fullName": currentUser["fullName"],
                  "username": currentUser["username"],
                  "password": currentUser["password"],
                  "companyName": currentUser["companyName"],
                  "profilePic": currentUser["profilePic"],
                  "accountStatus":"activate"

                })
            ).then((result) =>
            {
              if(result.statusCode == 200) {
                setState(() {
                  isLoading = false;
                  logError = activated;
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
                callToast(logError),
              }
            })
          }
          else{
            setState(() {
              isLoading = false;
              logError = "$emailNotFound";
              emailError="$emailNotFound";
            }),
            callToast(logError),
          }
        });
      }
    }
  }
}
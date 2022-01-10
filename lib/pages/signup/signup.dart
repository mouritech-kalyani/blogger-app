import 'dart:convert';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/fonts/fonts.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import '../dashboard/dashboard.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var uid;
  int userId=0;
  int userIdd=0;
  var currentData={};
  String fullName='';
  String companyName='';
  String password='';
  String email='';
  RegExp emailValid = RegExp(emailRegEx);
  String emailError='';
  String fnameError='';
  String compError='';
  String passwordError='';
  String logError='';
  bool isLoading=false;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:Colors.black,
      ),
      body:
          //Fill the details to register yourself
      SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color:Colors.black,
              child: Column(
                children: [
                  Text('New user ? Sign Up Here !',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: appBarTitle,fontFamily: fontFamily),),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.90,
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60),
                            )),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                             TextField(
                                style: TextStyle(color: Colors.black,fontFamily: fontFamily),
                                decoration: InputDecoration(
                                  focusedBorder : OutlineInputBorder(
                                    borderSide: BorderSide(color:(fnameError == requiredCurrentField || fnameError == validFullName) ? Color(0xffff4081) : Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:(fnameError == requiredCurrentField || fnameError == validFullName) ? Color(0xffff4081) : Colors.black),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.account_circle,
                                    color: Colors.black,
                                  ),
                                  border:OutlineInputBorder(),
                                  hintText: "$fullNamePlaceholder",
                                  hintStyle:TextStyle(color:Colors.black,fontFamily: fontFamily),
                                  labelText: "Full Name",
                                  labelStyle: TextStyle(fontSize: 20,color: Colors.black,fontFamily: fontFamily),
                                ),
                                keyboardType: TextInputType.text,
                                onChanged: (txt){
                                if(txt.length <3){
                                  setState(() {
                                    fnameError=validFullName;
                                  });
                                }else{
                                  setState(() {
                                    fnameError="";
                                    fullName=txt;
                                  });
                                }
                                },
                              ),
                              Text('$fnameError',style: TextStyle(color: Color(0xffff4081),fontSize: 15,fontFamily: fontFamily)),
                              SizedBox(height: blogTimeAndCompany),
                              TextField(
                                style: TextStyle(color: Colors.black,fontFamily: fontFamily),
                                decoration: InputDecoration(
                                  focusedBorder : OutlineInputBorder(
                                    borderSide: BorderSide(color:(compError == requiredCurrentField || compError == validCompanyName) ? Color(0xffff4081) : Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:(compError == requiredCurrentField || compError == validCompanyName) ? Color(0xffff4081) : Colors.black),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.home,
                                    color: Colors.black,
                                  ),
                                  hintText: "$companyNamePlaceholder",
                                  hintStyle:TextStyle(color:Colors.black,fontFamily: fontFamily),
                                  labelText: "Company Name",
                                  labelStyle: TextStyle(fontSize: 20,color: Colors.black,fontFamily: fontFamily),
                                ),
                                keyboardType: TextInputType.text,
                                onChanged: (txt){
                                if(txt.length <3){
                                  setState(() {
                                    compError=validCompanyName;
                                  });
                                }else{
                                  setState(() {
                                    compError="";
                                    companyName=txt;
                                  });
                                }
                                },
                              ),
                              Text('$compError',style: TextStyle(color: Color(0xffff4081),fontSize: 15,fontFamily: fontFamily)),
                              SizedBox(height: blogTimeAndCompany),
                              TextField(
                                style: TextStyle(color: Colors.black,fontFamily: fontFamily),
                                decoration: InputDecoration(
                                  focusedBorder : OutlineInputBorder(
                                    borderSide: BorderSide(color:(emailError == requiredCurrentField || emailError == validateError) ? Color(0xffff4081) : Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:(emailError == requiredCurrentField || emailError == validateError) ? Color(0xffff4081) : Colors.black),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.black,
                                  ),
                                  hintText: '$userNamePlaceholder',
                                  hintStyle:TextStyle(color:Colors.black,fontFamily: fontFamily),
                                  labelText: "Email/Username",
                                  labelStyle: TextStyle(fontSize: normalFontSize,color: Colors.black,fontFamily: fontFamily),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (txt){
                                  if(!emailValid.hasMatch(txt)){
                                    setState(() {
                                      emailError='$validateError';
                                    });
                                  }else{setState(() {
                                    emailError='';
                                    email=txt;
                                  });}
                                },
                              ),
                              //show email error if it is invalid
                              Text('$emailError',style: TextStyle(color: Color(0xffff4081),fontSize: blogTimeAndCompany,fontFamily: fontFamily)),

                              SizedBox(height: blogTimeAndCompany),
                              TextField(
                                style: TextStyle(color: Colors.black,fontFamily: fontFamily),
                                obscureText: !this._showPassword,
                                decoration: InputDecoration(
                                  focusedBorder : OutlineInputBorder(
                                    borderSide: BorderSide(color:(passwordError == requiredCurrentField || passwordError == validatePassword) ? Color(0xffff4081): Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:(passwordError == requiredCurrentField || passwordError == validatePassword) ? Color(0xffff4081) : Colors.black),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.vpn_key,
                                    color: Colors.black,
                                  ),
                                  hintText: "$passwordPlaceholderSignUp",
                                  labelText: "Password",
                                  hintStyle:TextStyle(color:Colors.black,fontFamily: fontFamily),
                                  labelStyle: TextStyle(fontSize: 20,color: Colors.black,fontFamily: fontFamily),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                     _showPassword ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() => this._showPassword = !this._showPassword);
                                    },
                                  ),
                                ),
                                onChanged: (txt){
                                  if(txt.length !=8){
                                    setState(() {
                                      passwordError="$validatePassword";
                                    });
                                  }else{
                                    setState(() {
                                      password=txt;
                                      passwordError='';
                                    });
                                    FocusScope.of(context).requestFocus(FocusNode());
                                  }
                                },
                              ),
                              Text('$passwordError',style: TextStyle(color: Color(0xffff4081),fontSize: 15,fontFamily: fontFamily)),
                              SizedBox(height: blogTimeAndCompany),
                              Center(
                                child: isLoading? SpinKitFadingCircle(color: Color(0xffd81b60),size: 40.0,) :
                                RaisedButton(
                                    onPressed: ()=>
                                    {
                                      if(fullName.isEmpty && companyName.isEmpty &&
                                          email.isEmpty && password.isEmpty){
                                        setState(() {
                                          logError = '$requiredField';
                                          fnameError='$requiredCurrentField';
                                          compError='$requiredCurrentField';
                                          emailError='$requiredCurrentField';
                                          passwordError='$requiredCurrentField';
                                        }),
                                        Fluttertoast.showToast(
                                          msg: logError,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                        )
                                      }else if(fullName.isEmpty || companyName.isEmpty ||
                                      email.isEmpty || password.isEmpty){
                                        if(fullName.isEmpty){
                                          setState(() {
                                            fnameError='$requiredCurrentField';
                                          }),
                                        }else if(companyName.isEmpty){
                                          setState(() {
                                            compError='$requiredCurrentField';
                                          }),
                                        }else if(email.isEmpty){
                                          setState(() {
                                            emailError='$requiredCurrentField';
                                          }),
                                        }else if(password.isEmpty){
                                          setState(() {
                                            passwordError='$requiredCurrentField';
                                          }),
                                        }
                                      } else
                                        {
                                           signUpFunction()
                                          }
                                        },
                                    // logInSuccess(context);
                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard(username:username,password:password)));
                                  textColor: Colors.black,
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
                                    child: Text(
                                        '$signUpHere',
                                        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white,fontFamily: 'Source Sans 3')
                                    ),
                                  ),
                                )
                              ),
                              SizedBox(height: normalFontSize),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    //If account is already there then do sign in
                                    child: Center(child: Text('$accountIs', style: TextStyle(color: Colors.black,fontSize: fullNameSize,fontFamily: fontFamily))),
                                    onTap: (){
                                      Navigator.pushNamed(context, '/signin');
                                    },
                                  ),
                                  GestureDetector(
                                    //If account is already there then do sign in
                                    child: Center(child: Text('$signInHere', style: TextStyle(color: Color(0xffd81b60),fontSize: fullNameSize,fontWeight: FontWeight.bold,fontFamily: fontFamily))),
                                    onTap: (){
                                      Navigator.pushNamed(context, '/signin');
                                    },
                                  ),
                                ],
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
  signUpFunction()async{
    if(passwordError.length <1 && emailError == '' && compError == '' && fnameError == ''){
      setState(() {
        isLoading = true;
      });
      //Validate all the fields and add user data
      await post(Uri.parse("$signUpApi"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
          },
          body: jsonEncode({
            "fullName": fullName,
            "username": email,
            "password":password,
            "companyName": companyName,
            "accountStatus":"activate"
          })
      ).then((result) => {

        if(result.body != ""){
          setState((){
            currentData=jsonDecode(result.body);
            isLoading = false;
          }),
          userId=currentData["userId"],
           setUserSession(),
          Fluttertoast.showToast(
            msg: "$registrationSuccess",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
          ).then((value) =>

                Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(
                    builder: (context) => Dashboard()),
                    ModalRoute.withName("/dashboard")
                ))
        }
        else{
          setState(() {
            isLoading = false;
            logError = "$emailPresent";
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

  }
  //put the userid into session to check whether user is logged in or not
  setUserSession()async{
    var session = FlutterSession();
    await session.set("userId", userId);

  }
}

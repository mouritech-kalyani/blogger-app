import 'dart:convert';
import 'dart:ui';
import 'package:bloggers/pages/dashboard/dashboard.dart';
import 'package:bloggers/utils/apis.dart';
import 'package:bloggers/utils/local.dart';
import 'package:bloggers/utils/styles/fonts.dart';
import 'package:bloggers/utils/styles/sizes.dart';
import 'package:bloggers/utils/validatefields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  List currentUser=[];
  List allBlogs=[];
  String email='';
  String password='';
  String emailError='';
  String passwordError='';
  String logError='';
  int userId=0;
  String username="";
  bool _showPassword = false;
  bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
      ),

      //body of sign in page to get valid username & password from user

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.black,
              child: Column(
                children: [
                  Text('Welcome, Sign In Here !',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: appBarTitle,fontFamily: fontFamily),),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.80,
                      child: Card(
                        color: Colors.white,
                          //contentPadding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60)
                            )),
                           // side: BorderSide(width: 1, color: Colors.white)),

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
                                  labelStyle: TextStyle(fontSize: normalFontSize,color: Colors.black,fontFamily: fontFamily),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (txt){
                                  validateEmailField(txt);
                                },
                              ),
                              //show email error if it is invalid
                              Text('$emailError',style: TextStyle(color: Color(0xffff4081),fontSize: blogTimeAndCompany,fontFamily: fontFamily)),
                              SizedBox(height: normalFontSize),
                              TextField(
                                style: TextStyle(color: Colors.black,fontFamily: fontFamily),
                                decoration: InputDecoration(
                                  focusedBorder : OutlineInputBorder(
                                      borderSide: BorderSide(color:(passwordError == requiredCurrentField || passwordError == validatePassword) ? Color(0xffd81b60) : Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:(passwordError == requiredCurrentField || passwordError == validatePassword) ? Color(0xffd81b60) : Colors.black),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.vpn_key,
                                    color: Colors.black,
                                  ),
                                  hintText: '$passwordPlaceholder',
                                  hintStyle:TextStyle(color:Colors.black,fontFamily: fontFamily),
                                  labelText: "Password",
                                  labelStyle: TextStyle(fontSize: normalFontSize,color: Colors.black,fontFamily: fontFamily),
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
                                obscureText: !this._showPassword,
                                onChanged: (txt){
                                  validatePasswordField(txt);
                                },
                              ),
                              //show password error if it is invalid
                              Text('$passwordError',style: TextStyle(color: Color(0xffff4081),fontSize: blogTimeAndCompany,fontFamily: fontFamily)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                                    child: Text(''),
                                  ),
                                  GestureDetector(
                                    //if account not there then sign up
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(160, 0, 0, 0),
                                      child: Text("$forgotPassword", style: TextStyle(color: Colors.black54,fontSize: blogTimeAndCompany,fontFamily: fontFamily)),
                                    ),
                                    onTap: (){
                                      Navigator.pushNamed(context, '/forgotpassword');
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: normalFontSize),
                              Center(
                                child: isLoading? SpinKitFadingCircle(color: Color(0xffd81b60),size: radiusCircle,) :
                                RaisedButton(
                                  onPressed: () {
                                    signInFunction();
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
                                    child: Text(
                                        '$signInHere',
                                        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Source Sans 3')
                                    ),
                                  ),
                                )
                              ),
                              SizedBox(height: normalFontSize,),
                              GestureDetector(
                                //if account not there then sign up

                                child: Center(child: Text("$activateAccount", style: TextStyle(decoration: TextDecoration.underline,color: Colors.black54, fontSize: fullNameSize,fontFamily: fontFamily))),
                                onTap: (){
                                  Navigator.pushNamed(context, '/activateaccount');
                                },
                              ),
                              SizedBox(height: 50,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    //if account not there then sign up

                                    child: Center(child: Text("$noAccount", style: TextStyle(color: Colors.black,fontSize: normalFontSize,fontFamily: fontFamily))),
                                    onTap: (){
                                      Navigator.pushNamed(context, '/signup');
                                    },
                                  ),
                                  GestureDetector(
                                    //if account not there then sign up

                                    child: Center(child: Text("$signUpHere", style: TextStyle(color: Color(0xffd81b60),fontSize: normalFontSize,fontWeight: FontWeight.bold,fontFamily: fontFamily))),
                                    onTap: (){
                                      Navigator.pushNamed(context, '/signup');
                                    },
                                  ),
                                ],
                              ),
                              // SizedBox(height: normalFontSize),
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
  signInFunction()async{
    final SharedPreferences sharedpreference = await SharedPreferences.getInstance();
    //if form error the show on toast
    if(email == '' && password == ''){
      setState(() {
        logError="$requiredField";
        emailError="$requiredCurrentField";
        passwordError="$requiredCurrentField";
      });
      //toast for empty fields
      callToast(logError);
    }else if(email.isEmpty || password.isEmpty){
      if(email.isEmpty){
        setState(() {
          emailError="$requiredCurrentField";
        });
      }else{
        setState(() {
          passwordError="$requiredCurrentField";
        });
      }
    }
    else {
      if(passwordError.length <1 && emailError == ''){
        setState(() {
          isLoading = true;
        });
        //Check username & password is correct or not
        await post(Uri.parse(
            "$signInAPi"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: jsonEncode({
              "username": email,
              "password":password,

            })
        ).then((result) async =>{
          if(result.body != 'false') {
            setState((){
              currentUser=jsonDecode(result.body);
            }),
            currentUser.forEach((e) => {
              setState(()  {
                userId=e["userId"];
                username=e["username"];
                password=e["password"];
              })
            }),
            sharedpreference.setString('userId', userId.toString()),
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(
                builder: (context) => Dashboard()),
                ModalRoute.withName("/dashboard")
            )
          }
          else{

            setState(() {
              isLoading = false;
              logError = "$invalidLogin";
            }),
            callToast(logError)
          }
        });
      }
    }
  }

}

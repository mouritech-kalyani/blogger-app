import 'dart:convert';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
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
  String userId='';
  int userIdd=0;
  List currentUser=[];
  String fullName='';
  String companyName='';
  String password='';
  String email='';
  RegExp emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
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
      appBar: AppBar(
        title: Text('Sign Up',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
        backgroundColor:Colors.deepOrangeAccent,
        leading: GestureDetector(
          child: Image.asset("$appIcon",color: Colors.white,),
        ),
      ),
      body:
          //Fill the details to register yourself
      SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Center(child: Text('$logError',
                //     style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold))),
                SizedBox(height: 20,),
                TextField(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: fnameError == "" ? Colors.black12 : Colors.red)
                    ),
                    border:OutlineInputBorder(),
                    hintText: "$fullNamePlaceholder",
                    labelText: "Full Name",
                    labelStyle: TextStyle(fontSize: 20,color: Colors.black54),
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
                Text('$fnameError',style: TextStyle(color: Colors.red,fontSize: 15),),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide:  BorderSide(color: compError == "" ? Colors.black12 : Colors.red)
                    ),
                    border:OutlineInputBorder(),
                    hintText: "$companyNamePlaceholder",
                    labelText: "Company Name",
                    labelStyle: TextStyle(fontSize: 20,color: Colors.black54),
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
                Text('$compError',style: TextStyle(color: Colors.red,fontSize: 15)),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    focusedBorder : OutlineInputBorder(
                        borderSide: BorderSide(color: emailError == "" ? Colors.black12 : Colors.red)
                    ),
                    border:OutlineInputBorder(),
                    hintText: '$userNamePlaceholder',
                    labelText: "Email/Username",
                    labelStyle: TextStyle(fontSize: normalFontSize,color: Colors.black54),
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
                Text('$emailError',style: TextStyle(color: Colors.red,fontSize: blogTimeAndCompany)),

                SizedBox(height: 20),
                TextField(
                  obscureText: !this._showPassword,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: passwordError == "" ? Colors.black12 : Colors.red)
                    ),
                    border:OutlineInputBorder(),
                    hintText: "$passwordPlaceholderSignUp",
                    labelText: "Password",
                    labelStyle: TextStyle(fontSize: 20,color: Colors.black54),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: this._showPassword ? Colors.blue : Colors.grey,
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
                Text('$passwordError',style: TextStyle(color: Colors.red,fontSize: 15)),

                SizedBox(height: 20),
                GestureDetector(
                  //If account is already there then do sign in
                  child: Center(child: Text('$accountIs', style: TextStyle(decoration: TextDecoration.underline,color: Colors.deepOrangeAccent,fontSize: 20))),
                  onTap: (){
                    Navigator.pushNamed(context, '/signin');
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: isLoading? SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: 40.0,) :
                  ElevatedButton(
                      onPressed: ()=>
                      {
                        if(fullName.isEmpty || companyName.isEmpty ||
                            email.isEmpty || password.isEmpty){
                          setState(() {
                            logError = '$requiredFilled';
                          }),
                          Fluttertoast.showToast(
                            msg: logError,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                          )
                        } else
                          {
                             signUpFunction()
                            }
                          },
                      // logInSuccess(context);
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard(username:username,password:password)));
                      child: Text('Sign Up',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50,20,50,20)),
                        backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  //side: BorderSide(color: Colors.red)
                              )
                          )

                      )
                    // ButtonStyle(
                    //     backgroundColor: MaterialStateProperty.all(Colors.pinkAccent),
                    // ),
                  ),
                ),
              ],
            ),
          ),
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
            userId=result.body.substring(10,12);
              isLoading = false;
          }),
          userIdd=int.parse(userId),
          print("userid is $userId"),
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

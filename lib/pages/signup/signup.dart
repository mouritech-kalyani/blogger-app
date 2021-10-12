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
  int userId=0;
  int userIdd=0;
  var currentData={};
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
        title: Row(
          children: [
            Text('Sign Up',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
            IconButton(onPressed: (){}, icon: Icon(Icons.article_sharp,color: Colors.white,)),
          ],
        ),
        backgroundColor:Colors.deepOrangeAccent,
      ),
      body:
          //Fill the details to register yourself
      SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Center(child: Text('$logError',
                    //     style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold))),
                    SizedBox(height: 20,),
                    TextField(
                      decoration: InputDecoration(
                        focusedBorder : OutlineInputBorder(
                          borderSide: BorderSide(color:(fnameError == requiredCurrentField || fnameError == validFullName) ? Colors.red : Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:(fnameError == requiredCurrentField || fnameError == validFullName) ? Colors.red : Colors.black12),
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
                        focusedBorder : OutlineInputBorder(
                          borderSide: BorderSide(color:(compError == requiredCurrentField || compError == validCompanyName) ? Colors.red : Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:(compError == requiredCurrentField || compError == validCompanyName) ? Colors.red : Colors.black12),
                        ),
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
                          borderSide: BorderSide(color:(emailError == requiredCurrentField || emailError == validateError) ? Colors.red : Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:(emailError == requiredCurrentField || emailError == validateError) ? Colors.red : Colors.black12),
                        ),
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
                        focusedBorder : OutlineInputBorder(
                          borderSide: BorderSide(color:(passwordError == requiredCurrentField || passwordError == validatePassword) ? Colors.red : Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:(passwordError == requiredCurrentField || passwordError == validatePassword) ? Colors.red : Colors.black12),
                        ),
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

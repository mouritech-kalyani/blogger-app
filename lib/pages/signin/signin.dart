import 'dart:convert';
import 'dart:ui';
import 'package:bloggers/pages/dashboard/dashboard.dart';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

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
  RegExp emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
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
      appBar: AppBar(
        title: Text('Sign In',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
        backgroundColor:Colors.deepOrangeAccent,
        leading: GestureDetector(
          child: Image.asset("$appIcon",color: Colors.white,),
        ),
      ),

      //body of sign in page to get valid username & password from user

      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: normalFontSize),
                TextField(
                  decoration: InputDecoration(
                    focusedBorder : OutlineInputBorder(
                        borderSide: BorderSide(color: emailError == "" ? Colors.black12 : Colors.red)
                    ),
                    border:OutlineInputBorder(),
                    hintText: '$usernamePlaceholder',
                    labelText: "Email/Username",
                    labelStyle: TextStyle(fontSize: normalFontSize,color: Colors.black54),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (txt){setState(() {
                    email=txt;
                  });
                  if(!emailValid.hasMatch(email)){
                    setState(() {
                      emailError='$validateError';
                    });
                  }else{setState(() {
                    emailError='';
                  });}
                  },
                ),
                //show email error if it is invalid
                Text('$emailError',style: TextStyle(color: Colors.red,fontSize: blogTimeAndCompany)),
                SizedBox(height: normalFontSize),
                TextField(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: passwordError == "" ? Colors.black12 : Colors.red)
                    ),
                    border:OutlineInputBorder(),
                    hintText: '$passwordPlaceholder',
                    labelText: "Password",
                    labelStyle: TextStyle(fontSize: normalFontSize,color: Colors.black54),
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
                  obscureText: !this._showPassword,
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
                //show password error if it is invalid
                Text('$passwordError',style: TextStyle(color: Colors.red,fontSize: blogTimeAndCompany)),
                SizedBox(height: normalFontSize),
                GestureDetector(
                  //if account not there then sign up

                  child: Center(child: Text("$noAccount", style: TextStyle(decoration: TextDecoration.underline,color: Colors.deepOrangeAccent,fontSize: normalFontSize))),
                  onTap: (){
                    Navigator.pushNamed(context, '/signup');
                  },
                ),
                SizedBox(height: normalFontSize),
                Center(
                  child: isLoading? SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: radiusCircle,) :
                  ElevatedButton(
                      onPressed: (){
                        //if form error the show on toast
                        if(email .isEmpty || password.isEmpty){
                          setState(() {
                            logError="$requiredFilled";
                          });
                          Fluttertoast.showToast(
                            msg: logError,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                          );
                        }else {
                          signInFunction();
                        }
                      },
                      child: Text('Sign In',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: normalFontSize),),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50,20,50,20)),
                        backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(sizedHeightMinHeight)
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
    );
  }
  signInFunction()async{
    if(passwordError.length <1){
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
      ).then((result) =>{
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
          setUserSession(),
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
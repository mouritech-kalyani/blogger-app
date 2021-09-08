import 'dart:convert';

import 'package:bloggers/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var uid;
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
      appBar: AppBar(title: Text("Sign Up"),backgroundColor:Colors.blueAccent,),
      body:
      SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(child: Text('$logError',
                    style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold))),
                SizedBox(height: 20,),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter full name",
                    labelText: "Full Name",
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (txt){setState(() {
                    fullName=txt;
                  });},
                ),
                Text('$fnameError',style: TextStyle(color: Colors.red,fontSize: 15),),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your company name",
                    labelText: "Company Name",
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (txt){setState(() {
                    companyName=txt;
                  });},
                ),
                Text('$compError',style: TextStyle(color: Colors.red,fontSize: 15)),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Valid Email ID",
                    labelText: "Email/Username",
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                  onChanged: (txt){setState(() {
                    email=txt;
                  });
                  if(!emailValid.hasMatch(email)){
                    setState(() {
                      emailError='Please enter valid email address';
                    });
                  }else{
                    emailError='';
                  }
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                Text('$emailError',style: TextStyle(color: Colors.red,fontSize: 15)),
                SizedBox(height: 10),
                TextField(
                  obscureText: !this._showPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Your Password",
                    labelText: "Password",
                    labelStyle: TextStyle(fontSize: 20),
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
                    if(txt.length <8){
                      setState(() {
                        passwordError="Password must be 8 characters";
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
                  child: Center(child: Text('Already have an Account ? Sign In', style: TextStyle(decoration: TextDecoration.underline,color: Colors.blueAccent,fontSize: 20))),
                  onTap: (){
                    Navigator.pushNamed(context, '/signin');
                  },
                ),
                SizedBox(height: 10),
                Center(
                  child: isLoading? SpinKitFadingCircle(color: Colors.blueAccent[400],size: 40.0,) :
                  ElevatedButton(
                      onPressed: ()=>
                      {
                        print(
                            'Data is $fullName ,$companyName, $email ,$password'),
                        if(fullName.isEmpty || companyName.isEmpty ||
                            email.isEmpty || password.isEmpty){
                          setState(() {
                            logError = 'All Flelds are Required !';
                          }),
                        } else
                          {
                             signUpFunction()
                            }
                          },
                      // logInSuccess(context);
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard(username:username,password:password)));
                      child: Text('Sign Up',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(40,10,40,10),
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
    if(passwordError.length <1){
      setState(() {
        isLoading = true;
      });
      await post(Uri.parse(
          "https://blogger-mobile.herokuapp.com/sign-up"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
          },
          body: jsonEncode({
            "fullName": fullName,
            "username": email,
            "password":password,
            "companyName": companyName
          })
      ).then((result) => {
        print('Registration is ${result.body}'),
        if(result.body != "Email already Exists !"){
          setState(() {
            isLoading = false;
          }),
          Fluttertoast.showToast(
            msg: "Registration Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
          ).then((value) =>
              Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(
                  builder: (context) => SignIn()),
                  ModalRoute.withName("/signin")
              )
          )
        }
        else{
          print('Registration is ${result.body}'),
          setState(() {
            isLoading = false;
            logError = "Email already Exist !Please try with another";
          })
        }
      });
    }

  }
}

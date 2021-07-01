import 'dart:convert';
import 'package:bloggers/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
        title: Text('Sign In'),
        backgroundColor:Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                Center(child: Text('$logError',style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold))),
                SizedBox(height:25),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Username',
                    labelText: "Email/Username",
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (txt){setState(() {
                    email=txt;
                  });
                  if(!emailValid.hasMatch(email)){
                    setState(() {
                      emailError='Please enter valid email address';
                    });
                  }else{setState(() {
                    emailError='';
                  });}
                  },
                ),
                Text('$emailError',style: TextStyle(color: Colors.red,fontSize: 15)),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Password',
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
                  obscureText: !this._showPassword,
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
                SizedBox(height: 10),
                GestureDetector(
                  child: Center(child: Text("Don't have an Account? Sign UP", style: TextStyle(decoration: TextDecoration.underline,color: Colors.blueAccent,fontSize: 20))),
                  onTap: (){
                    Navigator.pushNamed(context, '/signup');
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: isLoading? SpinKitFadingCircle(color: Colors.blueAccent[400],size: 40.0,) :
                  ElevatedButton(
                      onPressed: (){
                        if(email .isEmpty || password.isEmpty){
                          setState(() {
                            logError="All Fields are required !";
                          });
                        }else {
                          signInFunction();
                        }
                      },
                      child: Text('Sign In',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),
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
  signInFunction()async{
    setState(() {
      isLoading = true;
    });
    await post(Uri.parse(
        "https://blogger-mobile.herokuapp.com/log-in"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: jsonEncode({
          "username": email,
          "password":password,

        })
    ).then((result) => {
    print('Log in is ${result.body}'),
    if(result.body != 'false') {
      setState((){
        currentUser=jsonDecode(result.body);
      }),
    currentUser.forEach((e) => {
    setState((){
    userId=e["userId"];
    username=e["username"];
    password=e["password"];
    })
    }),
    Navigator.pushAndRemoveUntil(
    context, MaterialPageRoute(
    builder: (context) => Dashboard(userId:userId,username:username,password:password)),
    ModalRoute.withName("/dashboard")
    )
    }
    else{

      setState(() {
        isLoading = false;
        logError = "Invalid Login.Please check Username/Password";
      })
    }
    });

  }
}

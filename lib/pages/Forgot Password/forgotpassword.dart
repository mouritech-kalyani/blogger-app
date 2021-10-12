import 'dart:convert';
import 'dart:ui';
import 'package:bloggers/pages/Forgot%20Password/resetpassword.dart';
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
        title: Row(
          children: [
            Text('Forgot Password',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
            IconButton(onPressed: (){}, icon: Icon(Icons.article_sharp,color: Colors.white,)),
          ],
        ),
        backgroundColor:Colors.deepOrangeAccent,
        // leading: GestureDetector(
        //   child: Image.asset("$appIcon",color: Colors.white,),
        // ),
      ),

      //body of forgot password

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
                      decoration: new InputDecoration(
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
                    SizedBox(height: normalFontSize),
                    Center(
                      child: isLoading? SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: radiusCircle,) :
                      ElevatedButton(
                          onPressed: (){
                            //if form error the show on toast
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
                              setState(() {
                                isLoading = true;
                              });
                              searchEmail();
                            }

                          },
                          child: Text('Confirm Email',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: normalFontSize),),
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
        ),
      ),
    );
  }
  searchEmail()async{
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
}

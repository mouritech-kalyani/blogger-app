import 'dart:convert';
import 'dart:ui';
import 'package:bloggers/pages/dashboard/dashboard.dart';
import 'package:bloggers/pages/signin/signin.dart';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
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
      appBar: AppBar(
        title: Row(
          children: [
            Text('Activate Account',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
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
                              searchEmail();
                            }

                          },
                          child: Text('Activate Account',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: normalFontSize),),
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
      Fluttertoast.showToast(
      msg: logError,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      ),
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
      Fluttertoast.showToast(
      msg: logError,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      )
      }
      })
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
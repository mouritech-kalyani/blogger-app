import 'dart:convert';
import 'dart:io';
import 'package:bloggers/pages/signin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import 'dashboard.dart';
class MyProfile extends StatefulWidget {
  MyProfile();

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  var userId;
  var currentUser={};
  late String username='';
  late String fullName='';
  late String companyName='';
  late String password='';
  late String fullNameEdit='';
  late String companyNameEdit='';
  late String passwordEdit='';
  var profilePic;
  bool isLoading=true;
  bool isEditable=false;
  bool _showPassword=false;
  bool isProfileChange=false;
  String passwordError='';
  String formError = '';
  @override
  void initState() {
    getProfile();
    super.initState();
  }
  getProfile()async{
    dynamic sessionUid= await FlutterSession().get("userId");
    setState(() {
      userId=sessionUid;
    });
   await get(Uri.parse(
       "https://blogger-mobile.herokuapp.com/user-by-id/$userId"),
       headers: {
         "content-type": "application/json",
         "accept": "application/json",
       }
   ).then((result) => {
     print('Res of profile is ${result.body}'),
     currentUser=jsonDecode(result.body),
     print("current user is $currentUser"),
     userId=currentUser['userId'],
     username=currentUser['username'],
     password=currentUser['password'],
     fullName=currentUser['fullName'],
     companyName=currentUser['companyName'],
     profilePic=currentUser['profilePic'],
   print("data after profile get call is $userId,$username,$profilePic,$password,$fullName,$companyName"),
    setState((){
      isLoading=false;
    })
   });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(
            builder: (context) => SignIn()),
            ModalRoute.withName("/signin")
            );
          }, icon: Icon(Icons.logout),color: Colors.white),
        ],
      ),
      body:isLoading ? SpinKitFadingCircle(color: Colors.blueAccent[400],size: 70.0,) :SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5,10,3,10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profilePic == null ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/nodp.png'),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      color: Colors.black,
                      onPressed: () { getImage(); },
                      padding: EdgeInsets.fromLTRB(60, 40, 0, 0),
                    ),
              ),
                ):Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: CircleAvatar(
                  backgroundImage: FileImage(File(profilePic)),radius: 40,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt),
                    color: Colors.black,
                    onPressed: () { getImage(); },
                    padding: EdgeInsets.fromLTRB(60, 40, 0, 0),
                  ),
                ),
    ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 50, 0, 0),
                  child: Center(child: Text("$formError",style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),)),
                ),
    ]),
                Table(
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15,15,0,0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                            Text('Username', style: TextStyle(fontSize: 20.0)),
                          ]),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0,15,0,0),
                          child: Text('$username', style: TextStyle(fontSize: 20.0)),
                        ),
                      ]
                    ),
                    TableRow( children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15,15,0,0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[Text('Full Name', style: TextStyle(fontSize: 20.0))]),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5,0,0,0),
                              child: TextFormField(
                                  initialValue: fullName,
                                  enabled: isEditable,
                                  keyboardType: TextInputType.text,
                                  onChanged: (e){setState(() {
                                    fullNameEdit=e;
                                  });
                                  },
                                  style: TextStyle(fontSize: 20.0,)
                              ),
                            )
                          ],
                        )
                      ]),
                    TableRow( children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15,15,0,0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[Text('Password', style: TextStyle(fontSize: 20.0))]),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5,0,0,0),
                              child: TextFormField(
                                  initialValue: password,
                                  obscureText: !_showPassword,
                                  enabled: isEditable,
                                  keyboardType: TextInputType.text,
                                  onChanged: (e){setState(() {
                                    if(e.length !=8 ){
                                      setState(() {
                                        passwordError="Password must be 8 characters";
                                      });
                                    }else{
                                      setState(() {
                                        passwordEdit=e;
                                        passwordError='';
                                      });

                                      FocusScope.of(context).requestFocus(FocusNode());
                                    }
                                  });
                                  },
                                  style: TextStyle(fontSize: 20.0)
                              ),
                            ),
                            Text("$passwordError",style: TextStyle(color: Colors.red)),
                          ],
                        )
                      ]),
                    TableRow( children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15,0,0,0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[Text('Company Name', style: TextStyle(fontSize: 20.0))]),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5,0,0,0),
                              child: TextFormField(
                                  initialValue: companyName,
                                  enabled: isEditable,
                                  keyboardType: TextInputType.text,
                                  onChanged: (e){setState(() {
                                    companyNameEdit=e;
                                  });
                                  },
                                  style: TextStyle(fontSize: 20.0)
                              ),
                            )
                          ],
                        )
                      ]),
                      ]),
                SizedBox(height:20),
                SizedBox(
                  height: 60,
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10,10,10,10),
                    child: isLoading ? SpinKitFadingCircle(color: Colors.blueAccent[400],size: 40.0,) :ElevatedButton(onPressed: (){
                      if(isEditable){
                        saveDetails(context);
                      }
                      else{
                        setState(() {
                          isEditable=!isEditable;
                          _showPassword= !_showPassword;
                        });
                      }
                    },
                        child: isEditable ? Text('Save Record',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700),):Text('Edit Record',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700))),
                  )
                ),
                  SizedBox(height:20),
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton(onPressed:
               () {
                      Navigator.pushNamed(context, '/myblogs');
                    },
                        child: Text("My Blogs",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700))),
                  )
                    ,
                ],
                )
          )
        ),

    );
  }
  getImage() async {
    if(!isEditable){
      setState(() {
        isEditable=true;
        _showPassword= !_showPassword;
      });
    }
    final PickedFile = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      profilePic=PickedFile!.path;
      isProfileChange = true;
      formError='';
    });
    print('clicked profile img is $profilePic and pic flag is $isProfileChange');
  }
  saveDetails(BuildContext context) async{
    if(passwordError.length < 1){
      setState(() {
        isLoading=true;
      });
      print("before edited data is $fullName, $companyName, $password, $profilePic,$isProfileChange");
      print('pic flag $isProfileChange');
      if(fullNameEdit == '' && passwordEdit == '' && companyNameEdit == '' && isProfileChange == false){
        setState(() {
          // isEditable=false;
          formError="Please provide the data to update";
        });

      }else {
        setState(() {
          formError='';
        });
        if(fullNameEdit == '' && companyNameEdit == '' && passwordEdit == ''){

          setState(() {
            fullNameEdit=fullName;
            companyNameEdit=companyName;
            passwordEdit=password;
          });

        }
        else if(fullNameEdit == '' && companyNameEdit == ''){
          setState(() {
            fullNameEdit=fullName;
            companyNameEdit=companyName;
          });
        }
        else if(companyNameEdit == '' && passwordEdit == ''){
          setState(() {
            companyNameEdit=companyName;
            passwordEdit=password;
          });
        }
        else if(fullNameEdit == '' && passwordEdit == ''){
          setState(() {
            fullNameEdit=fullName;
            passwordEdit=password;
          });
        }


        print(
            "after editing is $fullNameEdit,$passwordEdit,$companyNameEdit,$profilePic");

        await put(Uri.parse(
            "https://blogger-mobile.herokuapp.com/users"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: jsonEncode({
              "userId": userId,
              "fullName": fullNameEdit,
              "username": username,
              "password": passwordEdit,
              "companyName": companyNameEdit,
              "profilePic": profilePic
            })
        ).then((result) =>
        {
          print('edited data is ${result.body}'),
          Fluttertoast.showToast(
            msg: "Record Saved !",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
          ).then((value) => {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(
                builder: (context) => Dashboard()),
                ModalRoute.withName("/dashboard")
            )})
          //   Navigator.push(
          //       context, MaterialPageRoute(builder: (context) =>
          //       Dashboard()))
          // })
        }
        );
        setState(() {
          isEditable=false;
          _showPassword=!_showPassword;
          isLoading=false;
        });
      }
    }

  }
}

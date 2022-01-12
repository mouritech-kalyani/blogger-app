import 'dart:convert';
import 'dart:io';
import 'package:bloggers/pages/signin/signin.dart';
import 'package:bloggers/utils/apis.dart';
import 'package:bloggers/utils/local.dart';
import 'package:bloggers/utils/styles/fonts.dart';
import 'package:bloggers/utils/styles/icons.dart';
import 'package:bloggers/utils/styles/sizes.dart';
import 'package:bloggers/utils/validatefields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import '../../dashboard/dashboard.dart';

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
  late int followers =0;
  late int following =0;
  late int blogCount=0;
  bool isLoading=true;
  bool isEditable=false;
  bool showPassword=false;
  bool isProfileChange=false;
  String passwordError='';
  String formError = '';
  @override
  void initState() {
    getProfile();
    super.initState();
  }
  //By passing userId get all personal details of the user
  getProfile()async{
    dynamic sessionUid= await FlutterSession().get("userId");
    setState(() {
      userId=sessionUid;
    });
   await get(Uri.parse(
       "$profileApi/$userId"),
       headers: {
         "content-type": "application/json",
         "accept": "application/json",
       }
   ).then((result) => {
     currentUser=jsonDecode(result.body),
     userId=currentUser['userId'],
     username=currentUser['username'],
     password=currentUser['password'],
     fullName=currentUser['fullName'],
     companyName=currentUser['companyName'],
     profilePic=currentUser['profilePic'],
   });
    getAllUserData();
  }

  getAllUserData()async{
    dynamic sessionUid= await FlutterSession().get("userId");
    setState(() {
      userId=sessionUid;
    });
    //Get following count of logged in user
    await get(Uri.parse(
        "$getFollowingApi/$userId")
    ).then((result) =>
    {
       setState((){
         following= int.parse(result.body);
       }),
    });
    //Get followers count of logged in user
    await get(Uri.parse(
    "$getFollowersApi/$userId")).then((result1) =>
    {
    setState((){
    followers=int.parse(result1.body);
    }),
    });
    //Get blogs count of logged in user
    await get(Uri.parse(
    "$getBlogsCount/$userId")
    ).then((result2) =>
    {
    setState((){
    blogCount=int.parse(result2.body);
    isLoading=false;
    }),
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Text('My Profile',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle,color: Colors.white,fontFamily:fontFamily)),
          ],
        ),
          backgroundColor: Colors.black,
        actions: [
          IconButton(onPressed: (){
            //Confirmation for Delete account
           Widget cancelButton = TextButton(
             child: Text("No"),
                onPressed:  () {
                Navigator.pop(context);
                },
                );
                Widget continueButton = TextButton(
                child: Text("Yes"),
                onPressed:  () async {
                  Navigator.pop(context);
                  setState(() {
                    isLoading=true;
                  });
                  //Api to deactivate user account
                  dynamic sessionUid= await FlutterSession().get("userId");
                 await put(Uri.parse("$accountStatusApi"),
                 headers: {
                 "content-type": "application/json",
                 "accept": "application/json",
                 },
                 body: jsonEncode({
                   "userId":sessionUid,
                   "fullName":fullName,
                   "username":username,
                   "password":password,
                   "companyName":companyName,
                   "profilePic":profilePic,
                   "accountStatus":"deactivate"
                     })
                 ).then((value) => {
                   callToast(deactivateAccount).then((value) => {
                   Navigator.pushAndRemoveUntil(
                   context, MaterialPageRoute(
                   builder: (context) => SignIn()),
                   ModalRoute.withName("/signin")
                   )
                   })
                 });
                },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.white, width: 1),
                  ),
                title: Text("Deactivate Account",style: TextStyle(color: Colors.white,fontFamily: fontFamily)),
                content: Text("$deleteAccount",style: TextStyle(color: Colors.white,fontFamily: fontFamily)),
                actions: [
                cancelButton,
                continueButton,
                ],
                );

                // show the dialog
                showDialog(
                context: context,
                builder: (BuildContext context) {
                return alert;
                },
                );
          }, icon: Icon(Icons.delete_rounded),color: Colors.white,iconSize: sizedBoxNormalHeight,),
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(
            builder: (context) => SignIn()),
            ModalRoute.withName("/signin")
            );
          }, icon: Icon(Icons.logout),color: Colors.white,iconSize: sizedBoxNormalHeight,),

        ],
      ),
      body:isLoading ? SpinKitFadingCircle(color: Color(0xffd81b60),size: fadingCircleSize,) :
      SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: containerHeight,
                width: containerWidth,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("$bgProfile"), fit: BoxFit.cover),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                  profilePic == null ?
                  CircleAvatar(
                  backgroundImage:AssetImage('$noDpImage'),radius: fadingCircleSize,
                    child: IconButton(
                        icon: Icon(Icons.camera_alt_rounded,size: radiusCircle,),
                        color: Colors.black,
                        onPressed: () { getImage(); },
                        padding: EdgeInsets.fromLTRB(110, 50, 0, 0)),
                ):
                  CircleAvatar(
                   backgroundImage: FileImage(File(profilePic)),radius: fadingCircleSize,
                        child: IconButton(
                            icon: Icon(Icons.camera_alt_rounded,size: radiusCircle,),
                            color: Colors.black,
                            onPressed: () { getImage(); },
                            padding: EdgeInsets.fromLTRB(110, 50, 0, 0)),
                      ),
                      SizedBox(height:sizedBoxNormalHeight),
                      Text('$username', style: TextStyle(fontSize: appBarTitle,fontWeight: FontWeight.bold,color: Colors.black,fontFamily: fontFamily)),

                    ],
                  ),
                ),
            ),

            Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,10,0,0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sizedHeightMinHeight),
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text("$followers",style: TextStyle(fontSize: sizedBoxNormalHeight,fontWeight: FontWeight.bold,color: Colors.white),),
                                Text("Followers",style: TextStyle(fontSize: blogTimeAndCompany,color:Colors.white,fontFamily:fontFamily),)
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sizedHeightMinHeight),
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25,10,25,10),
                            child: Column(
                              children: [
                                Text("$blogCount",style: TextStyle(fontSize: sizedBoxNormalHeight,fontWeight: FontWeight.bold,color:Colors.white),),
                                Text("Blogs",style: TextStyle(fontSize: blogTimeAndCompany,color:Colors.white,fontFamily:fontFamily),)
                              ],
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(sizedHeightMinHeight),
                                  topRight: Radius.circular(sizedHeightMinHeight),
                                  topLeft: Radius.circular(sizedHeightMinHeight),
                                  bottomLeft: Radius.circular(sizedHeightMinHeight)
                              ),
                              side: BorderSide(width: 1, color: Colors.white)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text("$following",style: TextStyle(fontSize: sizedBoxNormalHeight,fontWeight: FontWeight.bold,color:Colors.white),),
                                Text("Following",style: TextStyle(fontSize: blogTimeAndCompany,color:Colors.white,fontFamily:fontFamily),)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sizedHeightMinHeight),
                  side: BorderSide(color: Colors.white, width: 1),
                ),
                color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                            initialValue: fullName,
                            enabled: isEditable,
                            keyboardType: TextInputType.text,
                            onChanged: (e){setState(() {
                              fullNameEdit=e;
                            });
                            },
                            style: TextStyle(fontSize: normalFontSize,color: Colors.white,fontFamily: fontFamily)
                        ),
                        Padding(
                      padding: const EdgeInsets.fromLTRB(5,0,0,0),
                      child: TextFormField(
                      initialValue: password,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Visibility(
                            visible: isEditable,
                            child: Icon(
                              showPassword ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                              setState(() => this.showPassword = !this.showPassword);

                          },
                        )
                      ),
                      enabled: isEditable,
                      keyboardType: TextInputType.text,
                      onChanged: (e){setState(() {
                      if(e.length !=8 ){
                      setState(() {
                      passwordError="$validatePassword";
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
                      style: TextStyle(fontSize: normalFontSize,fontFamily: fontFamily,color:Colors.white)
                      ),
                      ),
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
                      style: TextStyle(fontSize: normalFontSize,fontFamily: fontFamily,color:Colors.white)
                      ),
                      ),
                    Padding(
                       padding: const EdgeInsets.fromLTRB(10,10,10,10),
                      child: isLoading ? SpinKitFadingCircle(color: Color(0xffd81b60),size: radiusCircle,) :
                      RaisedButton(
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(0.0),
                        shape:RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sizedHeightMinHeight)
                        ),
                        onPressed: (){
                          if(isEditable){
                            saveDetails(context);
                          }
                          else{
                            setState(() {
                              isEditable=!isEditable;
                            });
                          }
                        },
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
                            padding: EdgeInsets.fromLTRB(40,10,40,10),
                            child: isEditable ? Text('Save Record',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700,fontFamily: fontFamily,color: Colors.white),):Text('Edit Record',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700,fontFamily: fontFamily,color:Colors.white))

                        ),
                      ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10,10,10,10),
                      child: RaisedButton(
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(0.0),
                        shape:RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sizedHeightMinHeight)
                        ),
                        onPressed:
                        () {
                        //Move to see logged in user blogs
                        Navigator.pushNamed(context, '/myblogs');
                        },
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
                          padding: EdgeInsets.fromLTRB(50,10,50,10),
                          child: Text('My Blogs',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700,fontFamily:fontFamily),)

                      ),
                  ),
                    ),
                      ],
                    ),
                  ),

              ),
            )
          ],
        ),
        ),

    );
  }
  getImage() async {
    if(!isEditable){
      setState(() {
        isEditable=true;
      });
    }
    //To change profile picture
    final PickedFile = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      profilePic=PickedFile!.path;
      isProfileChange = true;
      formError='';
    });
  }
  saveDetails(BuildContext context) async{
    //Check which fields are edited

    if(passwordError.length < 1){
      setState(() {
        isLoading=true;
      });
      if(fullNameEdit == '' && passwordEdit == '' && companyNameEdit == '' && isProfileChange == false){
        setState(() {
          // isEditable=false;
          formError="$provideData";
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
        //Update user data
        await put(Uri.parse("$usersData"),
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
              "profilePic": profilePic,
              "accountStatus":"activate"
            })
        ).then((result) =>
        {
          callToast(recordSaved).then((value) => {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(
                builder: (context) => Dashboard()),
                ModalRoute.withName("/dashboard")
            )})
        }
        );
        setState(() {
          isEditable=false;
          isLoading=false;
        });
      }
    }

  }
}

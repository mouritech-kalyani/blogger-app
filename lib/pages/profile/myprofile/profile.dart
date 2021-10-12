import 'dart:convert';
import 'dart:io';
import 'package:bloggers/pages/signin/signin.dart';
import 'package:bloggers/utils/apis/allapis.dart';
import 'package:bloggers/utils/messages/message.dart';
import 'package:bloggers/utils/styles/icons/icons.dart';
import 'package:bloggers/utils/styles/sizes/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      appBar: AppBar(
        title: Row(
          children: [
            Text('My Profile',style: TextStyle(fontWeight: FontWeight.bold,fontSize: appBarTitle)),
            IconButton(onPressed: (){}, icon: Icon(Icons.article_sharp,color: Colors.white,)),
          ],
        ),
        backgroundColor:Colors.deepOrangeAccent,
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
                   Fluttertoast.showToast(
                     msg: "$deactivateAccount",
                     toastLength: Toast.LENGTH_SHORT,
                     gravity: ToastGravity.CENTER,
                     timeInSecForIosWeb: 1,
                   ).then((value) => {
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
                title: Text("Delete Account"),
                content: Text("$deleteAccount"),
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
      body:isLoading ? SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: fadingCircleSize,) :
      SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
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
                          color: Colors.black54,
                          onPressed: () { getImage(); },
                          padding: EdgeInsets.fromLTRB(110, 50, 0, 0)),
                  ):
                    CircleAvatar(
                     backgroundImage: FileImage(File(profilePic)),radius: fadingCircleSize,
                          child: IconButton(
                              icon: Icon(Icons.camera_alt_rounded,size: radiusCircle,),
                              color: Colors.black54,
                              onPressed: () { getImage(); },
                              padding: EdgeInsets.fromLTRB(110, 50, 0, 0)),
                        ),
                        SizedBox(height:sizedBoxNormalHeight),
                        Text('$username', style: TextStyle(fontSize: appBarTitle,fontWeight: FontWeight.bold,color: Colors.black87)),

                      ],
                    ),
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
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(sizedHeightMinHeight),
                                  topRight: Radius.circular(sizedHeightMinHeight),
                                  topLeft: Radius.circular(sizedHeightMinHeight),
                                  bottomLeft: Radius.circular(sizedHeightMinHeight)
                              ),
                              side: BorderSide(width: 3, color: Colors.orangeAccent)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text("$followers",style: TextStyle(fontSize: sizedBoxNormalHeight,fontWeight: FontWeight.bold,color: Colors.deepOrangeAccent),),
                                Text("Followers",style: TextStyle(fontSize: blogTimeAndCompany),)
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(sizedHeightMinHeight),
                                  topRight: Radius.circular(sizedHeightMinHeight),
                                  topLeft: Radius.circular(sizedHeightMinHeight),
                                  bottomLeft: Radius.circular(sizedHeightMinHeight)
                              ),
                              side: BorderSide(width: 3, color: Colors.orangeAccent)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25,10,25,10),
                            child: Column(
                              children: [
                                Text("$blogCount",style: TextStyle(fontSize: sizedBoxNormalHeight,fontWeight: FontWeight.bold,color:Colors.deepOrangeAccent),),
                                //Icon(Icons.people,size: 40),
                                Text("Blogs",style: TextStyle(fontSize: blogTimeAndCompany),)
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(sizedHeightMinHeight),
                                  topRight: Radius.circular(sizedHeightMinHeight),
                                  topLeft: Radius.circular(sizedHeightMinHeight),
                                  bottomLeft: Radius.circular(sizedHeightMinHeight)
                              ),
                              side: BorderSide(width: 3, color: Colors.orangeAccent)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text("$following",style: TextStyle(fontSize: sizedBoxNormalHeight,fontWeight: FontWeight.bold,color:Colors.deepOrangeAccent),),
                                Text("Following",style: TextStyle(fontSize: blogTimeAndCompany),)
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
                            style: TextStyle(fontSize: normalFontSize,)
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
                              Icons.remove_red_eye,
                              color: this.showPassword ? Colors.blue : Colors.grey,
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
                      style: TextStyle(fontSize: normalFontSize)
                      ),
                      ),
                        //Text("$passwordError",style: TextStyle(color: Colors.red)),
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
                      style: TextStyle(fontSize: normalFontSize)
                      ),
                      ),
                    Padding(
                       padding: const EdgeInsets.fromLTRB(10,10,10,10),
                      child: isLoading ? SpinKitFadingCircle(color: Colors.deepOrangeAccent,size: radiusCircle,) :ElevatedButton(onPressed: (){
                       if(isEditable){
                      saveDetails(context);
                      }
                      else{
                      setState(() {
                      isEditable=!isEditable;
                      });
                      }
                     },
                      style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(40,10,40,10)),
                      backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),

                      ),
                      child: isEditable ? Text('Save Record',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700),):Text('Edit Record',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700))),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10,10,10,10),
                      child: ElevatedButton(onPressed:
                        () {
                        //Move to see logged in user blogs
                        Navigator.pushNamed(context, '/myblogs');
                        },
                        style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50,10,50,10)),
                        backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),

                         ),
                        child: Text("My Blogs",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700))),
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
          Fluttertoast.showToast(
            msg: "$recordSaved",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
          ).then((value) => {
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

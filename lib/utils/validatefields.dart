import 'package:fluttertoast/fluttertoast.dart';

import 'local.dart';
String validData='';
RegExp emailValid = RegExp(emailRegEx);
String validateFields(String value, String typeOfField){
  if(typeOfField == staticEmail){
    if(!emailValid.hasMatch(value)){
      validData=validateError;
    }else{
      validData=value;
    }
    return validData;
  }
  if(typeOfField == staticPassword) {
    if (value.length < 8 || value.length > 8) {
      validData = validatePassword;
    } else {
      validData = value;
    }
    return validData;
  }
  if(typeOfField == staticFullName){
    if(value.length <3){
        validData=validFullName;
    }else{
      validData=value;
    }
    return validData;
  }
  if(typeOfField == staticCompanyName){
    if(value.length <3){
      validData=validCompanyName;
    }else{
      validData=value;
    }
    return validData;
  }
  if(typeOfField == staticComment){
    if(value.length <4){
      validData="$commentStatus";
    }else{
        validData=value;
    }
    return validData;
  }
  else{
    return validData;
  }

}

Future<bool?> callToast(String message){
  return (Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
  ));
}
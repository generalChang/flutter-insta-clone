import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community/models/custom_error.dart';

void errorDialog({required BuildContext context, required CustomError error}){
  if(Platform.isAndroid){
    showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text(error.code),
            content: Text(error.message),
            actions: [
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text("OK"))
            ],
          );
        });
  }else{
    showCupertinoDialog(context: context,
        builder: (context){
          return CupertinoAlertDialog(
            title: Text(error.code),
            content: Text(error.message),
            actions: [
              CupertinoDialogAction(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text("OK"))
            ],
          );
        });
  }
}
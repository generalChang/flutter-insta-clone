
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/custom_error.dart';

import '../models/user/user_model.dart';
import '../services/user_api_services.dart';

class UserRepository{
  final FirebaseFirestore firestore;
  final UserApiServices userApiServices;

  UserRepository({
    required this.firestore,
    required this.userApiServices
  });

  Future<UserModel> getProfile({required String uid}) async {
    try{
      final userData = await usersRef.doc(uid).get();
      return UserModel.fromDoc(userDoc: userData);
    }catch(e){
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<void> updateProfile({required String uid, required String name, required File profileImage}) async {
    try{
      await userApiServices.updateProfile(uid: uid, name: name, profileImage: profileImage);
    }catch(e){
      throw CustomError(
        code: "Error!",
        message: e.toString(),
        plugin: "flutter_error/server_error"
      );
    }
  }
}


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:uuid/uuid.dart';

class UserApiServices{
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  UserApiServices({
    required this.firestore,
    required this.storage,
  });

  Future<void> updateProfile({required String uid, required String name, required File profileImage}) async {
    try{
      await usersRef.doc(uid).update({
        "name" : name
      });

      final uuid = Uuid();

      final refImage = storage
          .ref()
          .child("picked_image")
          .child("${uuid.v4()}" + ".png");
      await refImage.putFile(profileImage);

      String downloadUrl = await refImage.getDownloadURL();

      await usersRef.doc(uid).update({
        "photoUrl": downloadUrl
      });

    }on FirebaseException catch(e){
      rethrow;
    }catch(e){
      rethrow;
    }
  }
}
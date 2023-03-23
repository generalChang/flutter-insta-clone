import 'package:cloud_firestore/cloud_firestore.dart';

final usersRef = FirebaseFirestore.instance.collection("users");
final paragraphsRef = FirebaseFirestore.instance.collection("paragraphs");
final commentsRef = FirebaseFirestore.instance.collection("comments");
final likesRef = FirebaseFirestore.instance.collection("likes");
final followsRef = FirebaseFirestore.instance.collection("follows");
final chatsRef = FirebaseFirestore.instance.collection("chats");
final shortVideosRef = FirebaseFirestore.instance.collection("shorts");
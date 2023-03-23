import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_community/models/pagination/model_with_id.dart';

class UserModel extends Equatable implements IPaginationBaseModel{
  final String id;
  final String email;
  final String name;
  final String photoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.photoUrl,
  });

  factory UserModel.initial(){
    return UserModel(id: "", email: "", name: "", photoUrl: "");
  }

  factory UserModel.fromDoc({required DocumentSnapshot userDoc}){
    final user = userDoc.data() as Map<String, dynamic>?;
    return UserModel(
        id: user!["id"],
        email: user["email"],
        name: user["name"],
        photoUrl: user["photoUrl"]);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id, email, name, photoUrl];

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'email': this.email,
      'name': this.name,
      'photoUrl': this.photoUrl,
    };
  }

  factory UserModel.fromJson({required Map<String, dynamic> json}) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
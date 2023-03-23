import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/models/user/user_model.dart';
import 'package:flutter_community/utils/follow_dialog.dart';

import '../pages/main_page.dart';
import '../pages/profile/profile_page.dart';


class UserCard extends StatelessWidget {
  final String photoUrl;
  final String uid;
  final String name;


  const UserCard({Key? key, required this.name,
  required this.uid, required this.photoUrl}) : super(key: key);

  factory UserCard.fromModel({required UserModel userModel}){
    return UserCard(name: userModel.name, uid: userModel.id, photoUrl: userModel.photoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTap: (){
            Navigator.of(context).pushNamedAndRemoveUntil(ProfilePage.routeName, arguments: uid,
                    (route) {
                  return route.settings.name == MainPage.routeName;
                });
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(photoUrl),
                radius: 25,
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                  child: Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  )),
              SizedBox(width: 8,),
              IconButton(onPressed: (){
                followDialog(context: context,
                    followed: true,
                    userId: context.read<ProfileCubit>().state.user!.id,
                    targetUser: UserModel(id: uid, email: "", name: name, photoUrl: photoUrl));
              }, icon: Icon(Icons.check_box), color: SECONDERY_COLOR,)
            ],
          ),
        ),
      ),
    );
  }
}

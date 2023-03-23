import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';

import '../comment/comment_model.dart';
import '../community/paragraph_model.dart';
import '../like_model.dart';


abstract class IPaginationBaseModel {
  final String id;

  IPaginationBaseModel({
    required this.id,
  });



}

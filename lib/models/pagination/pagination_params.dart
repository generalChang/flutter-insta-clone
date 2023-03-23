import 'package:cloud_firestore/cloud_firestore.dart';

class PaginationParams{
  final String? last;
  final int count;

  const PaginationParams({
    this.last,
    this.count = 10,
  });

  PaginationParams copyWith({
    String? last,
    int? count,
  }) {
    return PaginationParams(
      last: last ?? this.last,
      count: count ?? this.count,
    );
  }
}
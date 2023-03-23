import 'package:flutter_community/models/pagination/model_with_id.dart';

class CursorPagination<T extends IPaginationBaseModel> {
  final Meta meta;
  final List<T> data;

  CursorPagination({
    required this.meta,
    required this.data,
  });

  factory CursorPagination.initial() {
    return CursorPagination<T>(meta: Meta(), data: []);
  }

  CursorPagination<T> copyWith({
    Meta? meta,
    List<T>? data,
  }) {
    return CursorPagination<T>(
      meta: meta ?? this.meta,
      data: data ?? this.data,
    );
  }
}

class Meta {
  final bool hasNext;
  final int count;

  Meta({
    this.hasNext = true,
    this.count = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'hasNext': this.hasNext,
      'count': this.count,
    };
  }

  factory Meta.fromJson({required Map<String, dynamic> json}) {
    return Meta(
      hasNext: json['hasNext'] as bool,
      count: json['count'] as int,
    );
  }

  Meta copyWith({
    bool? hasNext,
    int? count,
  }) {
    return Meta(
      hasNext: hasNext ?? this.hasNext,
      count: count ?? this.count,
    );
  }
}

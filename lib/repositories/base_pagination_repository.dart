import 'package:flutter_community/models/pagination/model_with_id.dart';

import '../models/community/paragraph_model.dart';
import '../models/pagination/cursor_pagination.dart';
import '../models/pagination/pagination_params.dart';

abstract class BasePaginationRepository<T extends IPaginationBaseModel> {
  Future<CursorPagination<T>> pagination(
      {PaginationParams paginationParams = const PaginationParams(),
      String? paragraphId,
      String? userId,
      });

  Future<T> getById({required String id});
}

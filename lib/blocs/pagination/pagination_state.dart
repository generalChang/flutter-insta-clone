part of 'pagination_cubit.dart';

enum PaginationStatus{
  initial,
  loading,
  loaded,
  fetchingMore,
  refetching,
  error,
}

class PaginationState<T extends IPaginationBaseModel>{
  final PaginationStatus status;
  final CursorPagination<T> cursorPagination;
  final CustomError error;

  PaginationState({
    required this.status,
    required this.cursorPagination,
    required this.error,
  });

  factory PaginationState.initial(){
    return PaginationState(
        status: PaginationStatus.initial,
        cursorPagination: CursorPagination<T>.initial(),
        error: CustomError());
  }

  PaginationState<T> copyWith({
    PaginationStatus? status,
    CursorPagination<T>? cursorPagination,
    CustomError? error,
  }) {
    return PaginationState<T>(
      status: status ?? this.status,
      cursorPagination: cursorPagination ?? this.cursorPagination,
      error: error ?? this.error,
    );
  }
}
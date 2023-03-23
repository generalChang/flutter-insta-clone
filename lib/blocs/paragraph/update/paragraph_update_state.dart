part of 'paragraph_update_cubit.dart';

enum ParagraphUpdateStatus { initial, uploading, success, error }

class ParagraphUpdateState {
  final ParagraphUpdateStatus status;
  final ParagraphModel paragraph;
  final CustomError error;

  ParagraphUpdateState({
    required this.paragraph,
    required this.status,
    required this.error,
  });

  factory ParagraphUpdateState.initial() {
    return ParagraphUpdateState(
        status: ParagraphUpdateStatus.initial,
        paragraph: ParagraphModel.initial(),
        error: CustomError());
  }

  ParagraphUpdateState copyWith(
      {ParagraphUpdateStatus? status,
        CustomError? error,
        ParagraphModel? paragraph}) {
    return ParagraphUpdateState(
        status: status ?? this.status,
        error: error ?? this.error,
        paragraph: paragraph ?? this.paragraph);
  }
}
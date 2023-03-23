part of 'paragraph_add_cubit.dart';

enum ParagraphAddStatus { initial, uploading, success, error }

class ParagraphAddState {
  final ParagraphAddStatus status;
  final ParagraphModel paragraph;
  final CustomError error;

  ParagraphAddState({
    required this.paragraph,
    required this.status,
    required this.error,
  });

  factory ParagraphAddState.initial() {
    return ParagraphAddState(
        status: ParagraphAddStatus.initial,
        paragraph: ParagraphModel.initial(),
        error: CustomError());
  }

  ParagraphAddState copyWith(
      {ParagraphAddStatus? status,
      CustomError? error,
      ParagraphModel? paragraph}) {
    return ParagraphAddState(
        status: status ?? this.status,
        error: error ?? this.error,
        paragraph: paragraph ?? this.paragraph);
  }
}

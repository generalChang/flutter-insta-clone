part of 'upload_cubit.dart';


enum UploadStatus{
  initial,
  loading,
  success,
  error
}

class UploadState{
  final UploadStatus status;
  final double progress;

  UploadState({
    required this.status,
    required this.progress,
  });

  factory UploadState.initial(){
    return UploadState(status: UploadStatus.initial, progress: 0);
  }

  UploadState copyWith({
    UploadStatus? status,
    double? progress,
  }) {
    return UploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}
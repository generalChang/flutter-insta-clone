

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

import '../../models/custom_error.dart';
import '../../models/user/user_model.dart';
import '../../repositories/chat_repository.dart';

part 'upload_state.dart';

class UploadCubit extends Cubit<UploadState> {
  final ChatRepository repository;
  UploadCubit({required this.repository}) : super(UploadState.initial());

  Future<void> uploadVideo({required String chatRoomId, required UserModel user, required File video}) async {
    emit(state.copyWith(
      status: UploadStatus.loading,
      progress: 0
    ));
    try{
      Reference reference = repository.uploadVideo(chatRoomId: chatRoomId, user: user, video: video);
      UploadTask uploadTask = reference.putFile(video);
      uploadTask.snapshotEvents.listen((event) async {
        emit(state.copyWith(
            progress: (event.bytesTransferred.toDouble() / event.totalBytes.toDouble() * 100).roundToDouble()
        ));
        if(event.bytesTransferred == event.totalBytes){
          if(state.status == UploadStatus.success){
            return ;
          }
          //업로드 완료
          emit(state.copyWith(
            status: UploadStatus.success,
          ));
          repository.uploadVideoDetail(chatRoomId: chatRoomId, user: user, downloadUrl:  await reference.getDownloadURL());
        }
      });
    }on CustomError catch(e){
      emit(state.copyWith(
          status: UploadStatus.error,
      ));
    }
  }
}

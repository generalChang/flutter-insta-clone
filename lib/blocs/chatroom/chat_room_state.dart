part of 'chat_room_cubit.dart';

enum ChatRoomStatus {
  initial,
  loading,
  success,
  error,
}

class ChatRoomState {
  final ChatRoomStatus status;
  final ChatRoomModel chatRoom; //현재 내가 어떤 chatroom에 들어있는지.
  final List<MessageModel> messages;
  final CustomError error;
  final double progress;

  ChatRoomState({
    required this.status,
    required this.chatRoom,
    required this.error,
    required this.messages,
    required this.progress
  });

  factory ChatRoomState.initial(){
    return ChatRoomState(
        status: ChatRoomStatus.initial,
        chatRoom: ChatRoomModel.initial(),
        error: CustomError(),
       messages: [],
        progress: 0);
  }

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    ChatRoomModel? chatRoom,
    CustomError? error,
    List<MessageModel>? messages,
    double? progress
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      chatRoom: chatRoom ?? this.chatRoom,
      error: error ?? this.error,
      messages: messages ?? this.messages,
        progress : progress ?? this.progress
    );
  }
}

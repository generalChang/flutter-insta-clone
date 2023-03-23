part of 'chat_cubit.dart';

enum ChatStatus{
  initial,
  loading,
  success,
  error
}

class ChatState{
  final ChatStatus status;
  final List<ChatRoomModel> chatRooms;
  final CustomError error;

  ChatState({
    required this.status,
    required this.chatRooms,
    required this.error,
  });

  factory ChatState.initial(){
    return ChatState(status: ChatStatus.initial, chatRooms: [], error: CustomError());
  }

  ChatState copyWith({
    ChatStatus? status,
    List<ChatRoomModel>? chatRooms,
    CustomError? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      error: error ?? this.error,
    );
  }
}
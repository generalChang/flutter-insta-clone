import 'dart:io';

import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/chatroom/chat_room_cubit.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/models/chat/chat_room_model.dart';
import 'package:flutter_community/utils/error_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../blocs/upload/upload_cubit.dart';
import '../../components/chat_bubble.dart';
import '../../components/default_layout.dart';

class ChatPage extends StatefulWidget {
  final ChatRoomModel chatRoom;

  const ChatPage({Key? key, required this.chatRoom}) : super(key: key);

  static String get routeName => "/chat";

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool showSpinner = false;
  TextEditingController _controller = TextEditingController();
  String _enterMessage = "";
  List<File> pickedImages = [];
  File? pickedVideo;
  final imagePicker = ImagePicker();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<ChatRoomCubit>().listeningMessages();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: DefaultLayout(
        onWillPop: () async => true,
        automaticallyImplyLeading: false,
        title: "채팅방",
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Positioned(
                child: Column(
                  children: [
                    Expanded(
                      child: BlocConsumer<ChatRoomCubit, ChatRoomState>(
                        listener: (context, state) {
                          // TODO: implement listener
                          if (state.status == ChatRoomStatus.error) {
                            errorDialog(context: context, error: state.error);
                          }
                        },
                        builder: (context, state) {
                          if (state.status == ChatRoomStatus.error) {
                            return Center(
                              child: Text("에러가 발생했습니다."),
                            );
                          }

                          final messages = state.messages;
                          return ListView.builder(
                            reverse: true,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return ChatBubbles.fromModel(
                                  messageModel: message);
                            },
                            itemCount: messages.length,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              pickedImages = [];
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => showImageBottomSheet());
                            },
                            icon: Icon(
                              Icons.add,
                              color: SECONDERY_COLOR,
                            )),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: "메시지를 입력하세요",
                            ),
                            onChanged: (String? val) {
                              setState(() {
                                _enterMessage = val!;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _enterMessage.trim().isEmpty ? null : sendMessage,
                          icon: Icon(Icons.send),
                          color: SECONDERY_COLOR,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              BlocBuilder<UploadCubit, UploadState>(
                builder: (context, state) {
                  if(state.status == UploadStatus.loading){
                    return Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 200,
                        height: 200,
                        child: LiquidCircularProgressIndicator(
                          value: state.progress / 100, // Defaults to 0.5.
                          valueColor: AlwaysStoppedAnimation(
                              THIRD_COLOR), // Defaults to the current Theme's accentColor.
                          backgroundColor: Colors
                              .white, // Defaults to the current Theme's backgroundColor.
                          borderColor: THIRD_COLOR,
                          borderWidth: 2,
                          direction: Axis
                              .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                          center: Text("${state.progress}%..", style: TextStyle(fontSize: 20),),
                        ),
                      ),
                    );
                  }

                  return Container();

                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickImages({required StateSetter bottomState}) async {
    List<XFile> images = await imagePicker.pickMultiImage();
    if (images != null) {
      bottomState(() {
        pickedImages = [
          ...pickedImages,
          ...images.map((e) => File(e.path)).toList()
        ];
      });
    }
  }

  Future<void> uploadVideo() async {
    final xFile = await imagePicker.pickVideo(source: ImageSource.gallery);
    Navigator.of(context).pop();
    if (xFile != null) {
      context.read<UploadCubit>().uploadVideo(
          chatRoomId: context.read<ChatRoomCubit>().state.chatRoom.id,
          user: context.read<ProfileCubit>().state.user!,
          video: File(xFile.path));
    }
  }

  Widget showImageBottomSheet() {
    return StatefulBuilder(builder: (context, bottomState) {
      return Container(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pickedImages.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      pickImages(bottomState: bottomState);
                    },
                    icon: Icon(
                      Icons.add_photo_alternate_rounded,
                      color: SECONDERY_COLOR,
                      size: 45,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        uploadVideo();
                      },
                      icon: Icon(
                        Icons.video_library,
                        color: SECONDERY_COLOR,
                        size: 45,
                      ))
                ],
              ),
            if (pickedImages.isNotEmpty)
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImages(bottomState: bottomState);
                  },
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final pickedImage = pickedImages[index];
                        return Stack(
                          children: [
                            Positioned(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 12,
                                  left: 12,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    pickedImage,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              child: IconButton(
                                  onPressed: () {
                                    bottomState(() {
                                      pickedImages = pickedImages
                                          .where((file) => file != pickedImage)
                                          .toList();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    size: 22,
                                    color: SECONDERY_COLOR,
                                  )),
                              top: 5,
                              right: 5,
                            )
                          ],
                        );
                      },
                      itemCount: pickedImages.length),
                ),
              ),
            if (pickedImages.isNotEmpty)
              ElevatedButton(
                onPressed: sendImages,
                child: Text("이미지업로드"),
                style: ElevatedButton.styleFrom(primary: SECONDERY_COLOR),
              )
          ],
        ),
      );
    });
  }

  Future<void> sendImages() async {
    Navigator.of(context).pop();
    setState(() {
      showSpinner = true;
    });
    await context.read<ChatRoomCubit>().sendImages(
        chatRoomId: context.read<ChatRoomCubit>().state.chatRoom.id,
        user: context.read<ProfileCubit>().state.user!,
        images: pickedImages);
    setState(() {
      showSpinner = false;
    });
  }

  void sendMessage() {
    FocusScope.of(context).unfocus();
    context.read<ChatRoomCubit>().sendMessage(
        chatRoomId: context.read<ChatRoomCubit>().state.chatRoom.id,
        user: context.read<ProfileCubit>().state.user!,
        content: _enterMessage);
    _controller.clear();
    setState(() {
      _enterMessage = "";
    });
  }
}

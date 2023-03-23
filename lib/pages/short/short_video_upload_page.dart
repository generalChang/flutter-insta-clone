import 'dart:io';
import 'dart:typed_data';

import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/short/add/short_video_add_cubit.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/repositories/short_video_repository.dart';
import 'package:flutter_community/utils/error_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../blocs/pagination/pagination_cubit.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../models/short_video/short_video_model.dart';

class ShortVideoUploadPage extends StatefulWidget {
  static String get routeName => "/short/upload";

  const ShortVideoUploadPage({Key? key}) : super(key: key);

  @override
  State<ShortVideoUploadPage> createState() => _ShortVideoUploadPageState();
}

class _ShortVideoUploadPageState extends State<ShortVideoUploadPage> {
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  final imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  File? pickedVideo;
  String? content;
  Uint8List? thumbnail;
  bool showSpinner = false;

  void _submit() {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    form.save();

    setState(() {
      showSpinner = true;
    });

    final tempShortVideo = ShortVideoModel.initial();
    final shortVideo = tempShortVideo.copyWith(
      user: context.read<ProfileCubit>().state.user!,
      content: content!,
    );

    if (pickedVideo != null) {
      context
          .read<ShortVideoAddCubit>()
          .add(short: shortVideo, video: pickedVideo!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: DefaultLayout(
          title: "영상업로드",
          onWillPop: () async => true,
          automaticallyImplyLeading: false,
          body: BlocConsumer<ShortVideoAddCubit, ShortVideoAddState>(
            listener: (context, state) {
              // TODO: implement listener
              if (state.status == ShortVideoAddStatus.error) {
                errorDialog(context: context, error: state.error);
                setState(() {
                  showSpinner = false;
                });
              }

              if (state.status == ShortVideoAddStatus.success) {
                context
                    .read<
                        PaginationCubit<ShortVideoModel,
                            ShortVideoRepository>>()
                    .add(model: state.shortVideo);
                Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: autovalidateMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          prefixIcon: Icon(Icons.note),
                          prefixIconColor: SECONDERY_COLOR,
                          label: Text("내용"),
                          hintText: "내용을 입력하세요",
                        ),
                        validator: (String? val) {
                          if (val == null || val.trim().isEmpty) {
                            return "내용을 입력해주세요";
                          }

                          return null;
                        },
                        onSaved: (String? val) {
                          content = val!;
                        },
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      renderPickedVideo(),
                      SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text("업로드하기"),
                        style:
                            ElevatedButton.styleFrom(primary: SECONDERY_COLOR),
                      )
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget renderPickedVideo() {
    if (pickedVideo == null && thumbnail == null) {
      return TextButton.icon(
          onPressed: pickVideo,
          icon: Icon(
            Icons.video_collection_rounded,
            size: 72,
            color: SECONDERY_COLOR,
          ),
          label: Text(
            "짧영추가",
            style: TextStyle(fontSize: 24, color: SECONDERY_COLOR),
          ));
    }

    if (thumbnail != null)
      return Stack(
        children: [
          Image.memory(thumbnail!),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: PRIMARY_COLOR,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  pickedVideo = null;
                  thumbnail = null;
                });
              },
            ),
          )
        ],
      );

    return Container();
  }

  Future<void> pickVideo() async {
    final videoxFile = await imagePicker.pickVideo(source: ImageSource.gallery);
    if (videoxFile != null) {
      pickedVideo = File(videoxFile.path);
      final uint8list = await VideoThumbnail.thumbnailData(
          video: pickedVideo!.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: MediaQuery.of(context).size.width.toInt(),
          quality:
              100 // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          );
      thumbnail = uint8list;
      setState(() {});
    }
  }
}

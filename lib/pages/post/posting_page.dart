import 'dart:io';

import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/paragraph/add/paragraph_add_cubit.dart';
import 'package:flutter_community/blocs/paragraph/update/paragraph_update_cubit.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/repositories/like_repository.dart';
import 'package:flutter_community/utils/data_utils.dart';
import 'package:flutter_community/utils/error_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../blocs/pagination/pagination_cubit.dart';
import '../../consts/theme_const.dart';
import '../../repositories/paragraph_repository.dart';

class PostingPage extends StatefulWidget {
  final bool isEdit;
  final ParagraphModel? paragraph;
  static String get routeName => "/posting";

  PostingPage({Key? key, this.isEdit = false, this.paragraph})
      : super(key: key);

  @override
  State<PostingPage> createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  final _formKey = GlobalKey<FormState>();
  final imagePicker = ImagePicker();
  String? _content;
  List<File> pickedImages = [];
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  bool showSpinner = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  void initialize() async {
    if(widget.isEdit){
      setState(() {
        if (widget.paragraph!.content != "") {
          _content = widget.paragraph!.content;
        }

        if (widget.paragraph!.imagesUrl.isNotEmpty) {
          _initializePickedImages();
        }

      });
    }

  }

  Future<void> _initializePickedImages() async {
    List<File> fileList=[];
    List<Future<File>> futures = [];
    for(final image in widget.paragraph!.imagesUrl){
      futures.add(DataUtils.urlToFile(image));
    }

    fileList = await Future.wait(futures);
    setState(() {
      pickedImages = fileList;
    });

  }

  void _submit() {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    try{
      final form = _formKey.currentState;
      if (form == null || !form.validate()) return;

      form.save();

      setState(() {
        showSpinner = true;
      });

      final profileState = context.read<ProfileCubit>().state;

      if (!widget.isEdit) {
        final tempParagraph = ParagraphModel.initial();
        final paragraph = tempParagraph.copyWith(
          user: context.read<ProfileCubit>().state.user!,
          content: _content,
        );

        context
            .read<ParagraphAddCubit>()
            .add(paragraph: paragraph, images: pickedImages);
      } else {
        ParagraphModel updatedParagraph =
        widget.paragraph!.copyWith(content: _content);

        context
            .read<ParagraphUpdateCubit>()
            .update(paragraph: updatedParagraph, images: pickedImages);
      }
    }catch(e){
      setState(() {
        showSpinner = false;
      });
    }


  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: SECONDERY_COLOR),
    );
    return BlocConsumer<ParagraphAddCubit, ParagraphAddState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state.status == ParagraphAddStatus.error) {
          errorDialog(context: context, error: state.error);
        }

        if (state.status == ParagraphAddStatus.success) {
          context
              .read<
                  PaginationCubit<ParagraphModel, ParagraphRepository>>()
              .add(model: state.paragraph);
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return BlocConsumer<ParagraphUpdateCubit, ParagraphUpdateState>(
          listener: (context, state) {
            // TODO: implement listener
            if (state.status == ParagraphUpdateStatus.error) {
              errorDialog(context: context, error: state.error);
            }

            if (state.status == ParagraphUpdateStatus.success) {
              context
                  .read<
                  PaginationCubit<ParagraphModel, ParagraphRepository>>().update(model: state.paragraph);

              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return ModalProgressHUD(

              inAsyncCall: showSpinner,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: DefaultLayout(
                    title: widget.isEdit ? "업데이트하기" : "글쓰기",
                    onWillPop: () async => true,
                    body: SingleChildScrollView(
                      child: Form(
                        autovalidateMode: autovalidateMode,
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              initialValue: _content,
                              autocorrect: false,
                              decoration: InputDecoration(
                                filled: true,
                                labelText: "내용",
                                hintText: "내용을 입력해주세요",
                                prefixIcon: Icon(Icons.note),
                                prefixIconColor: SECONDERY_COLOR,
                                border: InputBorder.none,
                                focusedBorder: baseBorder,
                                enabledBorder: InputBorder.none,
                              ),
                              validator: (String? val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "내용을 입력해주세요";
                                }

                                return null;
                              },
                              maxLines: 6,
                              minLines: 3,
                              onSaved: (String? val) {
                                _content = val!;
                              },
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            renderShowImages(),
                            SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    state.status == ParagraphAddStatus.uploading
                                        ? null
                                        : _submit,
                                child: Text(widget.isEdit ? "업데이트하기" : "업로드하기"),
                                style: ElevatedButton.styleFrom(
                                    primary: SECONDERY_COLOR),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
              ),
            );
          },
        );
      },
    );
  }

  void pickImages() async {
    final pickedImageFiles = await imagePicker.pickMultiImage();

    setState(() {
      if (pickedImageFiles != null) {
        pickedImages = [
          ...pickedImages,
          ...pickedImageFiles.map((e) => File(e.path)).toList()
        ];
      }
    });
  }

  Widget renderShowImages() {
    if (pickedImages.length == 0) {
      return TextButton.icon(
        onPressed: pickImages,
        icon: Icon(
          Icons.add_photo_alternate_rounded,
          color: SECONDERY_COLOR,
          size: 72,
        ),
        label: Text(
          "이미지추가",
          style: TextStyle(fontSize: 24, color: SECONDERY_COLOR),
        ),
      );
    }

    return InkWell(
      onTap: pickImages,
      child: Container(
        height: 150,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final file = pickedImages[index];
              return Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                      )),
                  Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: PRIMARY_COLOR,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            pickedImages =
                                pickedImages.where((f) => file != f).toList();
                          });
                        },
                      ))
                ],
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                width: 8,
              );
            },
            itemCount: pickedImages.length),
      ),
    );
  }
}

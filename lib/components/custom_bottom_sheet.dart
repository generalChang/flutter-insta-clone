import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/comment/add/comment_add_cubit.dart';
import 'package:flutter_community/blocs/comment/update/comment_update_cubit.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/models/comment/comment_model.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/repositories/like_repository.dart';
import 'package:flutter_community/repositories/comment_repository.dart';
import 'package:flutter_community/utils/error_dialog.dart';

import '../consts/theme_const.dart';

class CustomBottomSheet extends StatefulWidget {
  final bool isEdit;
  final CommentModel? prevComment;
  final String paragraphId;
  const CustomBottomSheet(
      {Key? key,
      this.prevComment,
      this.isEdit = false,
      required this.paragraphId})
      : super(key: key);

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  String? _message;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isEdit && widget.prevComment != null) {
      setState(() {
        _message = widget.prevComment!.message;
      });
    }
  }

  void _submit() {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    form.save();

    final comment = CommentModel.initial();

    if (!widget.isEdit) {
      context.read<CommentAddCubit>().add(
          user: context.read<ProfileCubit>().state.user!,
          paragraphId: widget.paragraphId,
          message: _message!);
    } else {
      context
          .read<CommentUpdateCubit>()
          .update(comment: widget.prevComment!.copyWith(message: _message!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: SECONDERY_COLOR),
    );
    return BlocConsumer<CommentAddCubit, CommentAddState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state.status == CommentAddStatus.error) {
          errorDialog(context: context, error: state.error);
        }

        if (state.status == CommentAddStatus.success) {
          context
              .read<
                  PaginationCubit<CommentModel, CommentRepository>>()
              .add(model: state.comment);
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return BlocConsumer<CommentUpdateCubit, CommentUpdateState>(
          listener: (context, state) {
            if (state.status == CommentUpdateStatus.error) {
              errorDialog(context: context, error: state.error);
            }

            if (state.status == CommentUpdateStatus.success) {
              context
                  .read<
                  PaginationCubit<CommentModel, CommentRepository>>()
              .update(model: state.comment);
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return Container(
              padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: autovalidateMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        initialValue: _message,
                        decoration: InputDecoration(
                          filled: true,
                          labelText: "댓글작성",
                          hintText: "댓글을 입력해주세요",
                          prefixIcon: Icon(Icons.email),
                          border: InputBorder.none,
                          focusedBorder: baseBorder,
                          enabledBorder: InputBorder.none,
                        ),
                        validator: (String? val) {
                          if (val == null || val.trim().isEmpty) {
                            return "댓글을 입력해주세요";
                          }
                          return null;
                        },
                        onSaved: (String? val) {
                          _message = val;
                        },
                        minLines: 3,
                        maxLines: 6,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: state.status == CommentAddStatus.uploading
                            ? null
                            : _submit,
                        child: Text(widget.isEdit ? "수정하기" : "작성하기"),
                        style:
                            ElevatedButton.styleFrom(primary: SECONDERY_COLOR),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

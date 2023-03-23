import 'dart:io';

import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/utils/data_utils.dart';
import 'package:flutter_community/utils/error_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ProfileUpdatePage extends StatefulWidget {
  static String get routeName => "/profile/update";

  const ProfileUpdatePage({Key? key}) : super(key: key);

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  String? _name;
  final imagePicker = ImagePicker();
  File? _pickedImage;
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  bool showSpinner = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setProfile();
  }

  Future<void> setProfile() async {
    final profileState = context.read<ProfileCubit>().state;
    _name = profileState.user!.name;
    _pickedImage = await DataUtils.urlToFile(profileState.user!.photoUrl);
    setState(() {});
  }

  void _submit() {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
      showSpinner = true;
    });

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    form.save();

    final profileState = context.read<ProfileCubit>().state;

    context.read<ProfileCubit>().updateProfile(
        uid: profileState.user!.id, name: _name!, profileImage: _pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: DefaultLayout(
          onWillPop: () async => true,
          automaticallyImplyLeading: false,
          title: "프로필 업데이트",
          body: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              // TODO: implement listener
              if(state.status == ProfileStatus.error){
                setState(() {
                  showSpinner = false;
                });
                errorDialog(context: context, error: state.error);
              }

              if(state.status == ProfileStatus.success){
                setState(() {
                  showSpinner = false;
                });
                Navigator.of(context).pop();

              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: autovalidateMode,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      renderImage(),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        initialValue: _name,
                        autocorrect: false,
                        autofocus: false,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            label: Text("이름"),
                            hintText: "이름을 입력하세요",
                            prefixIcon: Icon(Icons.account_box),
                            prefixIconColor: SECONDERY_COLOR,
                            filled: true),
                        validator: (String? val) {
                          if (val == null || val.trim().isEmpty) {
                            return "이름을 입력하세요";
                          }

                          if (val.trim().length < 2) {
                            return "이름은 최소 2글자 이상이어야 합니다.";
                          }

                          return null;
                        },
                        onSaved: (String? val) {
                          _name = val;
                        },
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text("프로필 업데이트"),
                        style: ElevatedButton.styleFrom(primary: SECONDERY_COLOR),
                      )
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget renderImage() {
    if (_pickedImage == null) {
      return Center(
        child: Text("이미지를 불러오는 중입니다."),
      );
    }

    return InkWell(
      onTap: () {
        pickImages();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _pickedImage!,
          width: MediaQuery.of(context).size.width * 2 / 3,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void pickImages() async {
    final pickedImageFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
    }
  }
}

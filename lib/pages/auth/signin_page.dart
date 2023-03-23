import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/signin/signin_cubit.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/pages/auth/signup_page.dart';
import 'package:flutter_community/utils/error_dialog.dart';
import 'package:validators/validators.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  static String get routeName => "/signin";

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  String? _email, _password;

  void _submit() {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    form.save();

    context.read<SigninCubit>().signin(email: _email!, password: _password!);
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: SECONDERY_COLOR),
    );
    return BlocConsumer<SigninCubit, SigninState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state.status == SigninStatus.error) {
          errorDialog(context: context, error: state.error);
        }
      },
      builder: (context, state) {
        return DefaultLayout(
            title: "로그인",
            automaticallyImplyLeading: false,
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: autovalidateMode,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 7,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: "이메일",
                        hintText: "이메일을 입력해주세요",
                        prefixIcon: Icon(Icons.email),
                        border: InputBorder.none,
                        focusedBorder: baseBorder,
                        enabledBorder: InputBorder.none,
                      ),
                      validator: (String? val) {
                        if (val == null || val.trim().isEmpty) {
                          return "이메일을 입력해주세요";
                        }

                        if (!isEmail(val)) {
                          return "이메일 형식을 준수해주세요";
                        }

                        return null;
                      },
                      onSaved: (String? val) {
                        _email = val!.trim();
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      obscureText: true,
                      autocorrect: false,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: "비밀번호",
                        hintText: "비밀번호를 입력해주세요",
                        prefixIcon: Icon(Icons.password),
                        border: InputBorder.none,
                        focusedBorder: baseBorder,
                        enabledBorder: InputBorder.none,
                      ),
                      validator: (String? val) {
                        if (val == null || val.trim().isEmpty) {
                          return "비밀번호를 입력해주세요";
                        }

                        if (val.trim().length < 6) {
                          return "비밀번호는 최소 6자리 이상이어야 합니다.";
                        }

                        return null;
                      },
                      onSaved: (String? val) {
                        _password = val!.trim();
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: state.status == SigninStatus.submitting
                                ? null
                                : _submit,
                            child: Text("로그인"),
                            style: ElevatedButton.styleFrom(
                                primary: PRIMARY_COLOR),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextButton(onPressed: state.status == SigninStatus.submitting
                    ? null : (){
                      Navigator.of(context).pushNamed(SignupPage.routeName);
                    }, child: Text("회원가입하기"),
                    style: TextButton.styleFrom(
                      primary: SECONDERY_COLOR
                    ),)
                  ],
                ),
              ),
            ));
      },
    );
  }
}

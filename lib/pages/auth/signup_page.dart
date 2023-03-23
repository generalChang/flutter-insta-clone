import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/signup/signup_cubit.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:validators/validators.dart';

import '../../consts/theme_const.dart';
import '../../utils/error_dialog.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  static String get routeName => "/signup";

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  String? _email, _password, _name;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    form.save();

    context.read<SignupCubit>().signup(name: _name!, email: _email!, password: _password!);
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: SECONDERY_COLOR),
    );
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state.status == SignupStatus.error) {
          errorDialog(context: context, error: state.error);
        }
      },
      builder: (context, state) {
        return DefaultLayout(
            automaticallyImplyLeading: false,
            title: "로그인",
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
                      autocorrect: false,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: "이름",
                        hintText: "이름을 입력해주세요",
                        prefixIcon: Icon(Icons.account_box),
                        border: InputBorder.none,
                        focusedBorder: baseBorder,
                        enabledBorder: InputBorder.none,
                      ),
                      validator: (String? val) {
                        if (val == null || val.trim().isEmpty) {
                          return "이름을 입력해주세요";
                        }

                        if (val.trim().length < 2) {
                          return "이름은 최소 2글자 이상이어야 합니다.";
                        }

                        return null;
                      },
                      onSaved: (String? val) {
                        _name = val!.trim();
                      },
                    ),
                    SizedBox(
                      height: 16,
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
                      controller: _passwordController,
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
                    TextFormField(
                      obscureText: true,
                      autocorrect: false,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: "비밀번호 확인",
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

                        if (_passwordController.text != val) {
                          return "비밀번호가 일치하지 않습니다.";
                        }

                        return null;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: state.status == SignupStatus.submitting
                                ? null
                                : _submit,
                            child: Text("회원가입"),
                            style: ElevatedButton.styleFrom(
                                primary: PRIMARY_COLOR),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextButton(
                      onPressed: state.status == SignupStatus.submitting
                          ? null
                          : () {
                              Navigator.of(context)
                                  .pop();
                            },
                      child: Text("로그인하기"),
                      style: TextButton.styleFrom(primary: SECONDERY_COLOR),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}

import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/auth/auth_bloc.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/pages/main_page.dart';
import 'package:flutter_community/pages/auth/signin_page.dart';

class SplashPage extends StatelessWidget {
  static String get routeName => "/";

  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // TODO: implement listener
        if(state.status == AuthStatus.unauthenticated){
          Navigator.of(context).pushNamedAndRemoveUntil(SigninPage.routeName, (route) {
            return route.settings.name == ModalRoute.of(context)!.settings.name ? true : false;
          });
        }else if(state.status == AuthStatus.authenticated){
          Navigator.of(context).pushNamedAndRemoveUntil(MainPage.routeName, (route) {
            return route.settings.name == ModalRoute.of(context)!.settings.name ? true : false;
          });
        }
      },
      builder: (context, state) {
        return DefaultLayout(
          scaffoldBackgroundColor: PRIMARY_COLOR,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white,),
          ),
        );
      },
    );
  }
}

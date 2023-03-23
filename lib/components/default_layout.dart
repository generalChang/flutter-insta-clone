import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_community/consts/theme_const.dart';

class DefaultLayout extends StatefulWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Color? appBarBackgroundColor;
  final Color? appBarForegroundColor;
  final Widget? floatingActionButton;
  final Color? scaffoldBackgroundColor;
  final bool automaticallyImplyLeading;
  final Widget? bottomNavigationBar;
  final Future<bool> Function()? onWillPop;
  const DefaultLayout(
      {Key? key,
        this.onWillPop,
        this.bottomNavigationBar,
      this.scaffoldBackgroundColor,
      this.floatingActionButton,
      this.appBarForegroundColor,
      this.appBarBackgroundColor,
      this.automaticallyImplyLeading = true,
      required this.body,
      this.title,
      this.actions})
      : super(key: key);

  @override
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: widget.onWillPop ?? _onWillPop,
      child: Scaffold(
        bottomNavigationBar: widget.bottomNavigationBar,
        backgroundColor: widget.scaffoldBackgroundColor ?? Colors.white,
        appBar: renderAppbar(),
        floatingActionButton: widget.floatingActionButton,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: widget.body,
        )),
      ),
    );
  }

  AppBar? renderAppbar() {
    if (widget.title == null) {
      return null;
    }

    return AppBar(
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      title: Text(widget.title!),
      foregroundColor: widget.appBarForegroundColor ?? PRIMARY_COLOR,
      backgroundColor: widget.appBarBackgroundColor ?? Colors.white,
      actions: widget.actions,
      elevation: 2,
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) =>  AlertDialog(
        title:  Text("확인 메세지"),
        content:  Text('앱을 종료하시겠습니까?'),
        actions: <Widget>[
           TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:  Text('취소'),
          ),
           TextButton(
            onPressed: () => SystemNavigator.pop(),
            child:  Text('종료'),
          ),
        ],
      ),
    )) ?? false;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
//import 'package:prowes_motorizado/src/widgets/pedidos_motorizado_widget.dart';

class PageBuilder extends StatelessWidget {
  final Widget bodyWidget;
  final Widget? title;
  final bool colored;
  final bool navigation;

  const PageBuilder(
      {Key? key,
      required this.bodyWidget,
      this.title,
      this.colored = true,
      this.navigation = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10.h,
        backgroundColor: Colors.white,
        leading: navigation
            ? IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                iconSize: 20.h,
                tooltip: 'Regresar',
                color: Colors.black,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        flexibleSpace: colored
            ? Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                      CustomColors.primaryColor,
                      CustomColors.primaryColor,
                      CustomColors.primaryColor,
                    ])),
              )
            : null,
        toolbarHeight: 50.h,
        centerTitle: true,
        title: title ?? defaultTitle(),
      ),
      body: bodyWidget,
    );
  }

  Widget defaultTitle() {
    return Image.asset(
      'assets/images/Logo_2.1.png',
      fit: BoxFit.contain,
      height: 100.h,
      width: 100.h,
    );
  }
}

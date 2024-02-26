  
import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';

Future<void> delayedPop(BuildContext context, {home = true}) async {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WillPopScope(
          onWillPop: () async => false,
          child: const Scaffold(
            backgroundColor: Colors.black45,
            body: Center(
              child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColors.textColor),
                      ),
            ),
          ),
        ),
        transitionDuration: Duration.zero,
        barrierDismissible: false,
        barrierColor: Colors.black45,
        opaque: false,
      ),
    //),
  );
  await Future.delayed(const Duration(seconds: 1)) ;
  if (home) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  } else {
    Navigator.pop(context);
    Navigator.pop(context);
  }
  
}
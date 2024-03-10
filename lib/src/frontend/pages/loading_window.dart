import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';

Future<void> delayedPop(BuildContext context, {bool home = true}) async {
  // Asegúrate de que el contexto no sea nulo antes de usarlo
  assert(context != null);

  // Mostrar un widget de carga mientras esperamos
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => WillPopScope(
        onWillPop: () async => false,
        child: const Scaffold(
          backgroundColor: Colors.black45,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomColors.textColor),
            ),
          ),
        ),
      ),
      transitionDuration: Duration.zero,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      opaque: false,
    ),
  );

  // Esperar un segundo antes de realizar la navegación
  await Future.delayed(const Duration(seconds: 1));

  // Realizar la navegación según el valor de 'home'
  if (home) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  } else {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}

import 'package:flutter/material.dart';

class SnackBarTool {
  static void showSnackbar(BuildContext context, {
    required String text,
    Duration duration = const Duration(seconds: 2),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    SnackBarAction? action,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    VoidCallback? onTap,
  }) {
    final snackBar = SnackBar(
      content: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
      duration: duration,
      backgroundColor: backgroundColor,
      behavior: behavior,
      action: action,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

/*ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  'Cliente Registrado.'),
                                              duration: const Duration(
                                                  milliseconds: 1500),

                                              width: 280.0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              // Inner padding for SnackBar content.
                                            ),
                                          );*/
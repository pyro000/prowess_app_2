import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:prowes_motorizado/src/frontend/pages/confirm_location_page.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';

class CheckOutButton extends StatelessWidget {
  const CheckOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: () {
            siguiente(context);
          },
          child: Container(
            padding: const EdgeInsets.all(5.0),
            margin: EdgeInsets.symmetric(horizontal: 0.h, vertical: 0.h),
            decoration: BoxDecoration(
              color: CustomColors.secondaryColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Pedir ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.h,
                  ),
                ),
                Icon(
                  Icons.arrow_right_alt,
                  color: Colors.white,
                  size: 15.h,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void siguiente(BuildContext context) {
    var content = json.decode(MainProvider.instance.data);

    String msg = "Elija la ubicación exacta de retiro.";

    if (!content.containsKey("carrito")) {
      content["carrito"] = [];
    }

    if (content["carrito"].length > 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MapPage()));
    } else {
      msg = "No hay productos en el carrito.";
      Navigator.of(context).pop();
    }

    SnackBarTool.showSnackbar(
      context,
      text: msg,
    );
  }
}

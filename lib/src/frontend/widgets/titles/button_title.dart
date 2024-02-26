import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
//import 'package:prowes_motorizado/src/widgets/pedidos_motorizado_widget.dart';

class ButtonTitle extends StatelessWidget {
  final Widget bodyWidget;
  const ButtonTitle({Key? key, required this.bodyWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Spacer(),
      Image.asset(
        'assets/images/Logo_2.1.png',
        alignment: Alignment.centerRight,
        fit: BoxFit.contain,
        height: 100.h,
        width: 100.h,
      ),
      Spacer(),
      bodyWidget,
    ]);
  }
}

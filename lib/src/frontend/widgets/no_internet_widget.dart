import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200.h,
            height: 200.h,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 25.h),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/nowifi.png"))),
          ),
          Text("Sin conexión a internet ",
              style: TextStyle(fontSize: 23.h, fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.all(15.h),
            child: Text(
              "Intente conectar el WI-FI o los datos moviles, para el uso correcto de la app",
              style: TextStyle(fontSize: 16.h),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}

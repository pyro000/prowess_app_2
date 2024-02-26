// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class RedesSocialesWidget extends StatelessWidget {
  const RedesSocialesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(5.h, 5.h, 5.h, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Redes Sociales",
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 20,
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Image(
                        image: AssetImage('assets/images/tiktok.png'),
                        width: 52.h,
                      ),
                      onTap: () =>
                          launch('https://www.tiktok.com/@totalprowess_ec'),
                    ),
                    SizedBox(width: 16.h), // Espacio entre las imágenes
                    InkWell(
                      child: Image(
                        image: AssetImage('assets/images/instagram.png'),
                        width: 52.h,
                      ),
                      onTap: () =>
                          launch('https://www.instagram.com/prowess_ec/'),
                    ),
                    SizedBox(width: 16.h), // Espacio entre las imágenes
                    InkWell(
                      child: Image(
                        image: AssetImage('assets/images/facebook.png'),
                        width: 52.h,
                      ),
                      onTap: () =>
                          launch('https://www.facebook.com/prowess.ec'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

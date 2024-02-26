// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';

class ContactosWidget extends StatelessWidget {
  const ContactosWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Dr. Luis Simbaña Taipe",
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 18,
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.fromLTRB(22.h, 5.h, 30.h, 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => launch('https://wa.me/+593998160293'),
                      child: Image(
                        image: AssetImage('assets/images/whatsapp.png'),
                        width: 35.h,
                        height: 35.h,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                InkWell(
                  onTap: () => launch('tel:+593998160293'),
                  child: Text(
                    "+593 99 816 0293",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 14.h,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => launch('mailto:prowessagronomia@gmail.com'),
                      child: Image(
                        image: AssetImage('assets/images/email.png'),
                        width: 55.h,
                        height: 35.h,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                InkWell(
                  onTap: () => launch('mailto:prowessagronomia@gmail.com'),
                  child: Text(
                    "prowessagronomia@gmail.com",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 14.h,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildRaisedButton(String text, dynamic event) {
    return Expanded(
      child: GestureDetector(
        child: Text(
          text,
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            fontSize: 14.h,
            color: CustomColors.primaryColor,
          ),
        ),
        onTap: event,
      ),
    );
  }
}

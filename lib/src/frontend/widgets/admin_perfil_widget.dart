import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/frontend/pages/singup_user_page.dart';
//import 'package:prowes_motorizado/src/pages/singup_admin_page.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/frontend/widgets/stack_container.dart';

import 'dart:convert';
import 'package:prowes_motorizado/src/frontend/pages/singup_transporte_page.dart';

class AdminPerfil extends StatefulWidget {
  const AdminPerfil({Key? key}) : super(key: key);

  @override
  State<AdminPerfil> createState() => _AdminWidgetState();
}

class _AdminWidgetState extends State<AdminPerfil> {
  TextStyle _styleTitle() {
    return TextStyle(fontSize: 13.h, color: Colors.grey);
  }

  TextStyle _styleContain() {
    return TextStyle(fontSize: 16.h, fontWeight: FontWeight.w600);
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = MainProvider.instance;
    Map<String, dynamic> content = json.decode(mainProvider.data);
    String? imagenPerfil = content["datos"]["imagen"];

    return /*Scaffold(
      body:*/
        Column(
      children: <Widget>[
        StackContainer(
          imagenPerfil: imagenPerfil,
          content: content,
          mainProvider: mainProvider,
          isadmin: true,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Icon(Icons.badge),
                SizedBox(height: 8.h),
                Text("Cédula", style: _styleTitle()),
                Text(content["datos"]["cedula"], style: _styleContain()),
                SizedBox(height: 8.h),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.account_circle_sharp),
                SizedBox(height: 8.h),
                Text("Rol", style: _styleTitle()),
                Text(content["rol"], style: _styleContain()),
                SizedBox(height: 8.h),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.call),
                SizedBox(height: 8.h),
                Text("Teléfono", style: _styleTitle()),
                Text(content["datos"]["telefono"], style: _styleContain()),
                SizedBox(height: 8.h),
              ],
            )
          ],
        ),
        SizedBox(height: 8.h),
        const Icon(Icons.mail_outline),
        Text("Correo", style: _styleTitle()),
        Text(
          content["email"],
          style: _styleContain(),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: MaterialButton(
            minWidth: 250.h,
            height: 50.h,
            color: CustomColors.secondaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.h)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const SingUpPage(),
                ),
              );
            },
            child: const Text(
              "Registrar Motorizado",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: MaterialButton(
            minWidth: 250.h,
            height: 50.h,
            color: CustomColors.secondaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.h)),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpUserPage(
                        role: "Administrador"), //SingupAdmin()
                  ));
            },
            child: const Text(
              "Registrar Administrador",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ],
    );
    //);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/frontend/widgets/stack_container.dart';

import 'dart:convert';

class UserWidget extends StatefulWidget {
  const UserWidget({Key? key}) : super(key: key);

  @override
  State<UserWidget> createState() => _AdminWidgetState();
}

class _AdminWidgetState extends State<UserWidget> {
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

    return Scaffold(
      body: Column(
        children: <Widget>[
          StackContainer(
            imagenPerfil: imagenPerfil,
            content: content,
            mainProvider: mainProvider,
            isadmin: false,
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
        ],
      ),
    );
  }
}

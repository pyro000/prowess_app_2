import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/frontend/widgets/stack_container.dart';
import 'dart:convert';

class PerfilWidget extends StatefulWidget {
  const PerfilWidget({Key? key}) : super(key: key);

  @override
  State<PerfilWidget> createState() => _PerfilWidgetState();
}

class _PerfilWidgetState extends State<PerfilWidget> {
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
    String fechaCad = content["datos"]["transporte"]["caducidad_licencia"];
    DateTime date = DateTime.parse(fechaCad);

    return ListView(
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
                const Icon(Icons.call),
                SizedBox(height: 8.h),
                Text("Teléfono", style: _styleTitle()),
                Text(content["datos"]["telefono"], style: _styleContain()),
                SizedBox(height: 15.h),
                const Icon(Icons.badge),
                Text("Cédula", style: _styleTitle()),
                Text(content["datos"]["cedula"], style: _styleContain()),
                SizedBox(height: 15.h),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.two_wheeler),
                SizedBox(height: 8.h),
                Text("Rol", style: _styleTitle()),
                Text(content["rol"], style: _styleContain()),
                SizedBox(height: 15.h),
                const Icon(Icons.sticky_note_2),
                Text("Placa Vehiculo", style: _styleTitle()),
                Text(content["datos"]["transporte"]["placa"],
                    style: _styleContain()),
                SizedBox(height: 15.h),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.badge),
                SizedBox(height: 8.h),
                Text("Tipo de Licencia", style: _styleTitle()),
                Text(content["datos"]["transporte"]["tipo_licencia"],
                    style: _styleContain()),
                SizedBox(height: 15.h),
                const Icon(Icons.date_range_sharp),
                Text("F. de Caducidad", style: _styleTitle()),
                Text('${date.day} / ${date.month} / ${date.year}',
                    style: _styleContain()),
                SizedBox(height: 15.h),
              ],
            )
          ],
        ),
        const Icon(Icons.mail_outline),
        Text("Correo", textAlign: TextAlign.center, style: _styleTitle()),
        Text(
          content["email"],
          textAlign: TextAlign.center,
          style: _styleContain(),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}

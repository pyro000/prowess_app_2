import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/frontend/widgets/contactos_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/redes_sociales_widget.dart';

class OpcionesWidget extends StatefulWidget {
  const OpcionesWidget({Key? key}) : super(key: key);

  @override
  State<OpcionesWidget> createState() => _OpcionesWidgetState();
}

class _OpcionesWidgetState extends State<OpcionesWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.h, left: 50.h, right: 50.h),
              child: Material(
                child: SizedBox(
                  width: 184,
                  height: 111,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 30.h),
                        const Text(
                          "Contáctanos",
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "¿Alguna pregunta u observación?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(112, 112, 112, 1),
                              fontSize: 14,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.normal),
                        ),
                        const Text(
                          "¡Escríbanos un mensaje!",
                          style: TextStyle(
                              color: Color.fromRGBO(112, 112, 112, 1),
                              fontSize: 14,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              margin: EdgeInsets.fromLTRB(25.h, 5.h, 25.h, 5.h),
              width: 352,
              height: 452,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/backcontainer_1.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Información de contacto",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 23,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "Dinos algo para iniciar un chat en directo",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(200, 200, 200, 1),
                      fontSize: 13,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  ContactosWidget(),
                  RedesSocialesWidget()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

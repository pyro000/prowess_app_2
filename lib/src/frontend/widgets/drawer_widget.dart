import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/services/launch_services.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';

// Widget del cajón lateral (Drawer) utilizado para la navegación en la aplicación
class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    Key? key,
    required this.phoneCom,
    required this.phoneVen,
    required this.nameCom,
    required this.nameVen,
  }) : super(key: key);

  final String phoneCom, phoneVen, nameCom, nameVen;

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Ink(
        // Decoración del fondo del Drawer con gradiente de colores
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CustomColors.primaryColor,
               CustomColors.primaryColor,
               CustomColors.primaryColor
            ],
          ),
        ),
        // Contenido del Drawer con una lista de elementos
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Encabezado del Drawer con el logo de la aplicación
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                     CustomColors.primaryColor,
                     CustomColors.primaryColor,
                     CustomColors.primaryColor
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Logo de la aplicación
                  Expanded(
                    child: Image.asset(
                      'assets/images/Logo_3.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            // Sección de información personal del comprador y vendedor
            Container(
              margin: EdgeInsets.all(5.h),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  // Título y separador para la sección del comprador
                  persona('Comprador'),
                  SizedBox(height: 10.h),
                  // Nombre del comprador
                  Center(
                    child: Text(
                      widget.nameCom,
                      style: TextStyle(
                        fontSize: 18.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Número de teléfono del comprador con icono para llamar
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    child: ListTile(
                      leading: const Icon(
                        Icons.phone_forwarded_outlined,
                        color: Colors.black,
                      ),
                      title: Text(
                        widget.phoneCom,
                        style: TextStyle(
                          fontSize: 18.h,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      onTap: () {
                        // Función para llamar al número del comprador
                        launchPhone(widget.phoneCom);
                      },
                    ),
                  ),
                  // Ícono de WhatsApp para enviar mensajes
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/whatsapp.png',
                        fit: BoxFit.contain,
                        //color: Colors.black,
                        width: 23.h,
                      ),
                      title: Text(
                        'Escríbenos al WhatsApp',
                        style: TextStyle(
                          fontSize: 18.h,
                          fontWeight: FontWeight.w300,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: () {
                        // Función para abrir WhatsApp al número del comprador
                        launchWhatsApp(widget.phoneCom);
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Título y separador para la sección del vendedor
                  persona('Vendedor'),
                  SizedBox(height: 10.h),
                  // Nombre del vendedor
                  Center(
                    child: Text(
                      widget.nameVen,
                      style: TextStyle(
                        fontSize: 18.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Número de teléfono del vendedor con icono para llamar
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    child: ListTile(
                      leading: const Icon(
                        Icons.phone_forwarded_outlined,
                        color: Colors.black,
                      ),
                      title: Text(
                        widget.phoneVen,
                        style: TextStyle(
                          fontSize: 18.h,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      onTap: () {
                        // Función para llamar al número del vendedor
                        launchPhone(widget.phoneVen);
                      },
                    ),
                  ),
                  // Ícono de WhatsApp para enviar mensajes al vendedor
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/whatsapp.png',
                        fit: BoxFit.contain,
                        //color: Colors.black,
                        width: 23.h,
                      ),
                      title: Text(
                        'Escríbenos al WhatsApp',
                        style: TextStyle(
                          fontSize: 18.h,
                          fontWeight: FontWeight.w300,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: () {
                        // Función para abrir WhatsApp al número del vendedor
                        launchWhatsApp(widget.phoneVen);
                      },
                    ),
                  ),
                  /*SizedBox(height: 12.h),
                  // Botón flotante para la acción de "Entregar"
                  FloatingActionButton.extended(
                    onPressed: () {},
                    icon: const Icon(Icons.check, color: Colors.black),
                    label: const Text(
                      'Entregar',
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: const Color.fromARGB(255, 97, 206, 112),
                  ),
                  SizedBox(height: 12.h),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar un separador con un título
  Widget persona(String tipo) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 1.h,
            thickness: 1.h,
            indent: 18.h,
            endIndent: 18.h,
            color: Colors.black,
          ),
        ),
        Text(
          tipo,
          style: TextStyle(fontSize: 25.h, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Divider(
            height: 1.h,
            thickness: 1.h,
            indent: 18.h,
            endIndent: 18.h,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class NoLocation extends StatelessWidget {
  const NoLocation({Key? key}) : super(key: key);

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
                    image: AssetImage("assets/images/marker.png"))),
          ),
          Text("Ubicación no activada.",
              style: TextStyle(fontSize: 23.h, fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.all(15.h),
            child: Text(
              "Intente activar la ubicación o dar permisos a la aplicación para acceder a la ubicación para continuar.",
              style: TextStyle(fontSize: 16.h),
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Fluttertoast.showToast(
                msg:
                    'Active la ubicación, o busque nuestra app, y seleccione "Permitir".',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                //backgroundColor: Colors.black87,
                //textColor: Colors.white,
                //fontSize: 64.0,
              );
              await Geolocator.openLocationSettings();
            },
            child: const Text('Abrir Configuración de Ubicación'),
          ),
        ],
      ),
    );
  }
}

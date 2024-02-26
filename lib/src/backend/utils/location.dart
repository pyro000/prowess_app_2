import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';

Future<Position> determinarPosicion() async {
  //Cuando los servisioes de localización ested desabilitados
  //la función devolverá un error
  bool servicioHabilitado;
  LocationPermission permiso;
  //Prueba si los servicios de localización estan habilitados
  servicioHabilitado = await Geolocator.isLocationServiceEnabled();

  if (!servicioHabilitado) {
    return Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
  }

  //Compruebo que exista permisos
  permiso = await Geolocator.checkPermission();
  var totem = true;

  while (totem) {
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.whileInUse ||
        permiso == LocationPermission.always) {
      totem = false;
    }
    if (permiso == LocationPermission.deniedForever) {
      totem = false;
      return Position(
          longitude: 0,
          latitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);
    }
  }

  //Cuando llegue aquí, los permisos han sido aceptados
  //Se puede acceder a la posición del dispositivo
  return await Geolocator.getCurrentPosition();
}

LatLng getLocation() {
  var poss = MainProvider.instance.location.split("/");
  log("${MainProvider.instance.location} ${poss.length}");
  if (poss.length != 2) {
    return LatLng(0, 0);
  }

  var pos = LatLng(double.parse(poss[0]), double.parse(poss[1]));
  return pos;
}

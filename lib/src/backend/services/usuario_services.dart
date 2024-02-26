import 'dart:developer';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/services/pedidos_service.dart';
import 'package:prowes_motorizado/src/backend/utils/hasher.dart';

//POSTMAN
class UsuarioService {
  UsuarioService();

  final hasher = Hasher();
  final pedServ = PedidoService();

  Future<int> resetPassword(String email, String password) async {
    var col = FirestoreManager.instance.firestore
          .collection("UsuariosDel")
          .where("email", isEqualTo: email);

    var list = await FirestoreManager.instance.getData("", collection: col);

    if (list.isNotEmpty){
      var map = list.first;
      map["password"] = hasher.hashPassword(password);

      await FirestoreManager.instance
        .postData("UsuariosDel", map, uid: map["uid"], edit: true);
    } else {
      return 500;
    }

    return 200;
  }

  Future<Map<String, dynamic>> login2(Usuario usuario) async {
    try {
      var col = FirestoreManager.instance.firestore
          .collection("UsuariosDel")
          .where("email", isEqualTo: usuario.email);

      var map = await FirestoreManager.instance.getData("", collection: col);

      var pass = usuario.password.toString();
      var result = map.first;

      //log(result.toString());

      bool logged = hasher.checkPassword(pass, result["password"]);
      if (!logged) {
        return <String, dynamic>{};
      }
      return result;
    } catch (e) {
      log(e.toString());
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> postMotorizado2(Usuario motorizado) async {
    try {
      motorizado.password = hasher.hashPassword(motorizado.password.toString());
      var usuarioBody = motorizado.toJson();
      String uid =
          await FirestoreManager.instance.postData("UsuariosDel", usuarioBody);
      return {"uid": uid, "response": 201, "pass": motorizado.password};
    } catch (ex) {
      log("postMotorizado2 Error: $ex");
      return {"uid": "", "response": 500, "pass": ""};
    }
  }



  Future<void> updateLocation(String uid, LatLng loc) async {
    var list = await FirestoreManager.instance.getData("UsuariosDel", uid: uid);
    var map = list.first;

    var coords = {
      "lat": loc.latitude.toString(),
      "long": loc.longitude.toString()
    };

    map["datos"]["coords"] = coords;

    await FirestoreManager.instance
        .postData("UsuariosDel", map, uid: uid, edit: true);

    var list1 = await pedServ.getPedido(uid1: uid, prior: true);

    for (var ped in list1) {
      if (ped.motorizado != null) {
        ped.motorizado!.coords = coords;
      }
      
      var result = ped.toJson();

      await FirestoreManager.instance.postData("OrdenDel", result, uid: ped.numPedido!);
    }
  }

  Future<int> setRecoverCode(String email, int code) async {

    var col = FirestoreManager.instance.firestore
          .collection("UsuariosDel")
          .where("email", isEqualTo: email);

    var list = await FirestoreManager.instance.getData("", collection: col);

    if (list.isNotEmpty){
      var map = list.first;
      map["datos"]["codigo"] = code;

      await FirestoreManager.instance
        .postData("UsuariosDel", map, uid: map["uid"], edit: true);
    } else {
      return 500;
    }

    return 200;
  }


  Future<int> checkRecoverCode(String email, int code) async {
    var col = FirestoreManager.instance.firestore
          .collection("UsuariosDel")
          .where("email", isEqualTo: email);

    var list = await FirestoreManager.instance.getData("", collection: col);

    if (list.isNotEmpty){
      var map = list.first;
      if (map["datos"]["codigo"] == code){
        map["datos"].remove("codigo");
        await FirestoreManager.instance
          .postData("UsuariosDel", map, uid: map["uid"], edit: true);
      } else {
        return 500;
      }
    } else {
      return 500;
    }

    return 200;
  }
}

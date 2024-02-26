import 'dart:developer';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';


class MotorizadoService {
  MotorizadoService();
  Future<List<Usuario>?> getPedidoM() async {
    List<Usuario> result = [];
    List<Map<String, dynamic>> map = [];

    try {
      log("getMotorizado()");
      map = await FirestoreManager.instance.getData("UsuariosDel");
      //var list = map.first;

      log("${map.length}");
      //log("\n\n-------------------------------------\n\n");
    } catch (ex) {
      log("Error getPedidoM: $ex");
      return result;
    }

    //log("$map");
  
    for (var item in map) {
      try {
        //log("$item");
        //log("\n\n-------------------------------------\n\n");

        final pedido = Usuario.fromJson(item);
        result.add(pedido);

        //log("data: ${pedido.name} ${pedido.sector} ${pedido.profileImage}");

      } on NoSuchMethodError {
        //return result;
        final pedido = Usuario.fromJsonClient(item);
        result.add(pedido);

        //log("data: ${pedido.name} ${pedido.sector} ${pedido.profileImage}");
      }
      catch (ex) {
        //return result;
        log("error getMotorizado getPedidoM: $ex"); 
      }
    }
    return result;
  }
}
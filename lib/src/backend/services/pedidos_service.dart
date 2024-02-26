import 'dart:convert';
import 'dart:developer';
import 'package:firedart/generated/google/type/latlng.pb.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart'
    as loc;
import 'package:prowes_motorizado/src/backend/models/comprador_model.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
//import 'package:prowes_motorizado/src/models/producto_model.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/models/vendedor_model.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/utils/distance.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prowes_motorizado/src/backend/utils/location.dart';

class PedidoService {
  PedidoService();

  Future<List<Pedido>> getPedido(
      {String uid = "",
      String uid1 = "",
      prior = false,
      client = false}) async {
    List<Pedido> result = [];

    var map =
        await pullPedidos(uid: uid, uid1: uid1, prior: prior, client: client);

    var pos = getLocation();
    result = await processPedidos(map, pos, client);
    
    return result;
  }

  Future<List<Map<String, dynamic>>> pullPedidos(
      {String uid = "",
      String uid1 = "",
      prior = false,
      client = false}) async {
    String selTable = client ? "ord_cliente.uid" : "motorizado.uid";
    List<Map<String, dynamic>> map = [];

    try {
      //log("ped2");

      var col = FirestoreManager.instance.firestore
          .collection("OrdenDel")
          .where("ord_estado", isEqualTo: "Libre");
      //log("ped3");
      var col1 = FirestoreManager.instance.firestore
          .collection("OrdenDel")
          .where(/*"ord_uidMot"*/ selTable, isEqualTo: uid1);

      //log("ped4");

      if (uid.isEmpty && uid1.isEmpty) {
        map = await FirestoreManager.instance.getData("OrdenDel");
      } else if (uid.isNotEmpty) {
        map = await FirestoreManager.instance.getData("OrdenDel", uid: uid);
      } else if (uid1.isNotEmpty) {
        //var ids = [];
        if (!prior) {
          map = await FirestoreManager.instance.getData("", collection: col);
        }

        var mapaux =
            await FirestoreManager.instance.getData("", collection: col1);

        map = map + mapaux;
      }

      //log("getPedidoFirestore()");
    } catch (ex) {
      log("Error getPedido(): $ex");
      //return map;
    }
    return map;
  }

  Future<List<Pedido>> processPedidos(
      List<Map<String, dynamic>> map, loc.LatLng pos, bool client) async {
    List<Pedido> result = [];

    for (var item in map) {
      try {
        if (client && item["ord_estado"] == "Completado") continue;

        double dist = await calculateOrderDistance(item, pos);

        item["distance"] = dist;

        if (!item.containsKey("motorizado")) {
          var mot = Usuario();
          item["motorizado"] = mot.stock();
        }

        final pedido = Pedido.fromJson(item);

        result.add(pedido);
        //log("ITEM: $item");
      } catch (ex) {
        log("Error processPedidos(): $ex");
      }
    }
    return result;
  }

  Future<int> resetEstado(Pedido pedido) async {
    try {
      return putEstado2("Libre", pedido.numPedido ?? "", clear: true);
    } catch (ex) {
      return 500;
    }
  }

  Future<int> putEstado2(String estado, String uidOrden,
      {clear = false, setMot = false}) async {
    try {
      var data = json.decode(MainProvider.instance.data);
      var list =
          await FirestoreManager.instance.getData("OrdenDel", uid: uidOrden);
      var map = list.first;

      //log("MAP BEF: $map");

      if (clear) {
        map.remove("motorizado");
      } else if (setMot) {
        var motc1 = Usuario.fromJson(data);
        var motf = motc1.toJsonMot();
        map["motorizado"] = motf;
      }

      map["ord_estado"] = estado;

      //log("MAP AFTER: $map");

      await FirestoreManager.instance
          .postData("OrdenDel", map, uid: uidOrden, edit: true);

      log("putEstado2()");
      return 200;
    } catch (ex) {
      return 500;
    }
  }

  Future<String> getEstado(String uidOrden) async {
    try {
      var map =
          await FirestoreManager.instance.getData("OrdenDel", uid: uidOrden);
      var result = map.first["ord_estado"].toString();
      return result;
    } catch (e) {
      log("Err getestado: $e");
      return "";
    }
  }

  Future<String> newPedido(
      List<Map<String, dynamic>> productos, String uidcliente) async {
    try {
      Map<String, dynamic> data = {'ord_productos': productos};

      data['ord_estado'] = "Libre";
      data['ord_fecha'] = DateTime.now();
      data['ord_pago'] = {
        'tipo_de_pago': '',
        'total_tax': '',
      };

      var col = FirestoreManager.instance.firestore
          .collection("UsuariosDel")
          .where("rol", isEqualTo: "Administrador");
      var map = await FirestoreManager.instance.getData("", collection: col);
      var lven = map.first;

      var lven1 = Vendedor.fromJson(lven);
      var lvenf = lven1.toJson();

      data['ord_vendedor'] = lvenf;

      var cli = await FirestoreManager.instance
          .getData("UsuariosDel", uid: uidcliente);
      var lcli = cli.first;
      var lcli1 = Comprador.fromJson(lcli);
      var lclif = lcli1.toJson();

      data['ord_cliente'] = lclif;
      data['ord_cocinado'] = false;

      var len = productos.length;
      double ptotal = 0;

      for (int i = 0; i < len; i++) {
        Map<String, dynamic> d = productos[i];
        ptotal += d["total"].toDouble();
      }

      data['total'] = ptotal;

      var uid = await FirestoreManager.instance.postData("OrdenDel", data);
      
      //log("newPedido()");
      return uid;
    } catch (ex) {
      log("newPedido() ERROR: $ex");

      return "";
    }
  }
}

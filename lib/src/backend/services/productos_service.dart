import 'dart:developer';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';

class ProductoService {
  ProductoService();

  Future<List<Producto>?> getProductos(
      {String uid = "", String uid1 = ""}) async {
    List<Producto> result = [];
    List<Map<String, dynamic>> map;

    try {
      var col = FirestoreManager.instance.firestore.collection("producto");
      // antes PlatosDel
      map = await FirestoreManager.instance.getData("", collection: col);

    } catch (ex) {
      log("Error ProductoService: $ex");
      return result;
    }

    
    for (var p in map) {
      try {
        Producto prod = Producto.fromJson(p);
        result.add(prod); 
      } catch (ex) {
        log("Error ProductoServiceLoop: $ex");
      }
    }

      //log("$result");
      return result;
  }
}

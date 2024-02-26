import 'dart:convert';
import 'package:prowes_motorizado/src/backend/models/comprador_model.dart';
import 'package:prowes_motorizado/src/backend/models/pago_model.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
import 'package:prowes_motorizado/src/backend/models/vendedor_model.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';

Pedido pedidoFromJson(String str) => Pedido.fromJson(json.decode(str));
String pedidoToJson(Pedido data) => json.encode(data.toJson());

class Pedido {
  Pedido({
    this.numPedido,
    this.estado,
    this.fecha,
    this.comprador,
    this.vendedor,
    this.productos,
    this.pago,
    this.motorizado,
    this.distance,
    this.total,
    this.cocinado,
  });

  String? numPedido;
  String? estado;
  DateTime? fecha;
  Comprador? comprador;
  Vendedor? vendedor;
  Usuario? motorizado;
  List<Producto>? productos;
  Pago? pago;
  double? distance;
  double? total;
  bool? cocinado;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pedido &&
          runtimeType == other.runtimeType &&
          numPedido == other.numPedido &&
          estado == other.estado &&
          fecha == other.fecha &&
          comprador == other.comprador &&
          vendedor == other.vendedor &&
          motorizado == other.motorizado &&
          productosListEquals(productos,
              other.productos) && // Llama a la función productosListEquals
          pago == other.pago &&
          distance == other.distance &&
          total == other.total &&
          cocinado == other.cocinado;

  @override
  int get hashCode =>
      numPedido.hashCode ^
      estado.hashCode ^
      fecha.hashCode ^
      comprador.hashCode ^
      vendedor.hashCode ^
      motorizado.hashCode ^
      productos.hashCode ^
      pago.hashCode ^
      distance.hashCode ^
      total.hashCode;

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
        numPedido: json["uid"],
        estado: json["ord_estado"],
        fecha: json["ord_fecha"],
        comprador: Comprador.fromJson(json["ord_cliente"]),
        vendedor: Vendedor.fromJson(json["ord_vendedor"]),
        motorizado: Usuario.fromJson(json["motorizado"]),
        pago: Pago.fromJson(json["ord_pago"]),
        productos: List<Producto>.from(
            json["ord_productos"].map((x) => Producto.fromJson3(x))),
        distance: json["distance"],
        total: json["total"].toDouble(),
        cocinado: json["ord_cocinado"],
      );

  Map<String, dynamic> toJson() => {
        "ord_estado": estado,
        "ord_fecha": fecha,
        "ord_cliente": comprador!.toJson(),
        "ord_vendedor": vendedor!.toJson(),
        "motorizado": motorizado!.toJsonMot(),
        "ord_productos": List<dynamic>.from(productos!.map((x) => x.toJson2())),
        "ord_pago": pago!.toJson(),
        "distance": distance,
        "total": total,
        "ord_cocinado": cocinado,
      };
}

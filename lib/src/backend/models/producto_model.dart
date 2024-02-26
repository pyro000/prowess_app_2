import 'dart:convert';
import 'package:flutter/foundation.dart'; // Importante para usar listEquals

Producto pedidoFromJson(String str) => Producto.fromJson(json.decode(str));
String pedidoToJson(Producto data) => json.encode(data.toJson());

class Producto {
  Producto({
    //this.numProducto,
    this.id,
    this.nombre,
    //this.estado,
    this.categoria,
    this.precio,
    this.total,
    this.cantidad,
    this.stock,
    this.imagen,
  });

  //String? numProducto;
  int? id;
  String? nombre;
  //String? estado;
  String? categoria;
  double? precio;
  double? total;
  int? stock;
  int? cantidad;
  String? imagen;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Producto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nombre == other.nombre &&
          categoria == other.categoria &&
          precio == other.precio &&
          total == other.total &&
          stock == other.stock &&
          cantidad == other.cantidad &&
          imagen == other.imagen;

  @override
  int get hashCode =>
      id.hashCode ^
      nombre.hashCode ^
      categoria.hashCode ^
      precio.hashCode ^
      total.hashCode ^
      stock.hashCode ^
      cantidad.hashCode ^
      imagen.hashCode;

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: 1,
        cantidad: 1,
        //numProducto: json["uid"],
        nombre: json["nombre"],
        //estado: json["estado"],
        categoria: json["categoria"],
        precio: double.tryParse(json["precio"]),
        total: double.tryParse(json["precio"]),
        stock: int.tryParse(json["stock"]),
        imagen: json["imagen"],
      );

  factory Producto.fromJson2(Map<String, dynamic> json) => Producto(
        id: json["id"],
        nombre: json["nombre"],
        categoria: json["categoria"],
        precio: json["precio"],
        total: json["total"],
        stock: json["stock"],
        cantidad: json["cantidad"],
        imagen: json["imagen"],
      );

  factory Producto.fromJson3(Map<String, dynamic> json) => Producto(
        id: json["id"],
        nombre: json["nombre"],
        precio: json["precio"].toDouble(),
        total: json["total"].toDouble(),
        cantidad: json["cantidad"].toInt(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "categoria": categoria,
        "precio": precio,
        "total": total,
        "stock": stock,
        "cantidad": cantidad,
        "imagen": imagen,
      };

  Map<String, dynamic> toJson2() => {
        "cantidad": cantidad,
        "nombre": nombre,
        "precio": precio,
        "total": total,
      };
}

// Función para comparar dos listas de productos
bool productosListEquals(List<Producto>? list1, List<Producto>? list2) {
  if (list1 == null && list2 == null) return true;
  if (list1 == null || list2 == null) return false;
  if (list1.length != list2.length) return false;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
}
